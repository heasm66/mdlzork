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
// This forward declaration is necessary
struct atom_t;

// INTERNAL PROTOTYPES, definitions, etc
typedef struct mdl_symbol_t
{
    struct atom_t *atom;
    mdl_value_t *binding;
} mdl_symbol_t;

typedef struct mdl_local_symbol_t
{
    struct atom_t *atom;
    mdl_value_t *binding;
#ifdef CACHE_LOCAL_SYMBOLS
    mdl_local_symbol_t *prev_binding;
#endif
} mdl_local_symbol_t;

#define ALIGN_MDL_INT(x) (((((intptr_t)x) + sizeof(MDL_INT) - 1)/sizeof(MDL_INT)) * sizeof(MDL_INT))
typedef std::basic_string<char, std::char_traits<char>, gc_allocator<char> > gc_string;


#if 0
struct hash_gc_string
{
    size_t operator()(const gc_string __s) const
        {
            hash<const char *> H;
            return H(__s.c_str());
        }
};

struct hash_atom_ptr
{
    size_t operator()(const struct atom_t *__s) const
        {
            return (size_t)__s;
        }
};

typedef hash_map<const struct atom_t *, mdl_symbol_t,hash_atom_ptr, std::equal_to<const struct atom_t *>, 
    gc_allocator<std::pair<const struct atom_t * const, mdl_symbol_t> > >
    mdl_symbol_table_t;
#endif

typedef std::map<const struct atom_t *, mdl_symbol_t,std::less<const struct atom_t *>, 
		 gc_allocator<std::pair<const struct atom_t * const, mdl_symbol_t> > >
		 mdl_symbol_table_t;
typedef std::map<const struct atom_t *, mdl_local_symbol_t,std::less<const struct atom_t *>, 
		 gc_allocator<std::pair<const struct atom_t * const, mdl_local_symbol_t> > >
		 mdl_local_symbol_table_t;

typedef struct mdl_assoc_key_t
{
    mdl_value_t *item;
    mdl_value_t *indicator;
} mdl_assoc_key_t;

extern struct mdl_assoc_table_t *mdl_assoc_table;

typedef mdl_value_t *(*mdl_evaluator_t)(mdl_value_t *cdr);

#define MDL_FRAME_FLAGS_TRUEFRAME   1  /* a frame for a SUBR or FSUBR */
#define MDL_FRAME_FLAGS_ACTIVATION  2  /* a frame for a function, prog, repeat, bind, or map */
#define MDL_FRAME_FLAGS_NAMED_FUNC  4  /* a frame for a named function */
#define MDL_FRAME_FLAGS_UNWIND    0x100  /* unwind frame -- apply second arg */

// on OS X, setjmp is dog slow
#define mdl_setjmp _setjmp
#define mdl_longjmp _longjmp

typedef struct mdl_frame_t
{
    struct mdl_frame_t *prev_frame;
    jmp_buf interp_frame;
    mdl_value_t *result; // for RETURN
    mdl_local_symbol_table_t *syms;
    mdl_value_t *subr; // the atom containing the subroutine being applied
    mdl_value_t *args; // Argument tuple
    unsigned frame_flags;
} mdl_frame_t;

typedef mdl_value_t *mdl_built_in_proc_t(mdl_value_t *form, mdl_value_t *args);
typedef struct mdl_built_in_t
{
    mdl_built_in_proc_t *proc;
    mdl_value_t *a;
    mdl_value_t *v;
} mdl_built_in_t;

typedef struct mdl_type_table_entry_t
{
    primtype_t pt;   // primtype for type
    atom_t *a;       // atom for type
    mdl_value_t *printtype; 
    mdl_value_t *evaltype; 
    mdl_value_t *applytype; 
} mdl_type_table_entry_t;

typedef std::vector<mdl_built_in_t, traceable_allocator<mdl_built_in_t> > mdl_built_in_table_t;

typedef std::vector<mdl_type_table_entry_t, traceable_allocator<mdl_type_table_entry_t> > mdl_type_table_t;

extern mdl_type_table_t mdl_type_table;


typedef struct atom_t
{
    mdl_value_t *oblist;
    int typenum;
//    char pname[1]; //the pname of an atom is NUL terminated even in real MDL
    char *pname; //the pname of an atom is NUL terminated even in real MDL
#ifdef CACHE_LOCAL_SYMBOLS
    int bindid;
    mdl_local_symbol_t *binding; // LOCAL binding
#endif
} atom_t;

// welcome to hell... err, I mean LISP
typedef struct cons_pair_t
{
    struct mdl_value_t *car;
    struct mdl_value_t *cdr;
} cons_pair_t;

