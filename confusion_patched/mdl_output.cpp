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
#include "mdl_builtins.h"
#include <ctype.h>
#include <string.h>
#include <errno.h>
#include "mdl_strbuf.h"
#ifdef _WIN32
#include <io.h>
#else
#include <unistd.h>
#endif

typedef enum outbuf_items_t
{
    OUTBUF_BUFSIZE,
    OUTBUF_TOTLEN,
    OUTBUF_NBUFS,
    OUTBUF_LASTBUFLEN,
    OUTBUF_BUFCHAIN,
    OUTBUF_LASTBUFLIST,
    OUTBUF_VLENGTH
} ioutbuf_items_t;
// for flatsize
// BUFSIZE is BUFSIZE
// TOTLEN is TOTLEN
#define OUTBUF_MAXLEN OUTBUF_NBUFS
#define OUTBUF_FRAME OUTBUF_LASTBUFLEN
#define OUTBUF_FL_VLENGTH OUTBUF_BUFCHAIN

mdl_value_t *mdl_get_default_outchan()
{
    mdl_frame_t *frame = cur_frame;
    if (cur_frame == NULL) frame = cur_process_initial_frame;
    return mdl_local_symbol_lookup_pname("OUTCHAN!-", frame);
}

mdl_value_t *mdl_create_default_outchan()
{
    mdl_value_t *chan = mdl_internal_create_channel();
    int chnum = mdl_new_chan_num(stdout);
    mdl_set_chan_mode(chan, "PRINT");
    *VITEM(chan,CHANNEL_SLOT_CHNUM) = *mdl_new_fix(chnum);

    if (!isatty(fileno(stdout)))
        *VITEM(chan,CHANNEL_SLOT_DEVN) = *(mdl_new_string(3, "DSK"));
    else
        *VITEM(chan,CHANNEL_SLOT_DEVN) = *(mdl_new_string(3, "TTY"));
    return chan;
}
        
// "Reasonable" here means reasonable for terminal output
// (should binary channels be allowed?)
bool mdl_outchan_is_reasonable(mdl_value_t *chan)
{
    if (!chan || chan->type != MDL_TYPE_CHANNEL) return false;
//    if (!mdl_string_equal_cstr(&mdl_get_chan_mode(chan)->v.s, "WRITE")) return false;
    if (!mdl_chan_mode_is_output(chan)) return false;
    if (mdl_get_chan_channum(chan) <= 0) return false;
    return true;
}

mdl_value_t *mdl_create_internal_output_channel(int bufsize, int maxlen, mdl_value_t *frame)
{
    mdl_value_t *chan = mdl_internal_create_channel();
    mdl_value_t *devdep;
    mdl_value_t *zerofix = mdl_new_fix(0);
    mdl_set_chan_mode(chan, "PRINT");
    if (bufsize)
    {
        mdl_value_t *dp;
        mdl_value_t *buf;
        mdl_value_t *bufs;

        devdep = mdl_new_empty_vector(OUTBUF_VLENGTH, MDL_TYPE_VECTOR);
        dp = VITEM(devdep, 0);
        buf = mdl_new_string(bufsize);
        bufs = mdl_cons_internal(buf, NULL);
        dp[OUTBUF_BUFSIZE] = *mdl_new_fix(bufsize);
        dp[OUTBUF_TOTLEN] = *zerofix;
        dp[OUTBUF_NBUFS] = *zerofix;
        dp[OUTBUF_LASTBUFLEN] = *zerofix;
        dp[OUTBUF_BUFCHAIN] = *mdl_make_list(bufs);
        dp[OUTBUF_LASTBUFLIST] = dp[OUTBUF_BUFCHAIN];

    }
    else
    {
        mdl_value_t *dp;
        devdep = mdl_new_empty_vector(OUTBUF_FL_VLENGTH, MDL_TYPE_VECTOR);
        dp = VITEM(devdep, 0);
        dp[OUTBUF_BUFSIZE] = *zerofix;
        dp[OUTBUF_TOTLEN] = *zerofix;
        dp[OUTBUF_MAXLEN] = *mdl_new_fix(maxlen);
        dp[OUTBUF_FRAME] = *frame;
    }
    *VITEM(chan, CHANNEL_SLOT_DEVDEP) = *devdep;
    return chan;
}

MDL_INT mdl_get_internal_output_channel_length(mdl_value_t *chan)
{
    mdl_value_t *devdep = VITEM(chan, CHANNEL_SLOT_DEVDEP);
    MDL_INT totlen;

    if (devdep->type != MDL_TYPE_VECTOR)
        mdl_error("Cannot obtain length from channel");
    totlen = VITEM(devdep, OUTBUF_TOTLEN)->v.w;
    return totlen;
}

