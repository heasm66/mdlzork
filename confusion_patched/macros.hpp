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
#include <gc/gc.h>
#include <gc/gc_allocator.h>
#include <gc/gc_cpp.h>
#include <vector>
#include <string>
#include <map>
#include <setjmp.h>
#include <float.h>
#include "mdl_builtin_types.h"

// PRIMTYPES and TYPES must be specified in order, with
// naming and commenting convention as below, or
// make_types perl script will fail
typedef enum prim_type_t
{
    PRIMTYPE_ATOM,
    PRIMTYPE_WORD,
    PRIMTYPE_LIST,
    PRIMTYPE_STRING,
    PRIMTYPE_VECTOR,
    PRIMTYPE_UVECTOR,
    PRIMTYPE_TUPLE,

    // implemented, but differently
    PRIMTYPE_FRAME,

    // All these are unimplemented
    PRIMTYPE_ASOC,
    PRIMTYPE_BYTES,
    PRIMTYPE_OFFSET,
    PRIMTYPE_INTERNAL_TYPE,
    PRIMTYPE_LOCA,
    PRIMTYPE_LOCAS,
    PRIMTYPE_LOCB,
    PRIMTYPE_LOCD,
    PRIMTYPE_LOCL,
    PRIMTYPE_LOCR,
    PRIMTYPE_LOCS,
    PRIMTYPE_LOCT,
    PRIMTYPE_LOCU,
    PRIMTYPE_LOCV,
    PRIMTYPE_PROCESS,
    PRIMTYPE_STORAGE,
    PRIMTYPE_TEMPLATE,
    PRIMTYPE_MAX,
} primtype_t;

typedef enum mdl_type_t
{
    // all the elements of primtype_t are implicitly members also
    MDL_TYPE_ACTIVATION = PRIMTYPE_MAX,   // FRAME
    MDL_TYPE_BITS,                        // WORD
    MDL_TYPE_CHANNEL,                     // VECTOR
    MDL_TYPE_CHARACTER,                   // WORD
    MDL_TYPE_CLOSURE,                     // LIST (unimp)
    MDL_TYPE_CODE,                        // UVECTOR (unimp)
    MDL_TYPE_DECL,                        // LIST (unimp)
    MDL_TYPE_DISMISS,                     // ATOM (unimp)
    MDL_TYPE_ENVIRONMENT,                 // FRAME
    MDL_TYPE_FALSE,                       // LIST
    MDL_TYPE_FIX,                         // WORD
    MDL_TYPE_FLOAT,                       // WORD
    MDL_TYPE_FORM,                        // LIST
    MDL_TYPE_FSUBR,                       // WORD
    MDL_TYPE_FUNCTION,                    // LIST
    MDL_TYPE_HANDLER,                     // VECTOR (unimpl)
    MDL_TYPE_IHEADER,                     // VECTOR (unimpl)
    MDL_TYPE_ILLEGAL,                     // WORD (unimpl)
    MDL_TYPE_INTERNAL_LIST,               // LIST (not in real MDL -- essentially similar to DEFER, however)
    MDL_TYPE_LINK,                        // ATOM (unimpl)
    MDL_TYPE_LOSE,                        // WORD
    MDL_TYPE_MACRO,                       // LIST
    MDL_TYPE_OBLIST,                      // UVECTOR
    MDL_TYPE_PCODE,                       // WORD (unimpl)
    MDL_TYPE_PRIMTYPE_C,                  // WORD (unimpl)
    MDL_TYPE_QUICK_ENTRY,                 // VECTOR (unimpl)
    MDL_TYPE_QUICK_RSUBR,                 // VECTOR (unimpl)
    MDL_TYPE_READA,                       // FRAME (unimpl)
    MDL_TYPE_RSUBR,                       // VECTOR (unimpl)
    MDL_TYPE_RSUBR_ENTRY,                 // VECTOR (unimpl)
    MDL_TYPE_SEGMENT,                     // LIST
    MDL_TYPE_SPLICE,                      // LIST (unimpl)
    MDL_TYPE_SUBR,                        // WORD
    MDL_TYPE_TAG,                         // VECTOR (unimpl)
    MDL_TYPE_TIME,                        // WORD (unimpl)
    MDL_TYPE_TYPE_C,                      // WORD (unimpl)
    MDL_TYPE_TYPE_W,                      // WORD (unimpl)
    MDL_TYPE_UNBOUND,                     // WORD
} mdl_type_t;
#define MDL_BUILTIN_TYPE_LAST MDL_TYPE_UNBOUND
#define MDL_TYPE_NOTATYPE -1