struct counted_string_t 
{
    int l;
    char *p;
};

// a VECTOR/UVECTOR is implemented as a pointer to one of these,
// which actually points to the item.  This should allow GROW to
// work properly despite lacking the fine control over GC.
// it may break locatives however

typedef struct mdl_vector_block_t
{
    int size;
    int startoffset; // for GROW from beginning -- number of elements added to beginning since vector instantiation
    mdl_value_t *elements;
} mdl_vector_block_t;

typedef struct mdl_vector_t
{
    struct mdl_vector_block_t *p;
    int offset;
} mdl_vector_t;

typedef struct mdl_uvector_t
{
    struct mdl_uvector_block_t *p;
    int offset;
} mdl_uvector_t;


typedef union uvector_element_t
{
    struct atom_t *a;
    struct mdl_value_t *l; // Lists stored in a uvector have no car
    MDL_INT w;
    MDL_FLOAT fl;
    // allowing vectors and uvectors into the game reduces storage
    // efficiency.  Given this, there's no reason not to allow
    // strings as well, but I don't (for documented MDL compatibility)
    struct mdl_vector_t   v;
    struct mdl_uvector_t uv;
} uvector_element_t;

typedef struct mdl_uvector_block_t
{
    int size;
    int startoffset; // for GROW from beginning
    int type;
    uvector_element_t *elements;
} mdl_uvector_block_t;

// defined after value
struct mdl_tuple_block_t;

typedef struct mdl_tuple_t
{
    struct mdl_tuple_block_t *p;
    int offset;
} mdl_tuple_t;

union mdl_value_union; // for SORT
typedef union mdl_value_union
    {
        struct atom_t *a;
        cons_pair_t p;
        MDL_INT w;
        MDL_FLOAT fl;
        counted_string_t s;
        mdl_vector_t v;
        mdl_uvector_t uv;
        struct mdl_tuple_t tp;
        struct mdl_frame_t *f;
} mdl_value_union;

typedef struct mdl_value_t
{
    primtype_t pt;
    int type;
    mdl_value_union v;
} mdl_value_t;

// A tuple is simple array with length on the beginning, since it
// can't be subject to GROW
typedef struct mdl_tuple_block_t
{
    int size;
    mdl_value_t elements[1];
} mdl_tuple_block_t;

extern mdl_symbol_table_t global_syms;

//extern mdl_type_table_entry_t mdl_built_in_type_table[];
extern mdl_built_in_table_t built_in_table;
extern mdl_frame_t *cur_frame;
extern mdl_frame_t *initial_frame;
#define cur_process_initial_frame initial_frame // no process support

extern atom_t *atom_lastprog;
extern atom_t *atom_redefine;

extern atom_t *atom_oblist;
extern mdl_value_t *mdl_value_root_oblist;
extern mdl_value_t *mdl_value_initial_oblist;
extern mdl_value_t *mdl_value_oblist;
extern mdl_value_t *mdl_value_atom_redefine;
extern mdl_value_t *mdl_value_atom_lastprog;
extern mdl_value_t *mdl_value_atom_lastmap;
extern mdl_value_t *mdl_value_atom_default;
extern mdl_value_t *mdl_value_T;
extern mdl_value_t mdl_value_false;
extern mdl_value_t mdl_value_unassigned;
extern mdl_value_t *mdl_static_block_stack;


#define LITEM(l, skip) mdl_internal_list_nth(l, skip)
#define LREST(l, skip) mdl_internal_list_rest(l, skip)
#define LHASITEM(l, skip) (LITEM(l,skip) != NULL)

#define VITEM(l, skip) mdl_internal_vector_rest(l, skip)
#define VREST(l, skip) mdl_internal_vector_rest(l, skip)
#define VHASITEM(l, skip) ((((skip) + ((l)->v.v.offset)) >= -((l)->v.v.startoffset)) && (((skip)+((l)->v.v.offset)) < (((l)->v.v.size) - ((l)->v.v.startoffset))))
#define VLENGTH(l) (((l)->v.v.p->size)-((l)->v.v.p->startoffset)-((l)->v.v.offset))

#define UVITEM(l, skip) mdl_internal_uvector_nth(l, skip)
#define UVREST(l, skip) mdl_internal_uvector_rest(l, skip)
#define UVHASITEM(l, skip) ((((skip)+((l)->v.uv.offset)) >= -((l)->v.uv->startoffset)) && (((skip+((l)->v.uv.offset))) < (((l)->v.uv->size) - ((l)->v.uv->startoffset))))
#define UVLENGTH(l) (((l)->v.uv.p->size)-((l)->v.uv.p->startoffset)-((l)->v.uv.offset))
#define UVTYPE(l) ((l)->v.uv.p->type)