mdl_value_t *mdl_get_internal_output_channel_string(mdl_value_t *chan)
{
    mdl_value_t *devdep = VITEM(chan, CHANNEL_SLOT_DEVDEP);
    int totlen;
    mdl_value_t *cursor;
    mdl_value_t *result;
    char *d;
    int len;
    int bufsize;
    int cplen;

    if (devdep->type != MDL_TYPE_VECTOR || VLENGTH(devdep) != OUTBUF_VLENGTH)
        mdl_error("Cannot obtain string from channel");
    totlen = VITEM(devdep, OUTBUF_TOTLEN)->v.w;
    bufsize = VITEM(devdep, OUTBUF_BUFSIZE)->v.w;
    result = mdl_new_string(totlen);
    d = result->v.s.p;
    len = totlen;
    cursor = LREST(VITEM(devdep, OUTBUF_BUFCHAIN), 0);
    while (cursor && (len > 0))
    {
        cplen = (len > bufsize)?bufsize:len;
        memcpy(d, cursor->v.p.car->v.s.p, cplen);
        d += cplen;
        len -= cplen;
        cursor = cursor->v.p.cdr;
    }
    if (len != 0) mdl_error("Internal error in output buffer reading");
    return result;
}

bool mdl_need_line_break(int len, int extrawidth,

                         // extrawidth is for characters which will be
                         // added only if there is no line break
                         int linewidth, MDL_INT *linepos)
{
    // never break if linewidth is 0 (unlimited)
    // never break if *linepos is 0 (can't do any better)
    if (linewidth && *linepos && ((len + extrawidth) > (linewidth - *linepos)))
    {
        return true;
    }
    return false;
}

void mdl_print_newline_to_transcript_channels(mdl_value_t *chan, int printflags)
{
    mdl_value_t *transcript_chan_list = VITEM(chan, CHANNEL_SLOT_TRANSCRIPT);
    mdl_value_t *cursor;
    mdl_value_t *tchan;
    bool binary;

    if (transcript_chan_list &&
        transcript_chan_list->type == MDL_TYPE_LIST)
    {
        cursor = transcript_chan_list->v.p.cdr;
        while (cursor)
        {
            tchan = cursor->v.p.car;
            if (tchan->type == MDL_TYPE_CHANNEL)
            {
                binary = mdl_chan_mode_is_print_binary(tchan);
                if (binary) printflags |= MDL_PF_BINARY;
                else printflags &= ~MDL_PF_BINARY;
                if (!mdl_chan_mode_is_output(tchan))
                    mdl_error("INPUT channel in transcript list");
                mdl_print_newline_to_chan(tchan, printflags, NULL);
            }
            else
                mdl_error("Non-channel in transcript list");
            cursor = cursor->v.p.cdr;
        }
    }
}

void mdl_print_char_to_transcript_channels(mdl_value_t *chan, int ch, int printflags)
 {
    mdl_value_t *transcript_chan_list = VITEM(chan, CHANNEL_SLOT_TRANSCRIPT);
    mdl_value_t *cursor;
    mdl_value_t *tchan;
    bool binary;

    if (transcript_chan_list &&
        transcript_chan_list->type == MDL_TYPE_LIST)
    {
        cursor = transcript_chan_list->v.p.cdr;
        while (cursor)
        {
            tchan = cursor->v.p.car;
            if (tchan->type == MDL_TYPE_CHANNEL)
            {
                binary = mdl_chan_mode_is_print_binary(tchan);
                if (binary) printflags |= MDL_PF_BINARY;
                else printflags &= ~MDL_PF_BINARY;
                if (!mdl_chan_mode_is_output(tchan))
                    mdl_error("INPUT channel in transcript list");
                mdl_print_char_to_chan(tchan, ch, printflags, NULL);
            }
            else
                mdl_error("Non-channel in transcript list");
            cursor = cursor->v.p.cdr;
        }
    }
}

void mdl_print_newline_to_chan(mdl_value_t *chan, int printflags, FILE *f)
{
    int linewidth = VITEM(chan, CHANNEL_SLOT_LINEWIDTH)->v.w;
    MDL_INT *linepos = &(VITEM(chan, CHANNEL_SLOT_CPOS)->v.w);
    int pageheight = VITEM(chan, CHANNEL_SLOT_PAGEHEIGHT)->v.w;
    MDL_INT *pagepos = &(VITEM(chan, CHANNEL_SLOT_LINENO)->v.w);
    int chnum = VITEM(chan,CHANNEL_SLOT_CHNUM)->v.w;
    bool binary = (printflags & MDL_PF_BINARY) != 0;
    
    if (linewidth) *linepos = 0;
    if (pageheight) 
    {
        if (++*pagepos == pageheight) *pagepos = 0;
    }
    if (chnum)
    {
        if (!f) f = mdl_get_chan_file(chan);
        if (!f) mdl_error("No file for channel");
        if (binary)
            fputs("\r\n", f);
        else
            fputc('\n', f);
    }
    else
    {
        mdl_print_char_to_chan(chan, '\r', printflags | MDL_PF_NOSCRIPT | MDL_PF_NOADVANCE, NULL);
        mdl_print_char_to_chan(chan, '\n', printflags | MDL_PF_NOSCRIPT | MDL_PF_NOADVANCE, NULL);
    }
    mdl_print_newline_to_transcript_channels(chan, printflags);
}

