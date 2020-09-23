/*****************************************************************************/
/*    'Confusion', a MDL intepreter                                         */
/*    Copyright 2009 Matthew T. Russotto                                    */
/*                                                                          */
/*    This program is free software: you can redistribute it and/or modify  */
/*    it under the terms of the GNU General Public License as published by  */
/*    the Free Software Foundation, version 3 of 29 June 2007.              */
/*                                                                          */
/*    This program is distributed in the hope that it will be useful,       */
/*    but WITHOUT ANY WARRANTY; without even the implied warranty of        */
/*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         */
/*    GNU General Public License for more details.                          */
/*                                                                          */
/*    You should have received a copy of the GNU General Public License     */
/*    along with this program.  If not, see <http://www.gnu.org/licenses/>. */
/*****************************************************************************/
#include "macros.hpp"
#include "mdl_internal_defs.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#define BANGCHAR(ch) (('!' << 8) | (ch))
#define IS_BANGCHAR(ch) (((ch) >> 8) == '!')
#define STRIPBANG(ch) (ch & 0xFF)
#define FASTVITEM(val, skip) ((val)->v.v.p->elements + (val)->v.v.offset + (val)->v.v.p->startoffset + (skip))

typedef enum read_statenum_t
{
    READSTATE_INITIAL,
    READSTATE_COMMENT,
    READSTATE_TYPECODE,
    READSTATE_LVAL,
    READSTATE_SEGMENT_LVAL,
    READSTATE_GVAL,
    READSTATE_SEGMENT_GVAL,
    READSTATE_QUOTE,
    READSTATE_SEGMENT_QUOTE,
    READSTATE_READMACRO,
    READSTATE_INSTRING_LIT,
    READSTATE_INSTRING_LIT_BS,
    READSTATE_INCHAR_LIT,
    READSTATE_INATOM_OCTAL_FIX, // \*
    READSTATE_INATOM_OCTAL_FIX1, // \*[0-7]+
    READSTATE_INATOM_OCTAL_FIX2, // \*[0-7]+\*
    READSTATE_INATOM_FIX_FLOAT_MINUS, // just got a minus sign
    READSTATE_INATOM_FIX_FLOAT, // digits
    READSTATE_INATOM_FIXDOT_FLOAT, // digits followed by a dot
    READSTATE_INATOM_FLOAT, // digits dot digits
    READSTATE_INATOM_SCIFLOAT, // just got the e/E
    READSTATE_INATOM_SCIFLOAT_MINUS, // just got a minus sign
    READSTATE_INATOM_SCIFLOAT_E1, // just got a digit after e/E/e-/E-
    READSTATE_INATOM_SCIFLOAT_E2, // just got a 2nd digit after e/E/e-/E-
    READSTATE_INATOM,
    READSTATE_INATOM_BS,
    // The whole INLVALATOM set is needed to handle
    // floats with no digits before the decimal point
    READSTATE_INLVALATOM_FLOAT, // dot with digit lookahead or dot digits
    READSTATE_INLVALATOM_SCIFLOAT, // dot digits E/e
    READSTATE_INLVALATOM_SCIFLOAT_MINUS, // dot digits E-/e-
    READSTATE_INLVALATOM_SCIFLOAT_E1, // just got a digit after e/E/e-/E-
    READSTATE_INLVALATOM_SCIFLOAT_E2, // just got a 2nd digit after e/E/e-/E-
    READSTATE_INLVALATOM,
    READSTATE_INLVALATOM_BS,
    READSTATE_FINAL,
} read_statenum_t;

typedef struct readstate_t
{
    struct readstate_t *prev;
    read_statenum_t statenum;
    seqtype_t seqtype;
    char *buf; // buffer for current whatever is being built up
    int bufsize;
    int buflen;
    mdl_value_t *objects; // objects found so far
    mdl_value_t *lastitem; // for building the list faster
    int typecode;
} readstate_t;

mdl_charclass_t mdl_get_charclass(MDL_INT ch)
{
    if (IS_BANGCHAR(ch))
    {
        switch (STRIPBANG(ch))
        {
        case '\\': 
            return MDL_C_BANGBACK;
        case ',':
            return MDL_C_BANGCOMMA;
        case '.':
            return MDL_C_BANGDOT;
        case '[':
            return MDL_C_OPENUVECTOR;
        case ']':
            return MDL_C_CLOSEUVECTOR;
        case '<':
            return MDL_C_OPENSEGMENT;
        case '>':
            return MDL_C_CLOSESEGMENT;
        case '\'':
            return MDL_C_BANGSQUOTE;
        default:
            return MDL_C_BANGANY;
        }
    }
    if (isalpha(ch))
    {
        return MDL_C_ALPHA;
    }
    if (isdigit(ch))
    {
        return MDL_C_DIGIT;
    }
    switch (ch)
    {
    case '\\':
        return MDL_C_BACKSLASH;
    case ' ':
    case '\n':
    case '\r':
    case '\f':
    case '\t':
    case '\v':
        return MDL_C_WHITESPACE;
    case '(':
        return MDL_C_OPENLIST;
    case ')':
        return MDL_C_CLOSELIST;
    case '<':
        return MDL_C_OPENFORM;
    case '>':
        return MDL_C_CLOSEFORM;
    case '[':
        return MDL_C_OPENVECTOR;
    case ']':
        return MDL_C_CLOSEVECTOR;
    case '"':
        return MDL_C_QUOTE;
    case '%':
        return MDL_C_PERCENT;
    case '*':
        return MDL_C_STAR;
    case '#':
        return MDL_C_HASH;
    case '.':
        return MDL_C_DOT;
    case ',':
        return MDL_C_COMMA;
    case '\'':
        return MDL_C_SQUOTE;
    case ';':
        return MDL_C_SEMI;
    case '-':
        return MDL_C_MINUS;
    case '!': 
        return MDL_C_BANG;
    case -1:
        return MDL_C_EOF;
    default:
        return MDL_C_OTHERATOM;
    }
}