#define TPITEM(l, skip) mdl_internal_tuple_rest(l, skip)
#define TPREST(l, skip) mdl_internal_tuple_rest(l, skip)
#define TPLENGTH(l) (((l)->v.tp.p->size) - ((l)->v.tp.offset))
#define TPHASITEM(l, skip) (((skip) >= 0) && (skip < TPLENGTH(l)))

// These values aren't always checked
#define LONGJMP_ERROR  -1
#define LONGJMP_RETURN -2
#define LONGJMP_AGAIN  -3
#define LONGJMP_MAPSTOP  -4
#define LONGJMP_MAPRET  -5
#define LONGJMP_MAPLEAVE  -6
#define LONGJMP_FLATSIZE_EXCEEDED  -7
#define LONGJMP_ERRET -8
#define LONGJMP_RETRY -9
#define LONGJMP_RESTORE -10

// channel slots
// these are the zero-based numbers used internally, not the 1-based
// numbers used by NTH
#define CHANNEL_SLOT_OFFSET 2

#define CHANNEL_SLOT_TRANSCRIPT -2
#define CHANNEL_SLOT_DEVDEP     -1
#define CHANNEL_SLOT_CHNUM       0
#define CHANNEL_SLOT_MODE        1
#define CHANNEL_SLOT_FNARG1      2
#define CHANNEL_SLOT_FNARG2      3
#define CHANNEL_SLOT_DEVNARG     4
#define CHANNEL_SLOT_DIRNARG     5
#define CHANNEL_SLOT_FN1         6
#define CHANNEL_SLOT_FN2         7
#define CHANNEL_SLOT_DEVN        8
#define CHANNEL_SLOT_DIRN        9
#define CHANNEL_SLOT_STATUS     10
#define CHANNEL_SLOT_PDP10      11 // not implemented

// OUTPUT channel slots
#define CHANNEL_SLOT_LINEWIDTH  12
#define CHANNEL_SLOT_CPOS       13
#define CHANNEL_SLOT_PAGEHEIGHT 14
#define CHANNEL_SLOT_LINENO     15
#define CHANNEL_SLOT_PTR        16
#define CHANNEL_SLOT_RADIX      17
#define CHANNEL_SLOT_SINK       18 

// INPUT channel slots
#define CHANNEL_SLOT_EOFOBJ     12
#define CHANNEL_SLOT_LOOKAHEAD  13
#define CHANNEL_SLOT_PDP10I     14 // not implemented
#define CHANNEL_SLOT_BUFFERS    15 // not implemented
//#define CHANNEL_SLOT_PTR        16 (same as output)
//#define CHANNEL_SLOT_RADIX      17 (same as output)
#define CHANNEL_SLOT_IBUFFER    18 // source for internal channel or buffer

#define CHANNEL_NSLOTS (CHANNEL_SLOT_SINK + CHANNEL_SLOT_OFFSET + 1)

#define INTERNAL_BUFSIZE 100

// printflags for printing characters
#define MDL_PF_NONE         0
#define MDL_PF_NOADVANCE    1        // do not advance character/line position
#define MDL_PF_NOSCRIPT     2        // do not print to transcript channels
#define MDL_PF_BINARY       4        // binary channel -- newline == \n\r
enum
{
    ICHANNEL_AT_EOF = 1,
    ICHANNEL_HAS_LOOKAHEAD = 2,
};

typedef struct charinfo_t
{
    mdl_charclass_t charclass;
    bool closebracket;
    bool openbracket;
    bool separator;
} charinfo_t;

typedef enum
{
    SEQTYPE_SINGLE,
    SEQTYPE_LIST,
    SEQTYPE_FORM,
    SEQTYPE_SEGMENT,
    SEQTYPE_VECTOR,
    SEQTYPE_UVECTOR,
} seqtype_t;


#define mdl_primtype_structured(P) (!mdl_primtype_nonstructured(P))
#define mdl_is_false(V) (!mdl_is_true(V))