void mdl_print_char_to_chan(mdl_value_t *chan, int ch, int printflags, FILE *f)
{
    int pageheight = VITEM(chan, CHANNEL_SLOT_PAGEHEIGHT)->v.w;
    MDL_INT *pagepos = &(VITEM(chan, CHANNEL_SLOT_LINENO)->v.w);
    int linewidth = VITEM(chan, CHANNEL_SLOT_LINEWIDTH)->v.w;
    MDL_INT *linepos = &(VITEM(chan, CHANNEL_SLOT_CPOS)->v.w);
    int chnum = VITEM(chan,CHANNEL_SLOT_CHNUM)->v.w;
    bool noadvance = (printflags & MDL_PF_NOADVANCE) != 0;
    
    if (!noadvance)
    {
        if (pageheight && (ch == '\n'))
        {
            if (++*pagepos == pageheight) *pagepos = 0;
        }
        if (linewidth) 
        {
            (*linepos)++;
            if (ch == '\r' ||
                ((printflags & MDL_PF_BINARY) && (ch == '\n')))
                (*linepos) = 0;
        }
    }
    if (chnum)
    {
        if (!f) f = mdl_get_chan_file(chan);
        if (!f) mdl_error("No file for channel");
        putc(ch, f);
    }
    else
    {
        mdl_value_t *devdep = VITEM(chan, CHANNEL_SLOT_DEVDEP);
        if (devdep->type == MDL_TYPE_VECTOR)
        {
            // vector will either be empty, meaning discard, or
            // FIX bufsize, FIX totlen, FIX nbufs, FIX lastbuflen, LIST bufchain, LIST lastbuf

            if (VLENGTH(devdep) == OUTBUF_VLENGTH)
            {
                int bufsize = VITEM(devdep, OUTBUF_BUFSIZE)->v.w;
                int lastbuflen = VITEM(devdep, OUTBUF_LASTBUFLEN)->v.w;
                mdl_value_t *lastbuflist = VITEM(devdep, OUTBUF_LASTBUFLIST);
                mdl_value_t *lastbuf = LITEM(lastbuflist, 0);
                if (lastbuflen >= bufsize)
                {
                    int bufsize = VITEM(devdep, OUTBUF_BUFSIZE)->v.w;
                    lastbuf = mdl_new_string(bufsize);
                    lastbuflen = 0;
                    mdl_additem(LREST(lastbuflist, 0), lastbuf, &lastbuflist);
                    VITEM(devdep, OUTBUF_LASTBUFLIST)->v.p.cdr = lastbuflist;
                    VITEM(devdep, OUTBUF_NBUFS)->v.w++;
                }
                lastbuf->v.s.p[lastbuflen++] = ch;
                VITEM(devdep, OUTBUF_LASTBUFLEN)->v.w = lastbuflen;
                VITEM(devdep, OUTBUF_TOTLEN)->v.w++;
            }
            else if (VLENGTH(devdep) == OUTBUF_FL_VLENGTH)
            {
                if (VITEM(devdep, OUTBUF_TOTLEN)->v.w++ >= VITEM(devdep, OUTBUF_MAXLEN)->v.w)
                    mdl_longjmp_to(VITEM(devdep, OUTBUF_FRAME)->v.f,
                            LONGJMP_FLATSIZE_EXCEEDED);
            }
        }
        else
            mdl_error("Attempt to write to closed channel");
    }
    if (!(printflags & MDL_PF_NOSCRIPT))
        mdl_print_char_to_transcript_channels(chan, ch, printflags);
}