void mdl_get_charinfo(MDL_INT ch, charinfo_t *info)
{
    info->charclass = mdl_get_charclass(ch);
    info->separator = info->openbracket = info->closebracket = false;
    switch(info->charclass)
    {
    case MDL_C_OPENLIST:
    case MDL_C_OPENFORM:
    case MDL_C_OPENSEGMENT:
    case MDL_C_OPENVECTOR:
    case MDL_C_OPENUVECTOR:
        info->openbracket = true;
        info->separator = true;
        break;
    case MDL_C_CLOSELIST:
    case MDL_C_CLOSEFORM:
    case MDL_C_CLOSESEGMENT:
    case MDL_C_CLOSEVECTOR:
    case MDL_C_CLOSEUVECTOR:
        info->closebracket = true;
        info->separator = true;
        break;
    case MDL_C_QUOTE:
        info->openbracket = true;
        info->closebracket = true;
        info->separator = true;
        break;
    case MDL_C_COMMA:
    case MDL_C_BANGCOMMA:
    case MDL_C_BANGSQUOTE:
    case MDL_C_HASH:
    case MDL_C_SEMI:
    case MDL_C_PERCENT:
    case MDL_C_WHITESPACE:
    case MDL_C_EOF:
        info->separator = true;
        break;
    }
}

void mdl_readstate_buf_append(readstate_t *rdstate, int ch)
{
    int len = 1;
    if (IS_BANGCHAR(ch)) len++;
    if ((rdstate->buflen + len) > rdstate->bufsize)
    {
        rdstate->bufsize *= 2;
        rdstate->buf = (char *)GC_REALLOC(rdstate->buf, rdstate->bufsize);
    }
    if (IS_BANGCHAR(ch))
    {
        rdstate->buf[rdstate->buflen++] = '!';
        ch = STRIPBANG(ch);
    }
    rdstate->buf[rdstate->buflen++] = ch;
}

inline void mdl_readstate_buf_clear(readstate_t *rdstate)
{
    rdstate->buflen = 0;
}

readstate_t *mdl_new_readstate(readstate_t *prev_readstate, seqtype_t seqtype)
{
    readstate_t *result = (readstate_t *)GC_MALLOC(sizeof(readstate_t));
    result->statenum = READSTATE_INITIAL;
    result->bufsize = 256;
    result->buf = (char *)GC_MALLOC_ATOMIC(result->bufsize);
    result->prev = prev_readstate;
    result->seqtype = seqtype;
    result->typecode = MDL_TYPE_NOTATYPE;
    return result;
}

mdl_value_t *mdl_get_chan_eof_object(mdl_value_t *chan)
{
    return FASTVITEM(chan,CHANNEL_SLOT_EOFOBJ);
}

mdl_value_t *mdl_set_chan_eof_object(mdl_value_t *chan, mdl_value_t *obj)
{
    if (obj == NULL)
    {
        FASTVITEM(chan,CHANNEL_SLOT_EOFOBJ)->pt = PRIMTYPE_WORD;
        FASTVITEM(chan,CHANNEL_SLOT_EOFOBJ)->type = MDL_TYPE_LOSE;
    }
    else
    {
        *FASTVITEM(chan,CHANNEL_SLOT_EOFOBJ) = *obj;
    }
    return obj;
}

mdl_value_t *mdl_get_chan_input_source(mdl_value_t *chan)
{
    return FASTVITEM(chan,CHANNEL_SLOT_IBUFFER);
}

void mdl_set_chan_input_source(mdl_value_t *chan, mdl_value_t *source)
{
    *FASTVITEM(chan,CHANNEL_SLOT_IBUFFER) = *source;
}

mdl_value_t *mdl_exec_chan_eof_object(mdl_value_t *chan)
{
    mdl_value_t *eofobj = mdl_get_chan_eof_object(chan);

    mdl_internal_close_channel(chan);
    if (eofobj->type == MDL_TYPE_LOSE)
        mdl_error("Error: Unexpected EOF");
    return mdl_eval(eofobj);
}

FILE *mdl_get_chan_file(mdl_value_t *chan)
{
    int chnum = FASTVITEM(chan,CHANNEL_SLOT_CHNUM)->v.w;
    return mdl_get_channum_file(chnum);
}

int mdl_get_chan_radix(mdl_value_t *chan)
{
    int radix = FASTVITEM(chan,CHANNEL_SLOT_RADIX)->v.w;
    return radix;
}

inline 
MDL_INT mdl_get_chan_status(mdl_value_t *chan)
{
    return FASTVITEM(chan, CHANNEL_SLOT_STATUS)->v.w;
}

inline 
void mdl_set_chan_status(mdl_value_t *chan, MDL_INT status)
{
    FASTVITEM(chan, CHANNEL_SLOT_STATUS)->v.w = status;
}

inline 
bool mdl_chan_flags_are_set(mdl_value_t *chan, MDL_INT flags)
{
    return ((FASTVITEM(chan, CHANNEL_SLOT_STATUS)->v.w) & flags) == flags;
}

bool mdl_chan_at_eof(mdl_value_t *chan)
{
    return mdl_chan_flags_are_set(chan, ICHANNEL_AT_EOF);
}

inline 
bool mdl_chan_flags_are_clear(mdl_value_t *chan, MDL_INT flags)
{
    return (FASTVITEM(chan, CHANNEL_SLOT_STATUS)->v.w & flags) == 0;
}

inline 
MDL_INT mdl_set_chan_flags(mdl_value_t *chan, MDL_INT flags)
{
    return (FASTVITEM(chan, CHANNEL_SLOT_STATUS)->v.w |= flags);
}

MDL_INT mdl_clear_chan_flags(mdl_value_t *chan, MDL_INT flags)
{
    return (FASTVITEM(chan, CHANNEL_SLOT_STATUS)->v.w &= ~flags);
}