primtype_t mdl_type_primtype(int typenum);
atom_t *mdl_type_atom(int typenum);
bool mdl_type_is_applicable(int type);
bool mdl_primtype_nonstructured(int pt);
mdl_value_t *mdl_get_evaltype(int typenum);
mdl_value_t *mdl_get_applytype(int typenum);
mdl_value_t *mdl_get_printtype(int typenum);
bool mdl_value_equal(const mdl_value_t *a, const mdl_value_t *b);
size_t mdl_hash_value(const mdl_value_t *a);
bool mdl_value_double_equal(const mdl_value_t *a, const mdl_value_t *b);
bool mdl_value_equal_atom(const mdl_value_t *a, const atom_t *b);
bool mdl_string_equal_cstr(const counted_string_t *s, const char *cs);
mdl_value_t *mdl_global_symbol_lookup(const atom_t *atom);
mdl_value_t *mdl_local_symbol_lookup(atom_t *atom, mdl_frame_t *frame = cur_frame);
mdl_value_t *mdl_local_symbol_lookup_pname(const char *pname, mdl_frame_t *frame);
mdl_value_t *mdl_both_symbol_lookup_pname(const char *pname, mdl_frame_t *frame);
mdl_value_t *mdl_internal_apply(mdl_value_t *applier, mdl_value_t *apply_to, bool called_from_apply_subr);
mdl_value_t *mdl_std_apply(mdl_value_t *applier, mdl_value_t *apply_to, int apply_as, bool called_from_apply_subr);
mdl_value_t *mdl_eval_apply_expr(mdl_value_t *appl_expr);
mdl_value_t *mdl_std_eval(mdl_value_t *l, bool in_struct = false, int as_type = MDL_TYPE_NOTATYPE);
mdl_value_t *mdl_new_mdl_value();
mdl_value_t *mdl_set_lval(atom_t *a, mdl_value_t *val, mdl_frame_t *frame);
mdl_value_t *mdl_set_gval(atom_t *name, mdl_value_t *val);
mdl_value_t *mdl_internal_eval_put(mdl_value_t *arg, mdl_value_t *indexval, mdl_value_t *newitem);
mdl_value_t *mdl_internal_eval_nth(mdl_value_t *arg, mdl_value_t *indexval);
mdl_value_t *mdl_internal_eval_nth_i(mdl_value_t *arg, int index);
mdl_value_t *mdl_internal_eval_nth_copy(mdl_value_t *arg, mdl_value_t *indexval);
mdl_value_t *mdl_internal_list_nth(const mdl_value_t *, int);
mdl_value_t *mdl_internal_list_rest(const mdl_value_t *, int);
mdl_value_t *mdl_internal_vector_nth(const mdl_value_t *, int);
mdl_value_t *mdl_internal_vector_rest(const mdl_value_t *, int);
mdl_value_t *mdl_internal_uvector_nth(const mdl_value_t *, int);
uvector_element_t *mdl_internal_uvector_rest(const mdl_value_t *, int);
mdl_value_t *mdl_internal_tuple_rest(const mdl_value_t *, int);
// vectors and tuples do not have an internal nth, because
// it would be the same as rest, a pointer to the given item
mdl_value_t *mdl_uvector_element_to_value(const mdl_value_t *uv, const uvector_element_t *elem, mdl_value_t *to = NULL);
uvector_element_t *mdl_uvector_value_to_element(const mdl_value_t *newval, uvector_element_t *elem);
mdl_value_t *mdl_internal_eval_rest(mdl_value_t *arg, mdl_value_t index);
mdl_value_t *mdl_internal_eval_rest_i(mdl_value_t *arg, int index);
bool mdl_valid_uvector_primtype(int pt);
int mdl_eval_type(int t);
int mdl_apply_type(int t);
int mdl_print_type(int t);
mdl_value_t *mdl_get_atom_default_oblist(const char *pname, bool insert_allowed, mdl_value_t *oblists);
mdl_value_t *mdl_get_atom_from_oblist(const char *pname, mdl_value_t *oblist);
mdl_value_t *mdl_create_atom_on_oblist(const char *pname, mdl_value_t *oblist);
mdl_value_t *mdl_get_or_create_atom_on_oblist(const char *pname, mdl_value_t *oblist);
atom_t *mdl_get_oblist_name(mdl_value_t *oblist);
mdl_value_t *mdl_internal_eval_putprop(mdl_value_t *item, mdl_value_t *indicator, mdl_value_t *val);
mdl_value_t *mdl_internal_eval_getprop(mdl_value_t *item, mdl_value_t *indicator);
mdl_value_t *mdl_new_empty_vector(int size, int type);
mdl_value_t *mdl_new_empty_uvector(int size, int type);
char *mdl_new_raw_string(int len, bool immutable);
MDL_INT mdl_string_length(mdl_value_t *v);
bool mdl_string_immutable(mdl_value_t *v);
mdl_value_t *mdl_cons_internal(mdl_value_t *a, mdl_value_t *b);
FILE *mdl_get_chan_file(mdl_value_t *chan);
void mdl_set_chan_mode(mdl_value_t *chan, const char *mode);
FILE *mdl_get_channum_file(int channum);
int mdl_get_chan_channum(mdl_value_t *chan);
mdl_value_t *mdl_read_object_seq(mdl_value_t *chan, seqtype_t st);
mdl_value_t *mdl_internal_create_channel(void);
mdl_value_t *mdl_internal_open_channel(mdl_value_t *chan);
mdl_value_t *mdl_internal_reopen_channel(mdl_value_t *chan);
mdl_value_t *mdl_internal_reset_channel(mdl_value_t *chan);
mdl_value_t *mdl_internal_close_channel(mdl_value_t *chan);
mdl_value_t *mdl_get_chan_mode(mdl_value_t *chan);
mdl_value_t *mdl_create_default_inchan();
bool mdl_inchan_is_reasonable(mdl_value_t *chan);
mdl_value_t *mdl_create_default_outchan();
bool mdl_outchan_is_reasonable(mdl_value_t *chan);
mdl_value_t *mdl_set_chan_eof_object(mdl_value_t *chan, mdl_value_t *obj);
void mdl_set_chan_lookahead(mdl_value_t *chan, MDL_INT ch);
void mdl_set_chan_input_source(mdl_value_t *chan, mdl_value_t *source);
int mdl_new_chan_num(FILE *f);
MDL_INT mdl_clear_chan_flags(mdl_value_t *chan, MDL_INT flags);
mdl_value_t *mdl_read_character(mdl_value_t *chan);
mdl_value_t *mdl_next_character(mdl_value_t *chan);
mdl_value_t *mdl_read_binary(mdl_value_t *chan, mdl_value_t *buffer);
mdl_value_t *mdl_read_string(mdl_value_t *chan, mdl_value_t *buffer, mdl_value_t *stop);
mdl_value_t *mdl_load_file_from_chan(mdl_value_t *chan);
int mdl_get_chan_radix(mdl_value_t *chan);
bool mdl_chan_mode_is_print_binary(mdl_value_t *chan);
bool mdl_chan_mode_is_read_binary(mdl_value_t *chan);
bool mdl_chan_mode_is_input(mdl_value_t *chan);
bool mdl_chan_mode_is_output(mdl_value_t *chan);
mdl_charclass_t mdl_get_charclass(MDL_INT ch);
void mdl_get_charinfo(MDL_INT ch, charinfo_t *info);
mdl_value_t *mdl_new_string(int, const char *);
mdl_value_t *mdl_new_string(int);
void mdl_print_value_to_chan(mdl_value_t *chan, mdl_value_t *v, bool princ, 
                             bool prespace, mdl_value_t *oblists);