void mdl_print_string_to_chan(mdl_value_t *chan, 
                                      const char *str,
                                      int len,
                                      int extralen, // space to reserve, not including the addspacebefore value
                                      bool canbreakbefore,
                                      bool addspacebefore // add a space if no break
    )
{
    int linewidth = VITEM(chan, CHANNEL_SLOT_LINEWIDTH)->v.w;
    MDL_INT *linepos = &(VITEM(chan, CHANNEL_SLOT_CPOS)->v.w);
    bool broke = false;
    bool binary;
    const char *s;
    char ch;
    int olen, tlen;
    FILE *f;

    binary = mdl_chan_mode_is_print_binary(chan);
//    fflush(stdout);
//    fprintf(stderr, "||%3d %-.*s %d %d %d %d %d||\n", len, len, str, canbreakbefore, addspacebefore, binary, linewidth, (int)*linepos);

    olen = len;
    if (!binary)
    {
        tlen = olen;
        s = str;
        
        while (tlen--)
        {
            ch = *s++;
            if (!isspace(ch) && iscntrl(ch)) len++;     //HEASM: Fix in logic in counting length (see line 386)
        }
    }
    else if (!mdl_chan_mode_is_output(chan))
        mdl_error("Tried to print to an input channel!");

    f = mdl_get_chan_file(chan);
    if (addspacebefore) extralen++;
    if (canbreakbefore && !binary)
    {
        
        broke =  mdl_need_line_break(len, extralen,
                                     // added only if there is no line break
                                     linewidth, linepos);
        if (broke) mdl_print_newline_to_chan(chan, MDL_PF_NOSCRIPT, f);
    }
    if (!broke && addspacebefore)
    {
        mdl_print_char_to_chan(chan, ' ', binary?MDL_PF_BINARY:MDL_PF_NONE, f);
    }
    s = str;
    tlen = olen;
    while (tlen--)
    {
        ch = *s++;
        if (!binary && !isspace(ch) && iscntrl(ch))
        {
            mdl_print_char_to_chan(chan, '^', MDL_PF_NONE, f);
            ch = ch + 0x40;
        }
        mdl_print_char_to_chan(chan, ch, MDL_PF_NONE, f);
    }
}

void mdl_print_binary(mdl_value_t *chan, mdl_value_t *buffer)
{
    int len = UVLENGTH(buffer);
    FILE *f;
    uvector_element_t *elem = UVREST(buffer, 0);

    f = mdl_get_chan_file(chan);

    if (!f) mdl_error("Attempt to write to closed binary channel");
    while (len--)
    {
        int nitems;
        nitems = fwrite(&elem->w, sizeof(MDL_INT), 1, f);
        if (nitems != 1)
            mdl_error("Error on binary write");
        elem++;
    }
}

const char *mdl_quote_atomname(const char *name, bool *nonnump)
{
    int newlen;
    const char *s = name;
    bool nonnum = false;
    charinfo_t cinfo;
    bool gote = false;
    bool gotdot = false;
    bool octal = false;
    bool gotdigit = false;
    bool gotedigit = false;
    bool goteminus = false;
    bool doneoctal = false;
    char ch;
    
    newlen = 0;
    if (*s == '.' || *s == '!')
    {
        newlen += 2;
        nonnum = true;
        s++;
    }
    else if (*s == '-') 
    {
        newlen++;
        s++;
    }
    else if (*s == '*') 
    {
        newlen++;
        s++;
        octal = true;
    }
    while ((ch = *s++))
    {
        newlen++;
        if (doneoctal) nonnum = true;
        mdl_get_charinfo(ch, &cinfo);
        if (cinfo.separator || cinfo.charclass == MDL_C_BACKSLASH)
        {
            nonnum = true;
            newlen++;
        }
        else if (ch == 'E' || ch == 'e')
        {
            if (gote || octal || !gotdigit) nonnum = true;
            gote = true;
        }
        else if (ch == '.')
        {
            if (gote || gotdot || octal) nonnum = true;
            gotdot = true;
        }
        else if (ch == '-')
        {
            if (!gote || gotedigit || goteminus) nonnum = true;
            goteminus = true;
        }
        else if (ch == '*')
        {
            if (!octal || !gotdigit) nonnum = true;
            doneoctal = true;
        }
        else if (isdigit(ch))
        {
            if (gote) gotedigit = true;
            gotdigit = true;
        }
        else // not a digit or other special category
        {
            nonnum = true;
        }
    }
    if (!gotdigit || (gote && !gotedigit)) nonnum = true;
    *nonnump = *nonnump || nonnum;
    if (nonnum)
    {
        char *dbuf, *d;
        d = dbuf = (char *)GC_MALLOC_ATOMIC(newlen + 1);
        s = name;
        if (*s == '.' || *s == '!')
        {
            *d++ ='\\';
            *d++ = *s++;
        }
        while ((ch = *s++))
        {
            mdl_get_charinfo(ch, &cinfo);
            if (cinfo.separator || cinfo.charclass == MDL_C_BACKSLASH)
            {
                *d++ ='\\';
            }
            *d++ = ch;
        }
        *d = '\0';
        return dbuf;
    }
    else return name;
}