inline 
MDL_INT mdl_get_chan_lookahead(mdl_value_t *chan)
{
    if (mdl_chan_flags_are_set(chan, ICHANNEL_HAS_LOOKAHEAD))
        return FASTVITEM(chan, CHANNEL_SLOT_LOOKAHEAD)->v.w;
    else
        return -1;
}

void mdl_set_chan_lookahead(mdl_value_t *chan, MDL_INT ch)
{
    FASTVITEM(chan, CHANNEL_SLOT_LOOKAHEAD)->v.w = ch;
    mdl_set_chan_flags(chan, ICHANNEL_HAS_LOOKAHEAD);
}

int mdl_read_1_char(FILE *f)
{
    int ch, ch2;

    ch = getc(f);

    if (ch == '!')
    {
        ch2 = getc(f);
        if (ch2 == -1) return ch;
        ch = BANGCHAR(ch2);
    }
    return ch;

}

int mdl_read_1_char_cs(counted_string_t *s)
{
    int ch, ch2;

    if (s->l <= 0) return -1;
    ch = *(s->p++);
    s->l--;

    if (ch == '!')
    {
        if (s->l <= 0) return -1;
        ch2 = *(s->p++);
        s->l--;
        ch = BANGCHAR(ch2);
    }
    return ch;
}

int mdl_read_word_from_chan(mdl_value_t *chan, MDL_INT *buf)
{
    int chnum = mdl_get_chan_channum(chan);
    int nwords;
    int result;
    if (chnum > 0)
    {
        FILE *f = mdl_get_chan_file(chan);
        nwords = fread((void *)buf, sizeof(MDL_INT), 1, f);
        if (nwords != 1) result = -1;
        else result = 0;
    }
    else
    {
        mdl_error("Attempt to read from closed channel");
        result = -1;
    }

    if (result < 0)
    {
        mdl_set_chan_flags(chan, ICHANNEL_AT_EOF);
    }
    return result;
}

int mdl_read_from_chan(mdl_value_t *chan)
{
    int result;
    if (mdl_chan_flags_are_set(chan, ICHANNEL_HAS_LOOKAHEAD))
    {
        result = mdl_get_chan_lookahead(chan);
        mdl_clear_chan_flags(chan,ICHANNEL_HAS_LOOKAHEAD);
    }
    else
    {
        int chnum = mdl_get_chan_channum(chan);
        if (chnum > 0)
        {
            result = mdl_read_1_char(mdl_get_chan_file(chan));
        }
        else
        {
            mdl_value_t *source = mdl_get_chan_input_source(chan);
            if (source->type == MDL_TYPE_STRING)
            {
                result = mdl_read_1_char_cs(&source->v.s);
            }
            else
            {
                mdl_error("Attempt to read from closed channel");
                result = -1;
            }
        }
        if (result < 0)
        {
            mdl_set_chan_flags(chan, ICHANNEL_AT_EOF);
        }
        else
        {
            if (IS_BANGCHAR(result))
            {
                mdl_print_char_to_transcript_channels(chan, '!', MDL_PF_NONE);
                mdl_print_char_to_transcript_channels(chan, STRIPBANG(result), MDL_PF_NONE);
            }
            else
            {
                mdl_print_char_to_transcript_channels(chan, result, MDL_PF_NONE);
            }
        }
    }
    return result;
}

// this loads the lookahad if it is not set, unlike mdl_get_chan_lookahead
int mdl_read_chan_lookahead(mdl_value_t *chan)
{
    int result;
    if (mdl_chan_flags_are_set(chan, ICHANNEL_HAS_LOOKAHEAD))
    {
        result = mdl_get_chan_lookahead(chan);
    }
    else if (mdl_chan_flags_are_set(chan, ICHANNEL_AT_EOF))
        result = -1;
    else
    {
        result = mdl_read_from_chan(chan);
        if (result >= 0) 
        {
            mdl_set_chan_lookahead(chan, result);
        }
    }
    return result;
}

mdl_value_t *mdl_get_default_inchan()
{
    mdl_frame_t *frame = cur_frame;
    if (cur_frame == NULL) frame = cur_process_initial_frame;
    return mdl_local_symbol_lookup_pname("INCHAN!-", frame);
}

mdl_value_t *mdl_create_default_inchan()
{
    mdl_value_t *chan = mdl_internal_create_channel();
    int chnum = mdl_new_chan_num(stdin);
    mdl_set_chan_mode(chan, "READ");
    *FASTVITEM(chan,CHANNEL_SLOT_CHNUM) = *mdl_new_fix(chnum);

    if (!isatty(fileno(stdin)))
        *FASTVITEM(chan,CHANNEL_SLOT_DEVN) = *(mdl_new_string(3, "DSK"));
    else
        *FASTVITEM(chan,CHANNEL_SLOT_DEVN) = *(mdl_new_string(3, "TTY"));
    mdl_set_chan_eof_object(chan, NULL);
    return chan;
}

// "Reasonable" here means reasonable for terminal input, so
// no binary channels and no internal channels
bool mdl_inchan_is_reasonable(mdl_value_t *chan)
{
    int channum;
    if (!chan || chan->type != MDL_TYPE_CHANNEL) return false;
    if (!mdl_string_equal_cstr(&mdl_get_chan_mode(chan)->v.s, "READ")) return false;
    if ((channum = mdl_get_chan_channum(chan)) <= 0) return false;
    // FIXME -- demanding inchan be stdin probably isn't right
    if (mdl_get_channum_file(channum) != stdin) return false;
    return true;
}
        