void mdl_print_newline_to_chan(mdl_value_t *chan, int printflags, FILE *f);
void mdl_print_char_to_chan(mdl_value_t *chan, int ch, int printflags, FILE *f);
void mdl_print_char_to_transcript_channels(mdl_value_t *chan, int ch, int printflags);
mdl_value_t *mdl_create_internal_output_channel(int bufsize, int maxlen, mdl_value_t *frame);
mdl_value_t *mdl_get_internal_output_channel_string(mdl_value_t *chan);
MDL_INT mdl_get_internal_output_channel_length(mdl_value_t *chan);
void mdl_print_binary(mdl_value_t *chan, mdl_value_t *buffer);
void mdl_print_string_to_chan(mdl_value_t *chan,
                              const char *str,
                              int len,
                              int extralen, // space to reserve, not including the addspacebefore value
                              bool canbreakbefore,
                              bool addspacebefore // add a space if no break
                              );

void mdl_internal_erret(mdl_value_t *result, mdl_value_t *frame)  __attribute__((noreturn));
void mdl_longjmp_to(mdl_frame_t *frame, int value) __attribute__((noreturn));

void mdl_write_image(FILE *f, mdl_value_t *save_arg);
bool mdl_read_image(FILE *f);
mdl_value_t *mdl_call_error(const char *errstr, ...) __attribute__((sentinel));
mdl_value_t *mdl_call_error_ext(const char *errstr, const char *reason, ...) __attribute__((sentinel));
mdl_value_t *mdl_boolean_value(bool v);
bool mdl_is_true(mdl_value_t *item);
bool mdl_internal_struct_is_empty(mdl_value_t *arg);
mdl_value_t *mdl_check_decl(mdl_value_t *val, mdl_value_t *decl, bool *error);