mdl_strbuf_t *mdl_unparse_atom(const atom_t *a, bool princ, bool nonnum, bool *breakable, mdl_value_t *oblists)
{
    *breakable = false;
    mdl_strbuf_t *r = mdl_new_strbuf(40);

    if (!a) return mdl_strbuf_append_cstr(r,"#ATOM 0"); // should never happen, but GROW and CHUTYPE can do it
    if (princ)
    {
        r = mdl_strbuf_append_cstr(r, a->pname);
        return r;
    }
    else
        r = mdl_strbuf_append_cstr(r, mdl_quote_atomname(a->pname, &nonnum));
    
    if (!a->oblist) 
    {
        r = mdl_strbuf_append_cstr_len(r, "!-#FALSE ()", 11);
        *breakable = true;
    }
    else
    {
        if (!mdl_value_equal_atom(mdl_get_atom_default_oblist(a->pname, false, oblists), a))
        {
            r = mdl_strbuf_append_cstr_len(r, "!-", 2);
            if (a->oblist != mdl_value_root_oblist)
            {
                atom_t *oname = mdl_get_oblist_name(a->oblist);
                if (!oname)
                {
                    r = mdl_strbuf_append_cstr_len(r, "!-#FALSE ()", 11);
                    *breakable = true;
                }
                else
                    r = mdl_strbuf_append_strbuf(r, mdl_unparse_atom(oname, princ, true, breakable, oblists));
            }
        }
        else if (!nonnum)
        {
            r = mdl_strbuf_prepend_cstr("\\", r);
        }
    }
    return r;
}

void mdl_print_atom_to_chan(mdl_value_t *chan, const atom_t *a, bool princ, bool prespace, mdl_value_t *oblists)
{
    bool breakable = true;
    mdl_strbuf_t *r = mdl_unparse_atom(a, princ, false, &breakable, oblists);
    int len = mdl_strbuf_len(r);
    char *ps = mdl_strbuf_to_new_cstr(r);
    if (breakable)
    {
        mdl_print_string_to_chan(chan, ps, len-3, 0, true, prespace);
        mdl_print_string_to_chan(chan, ps + len - 2, 2, 0, true, true);
    }
    else
        mdl_print_string_to_chan(chan, ps, len, 0, true, prespace);
}

int mdl_int_to_string(MDL_INT mi, char *buf, int buflen, int radix)
{
    char *p = buf;
    char *p2 = buf;

    if ((mi < 0) && buflen)
    {
        *p++ = '-';
        p2++;
        buflen--;
        mi = -mi;
        
    }
    if (buflen < 2) return -1;
    do
    {
        int d;
        d = mi%radix;
        if (d < 10) d += '0';
        else d = d - 10 + 'A';
        *p++ = d;
        mi /= radix;
    }
    while (mi && --buflen);

    if (!buflen) return -1;
    *p-- = '\0';
    while (p2 < p)
    {
        char tmp = *p;
        *p-- = *p2;
        *p2++ = tmp;
    }
    return 0;
}

void mdl_print_hashtype(mdl_value_t *chan, int type, bool princ, bool prespace, mdl_value_t *oblists)
{
    mdl_strbuf_t *r;
    int rlen;
    char *rstr;
    atom_t *a = mdl_type_atom(type);
    bool breakable;
    
    // Note a->type, not print_as_type
    r = mdl_strbuf_prepend_cstr("#", mdl_unparse_atom(a, princ, true, &breakable, oblists));
    rstr = mdl_strbuf_to_new_cstr(r);
    rlen = mdl_strbuf_len(r);
    if (breakable)
    {
        mdl_print_string_to_chan(chan, rstr - 3, rlen - 3, 0, true, prespace);
        mdl_print_string_to_chan(chan, rstr + rlen - 2, 2, 0, true, true);
    }
    else
        mdl_print_string_to_chan(chan, rstr, rlen, 0, true, prespace);
}