mdl_value_t *mdl_advance_readstate(mdl_value_t *chan, readstate_t **rdstatep, MDL_INT ch)
{
    readstate_t *rdstate = *rdstatep;
    charinfo_t cinfo, cinfolook;
    int lookahead;
    mdl_value_t *obj = NULL;

    mdl_get_charinfo(ch, &cinfo);

    // handle backslash for the atom and string states ahead of time
    // also handle "!\"
    if (cinfo.charclass == MDL_C_BACKSLASH)
    {
        if ((rdstate->statenum >= READSTATE_INATOM_OCTAL_FIX) &&
            (rdstate->statenum <= READSTATE_INATOM))
        {
            rdstate->statenum = READSTATE_INATOM_BS;
            return NULL;
        }

        else if (rdstate->statenum == READSTATE_INSTRING_LIT)
        {
            rdstate->statenum = READSTATE_INSTRING_LIT_BS;
            return NULL;
        }

        else if ((rdstate->statenum >= READSTATE_INLVALATOM_FLOAT) &&
                 (rdstate->statenum <= READSTATE_INLVALATOM))
        {
            rdstate->statenum = READSTATE_INLVALATOM_BS;
        }
    }
    else if (cinfo.charclass == MDL_C_BANGBACK)
    {
        if ((rdstate->statenum >= READSTATE_INATOM_OCTAL_FIX) &&
            (rdstate->statenum <= READSTATE_INATOM))
        {
            mdl_readstate_buf_append(rdstate, '!');
            rdstate->statenum = READSTATE_INATOM_BS;
            return NULL;
        }
        else if (rdstate->statenum == READSTATE_INSTRING_LIT)
        {
            mdl_readstate_buf_append(rdstate, '!');
            rdstate->statenum = READSTATE_INSTRING_LIT_BS;
            return NULL;
        }
        else if ((rdstate->statenum >= READSTATE_INLVALATOM_FLOAT) &&
                 (rdstate->statenum <= READSTATE_INLVALATOM))
        {
            mdl_readstate_buf_append(rdstate, '!');
            rdstate->statenum = READSTATE_INLVALATOM_BS;
            return NULL;
        }
        else if ((rdstate->statenum == READSTATE_INSTRING_LIT_BS) ||
                 (rdstate->statenum == READSTATE_INATOM_BS) ||
                 (rdstate->statenum == READSTATE_INLVALATOM_BS))
        {
            mdl_readstate_buf_append(rdstate, '!');
            // remain in backslash state, do not append backslash -- e.g.
            // "FOO\!\!\!" -> "FOO!!!"
            return NULL;
        }
    }

    switch (rdstate->statenum)
    {
    case READSTATE_INITIAL:
        switch(cinfo.charclass)
        {
        case MDL_C_SQUOTE:
            rdstate->statenum = READSTATE_QUOTE;
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_SINGLE);
            break;
        case MDL_C_COMMA:
            rdstate->statenum = READSTATE_GVAL;
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_SINGLE);
            break;
        case MDL_C_DOT:
            lookahead = mdl_read_chan_lookahead(chan);
            mdl_get_charinfo(lookahead, &cinfolook);
            if (cinfolook.charclass == MDL_C_DIGIT)
            {
                mdl_readstate_buf_append(rdstate, ch);
                rdstate->statenum = READSTATE_INLVALATOM_FLOAT;
            }
            else
            {
                rdstate->statenum = READSTATE_LVAL;
                rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_SINGLE);
            }
            break;
        case MDL_C_HASH:
            rdstate->statenum = READSTATE_TYPECODE;
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_SINGLE);
            rdstate->statenum = READSTATE_INATOM;
            break;
        case MDL_C_BANGCOMMA:
            rdstate->statenum = READSTATE_SEGMENT_GVAL;
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_SINGLE);
            break;
        case MDL_C_BANGDOT:
            rdstate->statenum = READSTATE_SEGMENT_LVAL;
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_SINGLE);
            break;
        case MDL_C_BANGSQUOTE:
            rdstate->statenum = READSTATE_SEGMENT_QUOTE;
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_SINGLE);
            break;

        case MDL_C_PERCENT:
            lookahead = mdl_read_chan_lookahead(chan);
            if (lookahead == '%')
                mdl_error("Read %% macros not supported");
            rdstate->statenum = READSTATE_READMACRO;
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_SINGLE);
            break;
            
        case MDL_C_OPENLIST:
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_LIST);
            break;
        case MDL_C_OPENFORM:
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_FORM);
            break;

        case MDL_C_OPENSEGMENT:
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_SEGMENT);
            break;

        case MDL_C_OPENVECTOR:
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_VECTOR);
            break;

        case MDL_C_OPENUVECTOR:
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_UVECTOR);
            break;
            
        case MDL_C_CLOSELIST:
            if (rdstate->seqtype != SEQTYPE_LIST)
                mdl_error("Unexpected ) in input");
            rdstate->statenum = READSTATE_FINAL;
            break;

        case MDL_C_CLOSESEGMENT:
            if (rdstate->seqtype != SEQTYPE_SEGMENT)
                mdl_error("Unexpected !> in input");
            rdstate->statenum = READSTATE_FINAL;
            break;

        case MDL_C_CLOSEFORM:
            if (rdstate->seqtype != SEQTYPE_FORM &&
                rdstate->seqtype != SEQTYPE_SEGMENT)
                mdl_error("Unexpected > in input");
            rdstate->statenum = READSTATE_FINAL;
            break;

        case MDL_C_CLOSEVECTOR:
            if (rdstate->seqtype != SEQTYPE_VECTOR &&
                rdstate->seqtype != SEQTYPE_UVECTOR)
                mdl_error("Unexpected ] in input");
            rdstate->statenum = READSTATE_FINAL;
            break;

        case MDL_C_CLOSEUVECTOR:
            if (rdstate->seqtype != SEQTYPE_UVECTOR)
                mdl_error("Unexpected !] in input");
            rdstate->statenum = READSTATE_FINAL;
            break;

        case MDL_C_QUOTE:
            rdstate->statenum = READSTATE_INSTRING_LIT;
            break;

        case MDL_C_STAR:
            mdl_readstate_buf_append(rdstate, ch);
            rdstate->statenum = READSTATE_INATOM_OCTAL_FIX;
            break;

        case MDL_C_DIGIT:
            mdl_readstate_buf_append(rdstate, ch);
            rdstate->statenum = READSTATE_INATOM_FIX_FLOAT;
            break;

        case MDL_C_MINUS:
            mdl_readstate_buf_append(rdstate, ch);
            rdstate->statenum = READSTATE_INATOM_FIX_FLOAT_MINUS;
            break;

        case MDL_C_ALPHA:
        case MDL_C_OTHERATOM:
        case MDL_C_BANG:
        case MDL_C_BANGANY:
            rdstate->statenum = READSTATE_INATOM;
            mdl_readstate_buf_append(rdstate, ch);
            break;
        case MDL_C_BACKSLASH:
            rdstate->statenum = READSTATE_INATOM_BS;
            break;

        case MDL_C_BANGBACK:
            rdstate->statenum = READSTATE_INCHAR_LIT;
            break;
        case MDL_C_SEMI:
            rdstate->statenum = READSTATE_COMMENT;
            rdstate = *rdstatep = mdl_new_readstate(rdstate, SEQTYPE_SINGLE);
            break;

        case MDL_C_WHITESPACE:
            break; // ignored
        }
        break;
    case READSTATE_INCHAR_LIT:
        obj = mdl_new_word(ch, MDL_TYPE_CHARACTER);
        if (rdstate->seqtype == SEQTYPE_SINGLE)
            rdstate->statenum = READSTATE_FINAL;
        else
            rdstate->statenum = READSTATE_INITIAL;
        break;
    case READSTATE_INSTRING_LIT:
        if (IS_BANGCHAR(ch) && (STRIPBANG(ch) == '\"'))
        {
            cinfo.charclass = MDL_C_QUOTE;
            mdl_readstate_buf_append(rdstate, '!');
        }
        if (cinfo.charclass == MDL_C_QUOTE)
        {
            obj = mdl_new_string(rdstate->buflen, rdstate->buf);
            mdl_readstate_buf_clear(rdstate);
            if (rdstate->seqtype == SEQTYPE_SINGLE)
                rdstate->statenum = READSTATE_FINAL;
            else
                rdstate->statenum = READSTATE_INITIAL;
            break;
        }
        else
        {
            mdl_readstate_buf_append(rdstate, ch);
        }
        break;
    case READSTATE_INSTRING_LIT_BS:
        if (IS_BANGCHAR(ch) && (STRIPBANG(ch) == '\"'))
        {
            mdl_readstate_buf_append(rdstate, '!');
            obj = mdl_new_string(rdstate->buflen, rdstate->buf);
            mdl_readstate_buf_clear(rdstate);
            if (rdstate->seqtype == SEQTYPE_SINGLE)
                rdstate->statenum = READSTATE_FINAL;
            else
                rdstate->statenum = READSTATE_INITIAL;
            break;
        }
        mdl_readstate_buf_append(rdstate, ch);
        rdstate->statenum = READSTATE_INSTRING_LIT;
        break;
        
    case READSTATE_INATOM_OCTAL_FIX:
        mdl_readstate_buf_append(rdstate, ch);
        if (ch < '0'  || ch > '7')
            rdstate->statenum = READSTATE_INATOM;
        else
            rdstate->statenum = READSTATE_INATOM_OCTAL_FIX1;
        break;
    case READSTATE_INATOM_OCTAL_FIX1:
        mdl_readstate_buf_append(rdstate, ch);
        if (ch == '*')
            rdstate->statenum = READSTATE_INATOM_OCTAL_FIX2;
        else if (ch < '0'  || ch > '7')
            rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INATOM_OCTAL_FIX2:
        mdl_readstate_buf_append(rdstate, ch);
        // lookahead code would have caught separators
        rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INATOM_FIX_FLOAT_MINUS:
        mdl_readstate_buf_append(rdstate, ch);
        // -. is not permitted in a FLOAT or FIX.  I don't know
        // if it was in the original
        if (cinfo.charclass == MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INATOM_FIX_FLOAT;
        else
            rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INATOM_FIX_FLOAT:
        mdl_readstate_buf_append(rdstate, ch);
        // FIXME -- radix > 10?
        if (cinfo.charclass == MDL_C_DOT)
            rdstate->statenum = READSTATE_INATOM_FIXDOT_FLOAT;
        else if (ch == 'E' || ch == 'e')
            rdstate->statenum = READSTATE_INATOM_SCIFLOAT;
        else if (cinfo.charclass != MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INATOM_FIXDOT_FLOAT:
        mdl_readstate_buf_append(rdstate, ch);
        if (cinfo.charclass == MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INATOM_FLOAT;
        else if (ch == 'E' || ch == 'e')
            rdstate->statenum = READSTATE_INATOM_SCIFLOAT;
        else
            rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INATOM_FLOAT:
        mdl_readstate_buf_append(rdstate, ch);
        if (cinfo.charclass == MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INATOM_FLOAT;
        else if (ch == 'E' || ch == 'e')
            rdstate->statenum = READSTATE_INATOM_SCIFLOAT;
        else
            rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INATOM_SCIFLOAT:
        mdl_readstate_buf_append(rdstate, ch);
        if (cinfo.charclass == MDL_C_MINUS)
            rdstate->statenum = READSTATE_INATOM_SCIFLOAT_MINUS;
        else if (cinfo.charclass == MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INATOM_SCIFLOAT_E1;
        else
            rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INATOM_SCIFLOAT_MINUS:
        mdl_readstate_buf_append(rdstate, ch);
        if (cinfo.charclass == MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INATOM_SCIFLOAT_E1;
        else
            rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INATOM_SCIFLOAT_E1:
        mdl_readstate_buf_append(rdstate, ch);
        if (cinfo.charclass == MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INATOM_SCIFLOAT_E2;
        else
            rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INATOM_SCIFLOAT_E2:
        mdl_readstate_buf_append(rdstate, ch);
        rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INATOM:
    case READSTATE_INATOM_BS:
        mdl_readstate_buf_append(rdstate, ch);
        rdstate->statenum = READSTATE_INATOM;
        break;
    case READSTATE_INLVALATOM_FLOAT:
        mdl_readstate_buf_append(rdstate, ch);
        if (cinfo.charclass == MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INLVALATOM_FLOAT;
        else if (ch == 'E' || ch == 'e')
            rdstate->statenum = READSTATE_INLVALATOM_SCIFLOAT;
        else
            rdstate->statenum = READSTATE_INLVALATOM;
        break;
        
    case READSTATE_INLVALATOM_SCIFLOAT:
        mdl_readstate_buf_append(rdstate, ch);
        if (cinfo.charclass == MDL_C_MINUS)
            rdstate->statenum = READSTATE_INLVALATOM_SCIFLOAT_MINUS;
        else if (cinfo.charclass == MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INLVALATOM_SCIFLOAT_E1;
        else
            rdstate->statenum = READSTATE_INLVALATOM;
        break;
    case READSTATE_INLVALATOM_SCIFLOAT_MINUS:
        mdl_readstate_buf_append(rdstate, ch);
        if (cinfo.charclass == MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INLVALATOM_SCIFLOAT_E1;
        else
            rdstate->statenum = READSTATE_INLVALATOM;
        break;
    case READSTATE_INLVALATOM_SCIFLOAT_E1:
        mdl_readstate_buf_append(rdstate, ch);
        if (cinfo.charclass == MDL_C_DIGIT)
            rdstate->statenum = READSTATE_INLVALATOM_SCIFLOAT_E2;
        else
            rdstate->statenum = READSTATE_INLVALATOM;
        break;
    case READSTATE_INLVALATOM_SCIFLOAT_E2:
        mdl_readstate_buf_append(rdstate, ch);
        rdstate->statenum = READSTATE_INLVALATOM;
        break;

    case READSTATE_INLVALATOM:
    case READSTATE_INLVALATOM_BS:
        mdl_readstate_buf_append(rdstate, ch);
        rdstate->statenum = READSTATE_INLVALATOM;
        break;
    }

    
    if ((rdstate->statenum >= READSTATE_INATOM_OCTAL_FIX &&
         rdstate->statenum <= READSTATE_INATOM) ||
        (rdstate->statenum >= READSTATE_INLVALATOM_FLOAT &&
         rdstate->statenum <= READSTATE_INLVALATOM)
        )
        
    {
        if (IS_BANGCHAR(ch))
        {
            lookahead = STRIPBANG(ch);
            mdl_get_charinfo(lookahead, &cinfolook);
            if (cinfolook.separator) rdstate->buflen--;
            else
            {
                lookahead = mdl_read_chan_lookahead(chan);
                mdl_get_charinfo(lookahead, &cinfolook);
            }
            // FIXME: the separator will be lost, so an atom and string like
            // FOO!"BAR" will not parse properly
        }
        else
        {
            lookahead = mdl_read_chan_lookahead(chan);
            mdl_get_charinfo(lookahead, &cinfolook);
        }
        if (cinfolook.separator)
        {
            if (rdstate->buflen == 0)
                mdl_error("ATOM with null PNAME not permitted");
            mdl_readstate_buf_append(rdstate, '\0');
            switch(rdstate->statenum)
            {
            case READSTATE_INATOM:
            case READSTATE_INATOM_OCTAL_FIX:
            case READSTATE_INATOM_OCTAL_FIX1:
            case READSTATE_INATOM_FIX_FLOAT_MINUS:
            case READSTATE_INATOM_SCIFLOAT:
            case READSTATE_INATOM_SCIFLOAT_MINUS:
                // all these states are invalid numbers, so must be atoms
                obj = mdl_create_or_get_atom(rdstate->buf);
                break;
                
            case READSTATE_INATOM_OCTAL_FIX2:
            {
#ifdef MDL32
                MDL_INT oct = strtol(rdstate->buf + 1, NULL, 8);
#else
                MDL_INT oct = strtoll(rdstate->buf + 1, NULL, 8);
#endif
                obj = mdl_new_fix(oct);
                break;
            }
            case READSTATE_INATOM_FIX_FLOAT:
            {
                int radix = mdl_get_chan_radix(chan);
#ifdef MDL32
                MDL_INT num = strtol(rdstate->buf, NULL, radix);
#else
                MDL_INT num = strtoll(rdstate->buf, NULL, radix);
#endif
//                printf("MDL_INT = %lld %s\n", num, rdstate->buf);
                obj = mdl_new_fix(num);
                break;
            }
            case READSTATE_INATOM_FIXDOT_FLOAT:
            {
#ifdef MDL32
                MDL_INT dec = strtol(rdstate->buf, NULL, 10);
#else
                MDL_INT dec = strtoll(rdstate->buf, NULL, 10);
#endif
                obj = mdl_new_fix(dec);
                break;
            }
            case READSTATE_INLVALATOM_FLOAT:
            case READSTATE_INLVALATOM_SCIFLOAT_E1:
            case READSTATE_INLVALATOM_SCIFLOAT_E2:
            case READSTATE_INATOM_FLOAT:
            {
#ifdef MDL32
                MDL_FLOAT fl = strtof(rdstate->buf, NULL);
#else
                MDL_FLOAT fl = strtod(rdstate->buf, NULL);
#endif
                obj = mdl_new_float(fl);
                break;
            }
            case READSTATE_INATOM_SCIFLOAT_E1:
            case READSTATE_INATOM_SCIFLOAT_E2:
            {
                char *exp;
                char *dot = strchr(rdstate->buf, '.');
                MDL_FLOAT fl;
#ifdef MDL32
                long mantissa;
#else
                MDL_INT mantissa;
#endif
                MDL_INT oldmantissa;
                int exponent;
                bool notfix = false;
                
                if (dot) notfix = true;
#ifdef MDL32
                fl = strtof(rdstate->buf, NULL);
#else
                fl = strtod(rdstate->buf, NULL);
#endif
                
                if (!notfix)
                {
                    exp = strchr(rdstate->buf, 'e');
                    if (!exp) exp = strchr(rdstate->buf, 'E');
                    if (!exp) mdl_error("SCI without E should never happen");
                    *exp++ = 0;
                    errno = 0;
#ifdef MDL32
                    mantissa = strtol(rdstate->buf, NULL, 0);
#else
                    mantissa = strtoll(rdstate->buf, NULL, 0);
#endif
                    if (errno == ERANGE) notfix = true;
                    exponent = strtol(exp, NULL, 10);
                    if (exponent < 0) notfix = true;
                    while (exponent-- && !notfix)
                    {
                        oldmantissa = mantissa;
                        mantissa *= 10;
                        // hw integer overflow would come in handy here
                        if ((mantissa / 10) != oldmantissa)
                        {
                            notfix = true;
                        }
                    }
#ifdef MDL32
                    if (!notfix && (mantissa > MDL_INT_MAX || mantissa < MDL_INT_MIN))
                        notfix = true;
#endif
                }
                if (!notfix)
                {
                    obj = mdl_new_fix(mantissa);
                }
                else
                {
                    obj = mdl_new_float(fl);
                }
            }
            break;

            case READSTATE_INLVALATOM:
            case READSTATE_INLVALATOM_SCIFLOAT:
            case READSTATE_INLVALATOM_SCIFLOAT_MINUS:
                // These states are invalid as numbers starting with a .
                // Thus they are .ATOM = <LVAL ATOM>
                obj = mdl_create_or_get_atom(&rdstate->buf[1]);
                obj = mdl_make_localvar_ref(obj);
                break;                
            }
            mdl_readstate_buf_clear(rdstate);
            if (rdstate->seqtype == SEQTYPE_SINGLE)
                rdstate->statenum = READSTATE_FINAL;
            else
                rdstate->statenum = READSTATE_INITIAL;
        }
    }

    do {
        if (obj && rdstate->typecode != MDL_TYPE_NOTATYPE)
        {
            // FIXME make sure primtype is valid
            obj->type = rdstate->typecode;
            rdstate->typecode = MDL_TYPE_NOTATYPE;
        }

        if (obj && rdstate->seqtype == SEQTYPE_SINGLE)
        {
            rdstate->objects = obj;
        }
        else if (obj)
        {
            if (rdstate->objects == NULL)
                rdstate->objects = mdl_additem(NULL, obj, &rdstate->lastitem);
            else
                mdl_additem(rdstate->lastitem, obj, &rdstate->lastitem);
        }
        obj = NULL;
        
        lookahead = mdl_read_chan_lookahead(chan);
        if (rdstate->statenum == READSTATE_INITIAL && 
            rdstate->seqtype == SEQTYPE_SINGLE &&
            lookahead == -1)
            rdstate->statenum = READSTATE_FINAL;

        if (rdstate->statenum == READSTATE_FINAL && rdstate->prev)
        {
            switch (rdstate->seqtype)
            {
                case SEQTYPE_LIST:
                    obj = mdl_make_list(rdstate->objects);
                    break;
                case SEQTYPE_FORM:
                    obj = mdl_make_list(rdstate->objects, MDL_TYPE_FORM);
                    break;
                case SEQTYPE_SEGMENT:
                    obj = mdl_make_list(rdstate->objects, MDL_TYPE_SEGMENT);
                    break;
                case SEQTYPE_VECTOR:
                    obj = mdl_make_vector(rdstate->objects);
                    break;
                case SEQTYPE_UVECTOR:
                    obj = mdl_make_uvector(rdstate->objects);
                    break;
                case SEQTYPE_SINGLE:
                    switch (rdstate->prev->statenum)
                    {
                    case READSTATE_GVAL:
                        obj = mdl_make_globalvar_ref(rdstate->objects);
                        rdstate->prev->statenum = READSTATE_INITIAL;
                        break;
                    case READSTATE_SEGMENT_GVAL:
                        obj = mdl_make_globalvar_ref(rdstate->objects, MDL_TYPE_SEGMENT);
                        rdstate->prev->statenum = READSTATE_INITIAL;
                        break;
                    case READSTATE_LVAL:
                        obj = mdl_make_localvar_ref(rdstate->objects);
                        rdstate->prev->statenum = READSTATE_INITIAL;
                        break;
                    case READSTATE_SEGMENT_LVAL:
                        obj = mdl_make_localvar_ref(rdstate->objects, MDL_TYPE_SEGMENT);
                        rdstate->prev->statenum = READSTATE_INITIAL;
                        break;
                    case READSTATE_QUOTE:
                        obj = mdl_make_quote(rdstate->objects);
                        rdstate->prev->statenum = READSTATE_INITIAL;
                        break;
                    case READSTATE_SEGMENT_QUOTE:
                        obj = mdl_make_quote(rdstate->objects, MDL_TYPE_SEGMENT);
                        rdstate->prev->statenum = READSTATE_INITIAL;
                        break;
                    case READSTATE_TYPECODE:
                        rdstate->prev->typecode = mdl_get_typenum(rdstate->objects);
                        if (rdstate->prev->typecode == MDL_TYPE_NOTATYPE)
                            mdl_call_error("#ATOM does not name a type", rdstate->objects, NULL);
                        break;
                    case READSTATE_COMMENT:
                        // print comments to aid debugging
                        // of loaded programs
//                        mdl_print_value(stderr, rdstate->objects);
                        obj = rdstate->objects;
                        break;
                        
                    case READSTATE_READMACRO:
                        obj = mdl_eval(rdstate->objects);
                        if (obj->type == MDL_TYPE_SPLICE)
                        {
                            // FIXME
                            mdl_error("Splices not supported");
                        }
                        rdstate->prev->statenum = READSTATE_INITIAL;
                        break;
                    default:
                        mdl_error("Nested read of single object shouldn't happen here");
                        break;
                    }
            }
            rdstate = (*rdstatep = rdstate->prev);
            if (rdstate->statenum == READSTATE_COMMENT)
            {
                if (rdstate->seqtype != SEQTYPE_SINGLE && rdstate->objects)
                {
                    mdl_internal_eval_putprop(mdl_make_list(rdstate->lastitem), mdl_get_atom_from_oblist("COMMENT", mdl_value_root_oblist), obj);
                }
                else if ((rdstate->seqtype == SEQTYPE_SINGLE) && (rdstate->prev == NULL))
                {
                    mdl_internal_eval_putprop(chan, mdl_get_atom_from_oblist("COMMENT", mdl_value_root_oblist), obj);
                }
                obj = NULL;
            }
            if (rdstate->statenum == READSTATE_TYPECODE ||
                rdstate->statenum == READSTATE_COMMENT )
                rdstate->statenum = READSTATE_INITIAL;
            else if (rdstate->seqtype == SEQTYPE_SINGLE)
                rdstate->statenum = READSTATE_FINAL;
        }
    }
    while(obj);

    if (rdstate->statenum == READSTATE_FINAL)
        return rdstate->objects;
    return NULL;
}

mdl_value_t *mdl_read_object(mdl_value_t *chan)
{
    int curchar;
    readstate_t *readstate = mdl_new_readstate(NULL, SEQTYPE_SINGLE);
    mdl_value_t *result = NULL;

    mdl_internal_eval_putprop(chan, mdl_get_atom_from_oblist("COMMENT", mdl_value_root_oblist), NULL);
    curchar = mdl_read_from_chan(chan);
    while (!result && !mdl_chan_flags_are_set(chan, ICHANNEL_AT_EOF))
    {
        result = mdl_advance_readstate(chan, &readstate, curchar);
        if (!result && !mdl_chan_flags_are_set(chan, ICHANNEL_AT_EOF))
            curchar = mdl_read_from_chan(chan);
    }
    if (!result && mdl_chan_flags_are_set(chan, ICHANNEL_AT_EOF))
    {
        // push the EOF through just in case it's OK
        // this could be done by setting up the state machine to
        // always look ahead to the EOF, but that compromises
        // interactivity
        result = mdl_advance_readstate(chan, &readstate, curchar);
    }
    if (!result)
        return mdl_exec_chan_eof_object(chan);
    return result;
}

mdl_value_t *mdl_read_character(mdl_value_t *chan)
{
    int ch = mdl_read_from_chan(chan);
    if (ch == -1)
        return mdl_exec_chan_eof_object(chan);
    return mdl_new_word(ch, MDL_TYPE_CHARACTER);
}

mdl_value_t *mdl_next_character(mdl_value_t *chan)
{
    int ch;
    ch = mdl_read_chan_lookahead(chan);
    if (ch == -1)
        return mdl_exec_chan_eof_object(chan);
    return mdl_new_word(ch, MDL_TYPE_CHARACTER);
}

mdl_value_t *mdl_read_binary(mdl_value_t *chan, mdl_value_t *buffer)
{
    uvector_element_t *elem, *first;
    int nelem;
    // only call the EOF if we've already hit EOF on a previous read
    if (mdl_chan_flags_are_set(chan, ICHANNEL_AT_EOF))
    {
        return mdl_exec_chan_eof_object(chan);
    }
    if (mdl_type_primtype(buffer->v.uv.p->type) != PRIMTYPE_WORD)
    {
        mdl_error("UVECTOR for read must be of type WORD");
    }
    nelem = UVLENGTH(buffer);
    first = elem = UVREST(buffer, 0);
    while (nelem--)
    {
        MDL_INT w;
        int status;

        status = mdl_read_word_from_chan(chan, &w);
        if (status < 0) break;
        elem++->w = w;
        
    }
    return mdl_new_fix(elem - first);
}

mdl_value_t *mdl_read_string(mdl_value_t *chan, mdl_value_t *buffer, mdl_value_t *stop)
{
    int ntoread;
    int ch;
    char *stopstr = NULL;
    int stoplen = 0;
    char *buf;

    // only call the EOF if we've already hit EOF on a previous read
    if (mdl_chan_flags_are_set(chan, ICHANNEL_AT_EOF))
    {
        return mdl_exec_chan_eof_object(chan);
    }

    if (buffer->type != MDL_TYPE_STRING)
    {
        mdl_error("UVECTOR for readstring must be of type STRING");
    }
    buf = buffer->v.s.p;
    ntoread = buffer->v.s.l;
    if (stop)
    {
        if (stop->type == MDL_TYPE_FIX) ntoread = stop->v.w;
        else if (stop->type == MDL_TYPE_STRING)
        {
            stopstr = stop->v.s.p;
            stoplen = stop->v.s.l;
        }
    }
    
    while (ntoread--)
    {
        ch = mdl_read_from_chan(chan);
        if (ch < 0) break;
        if (stoplen && memchr(stopstr, ch, stoplen)) break;
        *buf++ = ch;
    }
    return mdl_new_fix(buf - buffer->v.s.p);
}

mdl_value_t *mdl_load_file_from_chan(mdl_value_t *chan)
{
    mdl_value_t *result = NULL;
    int ch;

    while (!mdl_chan_flags_are_set(chan, ICHANNEL_AT_EOF))
    {
        result = mdl_read_object(chan);
        mdl_eval(result);
        
        // skip whitespace and check for eof
        ch = mdl_read_chan_lookahead(chan);
        while (mdl_get_charclass(ch) == MDL_C_WHITESPACE)
        {
            mdl_read_from_chan(chan);
            ch = mdl_read_chan_lookahead(chan);
        }
    }
    return result;
}
