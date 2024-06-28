#include <string.h>
#include "mdl_builtin_macro.hpp"
#include "mdl_builtins.h"
#include "mdl_internal_defs.h"
void mdl_create_builtins()
{
    MDL_BUILTIN(QUOTE, quote, FSUBR, mdl_builtin_eval_quote);
    MDL_BUILTIN(LVAL, lval, SUBR, mdl_builtin_eval_lval);
    MDL_BUILTIN(GVAL, gval, SUBR, mdl_builtin_eval_gval);
    MDL_BUILTIN(VALUE, value, SUBR, mdl_builtin_eval_value);
    MDL_BUILTIN(BOUND?, bound, SUBR, mdl_builtin_eval_bound);
    MDL_BUILTIN(ASSIGNED?, assigned, SUBR, mdl_builtin_eval_assigned);
    MDL_BUILTIN(GBOUND?, gbound, SUBR, mdl_builtin_eval_gbound);
    MDL_BUILTIN(GASSIGNED?, gassigned, SUBR, mdl_builtin_eval_gassigned);
    MDL_BUILTIN(GUNASSIGN, gunassign, SUBR, mdl_builtin_eval_gunassign);
    MDL_BUILTIN(SETG, setg, SUBR, mdl_builtin_eval_setg);
    MDL_BUILTIN(SET, set, SUBR, mdl_builtin_eval_set);
    MDL_BUILTIN(COND, cond, FSUBR, mdl_builtin_eval_cond);
    MDL_BUILTIN(TYPE, type, SUBR, mdl_builtin_eval_type);
    MDL_BUILTIN(PRIMTYPE, primtype, SUBR, mdl_builtin_eval_primtype);
    MDL_BUILTIN(TYPEPRIM, typeprim, SUBR, mdl_builtin_eval_typeprim);
    MDL_BUILTIN(CHTYPE, chtype, SUBR, mdl_builtin_eval_chtype);
    MDL_BUILTIN(ALLTYPES, alltypes, SUBR, mdl_builtin_eval_alltypes);
    MDL_BUILTIN(VALID-TYPE?, valid_typep, SUBR, mdl_builtin_eval_valid_typep);
    MDL_BUILTIN(NEWTYPE, newtype, SUBR, mdl_builtin_eval_newtype);
    MDL_BUILTIN(EVALTYPE, evaltype, SUBR, mdl_builtin_eval_evaltype);
    MDL_BUILTIN(APPLYTYPE, applytype, SUBR, mdl_builtin_eval_applytype);
    MDL_BUILTIN(PRINTTYPE, printtype, SUBR, mdl_builtin_eval_printtype);
    MDL_BUILTIN(LENGTH, length, SUBR, mdl_builtin_eval_length);
    MDL_BUILTIN(NTH, nth, SUBR, mdl_builtin_eval_nth);
    MDL_BUILTIN(REST, rest, SUBR, mdl_builtin_eval_rest);
    MDL_BUILTIN(PUT, put, SUBR, mdl_builtin_eval_put);
    MDL_BUILTIN(GET, get, SUBR, mdl_builtin_eval_get);
    MDL_BUILTIN(SUBSTRUC, substruc, SUBR, mdl_builtin_eval_substruc);
    MDL_BUILTIN(LIST, list, SUBR, mdl_builtin_eval_list);
    MDL_BUILTIN(FORM, form, SUBR, mdl_builtin_eval_form);
    MDL_BUILTIN(VECTOR, vector, SUBR, mdl_builtin_eval_vector);
    MDL_BUILTIN(TUPLE, tuple, SUBR, mdl_builtin_eval_tuple);
    MDL_BUILTIN(UVECTOR, uvector, SUBR, mdl_builtin_eval_uvector);
    MDL_BUILTIN(FUNCTION, function, FSUBR, mdl_builtin_eval_function);
    MDL_BUILTIN(STRING, string, SUBR, mdl_builtin_eval_string);
    MDL_BUILTIN(ILIST, ilist, SUBR, mdl_builtin_eval_ilist);
    MDL_BUILTIN(IFORM, iform, SUBR, mdl_builtin_eval_iform);
    MDL_BUILTIN(IVECTOR, ivector, SUBR, mdl_builtin_eval_ivector);
    MDL_BUILTIN(IUVECTOR, iuvector, SUBR, mdl_builtin_eval_iuvector);
    MDL_BUILTIN(ISTRING, istring, SUBR, mdl_builtin_eval_istring);
    MDL_BUILTIN(PUTREST, putrest, SUBR, mdl_builtin_eval_putrest);
    MDL_BUILTIN(CONS, cons, SUBR, mdl_builtin_eval_cons);
    MDL_BUILTIN(BACK, back, SUBR, mdl_builtin_eval_back);
    MDL_BUILTIN(TOP, top, SUBR, mdl_builtin_eval_top);
    MDL_BUILTIN(SORT, sort, SUBR, mdl_builtin_eval_sort);
    MDL_BUILTIN(UTYPE, utype, SUBR, mdl_builtin_eval_utype);
    MDL_BUILTIN(CHUTYPE, chutype, SUBR, mdl_builtin_eval_chutype);
    MDL_BUILTIN(ASCII, ascii, SUBR, mdl_builtin_eval_ascii);
    MDL_BUILTIN(PARSE, parse, SUBR, mdl_builtin_eval_parse);
    MDL_BUILTIN(UNPARSE, unparse, SUBR, mdl_builtin_eval_unparse);
    MDL_BUILTIN(DEFINE, define, FSUBR, mdl_builtin_eval_define);
    MDL_BUILTIN(DEFMAC, defmac, FSUBR, mdl_builtin_eval_defmac);
    MDL_BUILTIN(EXPAND, expand, SUBR, mdl_builtin_eval_expand);
    MDL_BUILTIN(EVAL, eval, SUBR, mdl_builtin_eval_eval);
    MDL_BUILTIN(APPLY, apply, SUBR, mdl_builtin_eval_apply);
    MDL_BUILTIN(BIND, bind, FSUBR, mdl_builtin_eval_bind);
    MDL_BUILTIN(REPEAT, repeat, FSUBR, mdl_builtin_eval_repeat);
    MDL_BUILTIN(AGAIN, again, SUBR, mdl_builtin_eval_again);
    MDL_BUILTIN(RETURN, return, SUBR, mdl_builtin_eval_return);
    MDL_BUILTIN(PROG, prog, FSUBR, mdl_builtin_eval_prog);
    MDL_BUILTIN(MAPF, mapf, SUBR, mdl_builtin_eval_mapf);
    MDL_BUILTIN(MAPR, mapr, SUBR, mdl_builtin_eval_mapr);
    MDL_BUILTIN(MAPRET, mapret, SUBR, mdl_builtin_eval_mapret);
    MDL_BUILTIN(MAPSTOP, mapstop, SUBR, mdl_builtin_eval_mapstop);
    MDL_BUILTIN(MAPLEAVE, mapleave, SUBR, mdl_builtin_eval_mapleave);
    MDL_BUILTIN(0?, zerop, SUBR, mdl_builtin_eval_zerop);
    MDL_BUILTIN(1?, onep, SUBR, mdl_builtin_eval_onep);
    MDL_BUILTIN(G?, greaterp, SUBR, mdl_builtin_eval_greaterp);
    MDL_BUILTIN(L?, lessp, SUBR, mdl_builtin_eval_lessp);
    MDL_BUILTIN(G=?, greaterequalp, SUBR, mdl_builtin_eval_greaterequalp);
    MDL_BUILTIN(L=?, lessequalp, SUBR, mdl_builtin_eval_lessequalp);
    MDL_BUILTIN(==?, double_equalp, SUBR, mdl_builtin_eval_double_equalp);
    MDL_BUILTIN(N==?, double_nequalp, SUBR, mdl_builtin_eval_double_nequalp);
    MDL_BUILTIN(=?, equalp, SUBR, mdl_builtin_eval_equalp);
    MDL_BUILTIN(N=?, nequalp, SUBR, mdl_builtin_eval_nequalp);
    MDL_BUILTIN(MEMBER, member, SUBR, mdl_builtin_eval_member);
    MDL_BUILTIN(MEMQ, memq, SUBR, mdl_builtin_eval_memq);
    MDL_BUILTIN(STRCOMP, strcomp, SUBR, mdl_builtin_eval_strcomp);
    MDL_BUILTIN(*, multiply, SUBR, mdl_builtin_eval_multiply);
    MDL_BUILTIN(+, add, SUBR, mdl_builtin_eval_add);
    MDL_BUILTIN(-, subtract, SUBR, mdl_builtin_eval_subtract);
    MDL_BUILTIN(/, divide, SUBR, mdl_builtin_eval_divide);
    MDL_BUILTIN(MIN, min, SUBR, mdl_builtin_eval_min);
    MDL_BUILTIN(MAX, max, SUBR, mdl_builtin_eval_max);
    MDL_BUILTIN(MOD, mod, SUBR, mdl_builtin_eval_mod);
    MDL_BUILTIN(RANDOM, random, SUBR, mdl_builtin_eval_random);
    MDL_BUILTIN(FLOAT, float, SUBR, mdl_builtin_eval_float);
    MDL_BUILTIN(FIX, fix, SUBR, mdl_builtin_eval_fix);
    MDL_BUILTIN(ABS, abs, SUBR, mdl_builtin_eval_abs);
    MDL_BUILTIN(GETPROP, getprop, SUBR, mdl_builtin_eval_getprop);
    MDL_BUILTIN(PUTPROP, putprop, SUBR, mdl_builtin_eval_putprop);
    MDL_BUILTIN(MOBLIST, moblist, SUBR, mdl_builtin_eval_moblist);
    MDL_BUILTIN(OBLIST?, oblistp, SUBR, mdl_builtin_eval_oblistp);
    MDL_BUILTIN(LOOKUP, lookup, SUBR, mdl_builtin_eval_lookup);
    MDL_BUILTIN(ATOM, atom, SUBR, mdl_builtin_eval_atom);
    MDL_BUILTIN(REMOVE, remove, SUBR, mdl_builtin_eval_remove);
    MDL_BUILTIN(INSERT, insert, SUBR, mdl_builtin_eval_insert);
    MDL_BUILTIN(PNAME, pname, SUBR, mdl_builtin_eval_pname);
    MDL_BUILTIN(SPNAME, spname, SUBR, mdl_builtin_eval_spname);
    MDL_BUILTIN(ROOT, root, SUBR, mdl_builtin_eval_root);
    MDL_BUILTIN(BLOCK, block, SUBR, mdl_builtin_eval_block);
    MDL_BUILTIN(ENDBLOCK, endblock, SUBR, mdl_builtin_eval_endblock);
    MDL_BUILTIN(NOT, not, SUBR, mdl_builtin_eval_not);
    MDL_BUILTIN(AND, and, FSUBR, mdl_builtin_eval_and);
    MDL_BUILTIN(AND?, andp, SUBR, mdl_builtin_eval_andp);
    MDL_BUILTIN(OR, or, FSUBR, mdl_builtin_eval_or);
    MDL_BUILTIN(OR?, orp, SUBR, mdl_builtin_eval_orp);
    MDL_BUILTIN(TYPE?, typep, SUBR, mdl_builtin_eval_typep);
    MDL_BUILTIN(APPLICABLE?, applicablep, SUBR, mdl_builtin_eval_applicablep);
    MDL_BUILTIN(MONAD?, monadp, SUBR, mdl_builtin_eval_monadp);
    MDL_BUILTIN(STRUCTURED?, structuredp, SUBR, mdl_builtin_eval_structuredp);
    MDL_BUILTIN(EMPTY?, emptyp, SUBR, mdl_builtin_eval_emptyp);
    MDL_BUILTIN(LENGTH?, lengthp, SUBR, mdl_builtin_eval_lengthp);
    MDL_BUILTIN(CHANNEL, channel, SUBR, mdl_builtin_eval_channel);
    MDL_BUILTIN(OPEN, open, SUBR, mdl_builtin_eval_open);
    MDL_BUILTIN(FILE-EXISTS?, file_existsp, SUBR, mdl_builtin_eval_file_existsp);
    MDL_BUILTIN(CLOSE, close, SUBR, mdl_builtin_eval_close);
    MDL_BUILTIN(RESET, reset, SUBR, mdl_builtin_eval_reset);
    MDL_BUILTIN(ACCESS, access, SUBR, mdl_builtin_eval_access);
    MDL_BUILTIN(READ, read, SUBR, mdl_builtin_eval_read);
    MDL_BUILTIN(READCHR, readchr, SUBR, mdl_builtin_eval_readchr);
    MDL_BUILTIN(NEXTCHR, nextchr, SUBR, mdl_builtin_eval_nextchr);
    MDL_BUILTIN(PRINT, print, SUBR, mdl_builtin_eval_print);
    MDL_BUILTIN(PRIN1, prin1, SUBR, mdl_builtin_eval_prin1);
    MDL_BUILTIN(PRINC, princ, SUBR, mdl_builtin_eval_princ);
    MDL_BUILTIN(TERPRI, terpri, SUBR, mdl_builtin_eval_terpri);
    MDL_BUILTIN(FLATSIZE, flatsize, SUBR, mdl_builtin_eval_flatsize);
    MDL_BUILTIN(CRLF, crlf, SUBR, mdl_builtin_eval_crlf);
    MDL_BUILTIN(READB, readb, SUBR, mdl_builtin_eval_readb);
    MDL_BUILTIN(READSTRING, readstring, SUBR, mdl_builtin_eval_readstring);
    MDL_BUILTIN(PRINTB, printb, SUBR, mdl_builtin_eval_printb);
    MDL_BUILTIN(PRINTSTRING, printstring, SUBR, mdl_builtin_eval_printstring);
    MDL_BUILTIN(IMAGE, image, SUBR, mdl_builtin_eval_image);
    MDL_BUILTIN(LOAD, load, SUBR, mdl_builtin_eval_load);
    MDL_BUILTIN(FLOAD, fload, SUBR, mdl_builtin_eval_fload);
    MDL_BUILTIN(SNAME, sname, SUBR, mdl_builtin_eval_sname);
    MDL_BUILTIN(SAVE, save, SUBR, mdl_builtin_eval_save);
    MDL_BUILTIN(SAVE-EVAL, save_eval, SUBR, mdl_builtin_eval_save_eval);
    MDL_BUILTIN(RESTORE, restore, SUBR, mdl_builtin_eval_restore);
    MDL_BUILTIN(FILE-LENGTH, file_length, SUBR, mdl_builtin_eval_file_length);
    MDL_BUILTIN(DECL?, declp, SUBR, mdl_builtin_eval_declp);
    MDL_BUILTIN(LISTEN, listen, SUBR, mdl_builtin_eval_listen);
    MDL_BUILTIN(ERROR, error, SUBR, mdl_builtin_eval_error);
    MDL_BUILTIN(ERRET, erret, SUBR, mdl_builtin_eval_erret);
    MDL_BUILTIN(RETRY, retry, SUBR, mdl_builtin_eval_retry);
    MDL_BUILTIN(UNWIND, unwind, FSUBR, mdl_builtin_eval_unwind);
    MDL_BUILTIN(FUNCT, funct, SUBR, mdl_builtin_eval_funct);
    MDL_BUILTIN(ARGS, args, SUBR, mdl_builtin_eval_args);
    MDL_BUILTIN(FRAME, frame, SUBR, mdl_builtin_eval_frame);
    MDL_BUILTIN(FFRAME, fframe, SUBR, mdl_builtin_eval_fframe);
    MDL_BUILTIN(TFFRAME, tfframe, SUBR, mdl_builtin_eval_tfframe);
    MDL_BUILTIN(REP, rep, SUBR, mdl_builtin_eval_rep);
    MDL_BUILTIN(BITS, bits, SUBR, mdl_builtin_eval_bits);
    MDL_BUILTIN(GETBITS, getbits, SUBR, mdl_builtin_eval_getbits);
    MDL_BUILTIN(PUTBITS, putbits, SUBR, mdl_builtin_eval_putbits);
    MDL_BUILTIN(ANDB, andb, SUBR, mdl_builtin_eval_andb);
    MDL_BUILTIN(ORB, orb, SUBR, mdl_builtin_eval_orb);
    MDL_BUILTIN(XORB, xorb, SUBR, mdl_builtin_eval_xorb);
    MDL_BUILTIN(EQVB, eqvb, SUBR, mdl_builtin_eval_eqvb);
    MDL_BUILTIN(LSH, lsh, SUBR, mdl_builtin_eval_lsh);
    MDL_BUILTIN(GC, gc, SUBR, mdl_builtin_eval_gc);
    MDL_BUILTIN(TIME, time, SUBR, mdl_builtin_eval_time);
    MDL_BUILTIN(LOGOUT, logout, SUBR, mdl_builtin_eval_logout);
    MDL_BUILTIN(QUIT, quit, SUBR, mdl_builtin_eval_quit);
    MDL_BUILTIN(GETTIMEOFDAY, gettimeofday, SUBR, mdl_builtin_eval_gettimeofday);
    MDL_BUILTIN(GETTIMEDATE, gettimedate, SUBR, mdl_builtin_eval_gettimedate);
    MDL_BUILTIN(GDECL, gdecl, FSUBR, mdl_builtin_eval_gdecl);
    MDL_BUILTIN(MANIFEST, manifest, SUBR, mdl_builtin_eval_manifest);
    MDL_BUILTIN(FREEZE, freeze, SUBR, mdl_builtin_eval_freeze);
    MDL_BUILTIN(BLOAT, bloat, SUBR, mdl_builtin_eval_bloat);
    MDL_BUILTIN(OFF, off, SUBR, mdl_builtin_eval_off);
    MDL_BUILTIN(EVENT, event, SUBR, mdl_builtin_eval_event);
    MDL_BUILTIN(HANDLER, handler, SUBR, mdl_builtin_eval_handler);
    MDL_BUILTIN(ON, on, SUBR, mdl_builtin_eval_on);
    MDL_BUILTIN(ENABLE, enable, SUBR, mdl_builtin_eval_enable);
    MDL_BUILTIN(DISABLE, disable, SUBR, mdl_builtin_eval_disable);
    MDL_BUILTIN(INT-LEVEL, int_level, SUBR, mdl_builtin_eval_int_level);
    MDL_BUILTIN(SLEEP, sleep, SUBR, mdl_builtin_eval_sleep);
    MDL_BUILTIN(WARRANTY, warranty, SUBR, mdl_builtin_eval_warranty);
    MDL_BUILTIN(COPYING, copying, SUBR, mdl_builtin_eval_copying);
}
mdl_value_t *mdl_value_builtin_quote;
mdl_value_t *mdl_value_builtin_lval;
mdl_value_t *mdl_value_builtin_gval;
mdl_value_t *mdl_value_builtin_value;
mdl_value_t *mdl_value_builtin_bound;
mdl_value_t *mdl_value_builtin_assigned;
mdl_value_t *mdl_value_builtin_gbound;
mdl_value_t *mdl_value_builtin_gassigned;
mdl_value_t *mdl_value_builtin_gunassign;
mdl_value_t *mdl_value_builtin_setg;
mdl_value_t *mdl_value_builtin_set;
mdl_value_t *mdl_value_builtin_cond;
mdl_value_t *mdl_value_builtin_type;
mdl_value_t *mdl_value_builtin_primtype;
mdl_value_t *mdl_value_builtin_typeprim;
mdl_value_t *mdl_value_builtin_chtype;
mdl_value_t *mdl_value_builtin_alltypes;
mdl_value_t *mdl_value_builtin_valid_typep;
mdl_value_t *mdl_value_builtin_newtype;
mdl_value_t *mdl_value_builtin_evaltype;
mdl_value_t *mdl_value_builtin_applytype;
mdl_value_t *mdl_value_builtin_printtype;
mdl_value_t *mdl_value_builtin_length;
mdl_value_t *mdl_value_builtin_nth;
mdl_value_t *mdl_value_builtin_rest;
mdl_value_t *mdl_value_builtin_put;
mdl_value_t *mdl_value_builtin_get;
mdl_value_t *mdl_value_builtin_substruc;
mdl_value_t *mdl_value_builtin_list;
mdl_value_t *mdl_value_builtin_form;
mdl_value_t *mdl_value_builtin_vector;
mdl_value_t *mdl_value_builtin_tuple;
mdl_value_t *mdl_value_builtin_uvector;
mdl_value_t *mdl_value_builtin_function;
mdl_value_t *mdl_value_builtin_string;
mdl_value_t *mdl_value_builtin_ilist;
mdl_value_t *mdl_value_builtin_iform;
mdl_value_t *mdl_value_builtin_ivector;
mdl_value_t *mdl_value_builtin_iuvector;
mdl_value_t *mdl_value_builtin_istring;
mdl_value_t *mdl_value_builtin_putrest;
mdl_value_t *mdl_value_builtin_cons;
mdl_value_t *mdl_value_builtin_back;
mdl_value_t *mdl_value_builtin_top;
mdl_value_t *mdl_value_builtin_sort;
mdl_value_t *mdl_value_builtin_utype;
mdl_value_t *mdl_value_builtin_chutype;
mdl_value_t *mdl_value_builtin_ascii;
mdl_value_t *mdl_value_builtin_parse;
mdl_value_t *mdl_value_builtin_unparse;
mdl_value_t *mdl_value_builtin_define;
mdl_value_t *mdl_value_builtin_defmac;
mdl_value_t *mdl_value_builtin_expand;
mdl_value_t *mdl_value_builtin_eval;
mdl_value_t *mdl_value_builtin_apply;
mdl_value_t *mdl_value_builtin_bind;
mdl_value_t *mdl_value_builtin_repeat;
mdl_value_t *mdl_value_builtin_again;
mdl_value_t *mdl_value_builtin_return;
mdl_value_t *mdl_value_builtin_prog;
mdl_value_t *mdl_value_builtin_mapf;
mdl_value_t *mdl_value_builtin_mapr;
mdl_value_t *mdl_value_builtin_mapret;
mdl_value_t *mdl_value_builtin_mapstop;
mdl_value_t *mdl_value_builtin_mapleave;
mdl_value_t *mdl_value_builtin_zerop;
mdl_value_t *mdl_value_builtin_onep;
mdl_value_t *mdl_value_builtin_greaterp;
mdl_value_t *mdl_value_builtin_lessp;
mdl_value_t *mdl_value_builtin_greaterequalp;
mdl_value_t *mdl_value_builtin_lessequalp;
mdl_value_t *mdl_value_builtin_double_equalp;
mdl_value_t *mdl_value_builtin_double_nequalp;
mdl_value_t *mdl_value_builtin_equalp;
mdl_value_t *mdl_value_builtin_nequalp;
mdl_value_t *mdl_value_builtin_member;
mdl_value_t *mdl_value_builtin_memq;
mdl_value_t *mdl_value_builtin_strcomp;
mdl_value_t *mdl_value_builtin_multiply;
mdl_value_t *mdl_value_builtin_add;
mdl_value_t *mdl_value_builtin_subtract;
mdl_value_t *mdl_value_builtin_divide;
mdl_value_t *mdl_value_builtin_min;
mdl_value_t *mdl_value_builtin_max;
mdl_value_t *mdl_value_builtin_mod;
mdl_value_t *mdl_value_builtin_random;
mdl_value_t *mdl_value_builtin_float;
mdl_value_t *mdl_value_builtin_fix;
mdl_value_t *mdl_value_builtin_abs;
mdl_value_t *mdl_value_builtin_getprop;
mdl_value_t *mdl_value_builtin_putprop;
mdl_value_t *mdl_value_builtin_moblist;
mdl_value_t *mdl_value_builtin_oblistp;
mdl_value_t *mdl_value_builtin_lookup;
mdl_value_t *mdl_value_builtin_atom;
mdl_value_t *mdl_value_builtin_remove;
mdl_value_t *mdl_value_builtin_insert;
mdl_value_t *mdl_value_builtin_pname;
mdl_value_t *mdl_value_builtin_spname;
mdl_value_t *mdl_value_builtin_root;
mdl_value_t *mdl_value_builtin_block;
mdl_value_t *mdl_value_builtin_endblock;
mdl_value_t *mdl_value_builtin_not;
mdl_value_t *mdl_value_builtin_and;
mdl_value_t *mdl_value_builtin_andp;
mdl_value_t *mdl_value_builtin_or;
mdl_value_t *mdl_value_builtin_orp;
mdl_value_t *mdl_value_builtin_typep;
mdl_value_t *mdl_value_builtin_applicablep;
mdl_value_t *mdl_value_builtin_monadp;
mdl_value_t *mdl_value_builtin_structuredp;
mdl_value_t *mdl_value_builtin_emptyp;
mdl_value_t *mdl_value_builtin_lengthp;
mdl_value_t *mdl_value_builtin_channel;
mdl_value_t *mdl_value_builtin_open;
mdl_value_t *mdl_value_builtin_file_existsp;
mdl_value_t *mdl_value_builtin_close;
mdl_value_t *mdl_value_builtin_reset;
mdl_value_t *mdl_value_builtin_access;
mdl_value_t *mdl_value_builtin_read;
mdl_value_t *mdl_value_builtin_readchr;
mdl_value_t *mdl_value_builtin_nextchr;
mdl_value_t *mdl_value_builtin_print;
mdl_value_t *mdl_value_builtin_prin1;
mdl_value_t *mdl_value_builtin_princ;
mdl_value_t *mdl_value_builtin_terpri;
mdl_value_t *mdl_value_builtin_flatsize;
mdl_value_t *mdl_value_builtin_crlf;
mdl_value_t *mdl_value_builtin_readb;
mdl_value_t *mdl_value_builtin_readstring;
mdl_value_t *mdl_value_builtin_printb;
mdl_value_t *mdl_value_builtin_printstring;
mdl_value_t *mdl_value_builtin_image;
mdl_value_t *mdl_value_builtin_load;
mdl_value_t *mdl_value_builtin_fload;
mdl_value_t *mdl_value_builtin_sname;
mdl_value_t *mdl_value_builtin_save;
mdl_value_t *mdl_value_builtin_save_eval;
mdl_value_t *mdl_value_builtin_restore;
mdl_value_t *mdl_value_builtin_file_length;
mdl_value_t *mdl_value_builtin_declp;
mdl_value_t *mdl_value_builtin_listen;
mdl_value_t *mdl_value_builtin_error;
mdl_value_t *mdl_value_builtin_erret;
mdl_value_t *mdl_value_builtin_retry;
mdl_value_t *mdl_value_builtin_unwind;
mdl_value_t *mdl_value_builtin_funct;
mdl_value_t *mdl_value_builtin_args;
mdl_value_t *mdl_value_builtin_frame;
mdl_value_t *mdl_value_builtin_fframe;
mdl_value_t *mdl_value_builtin_tfframe;
mdl_value_t *mdl_value_builtin_rep;
mdl_value_t *mdl_value_builtin_bits;
mdl_value_t *mdl_value_builtin_getbits;
mdl_value_t *mdl_value_builtin_putbits;
mdl_value_t *mdl_value_builtin_andb;
mdl_value_t *mdl_value_builtin_orb;
mdl_value_t *mdl_value_builtin_xorb;
mdl_value_t *mdl_value_builtin_eqvb;
mdl_value_t *mdl_value_builtin_lsh;
mdl_value_t *mdl_value_builtin_gc;
mdl_value_t *mdl_value_builtin_time;
mdl_value_t *mdl_value_builtin_logout;
mdl_value_t *mdl_value_builtin_quit;
mdl_value_t *mdl_value_builtin_gettimeofday;
mdl_value_t *mdl_value_builtin_gettimedate;
mdl_value_t *mdl_value_builtin_gdecl;
mdl_value_t *mdl_value_builtin_manifest;
mdl_value_t *mdl_value_builtin_freeze;
mdl_value_t *mdl_value_builtin_bloat;
mdl_value_t *mdl_value_builtin_off;
mdl_value_t *mdl_value_builtin_event;
mdl_value_t *mdl_value_builtin_handler;
mdl_value_t *mdl_value_builtin_on;
mdl_value_t *mdl_value_builtin_enable;
mdl_value_t *mdl_value_builtin_disable;
mdl_value_t *mdl_value_builtin_int_level;
mdl_value_t *mdl_value_builtin_sleep;
mdl_value_t *mdl_value_builtin_warranty;
mdl_value_t *mdl_value_builtin_copying;