void mdl_print_nonstructured_to_chan(mdl_value_t *chan, const mdl_value_t *a, int print_as_type, bool princ, bool prespace, mdl_value_t *oblists)
{
    if (print_as_type == MDL_TYPE_NOTATYPE)
        print_as_type = a->type;
    if (a == NULL)
    {
        mdl_print_string_to_chan(chan, "nil!", 4, 0, true, prespace);
         // this should never happen
    }
    else
    {
        switch (a->pt)
        {
        case PRIMTYPE_WORD:
            switch (print_as_type)
            {
            case MDL_TYPE_CHARACTER:
            {
                char buf[5];
                if (princ)
                {
                    buf[0] = (char)a->v.w;
                    buf[1] = '\0';
                }
                else
                {
                    buf[0] = '!';
                    buf[1] = '\\';
                    if (isprint(a->v.w))
                    {
                        buf[2] = (char)a->v.w;
                        buf[3] = '\0';
                    }
                    else if (a->v.w < 0x20)
                    {
                        buf[2] = '^';
                        buf[3] = (char)((char)a->v.w + 0x40); // Maybe std MDL
                        buf[4] = '\0';
                    }
                    else
                    {
                    }
                }
                mdl_print_string_to_chan(chan,buf, strlen(buf), 0, true, prespace);
            }
            break;
            case MDL_TYPE_FIX:
            {
                char buf[(sizeof(MDL_INT) << 3) + 1]; // # bits + 1
                int radix = mdl_get_chan_radix(chan);
                mdl_int_to_string(a->v.w, buf, sizeof(buf), radix);
                mdl_print_string_to_chan(chan,buf, strlen(buf), 0, true, prespace);
            }
            break;
            case MDL_TYPE_FLOAT:
            {
                char buf[10];
                sprintf(buf, "%.7f", a->v.fl);
                mdl_print_string_to_chan(chan,buf, strlen(buf), 0, true, prespace);
            }
            break;
            default:
            {
                char buf[(((sizeof(MDL_INT) << 3) + 2) / 3) + 3]; // size of octal representation plus stars
                mdl_print_hashtype(chan, a->type, princ, prespace, oblists);
#ifdef MDL32
                sprintf(buf, "*%011o*", a->v.w);
#else
                sprintf(buf, "*%022llo*", (long long unsigned) a->v.w);
#endif
                mdl_print_string_to_chan(chan,buf, strlen(buf), 0, true, true);
                break;
            }
            }
            break;
        case PRIMTYPE_ATOM:
        {
            bool addspace = prespace;
            if (print_as_type != MDL_TYPE_ATOM)
            {
                // again, a->type, not print_as_type
                mdl_print_hashtype(chan, a->type, princ, prespace, oblists);
                addspace = true;
            }
            mdl_print_atom_to_chan(chan, a->v.a, princ, addspace, oblists);
            break;
        }
        case PRIMTYPE_FRAME:
            mdl_print_hashtype(chan, a->type, princ, prespace, oblists);
            mdl_print_value_to_chan(chan, a->v.f->subr, princ, true, oblists);
            break;
        default:
            // again, a->type, not print_as_type
            mdl_print_hashtype(chan, a->type, princ, prespace, oblists);
            mdl_print_string_to_chan(chan, "UNPRINTABLE", 11, 0, true, true);
        }
    }
}

// Add a line break to the start of strp if needed.  Return true if
// doing so
void mdl_print_list_to_chan(mdl_value_t *chan, const mdl_value_t *v, int print_as_type, bool princ, bool prespace, mdl_value_t *oblists)
{
    const char *startstr;
    const char *endstr;
    bool specialform = false;
    mdl_value_t *mdl_value_atom_lval;
    mdl_value_t *mdl_value_atom_gval;
    mdl_value_t *mdl_value_atom_quote;
    
    mdl_value_atom_lval = mdl_get_atom_from_oblist("LVAL", mdl_value_root_oblist);
    mdl_value_atom_gval = mdl_get_atom_from_oblist("GVAL", mdl_value_root_oblist);
    mdl_value_atom_quote = mdl_get_atom_from_oblist("QUOTE", mdl_value_root_oblist);
    
    if (print_as_type == MDL_TYPE_NOTATYPE) print_as_type = v->type;
    switch (print_as_type)
    {
    case MDL_TYPE_LIST:
        startstr = "(";
        endstr = ")";
        break;
    case MDL_TYPE_FORM:
        if (v->v.p.cdr && v->v.p.cdr->v.p.cdr && !v->v.p.cdr->v.p.cdr->v.p.cdr)
        {
            if (mdl_value_equal(v->v.p.cdr->v.p.car, mdl_value_atom_lval))
            {
                startstr = ".";
                specialform = true;
                break;
            }
            else if (mdl_value_equal(v->v.p.cdr->v.p.car, mdl_value_atom_gval))
            {
                startstr = ",";
                specialform = true;
                break;
            }
            else if (mdl_value_equal(v->v.p.cdr->v.p.car, mdl_value_atom_quote))
            {
                startstr = "'";
                specialform = true;
                break;
            }
        }
        startstr = "<";
        endstr = ">";
        break;
    case MDL_TYPE_SEGMENT:
        if (v->v.p.cdr && v->v.p.cdr->v.p.cdr && !v->v.p.cdr->v.p.cdr->v.p.cdr)
        {
            if (mdl_value_equal(v->v.p.cdr->v.p.car, mdl_value_atom_lval))
            {
                startstr = "!.";
                specialform = true;
                break;
            }
            else if (mdl_value_equal(v->v.p.cdr->v.p.car, mdl_value_atom_gval))
            {
                startstr = "!,";
                specialform = true;
                break;
            }
            else if (mdl_value_equal(v->v.p.cdr->v.p.car, mdl_value_atom_quote))
            {
                startstr = "!'";
                specialform = true;
                break;
            }
        }
        startstr = "!<";
        endstr = "!>";
        break;
    default:
    {
        mdl_print_hashtype(chan, v->type, princ, prespace, oblists);
        prespace = true;
        startstr = "(";
        endstr = ")";
        break;
    }
    }

    if (specialform)
    {
        // this can result in an orphan special form ... oh well
        mdl_print_string_to_chan(chan, startstr, strlen(startstr), 0, true, prespace);
        mdl_print_value_to_chan(chan, v->v.p.cdr->v.p.cdr->v.p.car, princ, false, oblists);
        return;
    }
    
    mdl_value_t *c = v->v.p.cdr;
    if (!c)
    {
        // no break allowed in ()
        int elen = strlen(endstr);
        mdl_print_string_to_chan(chan, startstr, strlen(startstr), elen, true, prespace);
        mdl_print_string_to_chan(chan, endstr, elen, 0, false, false);
        return;
    }

    mdl_print_string_to_chan(chan, startstr, strlen(startstr), 0, true, prespace);
    mdl_print_value_to_chan(chan, c->v.p.car, princ, false, oblists);
    c = c->v.p.cdr;
    while (c)
    {
        mdl_print_value_to_chan(chan, c->v.p.car, princ, true, oblists);
        c = c->v.p.cdr;
    }
    mdl_print_string_to_chan(chan, endstr, strlen(endstr), 0, true, false);
}