#ifdef MDL32
#define MDL_INT_MAX INT_MAX
#define MDL_INT_MIN INT_MIN
typedef int MDL_INT;
typedef unsigned int MDL_UINT; // for internal use

#define MDL_FLOAT_MAX 3.40282347e+38F
#define MDL_FLOAT_MIN 1.17549435e-38F
typedef float MDL_FLOAT;
#else
#define MDL_INT_MAX 9223372036854775807LL
#define MDL_INT_MIN (-9223372036854775807LL - 1LL)
typedef int64_t MDL_INT;
typedef uint64_t  MDL_UINT; // for internal use

#define MDL_FLOAT_MAX DBL_MAX
#define MDL_FLOAT_MIN DBL_MIN
typedef double MDL_FLOAT;
#endif

typedef struct mdl_value_t mdl_value_t;

typedef enum
{
    MDL_C_BACKSLASH,
    MDL_C_WHITESPACE,
    MDL_C_OPENLIST,
    MDL_C_CLOSELIST,
    MDL_C_OPENFORM,
    MDL_C_CLOSEFORM,
    MDL_C_OPENSEGMENT,
    MDL_C_CLOSESEGMENT,
    MDL_C_OPENVECTOR,
    MDL_C_CLOSEVECTOR,
    MDL_C_OPENUVECTOR,
    MDL_C_CLOSEUVECTOR,
    MDL_C_QUOTE,
    MDL_C_PERCENT,
    MDL_C_STAR,
    MDL_C_MINUS,
    MDL_C_DIGIT,
    MDL_C_ALPHA,
    MDL_C_OTHERATOM,
    MDL_C_HASH,
    MDL_C_DOT,
    MDL_C_COMMA,
    MDL_C_SQUOTE,
    MDL_C_SEMI,
    MDL_C_BANG,
    MDL_C_BANGBACK, // character introducer
    MDL_C_BANGDOT,
    MDL_C_BANGCOMMA,
    MDL_C_BANGSQUOTE,
    MDL_C_BANGANY,
    MDL_C_EOF,
} mdl_charclass_t;

typedef struct atom_t atom_t;
// convenience macro
#define mdl_new_fix(f) mdl_new_word(f, MDL_TYPE_FIX)
//*************************************
//********Function Definitions*********
//*************************************
mdl_value_t *mdl_create_or_get_atom(const char *pname);
mdl_value_t *mdl_new_word(MDL_INT fix, int type);
mdl_value_t *mdl_new_float(MDL_FLOAT flt);
mdl_value_t *mdl_new_string(const char *string);
mdl_value_t *mdl_newatomval(atom_t *a);
mdl_value_t *mdl_newlist();
mdl_value_t *mdl_additem(mdl_value_t *a, mdl_value_t *b, mdl_value_t **lastitem = NULL);
mdl_value_t *mdl_additem_a(mdl_value_t *a, const atom_t *b);
mdl_value_t *mdl_make_globalvar_ref(mdl_value_t *a, int reftype = MDL_TYPE_FORM);
mdl_value_t *mdl_make_localvar_ref(mdl_value_t *a, int reftype = MDL_TYPE_FORM);
mdl_value_t *mdl_make_quote(mdl_value_t *a, int qtype = MDL_TYPE_FORM);
mdl_value_t *mdl_make_list(mdl_value_t *a, int type = MDL_TYPE_LIST);
mdl_value_t *mdl_make_vector(mdl_value_t *a, int type = MDL_TYPE_VECTOR, bool destroy = false);
mdl_value_t *mdl_make_uvector(mdl_value_t *a, int type = MDL_TYPE_UVECTOR, bool destroy = false);
mdl_value_t *mdl_make_tuple(mdl_value_t *a, int type = MDL_TYPE_TUPLE, bool destroy = false);
void mdl_print_atom(FILE *f, const atom_t *a);
void mdl_print_value(FILE *f, mdl_value_t *v);
void mdl_interp_init();

mdl_value_t *mdl_eval(mdl_value_t *l, bool in_struct = false, mdl_value_t *environment = NULL);
int mdl_get_typenum(mdl_value_t *val);
mdl_value_t *mdl_read_object(mdl_value_t *chan);
mdl_value_t *mdl_get_default_inchan();
mdl_value_t *mdl_get_default_outchan();
bool mdl_chan_at_eof(mdl_value_t *chan);
mdl_charclass_t mdl_get_charclass(MDL_INT ch);
int mdl_read_from_chan(mdl_value_t *chan);
void mdl_error(const char *err)  __attribute__((noreturn));
void mdl_toplevel(FILE *restorefile);