void mdl_print_vector_to_chan(mdl_value_t *chan, const mdl_value_t *v, int print_as_type, bool princ, bool prespace, mdl_value_t *oblists)
{
    int vsize = VLENGTH(v);

    if (print_as_type == MDL_TYPE_NOTATYPE) print_as_type = v->type;

    if (print_as_type != MDL_TYPE_VECTOR)
    {
        mdl_print_hashtype(chan, v->type, princ, prespace, oblists);
        prespace = true;
    }

    if (vsize == 0)
    {
        // no break allowed in []
        mdl_print_string_to_chan(chan, "[]", 2, 0, true, prespace);
        return;
    }
    vsize--;
    mdl_print_string_to_chan(chan, "[", 1, 0, true, prespace);
    mdl_value_t *c = VREST(v,0);
    mdl_print_value_to_chan(chan, c++, princ, false, oblists);
    while (vsize--)
    {
        mdl_print_value_to_chan(chan, c++, princ, true, oblists);
    }
    mdl_print_string_to_chan(chan, "]", 1, 0, true, false);
}

void mdl_print_uvector_to_chan(mdl_value_t *chan, const mdl_value_t *v, int print_as_type, bool princ, bool prespace, mdl_value_t *oblists)
{
    int uvsize = UVLENGTH(v);

    if (print_as_type == MDL_TYPE_NOTATYPE) print_as_type = v->type;

    if (print_as_type != MDL_TYPE_UVECTOR)
    {
        mdl_print_hashtype(chan, v->type, princ, prespace, oblists);
        prespace = true;
    }

    if (uvsize == 0)
    {
        // no break allowed in ![!]
        mdl_print_string_to_chan(chan, "![!]", 4, 0, true, prespace);
        return;
    }

    uvsize--;
    mdl_print_string_to_chan(chan, "![", 2, 0, true, prespace);
    uvector_element_t *c = UVREST(v, 0);

    mdl_value_t *tmp = mdl_uvector_element_to_value(v, c++);
    mdl_print_value_to_chan(chan, tmp, princ, false, oblists);
    while (uvsize--)
    {
        mdl_value_t *tmp = mdl_uvector_element_to_value(v, c++);
        mdl_print_value_to_chan(chan, tmp, princ, true, oblists);
    }
    mdl_print_string_to_chan(chan, "!]", 2, 0, true, false);
}

void mdl_print_tuple_to_chan(mdl_value_t *chan, const mdl_value_t *v, int print_as_type, bool princ, bool prespace, mdl_value_t *oblists)
{
    int vsize = TPLENGTH(v);

    if (print_as_type == MDL_TYPE_NOTATYPE) print_as_type = v->type;

    if (print_as_type != MDL_TYPE_TUPLE)
    {
        mdl_print_hashtype(chan, v->type, princ, prespace, oblists);
        prespace = true;
    }

    if (vsize == 0)
    {
        // tuples shouldn't really print with the question marks
        // no break allowed in []
        mdl_print_string_to_chan(chan, "?[?]", 4, 0, true, prespace);
        return;
    }
    vsize--;

    mdl_print_string_to_chan(chan, "?[", 2, 0, true, prespace);
    mdl_value_t *c = TPREST(v,0);
    mdl_print_value_to_chan(chan, c++, princ, false, oblists);
    while (vsize--)
    {
        mdl_print_value_to_chan(chan, c++, princ, true, oblists);
    }
    mdl_print_string_to_chan(chan, "?]", 2, 0, true, false);
}

void mdl_quote_string(counted_string_t *d, const counted_string_t *s)
{
    const char *sp;
    char *dp;
    int i;
    bool needsquote = false;

    *d = *s;
    for (i = 0, sp = s->p; i < s->l; i++, sp++)
    {
        if (*sp == '"' || *sp == '\\') 
        {
            needsquote = true;
            d->l++;
        }
    }

    if (needsquote)
    {
        d->p = (char *)GC_MALLOC_ATOMIC(d->l + 1);
        for (i = 0, sp = s->p, dp = d->p; i < s->l; i++, sp++, dp++)
        {
            if (*sp == '"' || *sp == '\\') *dp++ = '\\';
            *dp = *sp;
        }
        *dp = 0;
    }
}
void mdl_print_stringval_to_chan(mdl_value_t *chan, const mdl_value_t *v, int print_as_type, bool princ, bool prespace, mdl_value_t *oblists)
{
    if (v->type != MDL_TYPE_STRING)
    {
        mdl_print_hashtype(chan, v->type, princ, prespace, oblists);
        prespace = true;
    }
    int len = v->v.s.l;
    char *s = v->v.s.p;
    if (princ)
    {
        mdl_print_string_to_chan(chan, s, len, 0, true, prespace);
    }
    else
    {
        counted_string_t ns;
        mdl_quote_string(&ns, &v->v.s);
        s = ns.p;
        len = ns.l;
        mdl_print_string_to_chan(chan, "\"", 1, len+1, true, prespace);
        mdl_print_string_to_chan(chan, s, len, 0, false, false);
        mdl_print_string_to_chan(chan, "\"", 1, 0, false, false);
    }
}

void mdl_print_value_to_chan(mdl_value_t *chan, mdl_value_t *v, bool princ, 
                             bool prespace, mdl_value_t *oblists)
{
    int print_as_type = MDL_TYPE_NOTATYPE;
    mdl_value_t *printtype;

    if (v == NULL) 
    {
    // this should never happen
        mdl_print_string_to_chan(chan, "nil", 3, 0, true, prespace);
        return;
    }

    printtype = mdl_get_printtype(v->type);
    if (printtype && printtype->type != MDL_TYPE_ATOM)
    {
        mdl_value_t *arglist = mdl_cons_internal(v, NULL);
        arglist = mdl_cons_internal(printtype, arglist);
        arglist = mdl_make_list(arglist);
        if (prespace)
            mdl_print_string_to_chan(chan, "", 0, 0, true, true);

        mdl_internal_apply(printtype, arglist, true);
        return;
    }

    if (mdl_primtype_nonstructured(v->pt))
    {
        mdl_print_nonstructured_to_chan(chan, v, print_as_type, princ, prespace, oblists);
    }
    else
    {
        switch(v->pt)
        {
        case PRIMTYPE_LIST:
            mdl_print_list_to_chan(chan, v, print_as_type, princ, prespace, oblists);
            break;
        case PRIMTYPE_VECTOR:
            mdl_print_vector_to_chan(chan, v, print_as_type, princ, prespace, oblists);
            break;
        case PRIMTYPE_UVECTOR:
            mdl_print_uvector_to_chan(chan, v, print_as_type, princ, prespace, oblists);
            break;
        case PRIMTYPE_TUPLE:
            mdl_print_tuple_to_chan(chan, v, print_as_type, princ, prespace, oblists);
            break;
        case PRIMTYPE_STRING:
            mdl_print_stringval_to_chan(chan, v, print_as_type, princ, prespace, oblists);
            break;
        default:
            mdl_print_hashtype(chan, v->type, princ, prespace, oblists);
            mdl_print_string_to_chan(chan, "UNPRINTABLE", 11, 0, true, true);
        }
    }
}


void mdl_print_value(FILE *f, mdl_value_t *v)
{
    // FIXME : remove
    mdl_value_t *chan = mdl_get_default_outchan();
    mdl_print_value_to_chan(chan, v, false, false, NULL);
}
