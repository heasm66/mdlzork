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
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <math.h>
#include "macros.hpp"
#include "mdl_internal_defs.h"
#include "mdl_builtin_types.h"
#include "mdl_builtins.h"
#include "mdl_assoc.hpp"
#include "mdl_strbuf.h"
#include <unistd.h>
#include <time.h>

#define DECODE_TENEX_FILESPECS

mdl_built_in_table_t built_in_table;
mdl_type_table_t mdl_type_table;
mdl_symbol_table_t global_syms;

mdl_frame_t *cur_frame = NULL;
mdl_frame_t *initial_frame = NULL;
int cur_process_bindid;
bool suppress_listen_message;

mdl_assoc_table_t *mdl_assoc_table;
GC_word last_assoc_clean;

// misc atoms

atom_t *atom_oblist;
mdl_value_t *mdl_value_oblist;
mdl_value_t *mdl_value_initial_oblist;
mdl_value_t *mdl_value_root_oblist;
mdl_value_t *mdl_value_atom_redefine;
mdl_value_t *mdl_value_atom_lastprog;
mdl_value_t *mdl_value_atom_lastmap;
mdl_value_t *mdl_value_atom_default;
mdl_value_t *mdl_value_T;
mdl_value_t mdl_value_false = { PRIMTYPE_LIST, MDL_TYPE_FALSE};
mdl_value_t mdl_value_unassigned = { PRIMTYPE_WORD, MDL_TYPE_UNBOUND};
mdl_value_t *mdl_static_block_stack = NULL;

#define MDL_OBLIST_HASHBUCKET_DEFAULT 17
#define MDL_ROOT_OBLIST_HASHBUCKET_DEFAULT 103

#define NEW_BINDID(X) ((++(X))?(X):(++(X))) // increment bindid, but disallow 0

mdl_type_table_entry_t *mdl_type_table_entry(int typenum)
{
    if (typenum >= (int)mdl_type_table.size()) return NULL;
    return &mdl_type_table[typenum];
}

atom_t *mdl_type_atom(int typenum)
{
    const mdl_type_table_entry_t *tte = mdl_type_table_entry(typenum);
    if (tte) return tte->a;
    return NULL;
}

int mdl_get_typenum(mdl_value_t *val)
{
    if (val->type != MDL_TYPE_ATOM)
        mdl_error("Only atoms can be types");
    return val->v.a->typenum;
}

atom_t *mdl_get_type_name(int typenum)
{
    const mdl_type_table_entry_t *tte = mdl_type_table_entry(typenum);
    
    if (tte)
        return tte->a;
    else
        mdl_error("Get_type_name passed invalid type");
}

primtype_t mdl_type_primtype(int typenum)
{
    const mdl_type_table_entry_t *tte = mdl_type_table_entry(typenum);
    if (tte) return tte->pt;
    return (primtype_t)MDL_TYPE_NOTATYPE;
}

mdl_value_t *mdl_internal_newtype(mdl_value_t *a, int oldtype)
{
    mdl_type_table_entry_t newt;
    memset(&newt, 0, sizeof(newt));
    if (a->type != MDL_TYPE_ATOM)
        mdl_error("Only atoms can be (new) types");
    newt.pt = mdl_type_primtype(oldtype);
    newt.a = a->v.a;
    newt.a->typenum = mdl_type_table.size();
    mdl_type_table.push_back(newt);
    return a;
}

mdl_value_t *mdl_get_printtype(int typenum)
{
    const mdl_type_table_entry_t *tte = mdl_type_table_entry(typenum);
    if (tte) return tte->printtype;
    return NULL;
}

mdl_value_t *mdl_get_evaltype(int typenum)
{
    const mdl_type_table_entry_t *tte = mdl_type_table_entry(typenum);
    if (tte) return tte->evaltype;
    return NULL;
}

mdl_value_t *mdl_get_applytype(int typenum)
{
    const mdl_type_table_entry_t *tte = mdl_type_table_entry(typenum);
    if (tte) return tte->applytype;
    return NULL;
}

mdl_value_t *mdl_set_printtype(int typenum, mdl_value_t *how)
{
    mdl_type_table_entry_t *tte = mdl_type_table_entry(typenum);
    if (tte) 
    {
        tte->printtype = how;
        return how;
    }
    return NULL;
}

mdl_value_t *mdl_set_evaltype(int typenum, mdl_value_t *how)
{
    mdl_type_table_entry_t *tte = mdl_type_table_entry(typenum);
    if (tte) 
    {
        tte->evaltype = how;
        return how;
    }
    return NULL;
}

mdl_value_t *mdl_set_applytype(int typenum, mdl_value_t *how)
{
    mdl_type_table_entry_t *tte = mdl_type_table_entry(typenum);
    if (tte) 
    {
        tte->applytype = how;
        return how;
    }
    return NULL;
}

// this returns a copy of the internal type vector, not the real thing as in
// real MDL
mdl_value_t *mdl_typevector()
{
    mdl_value_t * result = mdl_new_empty_vector(mdl_type_table.size(), MDL_TYPE_VECTOR);
    mdl_type_table_t::iterator iter;
    mdl_value_t *iptr;

    iptr = VREST(result, 0);
    for (iter = mdl_type_table.begin(); iter != mdl_type_table.end(); iter++)
    {
        iptr->type = MDL_TYPE_ATOM;
        iptr->pt = PRIMTYPE_ATOM;
        iptr->v.a = iter->a;
        iptr++;
    }
    return result;
}

bool mdl_atom_equal(const atom_t *a, const atom_t *b)
{
    return a == b;
}

bool mdl_string_equal_cstr(const counted_string_t *s, const char *cs)
{
    int len  = strlen(cs);
    return (len == s->l) && !memcmp(s->p, cs, len);
}

bool mdl_value_equal_atom(const mdl_value_t *a, const atom_t *b)
{
    if (a == NULL && b == NULL) return true; // ?? maybe wrong
    if (a == NULL || b == NULL) return false;
    if (a->pt != PRIMTYPE_ATOM) return false;
    if (a->type != MDL_TYPE_ATOM) return false;
    return mdl_atom_equal(a->v.a, b);
}

size_t mdl_hash_value(const mdl_value_t *a)
{
    size_t result;
    switch (a->pt)
    {
    case PRIMTYPE_ATOM:
    {
        result = (size_t)a->v.a;
        break;
    }
    case PRIMTYPE_WORD:
    {
        result = (size_t)a->v.w;
        break;
    }
    case PRIMTYPE_STRING:
    {
        result = (size_t)a->v.s.p; // pointer is sufficient, all strings
                                   // with the same pointer
                                   // must have the same length
        break;
    }
    case PRIMTYPE_LIST:
        result = (size_t)a->v.p.cdr; // CAR of list head should always be empty
        break;
    case PRIMTYPE_VECTOR:
        result = (size_t)(a->v.v.p + a->v.v.offset);
        break;
    case PRIMTYPE_UVECTOR:
        result = (size_t)(a->v.uv.p + a->v.uv.offset);
        break;
    case PRIMTYPE_TUPLE:
        result = (size_t)(a->v.tp.p + a->v.tp.offset);
        break;
    case PRIMTYPE_FRAME:
        result = (size_t)a->v.f;
        break;
    default:
        mdl_error("Can't hash that!");
        break;
    }
    result = result ^ ((a->type<<20)*7); // silly, yes.
    return result;
}

bool mdl_value_double_equal(const mdl_value_t *a, const mdl_value_t *b)
{
    if (a == b) return true;
    if (!a || !b) return false;
    if (a->pt != b->pt) return false;
    if (a->type != b->type) return false;
    switch (a->pt)
    {
    case PRIMTYPE_ATOM:
        return mdl_atom_equal(a->v.a, b->v.a);
    case PRIMTYPE_WORD:
        return a->v.w == b->v.w;
    case PRIMTYPE_STRING:
        return (a->v.s.l == b->v.s.l) && (a->v.s.p == b->v.s.p);
        // structured type tests may not be restrictive enough
        // but I think they are; see section 8.2.2 in the MDL Programming Language
    case PRIMTYPE_LIST:
        return a->v.p.cdr == b->v.p.cdr; // CAR of list head should always be empty
    case PRIMTYPE_VECTOR:
        return ((a->v.v.p == b->v.v.p) && (a->v.v.offset == b->v.v.offset));
    case PRIMTYPE_UVECTOR:
        return ((a->v.uv.p == b->v.uv.p) && (a->v.uv.offset == b->v.uv.offset));
    case PRIMTYPE_TUPLE:
        return ((a->v.tp.p == b->v.tp.p) && (a->v.tp.offset == b->v.tp.offset));
    case PRIMTYPE_FRAME:
        return a->v.f == b->v.f;
    }
    return false;
}

bool mdl_value_equal(const mdl_value_t *a, const mdl_value_t *b)
{
    if (a == b) return true;
    if (!a || !b) return false;
    if (a->pt != b->pt) return false;
    if (a->type != b->type) return false;
    switch (a->pt)
    {
    case PRIMTYPE_ATOM:
        return mdl_atom_equal(a->v.a, b->v.a);
    case PRIMTYPE_WORD:
        return a->v.w == b->v.w;
    case PRIMTYPE_STRING:
        return (a->v.s.l == b->v.s.l) && !memcmp(a->v.s.p, b->v.s.p, a->v.s.l);
    case PRIMTYPE_LIST:
        return mdl_value_equal(a->v.p.car, b->v.p.car) && mdl_value_equal(a->v.p.cdr, b->v.p.cdr);
    case PRIMTYPE_VECTOR:
    {
        int len = VLENGTH(a);
        if (len != VLENGTH(b)) return false;
        mdl_value_t *elema = VREST(a, 0);
        mdl_value_t *elemb = VREST(b, 0);
        while (len--)
        {
            if (!mdl_value_equal(elema, elemb)) return false;
            elema++;
            elemb++;
        }
        return true;
    }
    case PRIMTYPE_TUPLE:
    {
        int len = TPLENGTH(a);
        if (len != TPLENGTH(b)) return false;
        mdl_value_t *elema = TPREST(a, 0);
        mdl_value_t *elemb = TPREST(b, 0);
        while (len--)
        {
            if (!mdl_value_equal(elema, elemb)) return false;
            elema++;
            elemb++;
        }
        return true;
    }
    case PRIMTYPE_UVECTOR:
    {
        int len = UVLENGTH(a);
        if (len != UVLENGTH(b)) return false;
        if (UVTYPE(a) != UVTYPE(b)) return false;
        uvector_element_t *elema = UVREST(a, 0);
        uvector_element_t *elemb = UVREST(b, 0);
        while (len--)
        {
            mdl_value_t *vala = mdl_uvector_element_to_value(a, elema, NULL);
            mdl_value_t *valb = mdl_uvector_element_to_value(b, elemb, NULL);
            if (!mdl_value_equal(vala, valb)) return false;
            elema++;
            elemb++;
        }
        return true;
    }
    case PRIMTYPE_FRAME:
        return a->v.f == b->v.f;
    }
    return false;
}

mdl_value_t *mdl_new_mdl_value()
{
    return (mdl_value_t *)GC_MALLOC(sizeof(mdl_value_t));
}


MDL_INT mdl_hash_pname(const char *pname)
{
    // sdbm
    // for each character
    // hash = hash * 65599 + str[i];
    MDL_INT hash = 0;
    int c;
    while ((c = *pname++))
        hash = c + (hash << 6) + (hash << 16) - hash;
    if (hash < 0) hash += MDL_INT_MAX;
    return hash;
}

mdl_value_t *mdl_get_atom_from_oblist(const char *pname, mdl_value_t *oblist)
{
    if (oblist->type != MDL_TYPE_OBLIST)
        mdl_error("Oblist not of oblist type in atom lookup");
    int buckets = UVLENGTH(oblist);
    MDL_INT bucket_num = mdl_hash_pname(pname) % buckets;

    uvector_element_t *bucket = mdl_internal_uvector_rest(oblist, bucket_num);

    mdl_value_t *cursor = bucket->l;
    while (cursor)
    {
        mdl_value_t *av = cursor->v.p.car;
        if (av->type != MDL_TYPE_ATOM)
            mdl_error("Something not an atom in the oblist");
        if (!strcmp(pname, av->v.a->pname))
        {
            return av;
        }
        cursor = cursor->v.p.cdr;
    }
    return NULL;
}

mdl_value_t *mdl_remove_atom_from_oblist(const char *pname, mdl_value_t *oblist)
{
    if (oblist->type != MDL_TYPE_OBLIST)
        mdl_error("Oblist not of oblist type in atom remove");
    int buckets = UVLENGTH(oblist);
    MDL_INT bucket_num = mdl_hash_pname(pname) % buckets;

    uvector_element_t *bucket = mdl_internal_uvector_rest(oblist, bucket_num);

    mdl_value_t *cursor = bucket->l;
    mdl_value_t *lastcursor = NULL;
    while (cursor)
    {
        mdl_value_t *av = cursor->v.p.car;
        if (av->type != MDL_TYPE_ATOM)
            mdl_error("Something not an atom in the oblist");
        if (!strcmp(pname, av->v.a->pname))
        {
            if (cursor == bucket->l) bucket->l = cursor->v.p.cdr;
            else lastcursor->v.p.cdr = cursor->v.p.cdr;
            av->v.a->oblist = NULL;
            return av;
        }
        lastcursor = cursor;
        cursor = cursor->v.p.cdr;
    }
    return NULL;
}

// note that it is assumed the atom isn't already there
void mdl_put_atom_in_oblist(const char *pname, mdl_value_t *oblist, mdl_value_t *new_atom)
{
    if (oblist->type != MDL_TYPE_OBLIST)
        mdl_error("Oblist not of oblist type in atom lookup");
    int buckets = UVLENGTH(oblist);
    MDL_INT bucket_num = mdl_hash_pname(pname) % buckets;

    uvector_element_t *bucket = mdl_internal_uvector_rest(oblist, bucket_num);
    mdl_value_t *n = mdl_newlist();
    n->v.p.car = new_atom;
    n->v.p.cdr = bucket->l;
    bucket->l = n;
}

// create an atom not on an oblist
mdl_value_t *mdl_create_atom(const char *pname)
{
//    atom_t *a = (atom_t *)GC_MALLOC(sizeof(atom_t) + strlen(pname)); // the -1 and +1 cancel
//    strcpy(a->pname, pname);
    atom_t *a = (atom_t *)GC_MALLOC(sizeof(atom_t));
    int len = strlen(pname);
    a->typenum = MDL_TYPE_NOTATYPE;
    a->pname = mdl_new_raw_string(len, true);
    strcpy(a->pname, pname);
    mdl_value_t *atomval = mdl_newatomval(a);
    return atomval;
}

mdl_value_t *mdl_create_atom_on_oblist(const char *pname, mdl_value_t *oblist)
{
    if (oblist->type != MDL_TYPE_OBLIST)
        mdl_error("Oblist not of oblist type in ATOM create");

    if (mdl_get_atom_from_oblist(pname, oblist))
        return NULL; // no dupes allowed

    mdl_value_t *atomval = mdl_create_atom(pname);
    atomval->v.a->oblist = oblist;
    mdl_put_atom_in_oblist(pname, oblist, atomval);
    return atomval;
}

mdl_value_t *mdl_get_or_create_atom_on_oblist(const char *pname, mdl_value_t *oblist)
{
    mdl_value_t *atomval;

    if (oblist->type != MDL_TYPE_OBLIST)
        mdl_error("Oblist not of oblist type in ATOM create");

    if ((atomval = mdl_get_atom_from_oblist(pname, oblist)))
        return atomval;

    atomval = mdl_create_atom(pname);
    atomval->v.a->oblist = oblist;
    mdl_put_atom_in_oblist(pname, oblist, atomval);
    return atomval;
}

mdl_value_t *mdl_create_oblist(mdl_value_t *oblname, int buckets)
{
    mdl_value_t *result;

    if (oblname->type != MDL_TYPE_ATOM)
        mdl_error("OBLIST name must be atom");

    result = mdl_internal_eval_getprop(oblname, mdl_value_oblist);
    if (!result)
    {
        result = mdl_new_empty_uvector(buckets, MDL_TYPE_OBLIST);
        UVTYPE(result) = MDL_TYPE_LIST;
        mdl_internal_eval_putprop(oblname, mdl_value_oblist, result);
        mdl_internal_eval_putprop(result, mdl_value_oblist, oblname);
    }
    return result;
}

atom_t *mdl_get_oblist_name(mdl_value_t *oblist)
{
    mdl_value_t *oname = mdl_internal_eval_getprop(oblist, mdl_value_oblist);
    if (!oname) return NULL;
    if (oname->type != MDL_TYPE_ATOM) 
        mdl_error("Name of an oblist must be an atom"); // probably not actually true in real MDL
    return oname->v.a;
}

mdl_value_t *mdl_get_current_oblists()
{
    mdl_value_t *oblists;

    if (cur_frame == NULL) 
        oblists = mdl_local_symbol_lookup(atom_oblist, cur_process_initial_frame);
    else
        oblists = mdl_local_symbol_lookup(atom_oblist, cur_frame);
    return oblists;
}

mdl_value_t *mdl_get_atom_default_oblist(const char *pname, bool insert_allowed, mdl_value_t *oblists)
{
    if (!oblists)
        oblists = mdl_get_current_oblists();
        
    if (oblists == NULL)
    {
        if (insert_allowed)
            mdl_error(".OBLIST is not set");
        return NULL;
    }
    mdl_value_t *a = NULL;
    if (oblists->type == MDL_TYPE_OBLIST)
    {
        a = mdl_get_atom_from_oblist(pname, oblists);
        if (!a && insert_allowed)
            a = mdl_create_atom_on_oblist(pname, oblists);
    }
    else if (oblists->type == MDL_TYPE_LIST)
    {
        mdl_value_t *cursor = oblists->v.p.cdr;
        mdl_value_t *default_marker = oblists;
        while (cursor && !a)
        {
            mdl_value_t *oblist = cursor->v.p.car;
            if (oblist->type == MDL_TYPE_OBLIST)
            {
                a = mdl_get_atom_from_oblist(pname, oblist);
            }
            else if (insert_allowed && mdl_value_equal(oblist, mdl_value_atom_default))
            {
                default_marker = cursor;
            }
            cursor = cursor->v.p.cdr;
        }
        if (!a && insert_allowed)
        {
            default_marker = default_marker->v.p.cdr;
            if (!default_marker)
                mdl_error("Default oblist for insert missing");
            default_marker = default_marker->v.p.car;
            if (!default_marker)
                mdl_error("Default oblist for insert NULL");
            if (default_marker->type != MDL_TYPE_OBLIST)
                mdl_error("Default oblist for insert not OBLIST");
            a = mdl_create_atom_on_oblist(pname, default_marker);
        }
    }
    return a;
}

mdl_value_t *mdl_push_oblist_lval(mdl_value_t *new_lval)
{
    mdl_value_t *old_lval = mdl_get_current_oblists();
    mdl_static_block_stack = mdl_cons_internal(old_lval, mdl_static_block_stack);
    mdl_set_lval(atom_oblist, new_lval, cur_frame);
    return new_lval;
}

mdl_value_t *mdl_pop_oblist_lval()
{
    if (mdl_static_block_stack == NULL)
        mdl_error("Tried to pop static block stack when it was empty");
    mdl_value_t *old_lval = mdl_static_block_stack->v.p.car;
    mdl_static_block_stack = mdl_static_block_stack->v.p.cdr;
    mdl_set_lval(atom_oblist, old_lval, cur_frame);
    return old_lval;
}

bool mdl_oblists_are_reasonable(mdl_value_t *oblists)
{
    if (!oblists) return false;
    if (oblists->type == MDL_TYPE_OBLIST) return true;
    if (oblists->type != MDL_TYPE_LIST) return false;
    oblists = oblists->v.p.cdr;
    while (oblists)
    {
        if (oblists->v.p.car->type != MDL_TYPE_OBLIST &&
            (oblists->v.p.car->type != MDL_TYPE_ATOM ||
             !mdl_value_double_equal(oblists->v.p.car, mdl_value_atom_default))
            ) return false;
        oblists = oblists->v.p.cdr;
    }
    return true;
}

// mdl_get_atom and mdl_get_and_create_atom
// do what READ does with atoms
mdl_value_t *mdl_get_atom(const char *pname, bool insert_allowed, mdl_value_t *default_oblists)
{

    const char *trailer = strstr(pname, "!-");
    if (trailer == NULL)
    {
        return mdl_get_atom_default_oblist(pname, insert_allowed, default_oblists);
    }
    mdl_value_t *a = NULL;
    int ulen = trailer - pname;
    char *uname = (char *)alloca(ulen + 1);
    memcpy(uname, pname, ulen);
    uname[ulen] = 0;
    if (trailer[2] == '\0')
    {
        a = mdl_get_atom_from_oblist(uname, mdl_value_root_oblist);
        if (!a && insert_allowed)
            a = mdl_create_atom_on_oblist(uname, mdl_value_root_oblist);
    }
    else
    {
        mdl_value_t *oblist_name = mdl_get_atom(trailer + 2, insert_allowed, default_oblists);
        mdl_value_t *oblist = NULL;
        if (oblist_name)
        {
            oblist = mdl_internal_eval_getprop(oblist_name, mdl_value_oblist);
        }
        if (insert_allowed && !oblist)
        {
            oblist = mdl_create_oblist(oblist_name, MDL_OBLIST_HASHBUCKET_DEFAULT);
            a = mdl_create_atom_on_oblist(uname, oblist);
        }
        else if (oblist)
        {
            a = mdl_get_atom_from_oblist(uname, oblist);
            if (!a && insert_allowed)
                a = mdl_create_atom_on_oblist(uname, oblist);
        }
    }
    return a;
}

mdl_value_t *mdl_create_or_get_atom(const char *pname)
{
    mdl_value_t *a = mdl_get_atom(pname, true, NULL);
    return a;
}

// mdl_new_raw_string leaves space for a null, and puts original length on the end
// strings are made immutable by putting the one's complement of the
// original length on the end instead

// the beginning of a string is always v.s.p + v.s.l - len,
// since rest increments p and decrements l.  Assuming GC_MALLOC_ATOMIC
// returns aligned storage, the len of a string object can always be found with
// *(MDL_INT_*)ALIGN_MDL_INT(v.s.p + v.s.l + 1)
char *mdl_new_raw_string(int len, bool immutable)
{
    size_t alignlen = ALIGN_MDL_INT(len + 1);
    
    char *result = (char *)GC_MALLOC_ATOMIC(alignlen + sizeof(MDL_INT));
    memset(result, 0, alignlen);
    *((MDL_INT *)(result + alignlen)) = immutable?(~(MDL_INT)len):len;
    return result;
}

MDL_INT mdl_string_length(mdl_value_t *v)
{
    MDL_INT result = *(MDL_INT *)ALIGN_MDL_INT(v->v.s.p + v->v.s.l + 1);
    if (result < 0) result = ~result;
    return result;
}

bool mdl_string_immutable(mdl_value_t *v)
{
    MDL_INT result = *(MDL_INT *)ALIGN_MDL_INT(v->v.s.p + v->v.s.l + 1);
    return result < 0;
}

// return an empty string with length LEN
mdl_value_t *mdl_new_string(int len)
{
    mdl_value_t *result = mdl_new_mdl_value();
    result->pt = PRIMTYPE_STRING;
    result->type = MDL_TYPE_STRING;
    result->v.s.l = len;
    result->v.s.p = mdl_new_raw_string(len, false);
    return result;
}

mdl_value_t *mdl_new_string(int len, const char *s)
{
    mdl_value_t *result = mdl_new_string(len);
    memcpy(result->v.s.p, s, len);
    result->v.s.p[len] = '\0';
    return result;
}

mdl_value_t *mdl_new_string(const char *s)
{
    return mdl_new_string(strlen(s),s);
}

mdl_value_t *mdl_new_word(MDL_INT fix, int type)
{
    mdl_value_t *result = mdl_new_mdl_value();
    result->pt = PRIMTYPE_WORD;
    result->type = type;
    result->v.w = fix;
    return result;
}

mdl_value_t *mdl_new_float(MDL_FLOAT flt)
{
    mdl_value_t *result = mdl_new_mdl_value();
    result->pt = PRIMTYPE_WORD;
    result->type = MDL_TYPE_FLOAT;
    result->v.fl = flt;
    return result;
}

mdl_value_t *mdl_newatomval(atom_t *a)
{
    mdl_value_t *result = mdl_new_mdl_value();
    result->pt = PRIMTYPE_ATOM;
    result->type = MDL_TYPE_ATOM;
    result->v.a = a; 
    return result;
}

// mdl_newlist returns a new list structure
mdl_value_t *mdl_newlist()
{
    mdl_value_t *r;

    r = (mdl_value_t *)GC_MALLOC(sizeof(mdl_value_t));
    r->pt = PRIMTYPE_LIST;
    r->type = MDL_TYPE_INTERNAL_LIST; // it's not a true list without the first element
    r->v.p.car = r->v.p.cdr = NULL;
    return r;
}
// mdl_make_list returns a MDL list -- the input list with an extra element at the
// beginning containing its type.  This is necessary to handle the MDL
// REST and ARGS facilities properly

mdl_value_t *mdl_make_list(mdl_value_t *l, int type)
{
    mdl_value_t *r;
    r = mdl_newlist();
    r->v.p.cdr = l;
    r->type = type;
    return r;
}

mdl_value_t *mdl_make_string(int len, char *s)
{
    // like new_string, but doesn't copy s
    mdl_value_t *result = mdl_new_mdl_value();
    result->pt = PRIMTYPE_STRING;
    result->type = MDL_TYPE_STRING;
    result->v.s.l = len;
    result->v.s.p = s;
    return result;
}

mdl_value_t *mdl_make_string(char *s)
{
    return mdl_make_string(strlen(s), s);
}

mdl_value_t *mdl_new_empty_vector(int size, int type)
{ 
    // Elements will have type and primtype 0
    // caller must add any t=LOSE/pt=WORDs required
    mdl_value_t *result = mdl_new_mdl_value();
    mdl_vector_block_t *vec = (mdl_vector_block_t *)GC_MALLOC(sizeof(mdl_vector_block_t));
    mdl_value_t *elems = (mdl_value_t *)GC_MALLOC_IGNORE_OFF_PAGE(size * sizeof(mdl_value_t));

    result->type = type;
    result->pt = PRIMTYPE_VECTOR;
    result->v.v.p = vec;
    result->v.v.offset = 0;
    vec->elements = elems;
    vec->size = size;
    vec->startoffset = 0;
    return result;
}

// TUPLE doesn't really do what TUPLE is supposed to do, but... meh
mdl_value_t *mdl_new_empty_tuple(int size, int type)
{ 
    mdl_value_t *result = mdl_new_mdl_value();
    mdl_tuple_block_t *vec = (mdl_tuple_block_t *)GC_MALLOC(sizeof(mdl_tuple_block_t) + (size - 1) * sizeof(mdl_value_t));

    result->type = type;
    result->pt = PRIMTYPE_TUPLE;
    result->v.tp.p = vec;
    result->v.tp.offset = 0;
    vec->size = size;
    return result;
}

mdl_value_t *mdl_new_empty_uvector(int size, int type)
{ 
    mdl_value_t *result = mdl_new_mdl_value();
    mdl_uvector_block_t *vec = (mdl_uvector_block_t *)GC_MALLOC(sizeof(mdl_uvector_block_t));
    uvector_element_t *elems = (uvector_element_t *)GC_MALLOC_IGNORE_OFF_PAGE(size * sizeof(uvector_element_t));

    result->type = type;
    result->pt = PRIMTYPE_UVECTOR;
    result->v.uv.p = vec;
    result->v.uv.offset = 0;
    result->v.uv.p->type = MDL_TYPE_LOSE;
    vec->elements = elems;
    vec->size = size;
    vec->startoffset = 0;
    return result;
}

// mdl_make_vector makes a vector from an internal list (with no head)
// and optionally destroys the original list;
mdl_value_t *mdl_make_vector(mdl_value_t *l, int type, bool destroy)
{
    int length = 0;
    mdl_value_t *cursor = l;
    mdl_value_t *dest;

    while (cursor) 
    {
        length++;
        cursor = cursor->v.p.cdr;
    }
    dest = mdl_new_empty_vector(length, type);
    mdl_value_t *elems = VREST(dest, 0);
    cursor = l;
    while (cursor) 
    {
        
        mdl_value_t *oldcursor = cursor;
        *elems++ = *(cursor->v.p.car);
        cursor = cursor->v.p.cdr;
        if (destroy) GC_FREE(oldcursor);
    }
    return dest;
}

// mdl_make_tuple makes a tuple from an internal list (with no head)
// and optionally destroys the original list;
mdl_value_t *mdl_make_tuple(mdl_value_t *l, int type, bool destroy)
{
    int length = 0;
    mdl_value_t *cursor = l;
    mdl_value_t *dest;

    while (cursor) 
    {
        length++;
        cursor = cursor->v.p.cdr;
    }
    dest = mdl_new_empty_tuple(length, type);
    mdl_value_t *elems = TPREST(dest, 0);
    cursor = l;
    while (cursor) 
    {
        mdl_value_t *oldcursor = cursor;
        *elems++ = *(cursor->v.p.car);
        cursor = cursor->v.p.cdr;
        if (destroy) GC_FREE(oldcursor);
    }
    return dest;
}

// mdl_make_uvector makes a uvector from an internal list (with no head)
// and optionally destroys the original list;
mdl_value_t *mdl_make_uvector(mdl_value_t *l, int type, bool destroy)
{
    int length = 0;
    mdl_value_t *cursor = l;
    mdl_value_t *dest;

    while (cursor) 
    {
        length++;
        cursor = cursor->v.p.cdr;
    }
    dest = mdl_new_empty_uvector(length, type);
    if (length)
    {
        if (!mdl_valid_uvector_primtype(l->v.p.car->pt))
        {
            mdl_error("Invalid type for UVECTOR");
        }
        UVTYPE(dest) = l->v.p.car->type;
    }
    uvector_element_t *elems = UVREST(dest, 0);
    cursor = l;
    while (cursor) 
    {
        
        mdl_value_t *oldcursor = cursor;
        if (UVTYPE(dest) != cursor->v.p.car->type)
        {
            return mdl_call_error("TYPES-DIFFER-IN-UNIFORM-VECTOR", NULL);
        }
        mdl_uvector_value_to_element(cursor->v.p.car, elems++);
        cursor = cursor->v.p.cdr;
        if (destroy) GC_FREE(oldcursor);
    }
    return dest;
}

// mdl_additem adds b as the last member of a
// a must be primtype LIST or NULL
// a is modified if it is not null
mdl_value_t *mdl_additem(mdl_value_t *a, mdl_value_t *b, mdl_value_t **lastitem)
{
    if (!b)
    {
        printf("Additem NULL\n");
        if (lastitem) *lastitem = a; // not right, but I don't want to iterate for this special case
        return a;
    }
    
    if (a == NULL)
    {
        a = mdl_newlist();
        a->v.p.car = b;
        if (lastitem) *lastitem = a;
    }
    else if (a->pt != PRIMTYPE_LIST )
    {
        mdl_error("Can't add an item to a non-list");
        mdl_print_value(stderr, a);
        printf("\n");
        return NULL;
    }
    else
    {
        mdl_value_t *c = a;
        /* this ain't LISP, lists are always null terminated, if they terminate */
        while (c->v.p.cdr != NULL)
        {
            c = c->v.p.cdr;
        }
        
        mdl_value_t *n = mdl_newlist();
        n->v.p.car = b;
        c->v.p.cdr = n;
        if (lastitem) *lastitem = n;
    }
    return a;
}

// mdl_additem adds b as the last member of a
mdl_value_t *mdl_additem_a(mdl_value_t *a, atom_t *b)
{
    return mdl_additem(a, mdl_newatomval(b));
}

// mdl_cons_internal adds item a to the beginning of internal (no header pointer) list B and returns the resulting list
mdl_value_t *mdl_cons_internal(mdl_value_t *a, mdl_value_t *b)
{
    mdl_value_t *nl = mdl_newlist();
    nl->v.p.car = a;
    nl->v.p.cdr = b;
    return nl;
}

bool mdl_primtype_nonstructured(int pt)
{
    switch (pt)
    {
    case PRIMTYPE_LIST:
    case PRIMTYPE_VECTOR:
    case PRIMTYPE_UVECTOR:
    case PRIMTYPE_TUPLE:
    case PRIMTYPE_BYTES:
    case PRIMTYPE_STRING:
        return false;
    }
    return true;
    // unimplemented primtypes may not be accurate!
}

// INPUT/OUTPUT support

// channel number to file mapping (ick)
typedef std::vector<FILE *> chanfilemap_t;
chanfilemap_t chanfilemap;

int mdl_new_chan_num(FILE *f)
{
    chanfilemap_t::reverse_iterator iter;
    int i;

    for (i = chanfilemap.size(), iter = chanfilemap.rbegin(); iter != chanfilemap.rend(); iter++, i--)
    {
        if (*iter == NULL) 
        {
            *iter = f;
            return i;
        }
    }
    chanfilemap.push_back(f);
    return chanfilemap.size();
}

FILE *mdl_get_channum_file(int chnum)
{
    return chanfilemap[chnum - 1];
}

int mdl_get_chan_channum(mdl_value_t *chan)
{
    return VITEM(chan,CHANNEL_SLOT_CHNUM)->v.w;
}

void mdl_set_chan_mode(mdl_value_t *chan, const char *mode)
{
    *VITEM(chan, CHANNEL_SLOT_MODE) = *mdl_new_string(mode);
}

mdl_value_t *mdl_get_chan_mode(mdl_value_t *chan)
{
    return VITEM(chan, CHANNEL_SLOT_MODE);
}

bool mdl_chan_mode_is_input(mdl_value_t *chan)
{
    mdl_value_t *mode = mdl_get_chan_mode(chan);
    if (mode->v.s.l < 4) return false;
    return !strncmp("READ", mode->v.s.p, 4);
}

bool mdl_chan_mode_is_output(mdl_value_t *chan)
{
    mdl_value_t *mode = mdl_get_chan_mode(chan);
    if (mode->v.s.l < 5) return false;
    return !strncmp("PRINT", mode->v.s.p, 5);
}

bool mdl_chan_mode_is_read_binary(mdl_value_t *chan)
{
    mdl_value_t *mode = mdl_get_chan_mode(chan);
    if (mode->v.s.l != 5) return false;
    return !memcmp("READB", mode->v.s.p, 5);
}

bool mdl_chan_mode_is_print_binary(mdl_value_t *chan)
{
    mdl_value_t *mode = mdl_get_chan_mode(chan);
    if (mode->v.s.l != 6) return false;
    return !memcmp("PRINTB", mode->v.s.p, 6) || !memcmp("PRINTO", mode->v.s.p, 6);
}

void mdl_set_chan_file(int chnum, FILE *f)
{
    chanfilemap[chnum - 1] = f;
}

void mdl_free_chan_file(int chnum)
{
    chanfilemap[chnum - 1] = NULL;
}

// Create and return a new and unopened channel
mdl_value_t *mdl_internal_create_channel()
{
    int i;
    mdl_value_t *cvec = mdl_new_empty_vector(CHANNEL_NSLOTS, MDL_TYPE_CHANNEL);
    mdl_value_t *zerofix = mdl_new_fix(0);
    mdl_value_t *nullstring = mdl_new_string(0);

    cvec = mdl_internal_eval_rest_i(cvec, CHANNEL_SLOT_OFFSET);
    cvec->type = MDL_TYPE_CHANNEL;
    *VITEM(cvec, CHANNEL_SLOT_TRANSCRIPT) = *mdl_make_list(NULL);
    *VITEM(cvec, CHANNEL_SLOT_DEVDEP) = *zerofix;
    *VITEM(cvec, CHANNEL_SLOT_CHNUM) = *zerofix;
    for (i = CHANNEL_SLOT_MODE; i <= CHANNEL_SLOT_DIRN; i++)
    {
        *VITEM(cvec, i) = *nullstring;
    }
    for (i = CHANNEL_SLOT_STATUS; i <= CHANNEL_SLOT_SINK; i++)
    {
        *VITEM(cvec, i) = *zerofix;
    }
    VITEM(cvec, CHANNEL_SLOT_RADIX)->v.w = 10;
    return cvec;
}

const char *mdl_get_chan_os_mode(mdl_value_t *chan)
{
    counted_string_t *chanmode = &VITEM(chan,CHANNEL_SLOT_MODE)->v.s;
    if (mdl_string_equal_cstr(chanmode, "READ")) return "r";
    if (mdl_string_equal_cstr(chanmode, "READB")) return "rb";
    if (mdl_string_equal_cstr(chanmode, "PRINT")) return "w";
    if (mdl_string_equal_cstr(chanmode, "PRINTB")) return "wb";
    if (mdl_string_equal_cstr(chanmode, "PRINTO")) return "rb+";
    return NULL;
}

char *mdl_getcwd()
{
    int bsize = 256;
    char *cwdbuf ;
    char *cwdp;
    do
    {
        cwdbuf = (char *)GC_MALLOC_ATOMIC(bsize);
        cwdp = getcwd(cwdbuf, bsize);
        bsize = bsize << 2;
    }
    while (cwdbuf != NULL && cwdp == NULL && errno == ERANGE);
    return cwdp;
}

void *mdl_memrchr(const void *s, int c, size_t n)
{
    const unsigned char *p = (const unsigned char *)s + n;
    while (p-- != s) if (*p == c) return (void *)p;
    return NULL;
}

void mdl_decode_file_args(mdl_value_t **name1p, mdl_value_t **name2p, mdl_value_t **devicep, mdl_value_t **dirp)
{
    mdl_value_t *name1 = *name1p;
    mdl_value_t *name2 = *name2p;
    mdl_value_t *device = *devicep;
    mdl_value_t *dir = *dirp;
    if (name1 && !name2)
    {
        // a filespec
        char *slashp, *dotp;
#ifdef DECODE_TENEX_FILESPECS
        char *ltp;
        char *gtp;

        // handle the TENEX <DIR>FILEN1.FN2 and DEV:<DIR>FILEN1.NF2 cases
        if (name1->v.s.l > 1 && 
            (ltp = (char *)memchr(name1->v.s.p, '<', name1->v.s.l)) &&
            (gtp = (char *)memchr(name1->v.s.p, '>', name1->v.s.l)) &&
            ltp < gtp &&
            (ltp == name1->v.s.p || ltp[-1] == ':')
            )
        {
            int name1len = name1->v.s.l;
            char *name1p = name1->v.s.p;
            if (ltp != name1p)
            {
                device = mdl_new_string(ltp - name1p, name1p);
                name1len -= ltp - name1p;
                name1p = ltp;
            }
            name1len -= (gtp - name1p) + 1;

            dir = mdl_new_string(gtp - name1p - 1);
            memcpy(dir->v.s.p, name1p + 1, gtp - name1p - 1);
            dotp = (char *)mdl_memrchr(gtp, '.', name1len + 1);
            if (dotp)
            {
                name2 = mdl_new_string(name1->v.s.p + name1->v.s.l - dotp - 1, dotp+1);
                name1len = dotp - gtp - 1;
            }
            else  // do not add an extension to filespecs
            {
                name2 = mdl_new_string(0);
            }
//            fprintf(stderr, "TENEX %s ", name1->v.s.p);
            name1 = mdl_new_string(name1len, gtp+1);
//            fprintf(stderr, "= %s %s %s %s\n", device?device->v.s.p:"default", dir->v.s.p, name1->v.s.p, name2->v.s.p);
        }
#endif
        slashp = (char *)mdl_memrchr(name1->v.s.p, '/', name1->v.s.l);
        dotp = (char *)mdl_memrchr(name1->v.s.p, '.', name1->v.s.l);

        if (slashp || dotp)
        {
            char * name1start = name1->v.s.p;
            int name1len = name1->v.s.l;
            if (slashp)
            {
                dir = mdl_new_string(slashp - name1->v.s.p + 1, name1->v.s.p);
                name1start = slashp + 1;
                name1len = name1->v.s.p + name1->v.s.l - name1start;
            }
            if (!slashp || (dotp && dotp > slashp))
            {
                name2 = mdl_new_string(name1->v.s.p + name1->v.s.l - dotp - 1, dotp+1);

                name1len -= name1->v.s.p + name1->v.s.l - dotp;
            }
            else  // do not add an extension to filespecs
            {
                name2 = mdl_new_string(0);
            }
            name1 = mdl_new_string(name1len, name1start);
        }
        // no slash and no dot means interpret this as a name, not a spec
    }
    if (!name1)
    {
        name1 = mdl_both_symbol_lookup_pname("NM1", cur_frame);
        if (!name1) name1 = mdl_new_string("INPUT");
    }
    if (!name2)
    {
        name2 = mdl_both_symbol_lookup_pname("NM2", cur_frame);
        if (!name2) name2 = mdl_new_string("MUD");
    }
    if (!device)
    {
        device = mdl_both_symbol_lookup_pname("DEV", cur_frame);
        if (!device) device = mdl_new_string("DSK");
    }
    // special case for null device
    if (mdl_string_equal_cstr(&device->v.s, "NUL"))
    {
        name1 = mdl_new_string(4,"null");
        name2 = mdl_new_string(0);
        dir = mdl_new_string(5, "/dev/");
    }
    if (!dir)
    {
        dir = mdl_both_symbol_lookup_pname("SNM", cur_frame);
        if (!dir) 
        {
            char *cwdp = mdl_getcwd();
            if (!cwdp)
                mdl_error("Unable to determine a working directory");
            dir = mdl_new_string(cwdp);
        }
    }
    *name1p = name1;
    *name2p = name2;
    *devicep = device;
    *dirp = dir;
}

char *mdl_build_pathname(mdl_value_t *name1v, mdl_value_t *name2v, mdl_value_t *devv, mdl_value_t *dirv)
{
    mdl_strbuf_t *pname = mdl_new_strbuf(256);
    
    char *name1 = name1v->v.s.p;
    char *name2 = name2v->v.s.p;
    char *dir = dirv->v.s.p;
//    char *dev = devv->v.s.p;
    int name1len = name1v->v.s.l;
    int name2len = name2v->v.s.l;
    int dirlen = dirv->v.s.l;
//    int devlen = devv->v.s.l;

    if (dir)
    {
        pname = mdl_strbuf_append_cstr(pname, dir);
        if (dir[dirlen - 1] != '/') pname = mdl_strbuf_append_cstr(pname, "/");
    }
    if (name1len) pname = mdl_strbuf_append_cstr(pname, name1);
    if (name2len)
    {
        pname = mdl_strbuf_append_cstr(pname, ".");
        pname = mdl_strbuf_append_cstr(pname, name2);
    }
    return mdl_strbuf_to_new_cstr(pname);
}

char *mdl_build_chan_pathname(mdl_value_t *chan)
{
    return mdl_build_pathname(VITEM(chan, CHANNEL_SLOT_FNARG1), VITEM(chan, CHANNEL_SLOT_FNARG2), VITEM(chan, CHANNEL_SLOT_DEVNARG),VITEM(chan, CHANNEL_SLOT_DIRNARG));
}

mdl_value_t *mdl_internal_open_channel(mdl_value_t *chan)
{
    char *pathname;
    const char *osmode;
    int chnum;
    FILE *f;
    counted_string_t *dirstr;

    osmode = mdl_get_chan_os_mode(chan);
    if (osmode == NULL) mdl_error("Bad channel mode");
    pathname = mdl_build_chan_pathname(chan);

    f = fopen(pathname, osmode);
    if (f == NULL)
    {
        mdl_value_t *errfalse = NULL;
        errfalse = mdl_cons_internal(mdl_new_fix(errno), errfalse);
        errfalse = mdl_cons_internal(mdl_new_string(pathname), errfalse);
        errfalse = mdl_cons_internal(mdl_new_string(strerror(errno)), errfalse);
        return mdl_make_list(errfalse, MDL_TYPE_FALSE);
    }
    chnum = mdl_new_chan_num(f);
    VITEM(chan,CHANNEL_SLOT_STATUS)->v.w = 0;
    *VITEM(chan,CHANNEL_SLOT_CHNUM) = *mdl_new_fix(chnum);
    *VITEM(chan,CHANNEL_SLOT_FN1) = *VITEM(chan,CHANNEL_SLOT_FNARG1);
    *VITEM(chan,CHANNEL_SLOT_FN2) = *VITEM(chan,CHANNEL_SLOT_FNARG2);
    dirstr = &VITEM(chan,CHANNEL_SLOT_DIRNARG)->v.s;
    *VITEM(chan,CHANNEL_SLOT_DIRN) = *VITEM(chan,CHANNEL_SLOT_DIRNARG);
    if ((dirstr->l == 0) || (dirstr->p[0] != '/'))
    {
        char *wd = mdl_getcwd();
        if (wd)
        {
            mdl_strbuf_t *absdir = mdl_new_strbuf(256);
            absdir = mdl_strbuf_append_cstr(absdir, wd);
            if (wd[strlen(wd)-1] != '/') absdir = mdl_strbuf_append_cstr(absdir, "/");
            absdir = mdl_strbuf_append_cstr(absdir, VITEM(chan,CHANNEL_SLOT_DIRNARG)->v.s.p);
            *VITEM(chan,CHANNEL_SLOT_DIRN) = *mdl_new_string(mdl_strbuf_to_const_cstr(absdir));
        }
    }
    if (!isatty(fileno(f)))
        *VITEM(chan,CHANNEL_SLOT_DEVN) = *VITEM(chan,CHANNEL_SLOT_DEVNARG);
    else
        *VITEM(chan,CHANNEL_SLOT_DEVN) = *(mdl_new_string(3, "TTY"));
    return chan;
}

mdl_value_t *mdl_internal_reset_channel(mdl_value_t *chan)
{
    char *pathname;
    const char *osmode;
    int chnum;
    FILE *f;
    FILE *oldf;

    if ((chnum = VITEM(chan,CHANNEL_SLOT_CHNUM)->v.w) == 0)
        return mdl_internal_open_channel(chan);
    
    osmode = mdl_get_chan_os_mode(chan);
    if (osmode == NULL) mdl_error("Bad channel mode");
    pathname = mdl_build_pathname(VITEM(chan, CHANNEL_SLOT_FN1), VITEM(chan, CHANNEL_SLOT_FN2), VITEM(chan, CHANNEL_SLOT_DEVN),VITEM(chan, CHANNEL_SLOT_DIRN));
    oldf = mdl_get_channum_file(chnum);
    if (oldf == stdin || oldf == stdout)
    {
        f = oldf;
    }
    else
    {
        if (oldf) fclose(oldf);
        
        f = fopen(pathname, osmode);
    }
    if (f == NULL)
    {
        mdl_value_t *errfalse = NULL;
        mdl_free_chan_file(chnum);

        VITEM(chan,CHANNEL_SLOT_CHNUM)->v.w = 0;
        errfalse = mdl_cons_internal(mdl_new_fix(errno), errfalse);
        errfalse = mdl_cons_internal(mdl_new_string(pathname), errfalse);
        errfalse = mdl_cons_internal(mdl_new_string(strerror(errno)), errfalse);
        return mdl_make_list(errfalse, MDL_TYPE_FALSE);
    }
    mdl_set_chan_file(chnum, f);
    VITEM(chan,CHANNEL_SLOT_STATUS)->v.w = 0;
    if (!isatty(fileno(f)))
        *VITEM(chan,CHANNEL_SLOT_DEVN) = *VITEM(chan,CHANNEL_SLOT_DEVNARG);
    else
        *VITEM(chan,CHANNEL_SLOT_DEVN) = *(mdl_new_string(3, "TTY"));
    return chan;
}

// internal_reopen_channel re-opens a channel after a restore
mdl_value_t *mdl_internal_reopen_channel(mdl_value_t *chan)
{
    char *pathname;
    const char *osmode;
    int chnum;
    FILE *f;
    off_t seekpos;
    bool seekend;

    osmode = mdl_get_chan_os_mode(chan);
    if (osmode == NULL) mdl_error("Bad channel mode");
    seekend = osmode[0] == 'w';
    if (!strcmp(osmode, "w")) osmode = "r+";
    if (!strcmp(osmode, "wb")) osmode = "rb+";

    pathname = mdl_build_pathname(VITEM(chan, CHANNEL_SLOT_FN1), VITEM(chan, CHANNEL_SLOT_FN2), VITEM(chan, CHANNEL_SLOT_DEVN),VITEM(chan, CHANNEL_SLOT_DIRN));
    f = fopen(pathname, osmode);
    fprintf(stderr, "RE-opened %s = %p\n", pathname, f);
    if (f == NULL)
    {
        mdl_value_t *errfalse = NULL;

        VITEM(chan,CHANNEL_SLOT_CHNUM)->v.w = 0;
        errfalse = mdl_cons_internal(mdl_new_fix(errno), errfalse);
        errfalse = mdl_cons_internal(mdl_new_string(pathname), errfalse);
        errfalse = mdl_cons_internal(mdl_new_string(strerror(errno)), errfalse);
        return mdl_make_list(errfalse, MDL_TYPE_FALSE);
    }
    chnum = mdl_new_chan_num(f);
    VITEM(chan,CHANNEL_SLOT_CHNUM)->v.w = chnum;
    VITEM(chan,CHANNEL_SLOT_STATUS)->v.w = 0;
    if (!isatty(fileno(f)))
    {
        if (seekend)
        {
            fseek(f, 0, SEEK_END);
        }
        {
            seekpos = (off_t)VITEM(chan,CHANNEL_SLOT_PTR)->v.w;
            fseek(f, seekpos, SEEK_SET);
        }
        *VITEM(chan,CHANNEL_SLOT_DEVN) = *VITEM(chan,CHANNEL_SLOT_DEVNARG);
    }
    else
        *VITEM(chan,CHANNEL_SLOT_DEVN) = *(mdl_new_string(3, "TTY"));
    return chan;
}

mdl_value_t *mdl_internal_close_channel(mdl_value_t *chan)
{
    int chnum = VITEM(chan,CHANNEL_SLOT_CHNUM)->v.w;
    mdl_value_t *nullstring = mdl_new_string(0);
    FILE *f;
    int err;
    
    if (!chnum) return chan; // already closed
    f = mdl_get_channum_file(chnum);
    mdl_free_chan_file(chnum);
    err = fclose(f);

    VITEM(chan,CHANNEL_SLOT_CHNUM)->v.w = 0;
    *VITEM(chan,CHANNEL_SLOT_FN1) = *nullstring;
    *VITEM(chan,CHANNEL_SLOT_FN2) = *nullstring;
    *VITEM(chan,CHANNEL_SLOT_DEVN) = *nullstring;
    *VITEM(chan,CHANNEL_SLOT_DIRN) = *nullstring;
    if (err) mdl_error("fclose failed");
    return chan;
}

mdl_value_t *mdl_make_localvar_ref(mdl_value_t *a, int reftype)
{
    mdl_value_t *r;

    r = (mdl_value_t *)mdl_newlist();
    r->v.p.cdr = mdl_newlist();
    r->v.p.cdr->v.p.car = a;
    r->v.p.car = mdl_get_atom_from_oblist("LVAL", mdl_value_root_oblist);
    return mdl_make_list(r, reftype);
}

mdl_value_t *mdl_make_globalvar_ref(mdl_value_t *a, int reftype)
{
    mdl_value_t *r;

    r = (mdl_value_t *)mdl_newlist();
    r->v.p.cdr = mdl_newlist();
    r->v.p.cdr->v.p.car = a;
    r->v.p.car = mdl_get_atom_from_oblist("GVAL", mdl_value_root_oblist);
    return mdl_make_list(r, reftype);
}

mdl_value_t *mdl_make_quote(mdl_value_t *a, int qtype)
{
    mdl_value_t *r;

    r = (mdl_value_t *)mdl_newlist();
    r->v.p.cdr = mdl_newlist();
    r->v.p.cdr->v.p.car = a;
    r->v.p.car = mdl_get_atom_from_oblist("QUOTE", mdl_value_root_oblist);
    return mdl_make_list(r, qtype);
}

mdl_frame_t *mdl_new_frame()
{
    mdl_frame_t *r = (struct mdl_frame_t *)GC_MALLOC(sizeof(mdl_frame_t));
    // GC_MALLOC does a clear, so no need to clear anything
    r->syms = new (UseGC)mdl_local_symbol_table_t();
    return r;
}

mdl_value_t *mdl_make_frame_value(mdl_frame_t *frame, int t = MDL_TYPE_FRAME)
{
    mdl_value_t *result = mdl_new_mdl_value();
    result->pt = PRIMTYPE_FRAME;
    result->type = t;
    result->v.f = frame
;
    return result;
}

inline mdl_frame_t *mdl_push_frame(mdl_frame_t *frame)
{
    frame->prev_frame = cur_frame;
    cur_frame = frame;
    return frame->prev_frame;
}

mdl_frame_t *mdl_pop_frame(mdl_frame_t *frame)
{
    mdl_local_symbol_table_t::iterator iter;
    if (frame != cur_frame->prev_frame)
        mdl_error("Frames confused");
#ifdef CACHE_LOCAL_SYMBOLS
    for (iter = cur_frame->syms->begin(); iter != cur_frame->syms->end(); iter++)
    {
        if ((iter->second.atom->bindid == cur_process_bindid) &&
            (iter->second.atom->binding == &iter->second))
            iter->second.atom->binding = iter->second.prev_binding;
    }
#endif

    cur_frame = frame;
    return cur_frame;
}
                          
void mdl_longjmp_to(mdl_frame_t *jump_frame, int value)
{
    mdl_frame_t *frame = cur_frame;
    mdl_value_t *unwind_val;
    while (frame && frame != jump_frame)
    {
        if (frame->frame_flags & MDL_FRAME_FLAGS_UNWIND)
        {
//            fprintf(stderr, "UNWINDING\n");
            unwind_val = mdl_internal_eval_nth_i(frame->args,2);
            frame = mdl_pop_frame(frame->prev_frame);
            mdl_eval(unwind_val);
        }
        else
            frame = mdl_pop_frame(frame->prev_frame);
    }
    if (!frame) mdl_error("Tried to jump to frame not on stack!");
    mdl_longjmp(cur_frame->interp_frame, value);
}

void mdl_error(const char *err)
{
    fflush(stdout);
    fprintf(stderr, "%s\n",err);
    if (initial_frame)
    {
//        fprintf(stderr, "Error to initial jumpbuf\n");
        cur_frame = initial_frame;
        NEW_BINDID(cur_process_bindid);
        mdl_longjmp(initial_frame->interp_frame, LONGJMP_ERROR);
    }
    fprintf(stderr, "Fatal: Lost my stack\n");
    exit(-1);
}

mdl_value_t *mdl_call_error_ext(const char *erratom, const char *errstr, ...)
{
    va_list gp;
    mdl_value_t *arglist;
    mdl_value_t *lastitem;
    mdl_value_t *arg;

    va_start(gp, errstr);
    arglist = mdl_additem(NULL, mdl_value_builtin_error, &lastitem);
    // FIXME -- use atom instead of string for first arg
    mdl_additem(lastitem, mdl_new_string(erratom), &lastitem);
    mdl_additem(lastitem, mdl_new_string(errstr), &lastitem);
    while ((arg = va_arg(gp, mdl_value_t *)))
    {
        mdl_additem(lastitem, arg, &lastitem);
    }
    va_end(gp);
    return mdl_std_apply(mdl_value_builtin_error, mdl_make_list(arglist), MDL_TYPE_SUBR, true);
}

mdl_value_t *mdl_call_error(const char *errstr, ...)
{
    va_list gp;
    mdl_value_t *arglist;
    mdl_value_t *lastitem;
    mdl_value_t *arg;

    va_start(gp, errstr);
    arglist = mdl_additem(NULL, mdl_value_builtin_error, &lastitem);
    mdl_additem(lastitem, mdl_new_string(errstr), &lastitem);
    while ((arg = va_arg(gp, mdl_value_t *)))
    {
        mdl_additem(lastitem, arg, &lastitem);
    }
    va_end(gp);
    return mdl_std_apply(mdl_value_builtin_error, mdl_make_list(arglist), MDL_TYPE_SUBR, true);
}

mdl_value_t *mdl_parse_string(mdl_value_t *str, int radix, mdl_value_t *lookahead)
{
    mdl_value_t *chan = mdl_internal_create_channel();
    mdl_set_chan_mode(chan, "READ");
    mdl_set_chan_eof_object(chan, NULL); // error out on illegal object
    mdl_set_chan_input_source(chan, str);
    if (lookahead)
        mdl_set_chan_lookahead(chan, lookahead->v.w);
    return mdl_read_object(chan);
}

mdl_value_t *mdl_global_symbol_lookup(const atom_t *atom)
{
    mdl_symbol_table_t::iterator iter;

    iter = global_syms.find(atom);
    if (iter == global_syms.end()) return NULL;
    return iter->second.binding;
}

mdl_value_t *mdl_local_symbol_lookup_1_activation_only_please(const atom_t *atom, mdl_frame_t *frame)
{
    mdl_local_symbol_table_t::iterator iter;

    while (frame)
    {
        iter = frame->syms->find(atom);
        if (iter != frame->syms->end())
            return iter->second.binding;
        if (frame->frame_flags & MDL_FRAME_FLAGS_ACTIVATION) return NULL;
        frame = frame->prev_frame;
    }
    return NULL;
}

mdl_local_symbol_t *mdl_local_symbol_slot(atom_t *atom, mdl_frame_t *frame)
{
#ifdef CACHE_LOCAL_SYMBOLS
    bool fixbind;
#endif

    if (!frame)
    {
        mdl_error("Bad frame passed to local symbol lookup");
    }


#ifdef CACHE_LOCAL_SYMBOLS
    fixbind = frame == cur_frame;
    // shortcut -- use atom's bind value
    if (fixbind && atom->bindid == cur_process_bindid && atom->binding)
    {
        return atom->binding;
    }
#endif

    mdl_local_symbol_table_t::iterator iter;


    while (frame)
    {
        iter = frame->syms->find(atom);
        if (iter != frame->syms->end()) break;
        frame = frame->prev_frame;
    }
    if (!frame) return NULL;

#ifdef CACHE_LOCAL_SYMBOLS
    if (fixbind)
    {
        atom->binding = &iter->second;
        atom->bindid = cur_process_bindid;
    }
#endif
    return &iter->second;
}

mdl_value_t *mdl_bind_local_symbol(atom_t *atom, mdl_value_t *val, mdl_frame_t *frame, bool allow_replacement)
{
    mdl_local_symbol_table_t::iterator iter;
#ifdef CACHE_LOCAL_SYMBOLS
    bool fixbind = frame == cur_frame;
#endif

    iter = frame->syms->find(atom);
    if (iter != frame->syms->end())
    {
        if (!allow_replacement) return NULL;
        iter->second.binding = val;
    }
    else
    {
#ifdef CACHE_LOCAL_SYMBOLS
        mdl_local_symbol_t *oldsym = mdl_local_symbol_slot(atom, frame);
#endif
        mdl_local_symbol_t sym;
        std::pair<mdl_local_symbol_table_t::iterator, bool> insresult;
        sym.atom = atom;
        sym.binding = val;
#ifdef CACHE_LOCAL_SYMBOLS
        sym.prev_binding = oldsym;
#endif
        insresult = frame->syms->insert(std::pair<const atom_t *, mdl_local_symbol_t>(atom, sym));
#ifdef CACHE_LOCAL_SYMBOLS
        if (fixbind)
        {
            atom->binding = &insresult.first->second;
            atom->bindid = cur_process_bindid;
        }
        else
            atom->binding = NULL;
#endif
    }
    return val;
}

mdl_value_t *mdl_local_symbol_lookup(atom_t *atom, mdl_frame_t *frame)
{
    mdl_local_symbol_t *sym = mdl_local_symbol_slot(atom, frame);
    if (!sym) return NULL;
    return sym->binding;
}

mdl_value_t *mdl_local_symbol_lookup_pname(const char *pname, mdl_frame_t *frame)
{
    mdl_value_t *av = mdl_get_atom(pname, true, NULL);
    if (!av) return NULL;
    return mdl_local_symbol_lookup(av->v.a, frame);
}

// VALUE style lookup, first local then global, never returning
// UNBOUND
mdl_value_t *mdl_both_symbol_lookup(atom_t *atom, mdl_frame_t *frame)
{
    mdl_value_t *result;
    result = mdl_local_symbol_lookup(atom, frame);
    if (!result || result->type == MDL_TYPE_UNBOUND)
        result = mdl_global_symbol_lookup(atom);
    if (!result || result->type == MDL_TYPE_UNBOUND) return NULL;
    return result;
}

mdl_value_t *mdl_both_symbol_lookup_pname(const char *pname, mdl_frame_t *frame)
{
    mdl_value_t *result;
    mdl_value_t * av = mdl_get_atom(pname, true, NULL);
    if (!av) return NULL;
    result = mdl_local_symbol_lookup(av->v.a, frame);
    if (!result || result->type == MDL_TYPE_UNBOUND)
        result = mdl_global_symbol_lookup(av->v.a);
    if (!result || result->type == MDL_TYPE_UNBOUND) return NULL;
    return result;
}


// bind arguments to function/prog/repeat in frame
mdl_value_t *mdl_bind_args(mdl_value_t *fargs,
                   mdl_value_t *apply_to, // functions only
                   mdl_frame_t *frame,
                   mdl_frame_t *prev_frame, // for "BIND"
                   bool called_from_apply_subr,
                   bool auxonly)
{
    mdl_value_t *argptr = NULL;
    mdl_value_t *mdl_value_atom_quote = mdl_get_atom_from_oblist("QUOTE", mdl_value_root_oblist);



    if (apply_to) argptr = LREST(apply_to, 1);

    if (!fargs || fargs->type != MDL_TYPE_LIST)
        mdl_error("Formal arguments must be LIST");

    mdl_value_t *fargp = LREST(fargs, 0);
    enum {
        ARGSTATE_INITIAL, // looking for atoms or string
        ARGSTATE_BIND,    // just got the bind, looking for one atom
        ARGSTATE_ATOMS,   // looking for atoms or string other than BIND
        ARGSTATE_CALL,    // looking for a single atom
        ARGSTATE_OPTIONAL,// looking for atoms, 2 lists, or string
        ARGSTATE_ARGS,    // looking for a single atom
        ARGSTATE_TUPLE,   // looking for a single atom
        ARGSTATE_ANONLY,  // No more args, looking for AUX or NAME
        ARGSTATE_AUX,     // looking for atoms or 2-lists
        ARGSTATE_NAME,    // looking for atom
        ARGSTATE_NOMORE   // that's it, nothing else
    }  argstate = ARGSTATE_INITIAL;
    if (auxonly) argstate = ARGSTATE_AUX;

    int args_processed = 0;
    while (fargp)
    {
        mdl_value_t *farg = fargp->v.p.car;
        mdl_value_t *default_val = &mdl_value_unassigned;

        if (farg->type == MDL_TYPE_LIST)
        {
            default_val = LITEM(farg, 1);
            if (!default_val || LHASITEM(farg, 2))
                mdl_error("Only lists allowed in arg lists are 2-lists");
            farg = LITEM(farg, 0);
            if (farg->type != MDL_TYPE_FORM && farg->type != MDL_TYPE_ATOM)
                mdl_error("First element in 2-list must be atom or quoted atom");
            if (argstate != ARGSTATE_OPTIONAL && argstate != ARGSTATE_AUX)
                return mdl_call_error_ext("FIXME", "2-lists allowed only in OPTIONAL or AUX sections", NULL);
        }

        if (farg->type == MDL_TYPE_STRING)
        {
            if (mdl_string_equal_cstr(&farg->v.s, "BIND"))
            {
                if (argstate != ARGSTATE_INITIAL)
                    mdl_error("BIND must be first thing in argument list");
                argstate = ARGSTATE_BIND;
            }
            else if (mdl_string_equal_cstr(&farg->v.s, "CALL"))
            {
                if ((argstate != ARGSTATE_INITIAL &&
                     argstate != ARGSTATE_ATOMS)
                    || args_processed)
                    mdl_error("CALL must be the only argment-gatherer");
                if (called_from_apply_subr)
                    mdl_error("CALL not allowed when called from APPLY");
                argstate = ARGSTATE_CALL;
            }
            else if (mdl_string_equal_cstr(&farg->v.s, "OPT") ||
                mdl_string_equal_cstr(&farg->v.s, "OPTIONAL"))
            {
                if (argstate != ARGSTATE_INITIAL &&
                    argstate != ARGSTATE_ATOMS)
                    mdl_error("OPTIONAL in wrong place in argument string");
                argstate = ARGSTATE_OPTIONAL;
            }
            else if (mdl_string_equal_cstr(&farg->v.s, "ARGS"))
            {
                if (argstate != ARGSTATE_INITIAL &&
                    argstate != ARGSTATE_ATOMS &&
                    argstate != ARGSTATE_OPTIONAL)
                    mdl_error("ARGS in wrong place in argument string");
                if (called_from_apply_subr)
                    mdl_error("ARGS not allowed when called from APPLY");
                argstate = ARGSTATE_ARGS;
            }
            else if (mdl_string_equal_cstr(&farg->v.s, "TUPLE"))
            {
                if (argstate != ARGSTATE_INITIAL &&
                    argstate != ARGSTATE_ATOMS && 
                    argstate != ARGSTATE_OPTIONAL
                    )
                    mdl_error("TUPLE in wrong place in argument string");
                argstate = ARGSTATE_TUPLE;
            }
            else if (mdl_string_equal_cstr(&farg->v.s, "AUX") 
                || mdl_string_equal_cstr(&farg->v.s, "EXTRA"))
            {
                if (argstate != ARGSTATE_INITIAL &&
                    argstate != ARGSTATE_ATOMS && 
                    argstate != ARGSTATE_OPTIONAL &&
                    argstate != ARGSTATE_ANONLY
                    )
                    mdl_error("AUX/EXTRA in wrong place in argument string");
                argstate = ARGSTATE_AUX;
            }
            else if (mdl_string_equal_cstr(&farg->v.s, "NAME") 
                     || mdl_string_equal_cstr(&farg->v.s, "ACT"))
            {
                if (argstate != ARGSTATE_INITIAL &&
                    argstate != ARGSTATE_ATOMS && 
                    argstate != ARGSTATE_OPTIONAL &&
                    argstate != ARGSTATE_ANONLY &&
                    argstate != ARGSTATE_AUX
                    )
                    mdl_error("NAME/ACT in wrong place in argument string");
                argstate = ARGSTATE_NAME;
            }
        }
        else if (farg->type == MDL_TYPE_ATOM)
        {
            switch (argstate)
            {
            case ARGSTATE_INITIAL:
            case ARGSTATE_ATOMS:
            case ARGSTATE_OPTIONAL:
                if (argptr)
                {
                    mdl_value_t *arg = argptr->v.p.car;
                    if (!called_from_apply_subr)
                        arg = mdl_eval(arg, false, mdl_make_frame_value(prev_frame));
                    if (!mdl_bind_local_symbol(farg->v.a, arg, frame, false))
                        return mdl_call_error_ext ("BAD-ARGUMENT-LIST", "Duplicate formal argument", farg, fargs, NULL);
                    argptr = argptr->v.p.cdr;
                    args_processed++;
                }
                else if (argstate != ARGSTATE_OPTIONAL)
                {
                    return mdl_call_error("TOO-FEW-ARGUMENTS-SUPPLIED", frame->subr, NULL);
                }
                else 
                {
                    if (default_val != &mdl_value_unassigned)
                        default_val = mdl_eval(default_val);

                    if (!mdl_bind_local_symbol(farg->v.a, default_val, frame, false))
                        return mdl_call_error_ext ("BAD-ARGUMENT-LIST", "Duplicate formal argument", farg, fargs, NULL);
                }

                break;
            case ARGSTATE_BIND:
            {
                mdl_value_t *pframeval = mdl_make_frame_value(prev_frame, MDL_TYPE_ENVIRONMENT);
                if (!mdl_bind_local_symbol(farg->v.a, pframeval, frame, false))
                    return mdl_call_error_ext ("BAD-ARGUMENT-LIST", "Duplicate formal argument", farg, fargs, NULL);
                argstate = ARGSTATE_ATOMS;
                break;
            }
            case ARGSTATE_CALL:
                if (!mdl_bind_local_symbol(farg->v.a, apply_to, frame, false))
                    return mdl_call_error_ext ("BAD-ARGUMENT-LIST", "Duplicate formal argument", farg, fargs, NULL);
                argstate = ARGSTATE_ANONLY;
                argptr = NULL;
                break;
            case ARGSTATE_ARGS:
            {
                mdl_value_t *argsval = mdl_make_list(argptr);
                if (!mdl_bind_local_symbol(farg->v.a, argsval, frame, false))
                    return mdl_call_error_ext ("BAD-ARGUMENT-LIST", "Duplicate formal argument", farg, fargs, NULL);
                argstate = ARGSTATE_ANONLY;
                argptr = NULL;
                break;
            }
            case ARGSTATE_TUPLE:
            {
                // fixme -- need a better way of switching frames
                // probably just need to switch at AUX or first time
                // OPT argument isn't found
                mdl_value_t *argsval;
                if (!called_from_apply_subr)
                {
                    mdl_frame_t *save_frame = cur_frame;
                    cur_frame = prev_frame;

                    argsval = mdl_std_eval(mdl_make_list(argptr), false, MDL_TYPE_LIST);
                    if (argsval)
                        argsval = mdl_make_tuple(LREST(argsval, 0), MDL_TYPE_TUPLE);
                    cur_frame = save_frame;
                }
                else
                {
                    argsval = mdl_make_tuple(argptr, MDL_TYPE_TUPLE);
                }
                if (!mdl_bind_local_symbol(farg->v.a, argsval, frame, false))
                    return mdl_call_error_ext ("BAD-ARGUMENT-LIST", "Duplicate formal argument", farg, fargs, NULL);
                argstate = ARGSTATE_ANONLY;
                argptr = NULL;
                break;
            }
            case ARGSTATE_NAME:
            {
                mdl_value_t *cframeval = mdl_make_frame_value(frame, MDL_TYPE_ACTIVATION);
                if (!mdl_bind_local_symbol(farg->v.a, cframeval, frame, false))
                    return mdl_call_error_ext ("BAD-ARGUMENT-LIST", "Duplicate formal argument", farg, fargs, NULL);
                argstate = ARGSTATE_NOMORE;
                break;
            }
            case ARGSTATE_AUX:
                if (default_val != &mdl_value_unassigned)
                    default_val = mdl_eval(default_val);
                if (!mdl_bind_local_symbol(farg->v.a, default_val, frame, false))
                    return mdl_call_error_ext ("BAD-ARGUMENT-LIST", "Duplicate formal argument", farg, fargs, NULL);
                break;
            default:
                mdl_error("Unexpected ATOM in formal argument list");
            }
        }
        else if (farg->type == MDL_TYPE_FORM)
        {
            mdl_value_t *atom = LITEM(farg, 1);
            mdl_value_t *quote = LITEM(farg, 0);
            if (!atom ||
                atom->type != MDL_TYPE_ATOM ||
                LHASITEM(farg, 2) ||
                !mdl_value_equal(quote, mdl_value_atom_quote)
                )
                mdl_error("FORM in arg list may only be <QUOTE atom>");
            if (called_from_apply_subr)
                mdl_error("Can't use APPLY to call a function with quoted arguments");
            switch (argstate)
            {
            case ARGSTATE_INITIAL:
            case ARGSTATE_ATOMS:
            case ARGSTATE_OPTIONAL:
                if (argptr)
                {
                    mdl_value_t *arg = argptr->v.p.car;
                    if (!mdl_bind_local_symbol(atom->v.a, arg, frame, false))
                        return mdl_call_error_ext ("BAD-ARGUMENT-LIST", "Duplicate formal argument", farg, fargs, NULL);
                    argptr = argptr->v.p.cdr;
                    args_processed++;
                }
                else if (argstate != ARGSTATE_OPTIONAL)
                    mdl_error("Too few args in function call");
                else
                {
                    if (default_val != &mdl_value_unassigned)
                        default_val = mdl_eval(default_val);

                    if (!mdl_bind_local_symbol(atom->v.a, default_val, frame, false))
                        return mdl_call_error_ext ("BAD-ARGUMENT-LIST", "Duplicate formal argument", farg, fargs, NULL);
                }
                break;
            default:
                mdl_error("Unexpected quoted ATOM in formal argument list");
            }
        }
        fargp = fargp->v.p.cdr;
    }
    if (argptr != NULL)
        return mdl_call_error("TOO-MANY-ARGUMENTS-SUPPLIED", NULL);
    return NULL;
}

mdl_value_t *mdl_internal_prog_repeat_bind(mdl_value_t *orig_form, bool bind_to_lastprog, bool repeat)
{
    mdl_frame_t *frame = mdl_new_frame();
    mdl_frame_t *prev_frame = cur_frame;
    mdl_value_t *fargsp = LREST(orig_form, 1);
    mdl_value_t *fargs;
    mdl_value_t *act_atom = NULL;
    int jumpval;
    bool first;
    frame->prev_frame = prev_frame;
    
    if (fargsp->v.p.car->type == MDL_TYPE_ATOM)
    {
        act_atom = fargsp->v.p.car;
        fargsp = fargsp->v.p.cdr;
    }
    fargs = fargsp->v.p.car;

    if (bind_to_lastprog || act_atom)
    {
        mdl_value_t *activation = mdl_make_frame_value(frame, MDL_TYPE_ACTIVATION);
        if (bind_to_lastprog)
            mdl_bind_local_symbol(mdl_value_atom_lastprog->v.a, activation, frame, false);
        if (act_atom)
            mdl_bind_local_symbol(act_atom->v.a, activation, frame, false);
    }
    
    frame->frame_flags = MDL_FRAME_FLAGS_ACTIVATION;
    mdl_push_frame(frame);
    
    mdl_bind_args(fargs, NULL, frame, prev_frame,
                  false /* not called from apply */,
                  true /* AUX arguments only */);

    jumpval = mdl_setjmp(frame->interp_frame);
    // RETURN and AGAIN come here
    first = (jumpval == 0) || (jumpval == LONGJMP_AGAIN);
    while (first || (repeat && !frame->result))
    {
        first = false;
        mdl_value_t *fexprs = fargsp->v.p.cdr;
        mdl_value_t *mdl_last_value = NULL;
        while (fexprs)
        {
            mdl_last_value = mdl_eval(fexprs->v.p.car, false);
            fexprs = fexprs->v.p.cdr;
        }
        if (mdl_last_value == NULL) mdl_last_value = mdl_call_error("HAS_EMPTY_BODY", NULL);
        if (!repeat) frame->result = mdl_last_value;
    }
    mdl_pop_frame(frame->prev_frame);
    return frame->result;
}

mdl_value_t *mdl_apply_function(mdl_value_t *applier, mdl_value_t *apply_to, bool called_from_apply_subr)
{
    mdl_frame_t *frame = mdl_new_frame();
    mdl_frame_t *prev_frame = cur_frame;
    mdl_value_t *fargsp, *fargs;
    mdl_value_t *fname;
    
    frame->prev_frame = prev_frame;
    frame->frame_flags = MDL_FRAME_FLAGS_ACTIVATION;
    fname = LITEM(apply_to, 0);
    if (fname->type == MDL_TYPE_ATOM)
    {
        frame->frame_flags |= MDL_FRAME_FLAGS_NAMED_FUNC;
        frame->subr = fname;
        // these are actually unevaluated args, but for debugging it will do
        frame->args = mdl_make_list(LREST(apply_to, 1));
    }

    if (applier->pt != PRIMTYPE_LIST)
        mdl_error("A FUNCTION must be of primtype LIST");

    fargsp = LREST(applier, 0);
    fargs = fargsp->v.p.car;
    if (fargs && fargs->type == MDL_TYPE_ATOM)
    {
        mdl_value_t *activation = mdl_make_frame_value(frame, MDL_TYPE_ACTIVATION);
        mdl_bind_local_symbol(fargs->v.a, activation, frame, false);
        fargsp = fargsp->v.p.cdr;
        fargs = fargsp->v.p.car;
    }

    mdl_push_frame(frame);
    if (!mdl_setjmp(frame->interp_frame))
    {
        // mdl_bind_args returns NULL on success, return from ERRET on error
        frame->result = 
            mdl_bind_args(fargs, apply_to, frame, prev_frame,
                      called_from_apply_subr, false);
    }

    // RETURN and AGAIN come here (if there is an activation)
    if (!frame->result)
    {
        mdl_value_t *fexprs = LREST(applier, 1);
        mdl_value_t *mdl_last_value = NULL;
        while (fexprs)
        {
            mdl_last_value = mdl_eval(fexprs->v.p.car, false);
            fexprs = fexprs->v.p.cdr;
        }
        if (mdl_last_value == NULL)
            mdl_last_value = mdl_call_error("HAS-EMPTY-BODY", NULL);
        frame->result = mdl_last_value;
    }

    mdl_pop_frame(frame->prev_frame);
    return frame->result;
}

mdl_value_t *mdl_internal_expand(mdl_value_t *arg)
{
    mdl_frame_t *expand_frame;
    mdl_frame_t *save_frame;
    mdl_value_t *macro;
    mdl_value_t *result;
    int jumpval;

    expand_frame = mdl_new_frame();
    expand_frame->subr = cur_frame->subr; 
    save_frame = cur_frame;
    NEW_BINDID(cur_process_bindid);
    if ((jumpval = mdl_setjmp(expand_frame->interp_frame)) != 0)
    {
        // error handling
        mdl_longjmp_to(save_frame, jumpval);
    }
    if (mdl_eval_type(arg->type) == MDL_TYPE_FORM &&
        (macro = LITEM(arg, 0)) &&
        (macro = mdl_eval_apply_expr(macro)) &&
        (mdl_apply_type(macro->type) == MDL_TYPE_MACRO))
    {
//        printf("expand macro\n");
//        mdl_print_value(stdout, macro);
//        printf("\non form\n");
//        mdl_print_value(stdout, arg);
//        printf("\n");
        result = mdl_apply_function(macro, arg, false);
    }
    else
    {
        printf("eval top-level form\n");
        mdl_print_value(stdout, arg);
        result = mdl_eval(arg, false);
    }
    cur_frame = save_frame;
    NEW_BINDID(cur_process_bindid);
    return result;
}

bool mdl_type_is_applicable(int type)
{
    switch (type)
    {
    case MDL_TYPE_CLOSURE:
    case MDL_TYPE_FIX:
    case MDL_TYPE_FSUBR:
    case MDL_TYPE_FUNCTION:
    case MDL_TYPE_MACRO:
    case MDL_TYPE_OFFSET:
    case MDL_TYPE_SUBR:
    case MDL_TYPE_NOTATYPE: // custom application
        // compiled stuff -- is not and will not be implemented
//    case MDL_TYPE_QUICK_ENTRY:
//    case MDL_TYPE_QUICK_RSUBR:
//    case MDL_TYPE_RSUBR:
//    case MDL_TYPE_RSUBR_ENTRY:
        return true;
    default:
        return false;
    }
}

// this is not the SUBR APPLY.  Rather, it is the internal function used to
// apply things.  The apply_to is the FORM to be applied, including the
// first element.  
// If called from the apply subr, the apply_to is
// pre-evaluated.  For simplicity it contains a list where the first item
// is the eval of the thing applied.

mdl_value_t *mdl_std_apply(mdl_value_t *applier, mdl_value_t *apply_to, int apply_as, bool called_from_apply_subr)
{
    if (apply_as == MDL_TYPE_NOTATYPE) apply_as = applier->type;
    if (apply_as == MDL_TYPE_SUBR || 
        apply_as == MDL_TYPE_FSUBR)
    {
        if (applier->v.w < (MDL_INT)built_in_table.size())
        {
            mdl_built_in_t built_in = built_in_table[applier->v.w];
            mdl_frame_t *frame;
            mdl_value_t *result;
            mdl_value_t *arglist;
            int jumpval;
            
            if (apply_as == MDL_TYPE_FSUBR && called_from_apply_subr)
                mdl_error("Can't use APPLY with FSUBRs");

            frame = mdl_new_frame();
            frame->subr = built_in.a;
            if (apply_as == MDL_TYPE_FSUBR || called_from_apply_subr)
                arglist = mdl_make_list(apply_to->v.p.cdr->v.p.cdr);
            else
                arglist = mdl_std_eval(mdl_make_list(apply_to->v.p.cdr->v.p.cdr));
            frame->args = arglist;
            frame->prev_frame = cur_frame;
            frame->frame_flags = MDL_FRAME_FLAGS_TRUEFRAME;
            mdl_push_frame(frame);
            jumpval = mdl_setjmp(frame->interp_frame);
            if (jumpval == 0 || jumpval == LONGJMP_RETRY)
            {
                result = built_in.proc(apply_to, arglist);
            }
            else if (jumpval == LONGJMP_ERRET)
            {
                result = frame->result;
            }
            else
            {
                fprintf(stderr, "Bad longjmp in F/SUBR apply: %d", jumpval);
                //Huh?  pass it on
                mdl_longjmp_to(cur_frame->prev_frame, jumpval);
            }
            mdl_pop_frame(frame->prev_frame);
            return result;
        }
        else
            mdl_error("Invalid built-in");
    }
    else if (apply_as == MDL_TYPE_FUNCTION)
    {
        return mdl_apply_function(applier, apply_to, called_from_apply_subr);
    }
    else if (apply_as == MDL_TYPE_MACRO)
    {
        if (called_from_apply_subr)
            mdl_error("Can't use APPLY with MACROs"); // I don't think
        return mdl_eval(mdl_internal_expand(apply_to), false);
    }
    else if (apply_as == MDL_TYPE_FIX)
    {
        mdl_frame_t *frame;
        mdl_value_t *result;
        frame = mdl_new_frame();
        frame->prev_frame = cur_frame;
        frame->subr = applier;
        // args is not quite right; it should be evalled
        frame->args = mdl_make_list(LREST(apply_to, 1));
        frame->frame_flags = MDL_FRAME_FLAGS_TRUEFRAME;
        mdl_push_frame(frame);

        // handle this case in APPLY, because MAPF/MAPR need to be able
        // to do this
//        if (called_from_apply_subr)
//            mdl_error("Can't use APPLY with FIXes");

        if (LHASITEM(apply_to, 3))
            mdl_call_error_ext("TOO-MANY-ARGUMENTS-SUPPLIED", "Too many arguments to FIX", NULL);
        if (!LHASITEM(apply_to, 1))
            mdl_call_error_ext("TOO-FEW-ARGUMENTS-SUPPLIED","Too few arguments to FIX", NULL);
        mdl_value_t *index = applier;
        mdl_value_t *struc = LITEM(apply_to, 1);
        mdl_value_t *newitem = LITEM(apply_to, 2);
        
        if (!called_from_apply_subr)
        {
            struc = mdl_eval(struc);
            if (newitem) newitem = mdl_eval(newitem);
        }
        if (newitem)
            result = mdl_internal_eval_put(struc, index, newitem);
        else
            result = mdl_internal_eval_nth_copy(struc, index);
        mdl_pop_frame(frame->prev_frame);
        return result;
    }
    else
        return mdl_call_error("NON-APPLICABLE-TYPE", applier, apply_to, NULL);
    return NULL;
}

mdl_value_t *mdl_internal_apply(mdl_value_t *applier, mdl_value_t *apply_to, bool called_from_apply_subr)
{
    int apply_as = MDL_TYPE_NOTATYPE;
    mdl_value_t *applytype = mdl_get_applytype(applier->type);

    if (applytype && applytype->type != MDL_TYPE_ATOM)
    {
        apply_to = mdl_cons_internal(applier, LREST(apply_to, 1));
        apply_to = mdl_cons_internal(applytype, apply_to);
        apply_to = mdl_make_list(apply_to);
        return mdl_std_apply(applytype, apply_to, apply_as, called_from_apply_subr);
    }
    else
    {
        if (applytype)
        {
            apply_as = mdl_get_typenum(applytype);
            if (apply_as == MDL_TYPE_NOTATYPE)
                mdl_error("BAD APPLYTYPE: atom not a type");
        }
        return mdl_std_apply(applier, apply_to, apply_as, called_from_apply_subr);
    }
}

int mdl_eval_type(int t)
{
    // the type this type evaluates as, or MDL_TYPE_NOTATYPE
    // for custom evaluation
    mdl_value_t *evaltype = mdl_get_evaltype(t);
    if (evaltype)
    {
        if (evaltype->type == MDL_TYPE_ATOM)
            return mdl_get_typenum(evaltype);
        return MDL_TYPE_NOTATYPE;
    }
    return t;
}

int mdl_apply_type(int t)
{
    // the type this type ultmately should be applied as, or MDL_TYPE_NOTATYPE
    // for custom application
    mdl_value_t *applytype = mdl_get_applytype(t);
    if (applytype)
    {
        if (applytype->type == MDL_TYPE_ATOM)
            return mdl_get_typenum(applytype);
        return MDL_TYPE_NOTATYPE;
    }
    return t;
    return t;
}

typedef mdl_value_t *mdl_walker_next_t(struct mdl_struct_walker_t *w);
typedef mdl_value_t *mdl_walker_rest_t(struct mdl_struct_walker_t *w);

typedef struct mdl_struct_walker_t
{
    mdl_walker_next_t *next;
    mdl_walker_rest_t *rest;
    mdl_value_t *sv; // original structure
    mdl_value_t *vle; // vector/tuple/list element
    uvector_element_t *uve; // uvector element
    char *se;   // string element
    int length; // remaining length vector/uvector/string
} mdl_struct_walker_t;

mdl_value_t *mdl_next_list_element(mdl_struct_walker_t *w)
{
    if (!w->vle) return NULL;
    w->vle = w->vle->v.p.cdr;
    if (!w->vle) return NULL;
    mdl_value_t *result = w->vle->v.p.car;
    return result;
}

mdl_value_t *mdl_next_vector_tuple_element(mdl_struct_walker_t *w)
{
    // note: must not execute GROW for a vector while a walker is active on it
    w->vle++;
    w->length--;
    if (w->length <= 0) return NULL;
    mdl_value_t *result = w->vle;
    return result;
}

mdl_value_t *mdl_next_uvector_element(mdl_struct_walker_t *w)
{
    // note: must not execute GROW for a uvector while a walker is active on it
    w->uve++;
    w->length--;
    if (w->length <= 0) return NULL;
    mdl_value_t *result = mdl_uvector_element_to_value(w->sv, w->uve);
    return result;
}

mdl_value_t *mdl_next_string_element(mdl_struct_walker_t *w)
{
    w->se++;
    w->length--;
    if (w->length <= 0) return NULL;
    mdl_value_t *result = mdl_new_fix((int)(*w->se));
    result->type = MDL_TYPE_CHARACTER;
    return result;
}

mdl_value_t *mdl_rest_string_element(mdl_struct_walker_t *w)
{
    return mdl_make_string(w->length, w->se);
}

mdl_value_t *mdl_rest_list_element(mdl_struct_walker_t *w)
{
    return mdl_make_list(w->vle, MDL_TYPE_LIST);
}

mdl_value_t *mdl_rest_vector_element(mdl_struct_walker_t *w)
{
    mdl_value_t *result = mdl_new_mdl_value();
    result->pt = PRIMTYPE_VECTOR;
    result->type = MDL_TYPE_VECTOR;
    result->v.v.p = w->sv->v.v.p;
    result->v.v.offset = w->sv->v.v.offset + (w->vle - VREST(w->sv, 0));
    return result;
}

mdl_value_t *mdl_rest_tuple_element(mdl_struct_walker_t *w)
{
    mdl_value_t *result = mdl_new_mdl_value();
    result->pt = PRIMTYPE_TUPLE;
    result->type = MDL_TYPE_TUPLE;
    result->v.tp.p = w->sv->v.tp.p;
    result->v.tp.offset = w->sv->v.tp.offset + (w->vle - TPREST(w->sv, 0));
    return result;
}

mdl_value_t *mdl_rest_uvector_element(mdl_struct_walker_t *w)
{
    mdl_value_t *result = mdl_new_mdl_value();
    result->pt = PRIMTYPE_UVECTOR;
    result->type = MDL_TYPE_UVECTOR;
    result->v.uv.p = w->sv->v.uv.p;
    result->v.uv.offset = w->sv->v.tp.offset + (w->uve - UVREST(w->sv, 0));
    return result;
}

void mdl_init_struct_walker(mdl_struct_walker_t *w, mdl_value_t *sv)
{
    w->sv = sv;
    switch(sv->pt)
    {
    case PRIMTYPE_LIST:
        w->vle = sv;
        w->next = mdl_next_list_element;
        w->rest = mdl_rest_list_element;
        break;
    case PRIMTYPE_VECTOR:
        w->vle = VREST(sv, 0) - 1;
        w->length = VLENGTH(sv) + 1;
        w->next = mdl_next_vector_tuple_element;
        w->rest = mdl_rest_vector_element;
        break;
    case PRIMTYPE_TUPLE:
        w->vle = TPREST(sv, 0) - 1;
        w->length = TPLENGTH(sv) + 1;
        w->next = mdl_next_vector_tuple_element;
        w->rest = mdl_rest_tuple_element;
        break;

    case PRIMTYPE_UVECTOR:
        w->uve = UVREST(sv, 0) - 1;
        w->length = UVLENGTH(sv) + 1;
        w->next = mdl_next_uvector_element;
        w->rest = mdl_rest_uvector_element;
        break;

    case PRIMTYPE_STRING:
        w->se = sv->v.s.p - 1;
        w->length = sv->v.s.l + 1;
        w->next = mdl_next_string_element;
        w->rest = mdl_rest_string_element;
        break;
    }
}

mdl_value_t *mdl_internal_shallow_copy_list(mdl_value_t *oldlist)
{
    mdl_value_t *result = NULL;
    mdl_value_t *cursor = NULL;
    mdl_value_t *lastitem = NULL;
    if (oldlist)
    {
        lastitem = cursor = result = mdl_newlist();
        cursor->v.p.car = oldlist->v.p.car;
        oldlist = oldlist->v.p.cdr;
    }
    while (oldlist)
    {
        cursor = mdl_newlist();
        cursor->v.p.car = oldlist->v.p.car;
        lastitem->v.p.cdr = cursor;
        lastitem = cursor;
        oldlist = oldlist->v.p.cdr;
    }
    return result;
}

mdl_value_t *mdl_internal_copy_structured(mdl_value_t *v)
{
    mdl_value_t *copy;
    switch(v->pt)
    {
    case PRIMTYPE_LIST:
        copy = mdl_make_list(mdl_internal_shallow_copy_list(LREST(v,0)));
        break;
    case PRIMTYPE_VECTOR:
        copy = mdl_new_empty_vector(VLENGTH(v), MDL_TYPE_VECTOR);
        memcpy(VREST(copy, 0), VREST(v,0), VLENGTH(v) * sizeof(mdl_value_t));
        break;
    case PRIMTYPE_TUPLE:
        copy = mdl_new_empty_vector(TPLENGTH(v), MDL_TYPE_VECTOR);
        memcpy(VREST(copy, 0), TPREST(v,0), TPLENGTH(v) * sizeof(mdl_value_t));
        break;
    case PRIMTYPE_UVECTOR:
        copy = mdl_new_empty_uvector(UVLENGTH(v), MDL_TYPE_UVECTOR);
        memcpy(UVREST(copy, 0), UVREST(v,0), UVLENGTH(v) * sizeof(uvector_element_t));
        break;
    case PRIMTYPE_STRING:
        copy = mdl_new_string(v->v.s.l, v->v.s.p);
        break;
    default:
        return NULL;
    }
    return copy;
}

int mdl_internal_list_length(mdl_value_t *l)
{
    /* returns the length of an "internal" list lacking its initial word */
    int length = 0;
    mdl_value_t *cursor = l;

    while (cursor)
    {
        cursor = cursor->v.p.cdr;
        length++;
    }
    return length;
}

int mdl_internal_struct_length(mdl_value_t *sv)
{
    int length = -1;
    switch(sv->pt)
    {
    case PRIMTYPE_LIST:
    {
        mdl_value_t *cursor = sv->v.p.cdr;
        length = 0;
        while (cursor)
        {
            cursor = cursor->v.p.cdr;
            length++;
        }
        break;
    }
    case PRIMTYPE_VECTOR:
        length = VLENGTH(sv);
        break;
    case PRIMTYPE_TUPLE:
        length = TPLENGTH(sv);
        break;
    case PRIMTYPE_UVECTOR:
        length = UVLENGTH(sv);
        break;
    case PRIMTYPE_STRING:
        length = sv->v.s.l;
        break;
    }
    return length;
}

void mdl_resize_vector(mdl_value_t *v, int addend, int addbeg, bool makelose)
{
    int newsize;
    int sizechange = addbeg + addend;
    switch (v->pt)
    {
    case PRIMTYPE_VECTOR:
    {
        int saveelements = v->v.v.p->size;
        if ((addend == 0) && (addbeg == 0))
            return;

        newsize = v->v.v.p->size + sizechange;
        mdl_value_t *elems;
        if (addbeg < 0) saveelements += addbeg;
        if (addend < 0) saveelements += addend;
        elems = v->v.v.p->elements;
        
        if (sizechange > 0)
            elems = (mdl_value_t *)GC_MALLOC_IGNORE_OFF_PAGE(newsize * sizeof(mdl_value_t));
        if ((addbeg > 0) || (addbeg == 0 && sizechange > 0))
            memmove(elems + addbeg, v->v.v.p->elements, saveelements * sizeof(mdl_value_t));
        else if (addbeg < 0)
            memmove(elems, v->v.v.p->elements - addbeg, saveelements * sizeof(mdl_value_t));
        if (sizechange < 0)
            elems = (mdl_value_t *)GC_REALLOC(elems, newsize * sizeof(mdl_value_t));
        
        if (makelose) 
        {
            int loseme;
            mdl_value_t *loser;
            loser = elems;
            for (loseme = 0; loseme < addbeg; loseme++)
            {
                loser->pt = PRIMTYPE_WORD;
                loser->type = MDL_TYPE_LOSE;
                loser++;
            }
            loseme += saveelements;
            for (loseme = 0; loseme < addend; loseme++)
            {
                loser->pt = PRIMTYPE_WORD;
                loser->type = MDL_TYPE_LOSE;
                loser++;
            }
        }
        v->v.v.p->size = newsize;
        v->v.v.p->startoffset += addbeg;
        v->v.v.p->elements = elems;
        break;
    }
    case PRIMTYPE_UVECTOR:
    {
        int saveelements = v->v.uv.p->size;
        newsize = v->v.uv.p->size + sizechange;
        uvector_element_t *elems;
        if (addbeg < 0) saveelements += addbeg;
        if (addend < 0) saveelements += addend;
        elems = v->v.uv.p->elements;
        
        if (sizechange > 0)
            elems = (uvector_element_t *)GC_MALLOC_IGNORE_OFF_PAGE(newsize * sizeof(uvector_element_t));
        if ((addbeg > 0) || (addbeg == 0 && sizechange > 0))
            memmove(elems + addbeg, v->v.uv.p->elements, saveelements * sizeof(uvector_element_t));
        else if (addbeg < 0)
            memmove(elems, v->v.uv.p->elements - addbeg, saveelements * sizeof(uvector_element_t));
        if (sizechange < 0)
            elems = (uvector_element_t *)GC_REALLOC(elems, newsize * sizeof(uvector_element_t));
        if (makelose) 
        {
            if (addbeg > 0)
                memset(elems, 0, addbeg * sizeof(uvector_element_t));
            if (addend > 0)
                memset(elems + newsize - addend, 0, addend * sizeof(uvector_element_t));
        }
        v->v.uv.p->size = newsize;
        v->v.uv.p->startoffset += addbeg;
        v->v.uv.p->elements = elems;
    }
    break;
    default:
        mdl_error("Resize of unsupported type");
    }
}

//mdl_eval_apply_expr does the special evaluation of the first
//item of a form -- if an atom, returns gval, then lval, otherwise
//standard application
mdl_value_t *mdl_eval_apply_expr(mdl_value_t *appl_expr)
{
    mdl_value_t *applier;
    if (appl_expr->type == MDL_TYPE_ATOM)
    {
        applier = mdl_global_symbol_lookup(appl_expr->v.a);
        if (!applier || applier->type == MDL_TYPE_UNBOUND)
            applier = mdl_local_symbol_lookup(appl_expr->v.a);
        if (!applier || applier->type == MDL_TYPE_UNBOUND)
        {
            return mdl_call_error_ext("UNBOUND-VARIABLE", "In apply of form", appl_expr, NULL);
        }
    }
    else
    {
        applier = mdl_eval(appl_expr, false);
    }
    return applier;
}

mdl_value_t *mdl_std_eval(mdl_value_t *l, bool in_struct, int as_type)
{
    mdl_value_t *result = NULL;
    if (as_type == MDL_TYPE_NOTATYPE) as_type = l->type;
    switch (as_type)
    {
    case MDL_TYPE_LIST:
    {
        mdl_value_t *rest = l->v.p.cdr;
        mdl_value_t *lastitem = NULL;
        while (rest)
        {
            mdl_value_t *item = rest->v.p.car;
            rest = rest->v.p.cdr;
            if (mdl_eval_type(item->type) == MDL_TYPE_SEGMENT)
            {
                mdl_value_t *seg = mdl_eval(item, true);
                if (mdl_primtype_nonstructured(seg->pt))
                {
                    return mdl_call_error_ext("ILLEGAL-SEGMENT","Segment evaluated to nonstructured type", item, NULL);
                }
                if (!rest && seg->pt == PRIMTYPE_LIST)
                {
                    if (result == NULL)
                    {
                        result = seg->v.p.cdr;
                    }
                    else
                    {
                        lastitem->v.p.cdr = seg->v.p.cdr;
                        // lastitem is now wrong, but it won't be used
                        // again anyway
                    }
                }
                else
                {
                    mdl_value_t *tmp, *elem;
                    mdl_struct_walker_t w;

                    mdl_init_struct_walker(&w, seg);
                    elem = w.next(&w);
                    while (elem)
                    {
                        tmp = mdl_additem(lastitem, elem, &lastitem);
                        if (result == NULL) result = tmp;
                        elem= w.next(&w);
                    }
                }
            }
            else
            {
                // using "lastitem" avoids n^2 behavior
                mdl_value_t *newitem = mdl_eval(item, true);
                mdl_value_t *tmp;
                tmp = mdl_additem(lastitem, newitem, &lastitem);
                if (result == NULL) result = tmp;
            }
        }
        result = mdl_make_list(result);
        break;
    }
    case MDL_TYPE_SEGMENT:
        if (!in_struct)
            return mdl_call_error_ext("ILLEGAL-SEGMENT", "Attempt to evaluate segment outside structured type", NULL);
        /* FALLTHROUGH */
    case MDL_TYPE_FORM:
        if (l->v.p.cdr)
        {
            mdl_value_t *appl_expr = (l->v.p.cdr->v.p.car);
            mdl_value_t *applier = mdl_eval_apply_expr(appl_expr);
            result =  mdl_internal_apply(applier, l, false);
        }
        else
        {
            // an empty form is a FALSE
            result =  mdl_make_list(NULL, MDL_TYPE_FALSE);
        }
        break;
    case MDL_TYPE_VECTOR:
    {
        int vsize = VLENGTH(l);
        int vpos;
        mdl_value_t *elems = VREST(l, 0);
        result = mdl_new_empty_vector(vsize, MDL_TYPE_VECTOR);
        mdl_value_t *relems = VREST(result,0);
        for (vpos = 0; vpos < vsize; vpos++)
        {
            if (mdl_eval_type(elems->type) == MDL_TYPE_SEGMENT)
            {
                mdl_value_t *seg = mdl_eval(elems++, true);
                if (mdl_primtype_nonstructured(seg->pt))
                {
                    mdl_error("Segment evaluated to nonstructured type");
                }
                int seglength = mdl_internal_struct_length(seg);
                mdl_value_t *elem;
                mdl_struct_walker_t w;
                mdl_resize_vector(result, seglength - 1, 0, false);

                relems = VREST(result, vpos);
                mdl_init_struct_walker(&w, seg);
                elem = w.next(&w);
                while (elem)
                {
                    *relems++ = *elem;
                    elem = w.next(&w);
                }
                vpos = vpos + seglength - 1;
                vsize = vsize + seglength - 1;
            }
            else
            {
                mdl_value_t *newval = mdl_eval(elems++, true);
                *relems++ = *newval;
            }
        }
        break;
    }
    case MDL_TYPE_UVECTOR:
    {
        int vsize = UVLENGTH(l);
        int vpos;
        uvector_element_t *elems = UVREST(l, 0);
        result = mdl_new_empty_uvector(vsize, MDL_TYPE_UVECTOR);
        uvector_element_t *relems = UVREST(result,0);
        for (vpos = 0; vpos < vsize; vpos++)
        {
            // a UVECTOR of segments is legal
            
            if (mdl_eval_type(UVTYPE(l)) == MDL_TYPE_SEGMENT)
            {
                mdl_value_t *seg = mdl_uvector_element_to_value(l, elems++);
                seg = mdl_eval(seg, true);
                if (mdl_primtype_nonstructured(seg->pt))
                {
                    mdl_error("Segment evaluated to nonstructured type");
                }
                int seglength = mdl_internal_struct_length(seg);
                mdl_value_t *elem;
                mdl_struct_walker_t w;
                mdl_resize_vector(result, seglength - 1, 0, false);

                relems = UVREST(result, vpos);
                mdl_init_struct_walker(&w, seg);
                elem = w.next(&w);
                while (elem)
                {
                    if (UVTYPE(result) == MDL_TYPE_LOSE)
                    {
                        if (!mdl_valid_uvector_primtype(elem->pt))
                        {
                            mdl_error("Invalid type for UVECTOR");
                        }
                        UVTYPE(result) = elem->type;
                    }
                    else if (UVTYPE(result) != elem->type)
                    {
                        return mdl_call_error("TYPES-DIFFER-IN-UNIFORM-VECTOR", NULL);
                    }
                    mdl_uvector_value_to_element(elem, relems++);
                    elem = w.next(&w);
                }
                vpos = vpos + seglength - 1;
                vsize = vsize + seglength - 1;
            }
            else
            {
                mdl_value_t *newval = mdl_uvector_element_to_value(l, elems++);
                newval = mdl_eval(newval, true);
                if (UVTYPE(result) == MDL_TYPE_LOSE)
                {
                    if (!mdl_valid_uvector_primtype(newval->pt))
                    {
                        mdl_error("Invalid type for UVECTOR");
                    }
                    UVTYPE(result) = newval->type;
                }
                else if (UVTYPE(result) != newval->type)
                {
                    return mdl_call_error("TYPES-DIFFER-IN-UNIFORM-VECTOR", NULL);
                }
                mdl_uvector_value_to_element(newval, relems++);
            }
        }
        break;
    }
    default:
        // atoms, strings, fixes, falses and undefined types
        result = l;
        break;
    }
    return result;
}

mdl_value_t *mdl_eval(mdl_value_t *l, bool in_struct, mdl_value_t *environment)
{
    mdl_frame_t *save_frame = cur_frame;
    mdl_value_t *result = NULL;
    int eval_as_type;
    mdl_value_t *evaltype;
    if (environment)
    {
        cur_frame = environment->v.f;
        NEW_BINDID(cur_process_bindid);
    }

    eval_as_type = l->type;
    evaltype = mdl_get_evaltype(l->type);
    if (evaltype && evaltype->type != MDL_TYPE_ATOM)
    {
        mdl_value_t *arglist = mdl_cons_internal(l, NULL);
        arglist = mdl_cons_internal(evaltype, arglist);
        arglist = mdl_make_list(arglist);
        result = mdl_internal_apply(evaltype, arglist, true);
    }
    else
    {
        if (evaltype)
        {
            eval_as_type = mdl_get_typenum(evaltype);
            if (eval_as_type == MDL_TYPE_NOTATYPE)
                mdl_error("BAD EVALTYPE: atom not a type");
        }
        result = mdl_std_eval(l, in_struct, eval_as_type);
    }
    if (environment)
    {
        cur_frame = save_frame;
        NEW_BINDID(cur_process_bindid);
    }
    return result;
}

mdl_value_t *mdl_set_gval(atom_t *a, mdl_value_t *val)
{
    mdl_symbol_t *symbol = &global_syms[a];
    symbol->binding = val;
    symbol->atom = a;
    return val;
}

mdl_value_t *mdl_set_lval(atom_t *a, mdl_value_t *val, mdl_frame_t *frame)
{
    mdl_local_symbol_t *symbol = mdl_local_symbol_slot(a, frame);
    if (symbol)
    {
        symbol->binding = val;
        symbol->atom = a;
    }
    else
    {
        // Binding on initial stack, not current stack
        mdl_bind_local_symbol(a, val, cur_process_initial_frame, false);
    }
    return val;
}

void mdl_interp_init()
{
    extern void mdl_create_builtins();

    if (sizeof(MDL_FLOAT) != sizeof(MDL_INT))
    {
        // math and UVECTORS don't work right if this isn't true
        // could fix it by making FLOAT its own primtype, but
        // that might break MDL
        printf("sizeof(MDL_FLOAT) %zd != sizeof(MDL_INT) %zd\n", sizeof(MDL_FLOAT), sizeof(MDL_INT));
        exit(-1);
    }

    srand48(1);
    mdl_assoc_table = mdl_create_assoc_table();

    // must initialize root oblist before the built-in types
    mdl_value_initial_oblist = mdl_new_empty_uvector(MDL_OBLIST_HASHBUCKET_DEFAULT, MDL_TYPE_OBLIST);
    UVTYPE(mdl_value_initial_oblist) = MDL_TYPE_LIST;
    mdl_value_root_oblist = mdl_new_empty_uvector(MDL_ROOT_OBLIST_HASHBUCKET_DEFAULT, MDL_TYPE_OBLIST);
    UVTYPE(mdl_value_root_oblist) = MDL_TYPE_LIST;

    mdl_create_builtins();
    mdl_init_built_in_types();

    mdl_value_oblist = mdl_get_atom_from_oblist("OBLIST", mdl_value_root_oblist);
    atom_oblist = mdl_value_oblist->v.a;

    // MUDDLE!- is the version number of MUDDLE.  101 is a lie
    mdl_value_t *muddle = mdl_value_T = mdl_create_atom_on_oblist("MUDDLE", mdl_value_root_oblist);
    mdl_set_gval(muddle->v.a, mdl_new_fix(101));


    mdl_value_T = mdl_create_atom_on_oblist("T", mdl_value_root_oblist);


    mdl_value_atom_redefine = mdl_create_atom_on_oblist("REDEFINE", mdl_value_root_oblist);
    mdl_value_atom_default = mdl_create_atom_on_oblist("DEFAULT", mdl_value_root_oblist);
    mdl_create_atom_on_oblist("OPT", mdl_value_root_oblist); // for DECL checking
    mdl_create_atom_on_oblist("COMMENT", mdl_value_root_oblist);

    mdl_value_t *mdl_value_atom_interrupts = mdl_create_atom_on_oblist("INTERRUPTS", mdl_value_root_oblist);
    mdl_value_t *iobl = mdl_create_oblist(mdl_value_atom_interrupts, MDL_OBLIST_HASHBUCKET_DEFAULT);
    
    mdl_value_atom_lastprog = mdl_create_atom_on_oblist("LPROG ", iobl);
    mdl_value_atom_lastmap = mdl_create_atom_on_oblist("LMAP ", iobl);
    
    mdl_value_t *atomval_initial = mdl_create_atom_on_oblist("INITIAL", mdl_value_root_oblist);
    // ROOT already exists on ROOT because it's a SUBR
    mdl_value_t *atomval_root = mdl_get_atom_from_oblist("ROOT", mdl_value_root_oblist);

    mdl_internal_eval_putprop(mdl_value_initial_oblist, mdl_value_oblist, atomval_initial);
    mdl_internal_eval_putprop(mdl_value_root_oblist, mdl_value_oblist, atomval_root);
    mdl_internal_eval_putprop(atomval_initial, mdl_value_oblist, mdl_value_initial_oblist);
    mdl_internal_eval_putprop(atomval_root, mdl_value_oblist, mdl_value_root_oblist);

    cur_process_bindid = 1;

    initial_frame = mdl_new_frame();
    initial_frame->subr = mdl_get_atom("TOPLEVEL!-", true, NULL);
    initial_frame->frame_flags = MDL_FRAME_FLAGS_TRUEFRAME;

    mdl_value_t *dotoblist = mdl_additem(NULL, mdl_value_initial_oblist);
    mdl_additem(dotoblist, mdl_value_root_oblist);
    mdl_value_t *commaoblist = mdl_internal_shallow_copy_list(dotoblist);
    dotoblist = mdl_make_list(dotoblist);
    commaoblist = mdl_make_list(commaoblist);

    mdl_set_lval(atom_oblist, dotoblist, initial_frame);
    mdl_set_gval(atom_oblist, commaoblist);

    // initialize channels
    mdl_value_t *mdl_value_atom_inchan = mdl_create_atom_on_oblist("INCHAN", mdl_value_root_oblist);
    mdl_value_t *mdl_value_atom_outchan = mdl_create_atom_on_oblist("OUTCHAN", mdl_value_root_oblist);

    mdl_value_t *def_inchan = mdl_create_default_inchan();
    mdl_set_lval(mdl_value_atom_inchan->v.a, def_inchan, initial_frame);
    mdl_set_gval(mdl_value_atom_inchan->v.a, def_inchan);

    mdl_value_t *def_outchan = mdl_create_default_outchan();
    mdl_set_lval(mdl_value_atom_outchan->v.a, def_outchan, initial_frame);
    mdl_set_gval(mdl_value_atom_outchan->v.a, def_outchan);
    
    last_assoc_clean = GC_get_gc_no();
}

bool mdl_is_true(mdl_value_t *item)
{
    if (!item) mdl_call_error("WTF", NULL);
    return item->type != MDL_TYPE_FALSE;
}

mdl_value_t *mdl_boolean_value(bool v)
{
    return v?mdl_value_T:&mdl_value_false;
}

mdl_value_t *mdl_internal_list_rest(const mdl_value_t *val, int skip)
{
    // takes a value of primtype "list", returns the portion of the list without
    // initial "type" element and without the "skip" elements after that
    // i.e. mdl_internal_list_rest(list,0) is the entire list without the type
    // returns null for an empty list, (mdl_value_t *)-1 for error

    if (val->pt != PRIMTYPE_LIST) return (mdl_value_t *)-1;
    mdl_value_t *result = val->v.p.cdr;
    while (skip--)
    {
        if (!result) return (mdl_value_t *)-1;
        result = result->v.p.cdr;
    }
    return result;
}

mdl_value_t *mdl_internal_list_nth(const mdl_value_t *val, int skip)
{
    mdl_value_t *result = mdl_internal_list_rest(val, skip);
    if (result == NULL || (result == (mdl_value_t *)-1)) return NULL;
    return result->v.p.car;
}

mdl_value_t *mdl_internal_vector_rest(const mdl_value_t *val, int skip)
{
    // takes a value of primtype "vector", returns a pointer to the
    // vector items starting at "skip"

    if (val->pt != PRIMTYPE_VECTOR) return (mdl_value_t *)-1;
    mdl_value_t *result = val->v.v.p->elements + val->v.v.offset + val->v.v.p->startoffset + skip;
    return result;
}

mdl_value_t *mdl_internal_tuple_rest(const mdl_value_t *val, int skip)
{
    // takes a value of primtype "tuple", returns a pointer to the
    // vector items starting at "skip"

    if (val->pt != PRIMTYPE_TUPLE) return (mdl_value_t *)-1;
    if (skip >= (val->v.tp.p->size - val->v.tp.offset)) return NULL;
    mdl_value_t *result = val->v.tp.p->elements + val->v.tp.offset + skip;
    return result;
}

uvector_element_t *mdl_internal_uvector_rest(const mdl_value_t *val, int skip)
{
    // takes a value of primtype "uvector", returns a pointer to the
    // uvector elements starting at "skip"

    if (val->pt != PRIMTYPE_UVECTOR) return (uvector_element_t *)-1;
    uvector_element_t *result = val->v.uv.p->elements + val->v.uv.p->startoffset + val->v.uv.offset + skip;
    return result;
}

bool mdl_valid_uvector_primtype(int pt)
{
    switch (pt)
    {
    case PRIMTYPE_ATOM:
    case PRIMTYPE_LIST:
    case PRIMTYPE_WORD:
    case PRIMTYPE_VECTOR:
    case PRIMTYPE_UVECTOR:
        return true;
    }
    return false;
}

mdl_value_t *mdl_uvector_element_to_value(const mdl_value_t *uv, const uvector_element_t *elem, mdl_value_t *to)
{
    if (!to) to = mdl_new_mdl_value();
    to->type = UVTYPE(uv);
    to->pt = mdl_type_primtype(UVTYPE(uv));
    switch (to->pt)
    {
    case PRIMTYPE_ATOM:
        to->v.a = elem->a;
        break;
    case PRIMTYPE_LIST:
        to->v.p.cdr = elem->l;
        break;
    case PRIMTYPE_WORD:
        to->v.w = elem->w;
        break;
    case PRIMTYPE_VECTOR:
        to->v.v = elem->v;
        break;
    case PRIMTYPE_UVECTOR:
        to->v.uv = elem->uv;
        break;
    }
    return to;
}

mdl_value_t *mdl_internal_uvector_nth(const mdl_value_t *val, int skip)
{
    uvector_element_t *elem;

    if (val->pt != PRIMTYPE_UVECTOR) return (mdl_value_t *)-1;
    elem = mdl_internal_uvector_rest(val, skip);
    if (!elem) return NULL;
    return mdl_uvector_element_to_value(val, elem);
}

uvector_element_t *mdl_uvector_value_to_element(const mdl_value_t *newval, uvector_element_t *elem)
{
    switch (newval->pt)
    {
    case PRIMTYPE_ATOM:
        elem->a = newval->v.a;
        break;
    case PRIMTYPE_LIST:
        elem->l = newval->v.p.cdr;
        break;
    case PRIMTYPE_WORD:
        elem->w = newval->v.w;
        break;
    case PRIMTYPE_VECTOR:
        elem->v = newval->v.v;
        break;
    case PRIMTYPE_UVECTOR:
        elem->uv = newval->v.uv;
        break;
    }
    return elem;
}

mdl_value_t *mdl_internal_uvector_put(mdl_value_t *val, int skip, mdl_value_t *newval)
{
    uvector_element_t *elem;

    if (val->pt != PRIMTYPE_UVECTOR) return (mdl_value_t *)-1;
    if (newval->type != UVTYPE(val)) return (mdl_value_t *)-1;
    elem = mdl_internal_uvector_rest(val, skip);
    if (!elem) return NULL;
    mdl_uvector_value_to_element(newval, elem);
    return val;
}

mdl_value_t *mdl_internal_eval_nth(mdl_value_t *arg, mdl_value_t *indexval)
{
    int index = 1;
    if (indexval) 
    {
        if (indexval->type != MDL_TYPE_FIX )
            return mdl_call_error("Second argument to NTH must be a FIX", NULL);
        index = indexval->v.w;
    }
    return mdl_internal_eval_nth_i(arg, index);
}
    
mdl_value_t *mdl_internal_eval_nth_i(mdl_value_t *arg, int index)
{
    if (index <= 0)
        return mdl_call_error("ARGUMENT-OUT-OF-RANGE",NULL);

    mdl_value_t *result;
    switch (arg->pt)
    {
    case PRIMTYPE_LIST:
        result = LITEM(arg, index - 1);
        if (!result)
            return mdl_call_error("ARGUMENT-OUT-OF-RANGE",NULL);
        break;
    case PRIMTYPE_STRING:
        if (index > arg->v.s.l)
            return mdl_call_error("ARGUMENT-OUT-OF-RANGE",NULL);
        result = mdl_new_fix((int)arg->v.s.p[index - 1]);
        result->type = MDL_TYPE_CHARACTER;
        break;
    case PRIMTYPE_VECTOR:
        if (index > VLENGTH(arg))
            return mdl_call_error("ARGUMENT-OUT-OF-RANGE",NULL);
        result = VITEM(arg, index - 1);
        break;
    case PRIMTYPE_UVECTOR:
        if (index > UVLENGTH(arg))
            return mdl_call_error("ARGUMENT-OUT-OF-RANGE",NULL);
        result = UVITEM(arg, index - 1);
        break;
    case PRIMTYPE_TUPLE:
        if (index > TPLENGTH(arg))
            return mdl_call_error("ARGUMENT-OUT-OF-RANGE",NULL);
        result = TPITEM(arg, index - 1);
        break;
    default:
        if (mdl_primtype_nonstructured(arg->pt))
        {
            return mdl_call_error_ext("FIRST-ARG-WRONG-TYPE", "First arg to NTH must be structured", NULL);
        }
        // other structued types such as BYTES
        mdl_error("UNIMPLEMENTED PRIMTYPE");
    }
    return result;
}

mdl_value_t *mdl_internal_eval_nth_copy(mdl_value_t *arg, mdl_value_t *indexval)
{
    // need to ensure that objects internal to other structures aren't
    // returned (in some cases)
    mdl_value_t *val = mdl_internal_eval_nth(arg, indexval);
    if (val && 
        (arg->pt == PRIMTYPE_VECTOR ||
         arg->pt == PRIMTYPE_LIST ||
         arg->pt == PRIMTYPE_TUPLE))
    {
        mdl_value_t *copy = mdl_new_mdl_value();
        *copy = *val;
        return copy;
    }
    return val;
}

bool mdl_internal_struct_is_empty(mdl_value_t *arg)
{
    mdl_value_t *tmp;
    bool result;
    switch (arg->pt)
    {
    case PRIMTYPE_LIST:
        tmp = LREST(arg, 0);
        result = !tmp || (tmp == (mdl_value_t *)-1);
        break;
    case PRIMTYPE_STRING:
        result = arg->v.s.l == 0;
        break;
    case PRIMTYPE_VECTOR:
        result = VLENGTH(arg) == 0;
        break;
    case PRIMTYPE_UVECTOR:
        result = UVLENGTH(arg) == 0;
        break;
    case PRIMTYPE_TUPLE:
        result = TPLENGTH(arg) == 0;
        break;
    default:
        if (mdl_primtype_nonstructured(arg->pt))
        {
            mdl_error("Argument to LENGTH must be structured");
        }
        // BYTES
        mdl_error("UNIMPLEMENTED PRIMTYPE");
    }
    return result;
}

mdl_value_t *mdl_internal_eval_rest_i(mdl_value_t *arg, int index)
{
    mdl_value_t *result;

    if (index < 0)
        mdl_error("REST index too small");

    switch (arg->pt)
    {
    case PRIMTYPE_LIST:
        result = LREST(arg, index);
        if (result == (mdl_value_t *)-1)
            mdl_error("REST index too large");
        result = mdl_make_list(result);
        break;
    case PRIMTYPE_STRING:
        if (index > arg->v.s.l)
            mdl_error("REST index too large");
        result = mdl_make_string(arg->v.s.l - index, arg->v.s.p + index);
        break;
    case PRIMTYPE_VECTOR:
        if (index > VLENGTH(arg))
            mdl_error("REST index too large");
        result = mdl_new_mdl_value();
        result->pt = PRIMTYPE_VECTOR;
        result->type = MDL_TYPE_VECTOR;
        result->v.v.p = arg->v.v.p;
        result->v.v.offset = arg->v.v.offset + index;
        break;
    case PRIMTYPE_UVECTOR:
        if (index > UVLENGTH(arg))
            mdl_error("REST index too large");
        result = mdl_new_mdl_value();
        result->pt = PRIMTYPE_UVECTOR;
        result->type = MDL_TYPE_UVECTOR;
        result->v.uv.p = arg->v.uv.p;
        result->v.uv.offset = arg->v.uv.offset + index;
        break;
    case PRIMTYPE_TUPLE:
        if (index > TPLENGTH(arg))
            mdl_error("REST index too large");
        result = mdl_new_mdl_value();
        result->pt = PRIMTYPE_TUPLE;
        result->type = MDL_TYPE_TUPLE;
        result->v.tp.p = arg->v.tp.p;
        result->v.tp.offset = arg->v.tp.offset + index;
        break;
    default:
        if (mdl_primtype_nonstructured(arg->pt))
        {
            mdl_error("Argument to REST must be structured");
        }
        // BYTES
        mdl_error("UNIMPLEMENTED PRIMTYPE");
    }
    return result;
}

mdl_value_t *mdl_internal_eval_rest(mdl_value_t *arg, mdl_value_t *indexval)
{
    int index = 1;
    if (indexval)
    {
        if (indexval->type != MDL_TYPE_FIX)
            mdl_error("Second argument to REST must be a FIX");
        index = indexval->v.w;
    }
    return mdl_internal_eval_rest_i(arg, index);
}


mdl_value_t *mdl_internal_eval_put(mdl_value_t *arg, mdl_value_t *indexval, mdl_value_t *newitem)
{
    if (indexval->type != MDL_TYPE_FIX)
        mdl_error("Second argument to PUT must be a FIX");
    int index = indexval->v.w;
    
    if (index <= 0)
        return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "PUT index too small", NULL);

    mdl_value_t *tail;
    switch (arg->pt)
    {
    case PRIMTYPE_LIST:

        tail = LREST(arg, index - 1);
        if (!tail || tail == (mdl_value_t *)-1)
            mdl_error("PUT index too large");
        tail->v.p.car = newitem;
        break;
    case PRIMTYPE_VECTOR:

        tail = VREST(arg, index - 1);
        if (!tail || tail == (mdl_value_t *)-1)
            mdl_error("PUT index too large");
        *tail = *newitem;
        break;
    case PRIMTYPE_UVECTOR:
        uvector_element_t *uvtail;
        uvtail = UVREST(arg, index - 1);
        if (!uvtail || uvtail == (uvector_element_t *)-1)
            mdl_error("PUT index too large");
        if (UVTYPE(arg) != newitem->type)
            return mdl_call_error("UVECTOR-PUT-TYPE-VIOLATION", NULL);
        mdl_uvector_value_to_element(newitem, uvtail);
        break;

    case PRIMTYPE_STRING:
        if (index > arg->v.s.l)
            mdl_error("PUT index too large");
        if (mdl_string_immutable(arg))
            mdl_error("String is immutable");
        if (newitem->type != MDL_TYPE_CHARACTER)
            mdl_error("Error in PUT: Strings may only contain CHARACTER type");
        arg->v.s.p[index - 1] = (char)newitem->v.w;
        break;

    case PRIMTYPE_TUPLE:
        tail = TPREST(arg, index - 1);
        if (!tail || tail == (mdl_value_t *)-1)
            mdl_error("PUT index too large");
        *tail = *newitem;
        break;

    default:
        if (mdl_primtype_nonstructured(arg->pt))
        {
            mdl_call_error_ext("FIXME", "First argument to PUT must be structured", cur_frame->subr, NULL);
        }
        // VECTOR, UVECTOR, BYTES
        mdl_error("UNIMPLEMENTED PRIMTYPE");
    }
    return arg;
}

mdl_value_t *mdl_internal_eval_putprop(mdl_value_t *item, mdl_value_t *indicator, mdl_value_t *val)
{
    struct mdl_assoc_key_t key;

    key.item = item;
    key.indicator = indicator;
    if (val == NULL)
        mdl_delete_assoc(mdl_assoc_table, &key);
    else
        mdl_add_assoc(mdl_assoc_table, &key, val);
    return item;
}

mdl_value_t *mdl_internal_eval_getprop(mdl_value_t *item, mdl_value_t *indicator)
{
    struct mdl_assoc_key_t key = {item, indicator};

    return mdl_assoc_find_value(mdl_assoc_table, &key);
}

mdl_value_t *mdl_internal_eval_mapfr(mdl_value_t *form, mdl_value_t *args, bool is_mapr)
{
    mdl_value_t *finalf = LITEM(args, 0);
    mdl_value_t *loopf = LITEM(args, 1);
    mdl_value_t *sp = LREST(args, 2);
    int num_structs, i;
    bool done = false;
    bool hasfinal;
    int jumpval;
    mdl_frame_t *frame = mdl_new_frame();
    mdl_frame_t *prev_frame = cur_frame;
    mdl_value_t *result = NULL;

    if (!loopf)
        mdl_error("Not enough args to MAPF/R");

    // set up the frame
    frame->prev_frame = prev_frame;

    // frame->subr = mdl_value_atom_mapf; FIXME
    // setup the activation (or should it be a frame?)
    mdl_value_t *act = mdl_make_frame_value(frame, MDL_TYPE_ACTIVATION); 
    mdl_bind_local_symbol(mdl_value_atom_lastmap->v.a, act, frame, false);
    frame->frame_flags = MDL_FRAME_FLAGS_ACTIVATION;
    mdl_push_frame(frame);

    hasfinal = mdl_is_true(finalf);
    // get the s-values
    mdl_value_t *stup;
    if (sp)
    {
        stup = mdl_make_tuple(sp, MDL_TYPE_TUPLE, false);
        num_structs = TPLENGTH(stup);
    }
    else num_structs = 0;

    mdl_value_t *lastitem, *flastitem = NULL;
    mdl_value_t *flist;
    mdl_value_t *val = &mdl_value_false;
    if (hasfinal)
        flist = mdl_additem(NULL, finalf, &flastitem);
    while (!done)
    {
        mdl_value_t *rlist = mdl_additem(NULL, loopf, &lastitem);
        for (i = 0; i < num_structs; i++)
        {
            mdl_value_t *s = TPITEM(stup, i);
            if (mdl_primtype_nonstructured(s->pt))
                mdl_error("Arguments to MAPF must be structured");
            if (mdl_internal_struct_is_empty(s)) 
                done = true;
            else
            {
                if (is_mapr)
                    val = mdl_internal_eval_rest_i(s, 0);
                else
                    val = mdl_internal_eval_nth_copy(s, NULL);
                mdl_additem(lastitem, val, &lastitem);
            }
        }
        if (!done)
        {
            rlist = mdl_make_list(rlist, MDL_TYPE_FORM);
            jumpval = mdl_setjmp(frame->interp_frame);
            switch (jumpval)
            {
            case 0: // normal case
                val = mdl_internal_apply(loopf, rlist, true);
                if (hasfinal)
                    mdl_additem(flastitem, val, &flastitem);
                break;
            case LONGJMP_MAPSTOP:
                done = 1;
                /*FALLTHROUGH*/
            case LONGJMP_MAPRET:
            {
                mdl_value_t *cursor;
                if (!frame->result || frame->result->type != MDL_TYPE_LIST)
                    mdl_error("MAPSTOP/MAPRET must return list");
                cursor = frame->result->v.p.cdr;
                while (cursor)
                {
                    mdl_additem(flastitem, cursor->v.p.car, &flastitem);
                    cursor = cursor->v.p.cdr;
                }
                frame->result = NULL;
            }
            break;
            case LONGJMP_MAPLEAVE:
                done = 1;
                result = frame->result;
                frame->result = NULL;
                break;
            default:
                mdl_error("Bad longjmp to MAPF/R");
            }
            for (i = 0; i < num_structs; i++)
            {
                mdl_value_t *s = TPITEM(stup, i);
                *s = *mdl_internal_eval_rest(s, NULL);
            }
        }
    }
    if (!result)
    {
        if (hasfinal)
        {
            flist = mdl_make_list(flist, MDL_TYPE_FORM);
            jumpval = mdl_setjmp(frame->interp_frame);
            if (jumpval)
            {
                mdl_error("Error Longjmp in finalf");
            }   
            result = mdl_internal_apply(finalf, flist, true);
        }
        else result = val;
    }
    
    mdl_pop_frame(prev_frame);
    return result;
}

mdl_value_t *mdl_internal_listen_error(mdl_value_t *args, bool is_error)
{
    mdl_value_t *oblists;
    mdl_value_t *inchan;
    mdl_value_t *outchan;
    mdl_value_t *atom_inchan, *atom_outchan;
    mdl_value_t *atom_l_level;
    mdl_value_t *atom_lerr;
    mdl_value_t *l_level;
    mdl_value_t *intlevel, *atom_intlevel;
    mdl_value_t *result = NULL;
    mdl_value_t *atom_rep;
    mdl_value_t *rep;
    int jumpval;
    int printflags;

    oblists = mdl_local_symbol_lookup(atom_oblist, cur_frame);
    if (!mdl_oblists_are_reasonable(oblists))
    {
        fprintf(stderr, "LVAL of OBLIST not reasonable\n");
        oblists = mdl_global_symbol_lookup(atom_oblist);
        if (!mdl_oblists_are_reasonable(oblists))
        {
            fprintf(stderr, "GVAL of OBLIST not reasonable\n");
            oblists = mdl_cons_internal(mdl_value_root_oblist, NULL);
            oblists = mdl_cons_internal(mdl_value_initial_oblist, oblists);
            oblists = mdl_make_list(oblists);
        }
    }
    mdl_bind_local_symbol(atom_oblist, oblists, cur_frame, false);

    atom_inchan = mdl_get_atom("INCHAN!-", true, NULL);
    inchan = mdl_local_symbol_lookup(atom_inchan->v.a, cur_frame);
    if (!mdl_inchan_is_reasonable(inchan))
    {
        fprintf(stderr, "LVAL of INCHAN not reasonable\n");
        inchan = mdl_global_symbol_lookup(atom_inchan->v.a);
        if (!mdl_inchan_is_reasonable(inchan))
        {
            fprintf(stderr, "GVAL of INCHAN not reasonable\n");
            inchan = mdl_create_default_inchan();
        }
    }
    mdl_bind_local_symbol(atom_inchan->v.a, inchan, cur_frame, false);

    atom_outchan = mdl_get_atom("OUTCHAN!-", true, NULL);
    outchan = mdl_local_symbol_lookup(atom_outchan->v.a, cur_frame);
    if (!mdl_outchan_is_reasonable(outchan))
    {
        fprintf(stderr, "LVAL of OUTCHAN not reasonable\n");
        outchan = mdl_global_symbol_lookup(atom_outchan->v.a);
        if (!mdl_outchan_is_reasonable(outchan))
        {
            fprintf(stderr, "GVAL of OUTCHAN not reasonable\n");
            outchan = mdl_create_default_outchan();
        }
    }
    mdl_bind_local_symbol(atom_outchan->v.a, outchan, cur_frame, false);
    printflags = mdl_chan_mode_is_print_binary(outchan)?MDL_PF_BINARY:0;
    
    atom_l_level = mdl_get_atom("L-LEVEL !-INTERRUPTS!-", true, NULL);
    l_level = mdl_local_symbol_lookup(atom_l_level->v.a, cur_frame);
    if (!l_level || l_level->type != MDL_TYPE_FIX)
        l_level = mdl_new_fix(1);
    else
        l_level = mdl_new_fix(l_level->v.w + 1);
    mdl_bind_local_symbol(atom_l_level->v.a, l_level, cur_frame, false);

    atom_lerr = mdl_get_atom("L-ERR !-INTERRUPTS!-", true, NULL);
    mdl_bind_local_symbol(atom_lerr->v.a, mdl_make_frame_value(cur_frame), cur_frame, false);
    if (is_error)
    {
        mdl_print_newline_to_chan(outchan, printflags, NULL);
        mdl_print_string_to_chan(outchan, "*ERROR*", 7, 0, true, true);
        mdl_print_char_to_chan(outchan, ' ', printflags, NULL);
    }

    if (!suppress_listen_message)
    {
        // print args
        args = args->v.p.cdr;
        while (args)
        {
            mdl_print_newline_to_chan(outchan, printflags, NULL);
            mdl_print_value_to_chan(outchan, args->v.p.car, false, true, NULL);
            mdl_print_char_to_chan(outchan, ' ', printflags, NULL);
            args = args->v.p.cdr;
        }
        
        atom_intlevel = mdl_get_atom("INT-LEVEL!-INTERRUPTS!-", true, NULL);
        intlevel = mdl_global_symbol_lookup(atom_intlevel->v.a);
        
        mdl_print_newline_to_chan(outchan, printflags, NULL);
        mdl_print_string_to_chan(outchan, "LISTENING-AT-LEVEL ", 18, 0, true, false);
        mdl_print_value_to_chan(outchan, l_level, false, true, NULL);
        mdl_print_string_to_chan(outchan, "PROCESS", 7, 0, true, true);
        mdl_print_string_to_chan(outchan, "1", 1, 0, true, true);
        if (intlevel && (intlevel->type != MDL_TYPE_FIX || intlevel->v.w != 0))
        {
            mdl_print_string_to_chan(outchan, "INT-LEVEL", 9, 0, true, true);
            mdl_print_value_to_chan(outchan, intlevel, false, true, NULL);
        }
        mdl_print_newline_to_chan(outchan, printflags, NULL);
    }
    suppress_listen_message = false;

    jumpval = mdl_setjmp(cur_frame->interp_frame);

    if (jumpval == 0)
    {
        // Zork's behavior implies this while loop, but the documentation
        // suggests the looping is within REP
        while (1) 
        {
            // Not sure if this should be REP or REP!-
            atom_rep = mdl_get_atom("REP", true, NULL);
            rep = mdl_both_symbol_lookup(atom_rep->v.a, cur_frame);
            // FIXME -- is_error doesn't belong here
            if (!is_error && rep && mdl_type_is_applicable(mdl_apply_type(rep->type)))
            {
                result = mdl_internal_apply(rep, mdl_make_list(mdl_cons_internal(atom_rep, NULL)), true);
            }
            else
            {
                // a new frame is not made here; this is called out
                // explicitly in the documentation
                mdl_value_t *mdl_builtin_eval_rep(mdl_value_t *form, mdl_value_t *args);
                
                fprintf(stderr, "Atom REP has neither LVAL nor GVAL\n");
                result = mdl_builtin_eval_rep(NULL, mdl_make_list(NULL));
            }
        }
    }
    else if (jumpval == LONGJMP_ERRET)
    {
        result = cur_frame->result;
    }
    else
    {
        printf("Bad longjmp to LISTEN frame");
    }
    return result;
}

void mdl_toplevel(FILE *restorefile)
{
    int jumpval;

    cur_frame = initial_frame;
    cur_frame->frame_flags |= MDL_FRAME_FLAGS_TRUEFRAME;
    cur_frame->args = mdl_make_list(NULL);
    jumpval = mdl_setjmp(cur_frame->interp_frame);
    if (restorefile && !jumpval)
    {
        mdl_read_image(restorefile);
        fprintf(stderr, "Initial restore failed");
        exit(-1);
    }
    // re-acquire the atom in case of restore
    cur_frame->subr = mdl_get_atom("TOPLEVEL!-", true, NULL);
    suppress_listen_message = jumpval == LONGJMP_RESTORE;
    if (jumpval == LONGJMP_RESTORE && cur_frame->result)
    {
        mdl_eval(cur_frame->result);
    }
    cur_frame->result = NULL;
    if (!mdl_chan_at_eof(mdl_get_default_inchan()))
    {
        mdl_std_apply(mdl_value_builtin_listen, mdl_make_list(mdl_cons_internal(mdl_value_builtin_listen, NULL)), MDL_TYPE_SUBR, true);
    }
    cur_frame = NULL;
}

void mdl_internal_erret(mdl_value_t *result, mdl_value_t *frame)
{
    if (result)
    {
        if (!frame) frame = mdl_local_symbol_lookup_pname("L-ERR !-INTERRUPTS!-", cur_frame);
        if (!frame) mdl_error("No frame in ERRET!");
        frame->v.f->result = result;
        mdl_longjmp_to(frame->v.f, LONGJMP_ERRET);
    }
    else
    {
        mdl_longjmp_to(cur_process_initial_frame, LONGJMP_ERRET);
    }
}

// built-in support macros

// Random access to args
#define GETARG(a, n, args) ((a) = LITEM(args, n))
#define GETREQARG(a, n, args) do {(a) = LITEM(args, n); if (!a) return mdl_call_error("TOO-FEW-ARGUMENTS-SUPPLIED", NULL); }  while(0)
#define DENYARG(n, args) do {if (LITEM(args, n)) return mdl_call_error("TOO-MANY-ARGUMENTS-SUPPLIED", NULL); } while(0)

// Sequential access to args
#define ARGSETUP(args) mdl_value_t *args##cursor = args->v.p.cdr

#define GETNEXTARG(a, args) do { if (args##cursor) { (a) = args##cursor->v.p.car; args##cursor = args##cursor->v.p.cdr; } else { (a) = NULL; } } while(0)
#define GETNEXTREQARG(a, args) do { if (args##cursor) { (a) = args##cursor->v.p.car; args##cursor = args##cursor->v.p.cdr; } else { return mdl_call_error("TOO-FEW-ARGUMENTS-SUPPLIED", NULL);  } } while(0)
#define REMAINING_ARGS(args) (args##cursor)
#define NOMOREARGS(args) do { if (args##cursor) { return mdl_call_error("TOO-MANY-ARGUMENTS-SUPPLIED", NULL); }} while(0)

// old ones
#define OARGSETUP(args, cursor) (cursor) = (args)->v.p.cdr
#define OGETNEXTARG(arg, cursor) do {if (cursor) { (arg) = (cursor)->v.p.car; (cursor) = (cursor)->v.p.cdr; } else { (arg) = NULL; } } while (0)

// below this point are built-ins
// BEGIN BUILT-INS (do not remove this line)

mdl_value_t *mdl_builtin_eval_quote(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    mdl_value_t *arg;
    ARGSETUP(args);

    GETNEXTREQARG(arg, args);
    NOMOREARGS(args);

    return arg;
}

mdl_value_t *mdl_builtin_eval_lval(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_frame_t *frame;
    mdl_value_t *atomval; 
    mdl_value_t *frameval;

    GETNEXTREQARG(atomval, args);
    GETNEXTARG(frameval, args);
    NOMOREARGS(args);

    if (frameval)
    {
        if (frameval->pt != PRIMTYPE_FRAME)
            mdl_error("Type Mismatch, 2nd arg to LVAL must be frame");
        frame = frameval->v.f;
    }
    else frame = cur_frame;

    if (atomval->pt != PRIMTYPE_ATOM)
        return mdl_call_error("Type Mismatch, 1st arg to LVAL must be atom", NULL);
    mdl_value_t *result = mdl_local_symbol_lookup(atomval->v.a, frame);
    if (!result || result->type == MDL_TYPE_UNBOUND)
    {
        return mdl_call_error_ext("UNBOUND-VARIABLE", "LVAL", atomval, NULL);
    }
    return result;
}

mdl_value_t *mdl_builtin_eval_gval(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *atomval;

    GETNEXTREQARG(atomval, args);
    NOMOREARGS(args);

    if (atomval->pt != PRIMTYPE_ATOM)
        mdl_call_error_ext("FIRST-ARG-WRONG-TYPE", "First arg to GVAL must be atom", NULL);
    mdl_value_t *result = mdl_global_symbol_lookup(atomval->v.a);
    if (!result || result->type == MDL_TYPE_UNBOUND)
    {
        return mdl_call_error_ext("UNBOUND-VARIABLE", "GVAL", atomval, NULL);
    }
    return result;
}

mdl_value_t *mdl_builtin_eval_value(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_frame_t *frame;
    mdl_value_t *frameval;
    mdl_value_t *atomval;

    GETNEXTREQARG(atomval, args);
    GETNEXTARG(frameval, args);
    NOMOREARGS(args);

    if (frameval)
    {
        if (frameval->pt != PRIMTYPE_FRAME)
            mdl_error("Type Mismatch, 2nd arg to VALUE must be frame");
        frame = frameval->v.f;
    }
    else frame = cur_frame;

    if (atomval->pt != PRIMTYPE_ATOM)
            mdl_error("Type Mismatch, 1st arg to VALUE must be atom");
    mdl_value_t *result = mdl_local_symbol_lookup(atomval->v.a, frame);
    if (!result || result->type == MDL_TYPE_UNBOUND)
        result = mdl_global_symbol_lookup(atomval->v.a);
    if (!result || result->type == MDL_TYPE_UNBOUND)
        mdl_error("Attempt to determine VALUE of atom without one");
    return result;
}

mdl_value_t *mdl_builtin_eval_bound(mdl_value_t *form, mdl_value_t *args)
/* SUBR BOUND? */
{
    ARGSETUP(args);
    mdl_frame_t *frame;
    mdl_value_t *frameval;
    mdl_value_t *atomval;

    GETNEXTREQARG(atomval, args);
    GETNEXTARG(frameval, args);
    NOMOREARGS(args);

    if (frameval)
    {
        if (frameval->pt != PRIMTYPE_FRAME)
            mdl_error("Type Mismatch, 2nd arg to BOUND? must be frame");
        frame = frameval->v.f;
    }
    else frame = cur_frame;
    if (atomval->pt != PRIMTYPE_ATOM)
            mdl_error("Type Mismatch, 1st arg to BOUND? must be atom");
    mdl_value_t *result = mdl_local_symbol_lookup(atomval->v.a, frame);
    return mdl_boolean_value(result != NULL);
}

mdl_value_t *mdl_builtin_eval_assigned(mdl_value_t *form, mdl_value_t *args)
/* SUBR ASSIGNED? */
{
    ARGSETUP(args);
    mdl_frame_t *frame;
    mdl_value_t *frameval;
    mdl_value_t *atomval;

    GETNEXTREQARG(atomval, args);
    GETNEXTARG(frameval, args);
    NOMOREARGS(args);

    if (frameval)
    {
        if (frameval->pt != PRIMTYPE_FRAME)
            mdl_error("Type Mismatch, 2nd arg to ASSIGNED? must be frame");
        frame = frameval->v.f;
    }
    else frame = cur_frame;
    if (atomval->pt != PRIMTYPE_ATOM)
            mdl_error("Type Mismatch, 1st arg to ASSIGNED? must be atom");
    mdl_value_t *result = mdl_local_symbol_lookup(atomval->v.a, frame);
    return mdl_boolean_value(result && result->type != MDL_TYPE_UNBOUND);
}

mdl_value_t *mdl_builtin_eval_gbound(mdl_value_t *form, mdl_value_t *args)
/* SUBR GBOUND? */
{
    ARGSETUP(args);
    mdl_value_t *atomval;

    GETNEXTREQARG(atomval, args);
    NOMOREARGS(args);

    if (atomval->pt != PRIMTYPE_ATOM)
            mdl_error("Type Mismatch, 1st arg to GBOUND? must be atom");
    mdl_value_t *result = mdl_global_symbol_lookup(atomval->v.a);
    return mdl_boolean_value(result != NULL);
}

mdl_value_t *mdl_builtin_eval_gassigned(mdl_value_t *form, mdl_value_t *args)
/* SUBR GASSIGNED? */
{
    ARGSETUP(args);
    mdl_value_t *atomval;

    GETNEXTREQARG(atomval, args);
    NOMOREARGS(args);

    if (atomval->pt != PRIMTYPE_ATOM)
            mdl_error("Type Mismatch, 1st arg to GASSIGNED? must be atom");
    mdl_value_t *result = mdl_global_symbol_lookup(atomval->v.a);
    return mdl_boolean_value(result && result->type != MDL_TYPE_UNBOUND);
}

mdl_value_t *mdl_builtin_eval_gunassign(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *atomval;

    GETNEXTREQARG(atomval, args);
    NOMOREARGS(args);

    if (atomval->pt != PRIMTYPE_ATOM)
        return mdl_call_error("FIRST-ARG-WRONG-TYPE", "First arg to GUNASSIGN must be atom", NULL);
    mdl_set_gval(atomval->v.a, &mdl_value_unassigned);
    return atomval;
}

mdl_value_t *mdl_builtin_eval_setg(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *atomval;
    mdl_value_t *newval;

    GETNEXTREQARG(atomval, args);
    GETNEXTREQARG(newval, args);
    NOMOREARGS(args);

    if (atomval->pt != PRIMTYPE_ATOM)
            mdl_error("Type Mismatch, 1st arg to SETG must be atom");
    return mdl_set_gval(atomval->v.a, newval);
}

mdl_value_t *mdl_builtin_eval_set(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *atomval;
    mdl_value_t *newval;
    mdl_frame_t *frame = cur_frame;
    mdl_value_t *frameval;

    GETNEXTREQARG(atomval, args);
    GETNEXTREQARG(newval, args);
    GETNEXTARG(frameval, args);
    NOMOREARGS(args);

    if (atomval->pt != PRIMTYPE_ATOM)
            mdl_error("Type Mismatch, 1st arg to SET must be atom");
    if (frameval)
    {
        if (frameval->pt != PRIMTYPE_FRAME)
            mdl_error("Type Mismatch, 3rd arg to SET must be frame");
        frame = frameval->v.f;
    }
    return mdl_set_lval(atomval->v.a, newval, frame);
}

mdl_value_t *mdl_builtin_eval_cond(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    ARGSETUP(args);

    mdl_value_t *cur_clause;
    mdl_value_t *cur_eval = NULL;

    GETNEXTREQARG(cur_clause,args);
    while (cur_clause)
    {
        if (cur_clause->type != MDL_TYPE_LIST)
            return mdl_call_error_ext("BAD-CLAUSE", "COND clauses must be LISTs", NULL);
        if (!LHASITEM(cur_clause, 0))
            return mdl_call_error_ext("BAD-CLAUSE", "COND clauses must have at least one item", NULL);
        
        cur_eval = mdl_eval(LITEM(cur_clause, 0), false);
        if (mdl_is_true(cur_eval))
        {
            mdl_value_t *eval_list = LREST(cur_clause, 1);
            while (eval_list)
            {
                cur_eval = mdl_eval(eval_list->v.p.car);
                eval_list = eval_list->v.p.cdr;
            }
            return cur_eval;
        }
        GETNEXTARG(cur_clause, args);
    }
    return cur_eval;
}

// TYPE subrs (6.3)
mdl_value_t *mdl_builtin_eval_type(mdl_value_t *form, mdl_value_t *args)
{
    ARGSETUP(args);
    mdl_value_t *tobj;

    GETNEXTREQARG(tobj, args);
    NOMOREARGS(args);

    return mdl_newatomval(mdl_type_atom(tobj->type));
}

mdl_value_t *mdl_builtin_eval_primtype(mdl_value_t *form, mdl_value_t *args)
{
    ARGSETUP(args);
    mdl_value_t *tobj;

    GETNEXTREQARG(tobj, args);
    NOMOREARGS(args);
    
    return mdl_newatomval(mdl_type_atom(tobj->pt));
}

mdl_value_t *mdl_builtin_eval_typeprim(mdl_value_t *form, mdl_value_t *args)
{
    ARGSETUP(args);
    mdl_value_t *tobj;
    int typenum;

    GETNEXTREQARG(tobj, args);
    NOMOREARGS(args);
    
    typenum = mdl_get_typenum(tobj);
    if (typenum == MDL_TYPE_NOTATYPE)
        mdl_error("Value passed to TYPEPRIM was not a type");
    return mdl_newatomval(mdl_type_atom(mdl_type_primtype(typenum)));}

mdl_value_t *mdl_builtin_eval_chtype(mdl_value_t *form, mdl_value_t *args)
{
    ARGSETUP(args);
    mdl_value_t *tobj;
    mdl_value_t *newtype;
    mdl_value_t *nobj;
    int typecode;

    GETNEXTREQARG(tobj, args);
    GETNEXTREQARG(newtype, args);
    NOMOREARGS(args);

    typecode = mdl_get_typenum(newtype);
    if (mdl_type_primtype(typecode) != tobj->pt)
        mdl_error("PRIMTYPES do not match in CHTYPE");
    nobj = mdl_new_mdl_value();
    *nobj = *tobj;
    nobj->type = typecode;
    return nobj;
    
}
// More SUBRs related to types (6.4)
mdl_value_t *mdl_builtin_eval_alltypes(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    DENYARG(0, args);
    return mdl_typevector();
}

mdl_value_t *mdl_builtin_eval_valid_typep(mdl_value_t *form, mdl_value_t *args)
/* SUBR VALID-TYPE? */
{
    ARGSETUP(args);
    int typenum;
    mdl_value_t *obj;

    GETNEXTREQARG(obj, args);
    NOMOREARGS(args);

    typenum = mdl_get_typenum(obj);
    if (typenum == MDL_TYPE_NOTATYPE)
        return &mdl_value_false;
    return mdl_new_word(typenum, MDL_TYPE_TYPE_C);
}

mdl_value_t *mdl_builtin_eval_newtype(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *newtype = NULL;
    mdl_value_t *oldtype = NULL;
    mdl_value_t *desc = NULL;
    int oldtypenum, prevtypenum;

    GETNEXTARG(newtype, args);
    GETNEXTREQARG(oldtype, args);
    GETNEXTARG(desc, args);
    NOMOREARGS(args);

    oldtypenum = mdl_get_typenum(oldtype);
    if (oldtypenum == MDL_TYPE_NOTATYPE)
        mdl_error("Second argument to NEWTYPE must name a type");
    prevtypenum = mdl_get_typenum(newtype);

    mdl_value_t *redefine = mdl_local_symbol_lookup(mdl_value_atom_redefine->v.a);
    if (!redefine || redefine->type == MDL_TYPE_UNBOUND ||
        !mdl_is_true(redefine))
    {
        // FIXME -- not sure if REDEFINE allows redefining types
        if (prevtypenum != MDL_TYPE_NOTATYPE && 
            mdl_type_primtype(prevtypenum) != mdl_type_primtype(oldtypenum))
            mdl_error("First arg to NEWTYPE must not already be a type");
    }
    return mdl_internal_newtype(newtype, oldtypenum);
}

mdl_value_t *mdl_builtin_eval_evaltype(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *thetype = NULL;
    mdl_value_t *how = NULL;
    mdl_value_t *result;
    int typenum;

    GETNEXTREQARG(thetype, args);
    GETNEXTARG(how, args);
    NOMOREARGS(args);

    typenum = mdl_get_typenum(thetype);
    if (typenum == MDL_TYPE_NOTATYPE)
        mdl_error("First argument to EVALTYPE must name a type");
    if (!how) 
    {
        result = mdl_get_evaltype(typenum);
        if (result == NULL) result = &mdl_value_false;
    }
    else
    {
        
        result = thetype;
        if (mdl_value_double_equal(how, mdl_value_builtin_eval)) 
            mdl_set_evaltype(typenum, NULL);
        else
            mdl_set_evaltype(typenum, how);
    }
    return result;    
}

mdl_value_t *mdl_builtin_eval_applytype(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *thetype = NULL;
    mdl_value_t *how = NULL;
    mdl_value_t *result;
    int typenum;

    GETNEXTREQARG(thetype, args);
    GETNEXTARG(how, args);
    NOMOREARGS(args);
    typenum = mdl_get_typenum(thetype);
    if (typenum == MDL_TYPE_NOTATYPE)
        mdl_error("First argument to APPLYTYPE must name a type");
    if (!how) 
    {
        result = mdl_get_applytype(typenum);
        if (result == NULL) result = &mdl_value_false;
    }
    else
    {
        result = thetype;
        if (mdl_value_double_equal(how, mdl_value_builtin_apply)) 
            mdl_set_applytype(typenum, NULL);
        else
            mdl_set_applytype(typenum, how);
    }
    return result;    
}

mdl_value_t *mdl_builtin_eval_printtype(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *thetype = NULL;
    mdl_value_t *how = NULL;
    mdl_value_t *result;
    int typenum;

    GETNEXTREQARG(thetype, args);
    GETNEXTARG(how, args);
    NOMOREARGS(args);
    typenum = mdl_get_typenum(thetype);
    if (typenum == MDL_TYPE_NOTATYPE)
        mdl_error("First argument to PRINTTYPE must name a type");
    if (!how) 
    {
        result = mdl_get_printtype(typenum);
        if (result == NULL) result = &mdl_value_false;
    }
    else
    {
        result = thetype;
        if (mdl_value_double_equal(how, mdl_value_builtin_print)) 
            mdl_set_printtype(typenum, NULL);
        else
            mdl_set_printtype(typenum, how);
    }
    return result;    
}
// STRUCTURE OBJECT builtins

mdl_value_t *mdl_builtin_eval_length(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *arg;
    int count = 0;

    GETNEXTREQARG(arg, args);
    NOMOREARGS(args);

    switch (arg->pt)
    {
    case PRIMTYPE_LIST:
    case PRIMTYPE_STRING:
    case PRIMTYPE_VECTOR:
    case PRIMTYPE_UVECTOR:
    case PRIMTYPE_TUPLE:
        count = mdl_internal_struct_length(arg);
        break;
    default:
        if (mdl_primtype_nonstructured(arg->pt))
        {
            mdl_error("Argument to LENGTH must be structured");
        }
        // BYTES
        mdl_error("UNIMPLEMENTED PRIMTYPE");
    }
    return mdl_new_fix(count);
}

mdl_value_t *mdl_builtin_eval_nth(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *arg;
    mdl_value_t *indexval;

    GETNEXTREQARG(arg, args);
    GETNEXTARG(indexval, args);
    NOMOREARGS(args);
    
    return mdl_internal_eval_nth_copy(arg, indexval);
}

mdl_value_t *mdl_builtin_eval_rest(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *arg;
    mdl_value_t *indexval;

    GETNEXTREQARG(arg, args);
    GETNEXTARG(indexval, args);
    NOMOREARGS(args);

    return mdl_internal_eval_rest(arg, indexval);
}

mdl_value_t *mdl_builtin_eval_put(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    
    ARGSETUP(args);
    mdl_value_t *arg;
    mdl_value_t *indexval;
    mdl_value_t *newitem;

    GETNEXTARG(arg, args);
    GETNEXTREQARG(indexval, args);
    GETNEXTARG(newitem, args);
    NOMOREARGS(args);

    if (mdl_primtype_structured(arg->pt) &&
        (indexval->type == MDL_TYPE_FIX || indexval->type == MDL_TYPE_OFFSET))
    {
        if (newitem == NULL)
        {
            return mdl_call_error("TOO-FEW-ARGUMENTS-SUPPLIED", NULL);
        }
        return mdl_internal_eval_put(arg, indexval, newitem);
    }
    else
        return mdl_internal_eval_putprop(arg, indexval, newitem);
}

mdl_value_t *mdl_builtin_eval_get(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *arg;
    mdl_value_t *indexval;
    mdl_value_t *exp;

    GETNEXTREQARG(arg, args);
    GETNEXTARG(indexval, args);
    GETNEXTARG(exp, args);
    NOMOREARGS(args);

    if (mdl_primtype_structured(arg->pt) &&
        (!indexval || indexval->type == MDL_TYPE_FIX || indexval->type == MDL_TYPE_OFFSET))
    {
        if (exp != NULL) 
            return mdl_call_error_ext("TOO-MANY-ARGUMENTS-SUPPLIED", "No EXP allowed for GET on structure", NULL);
        return mdl_internal_eval_nth_copy(arg, indexval);
    }
    else
    {
        mdl_value_t *result =  mdl_internal_eval_getprop(arg, indexval);
        if (result == NULL)
        {
            if (exp) result =  mdl_eval(exp);
            else result = &mdl_value_false;
        }
        return result;
    }
}

// SUBSTRUC -- note that this makes a shallow copy.

mdl_value_t *mdl_builtin_eval_substruc(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *from;
    mdl_value_t *restval;
    mdl_value_t *amountval;
    mdl_value_t *to;

    GETNEXTREQARG(from, args);
    GETNEXTARG(restval, args);
    GETNEXTARG(amountval, args);
    GETNEXTARG(to, args);
    NOMOREARGS(args);
    
    if (mdl_primtype_nonstructured(from->pt))
        return mdl_call_error_ext("FIRST-ARG-WRONG-TYPE", "First arg to SUBSTRUC must be structured", NULL);
    if (restval && restval->type != MDL_TYPE_FIX)
        return mdl_call_error_ext("SECOND-ARG-WRONG-TYPE", "Second argument to SUBSTRUC must be a FIX", NULL);
    if (amountval && amountval->type != MDL_TYPE_FIX)
        return mdl_call_error_ext("THIRD-ARG-WRONG-TYPE", "Third argument to SUBSTRUC must be a FIX", NULL);
    if (to && ((int)from->pt != to->type) && (from->pt != PRIMTYPE_TUPLE && to->type != PRIMTYPE_VECTOR))
    {
        return mdl_call_error_ext("ARG-WRONG-TYPE", "Last arg to SUBSTRUC must be same type as primtype of first arg", NULL);
    }
    if (amountval && amountval->v.w < 0)
    {
        return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC amount cannot be negative", NULL);
    }
    int rest = 0;
    int amount = -1;

    if (restval) rest = restval->v.w;
    if (amountval) amount = amountval->v.w;

    if (rest < 0)
    {
        return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC rest cannot be negative", NULL);
    }

    switch (from->pt)
    {
    case PRIMTYPE_LIST: 
    {
        mdl_value_t *start = LREST(from, rest);
        if (start == (mdl_value_t *)-1)
        {
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC rest too large", NULL);
        }
        if (!to)
        {
            mdl_value_t *lastitem = NULL;
            if (start && amount--)
            {
                to = lastitem = mdl_newlist();
                to->v.p.car = start->v.p.car;
                start = start->v.p.cdr;
            }
            while(start && amount--)
            {
                mdl_additem(lastitem, start->v.p.car, &lastitem);
                start = start->v.p.cdr;
            }
            to = mdl_make_list(to);
        }
        else
        {
            mdl_value_t *cursor = LREST(to, 0);
            while(start && amount--)
            {
                if (!cursor)
                    return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC destination too short", NULL);
                cursor->v.p.car = start->v.p.car;
                cursor = cursor->v.p.cdr;
                start = start->v.p.cdr;
            }
        }
        if (amount > 0)
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC amount too big for source", NULL);
        break;
    }
    case PRIMTYPE_VECTOR:
        if (rest > VLENGTH(from))
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC rest too large", NULL);
        if (amount < 0) amount = VLENGTH(from) - rest;
        if ((rest + amount) > VLENGTH(from))
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC amount too big for source", NULL);
        if (to && (amount > VLENGTH(to)))
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC destination too short", NULL);
        if (!to) to = mdl_new_empty_vector(amount, MDL_TYPE_VECTOR);
        memcpy(VREST(to,0), VREST(from, rest), amount * sizeof(mdl_value_t));
        break;
    case PRIMTYPE_UVECTOR:
        if (rest > UVLENGTH(from))
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC rest too large", NULL);
        if (amount < 0) amount = UVLENGTH(from) - rest;
        if ((rest + amount) > UVLENGTH(from))
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC amount too big for source", NULL);
        if (to && (amount > UVLENGTH(to)))
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC destination too short", NULL);
        if (to && (UVTYPE(to) != UVTYPE(from)))
            return mdl_call_error_ext("TYPES-DIFFER-IN-UNIFORM-VECTOR", "SUBSTRUC UVECTOR to and from must be same type", NULL);
        if (!to) 
        {
            to = mdl_new_empty_uvector(amount, MDL_TYPE_UVECTOR);
            UVTYPE(to) = UVTYPE(from);
        }
        memcpy(UVREST(to,0), UVREST(from, rest), amount * sizeof(uvector_element_t));
        break;
    case PRIMTYPE_TUPLE:
        if (rest > TPLENGTH(from))
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC rest too large", NULL);
        if (amount < 0) amount = TPLENGTH(from) - rest;
        if ((rest + amount) > TPLENGTH(from))
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC amount too big for source", NULL);
        if (to && (amount > mdl_internal_struct_length(to)))
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC destination too short", NULL);
        if (!to) to = mdl_new_empty_vector(amount, MDL_TYPE_VECTOR);
        if (to->pt == PRIMTYPE_VECTOR)
            memcpy(VREST(to,0), TPREST(from, rest), amount * sizeof(mdl_value_t));
        else // must be another tuple
            memcpy(TPREST(to,0), TPREST(from, rest), amount * sizeof(mdl_value_t));
        break;
    case PRIMTYPE_STRING:
        if (rest > from->v.s.l)
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC rest too large", NULL);
        if (amount < 0) amount = from->v.s.l - rest;
        if ((rest + amount) > from->v.s.l)
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC amount too big for source", NULL);
        if (to && (amount > to->v.s.l))
            return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SUBSTRUC destination too short", NULL);
        if (to) memcpy(to->v.s.p, from->v.s.p + rest, amount);
        else to = mdl_new_string(amount, from->v.s.p + rest);
        break;
    default:
        mdl_error("UNIMPLEMENTED PRIMTYPE");
    }

    return to;
}

// 7.5.3 LIST, VECTOR, UVECTOR, STRING (also TUPLE, which doesn't belong)
mdl_value_t *mdl_builtin_eval_list(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    // Naively, one could just return args here.  But if there's a SEGMENT
    // passed as an argument that won't work; instead, a copy must be returned
    mdl_value_t *result = mdl_internal_shallow_copy_list(LREST(args,0));
    return mdl_make_list(result);
}

mdl_value_t *mdl_builtin_eval_form(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *result = mdl_internal_shallow_copy_list(LREST(args,0));
    return mdl_make_list(result, MDL_TYPE_FORM);
    return result;
}

mdl_value_t *mdl_builtin_eval_vector(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_make_vector(LREST(args,0), MDL_TYPE_VECTOR);
}

mdl_value_t *mdl_builtin_eval_tuple(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_make_tuple(LREST(args,0), MDL_TYPE_TUPLE);
}

mdl_value_t *mdl_builtin_eval_uvector(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_make_uvector(LREST(args,0), MDL_TYPE_UVECTOR);
}

// ahh, yes, form and function -- but note that function is an fsubr
mdl_value_t *mdl_builtin_eval_function(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    mdl_value_t *result = mdl_internal_shallow_copy_list(LREST(args,0));
    return mdl_make_list(result, MDL_TYPE_FUNCTION);
}

mdl_value_t *mdl_builtin_eval_string(mdl_value_t *form, mdl_value_t *args)
{
    mdl_value_t *cursor = LREST(args,0);
    mdl_value_t *result;
    int length = 0;
    while (cursor)
    {
        switch (cursor->v.p.car->type)
        {
        case MDL_TYPE_CHARACTER:
            length++;
            break;
        case MDL_TYPE_STRING:
            length += cursor->v.p.car->v.s.l;
            break;
        default:
            mdl_call_error_ext("ARG-WRONG-TYPE", "Arguments to STRING must be strings or characters", NULL);
        }
        cursor = cursor->v.p.cdr;
    }
    result = mdl_new_string(length);
    char *s = result->v.s.p;
    cursor = LREST(args,0);
    while (cursor)
    {
        switch (cursor->v.p.car->type)
        {
        case MDL_TYPE_CHARACTER:
            *s++ = (char)cursor->v.p.car->v.w;
            break;
        case MDL_TYPE_STRING:
            memcpy(s, cursor->v.p.car->v.s.p, cursor->v.p.car->v.s.l);
            s += cursor->v.p.car->v.s.l;
            break;
        }
        cursor = cursor->v.p.cdr;
    }
    return result;
}

// 7.5.4-7.5.5 ILIST, IVECTOR, IUVECTOR, ISTRING, IFORM
mdl_value_t *mdl_builtin_eval_ilist(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *nelem;
    mdl_value_t *expr;
    int nelements;
    mdl_value_t *lastelem = NULL;
    mdl_value_t *firstelem = NULL;
    mdl_value_t *elem;
    mdl_value_t *tmp;
    
    GETNEXTREQARG(nelem, args);
    GETNEXTARG(expr, args);
    NOMOREARGS(args);
    if (nelem->type != MDL_TYPE_FIX) mdl_error("Number of elements must be a FIX");
    nelements = nelem->v.w;
    if (nelements < 0) mdl_error("Number of elements must be >= 0");
    while (nelements--)
    {
        if (expr) elem = mdl_eval(expr);
        else elem = mdl_new_word(0, MDL_TYPE_LOSE);
        tmp = mdl_additem(lastelem, elem, &lastelem);
        if (!firstelem) firstelem = tmp;
    }
    return mdl_make_list(firstelem);
}

mdl_value_t *mdl_builtin_eval_iform(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *result = mdl_builtin_eval_ilist(form, args);
    result->type = MDL_TYPE_FORM;
    return result;
}

mdl_value_t *mdl_builtin_eval_ivector(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *nelem;
    mdl_value_t *expr;
    int nelements;
    mdl_value_t *result;
    mdl_value_t *elem;
    mdl_value_t *lose;
    
    GETNEXTREQARG(nelem, args);
    GETNEXTARG(expr, args);
    NOMOREARGS(args);
    if (nelem->type != MDL_TYPE_FIX) mdl_error("Number of elements must be a FIX");
    nelements = nelem->v.w;
    if (nelements < 0) mdl_error("Number of elements must be >= 0");
    result = mdl_new_empty_vector(nelements, MDL_TYPE_VECTOR);
    elem = VREST(result,0);
    if (!expr) lose = mdl_new_word(0, MDL_TYPE_LOSE);
    while (nelements--)
    {
        if (expr) *elem = *mdl_eval(expr);
        else *elem = *lose;
        elem++;
    }
    return result;
}

mdl_value_t *mdl_builtin_eval_iuvector(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *nelem;
    mdl_value_t *expr;
    int nelements;
    mdl_value_t *result;
    mdl_value_t *elem;
    uvector_element_t *uelem;
    
    GETNEXTREQARG(nelem, args);
    GETNEXTARG(expr, args);
    NOMOREARGS(args);
    if (nelem->type != MDL_TYPE_FIX) mdl_error("Number of elements must be a FIX");
    nelements = nelem->v.w;
    if (nelements < 0) mdl_error("Number of elements must be >= 0");
    result = mdl_new_empty_uvector(nelements, MDL_TYPE_UVECTOR);
    if (expr && nelements)
    {
        uelem = UVREST(result, 0);
        elem = mdl_eval(expr);
        if (!mdl_valid_uvector_primtype(elem->pt))
            mdl_error("Type not valid for inclusion in UVECTOR");
        mdl_uvector_value_to_element(elem, uelem);
        UVTYPE(result) = elem->type;
        while (nelements--)
        {
            elem = mdl_eval(expr);
            if (UVTYPE(result) != elem->type)
                mdl_error("All elements of UVECTOR must be of the same type");
            mdl_uvector_value_to_element(elem, uelem);
            uelem++;
        }
    }
    else UVTYPE(result) = MDL_TYPE_LOSE;
    return result;
}

mdl_value_t *mdl_builtin_eval_istring(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *nelem;
    mdl_value_t *expr;
    int nelements;
    mdl_value_t *result;
    mdl_value_t *elem;
    char *s;
    
    GETNEXTREQARG(nelem, args);
    GETNEXTARG(expr, args);
    NOMOREARGS(args);
    if (nelem->type != MDL_TYPE_FIX) mdl_error("Number of elements must be a FIX");
    nelements = nelem->v.w;
    if (nelements < 0) mdl_error("Number of elements must be >= 0");
    result = mdl_new_string(nelements);
    if (expr)
    {
        s = result->v.s.p;
        while (nelements--)
        {
            if (expr) elem = mdl_eval(expr);
            if (elem->type != MDL_TYPE_CHARACTER)
                mdl_error("String elements must be characters");
            *s++ = (char)elem->v.w;
        }
    }
    return result;
}

// 7.6 PRIMTYPE LIST operations
mdl_value_t *mdl_builtin_eval_putrest(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *head;
    mdl_value_t *tail;

    GETNEXTARG(head, args);
    GETNEXTREQARG(tail, args);
    NOMOREARGS(args);
    if (head->pt != PRIMTYPE_LIST) mdl_error("First arg to PUTREST must have primtype LIST");
    if (tail->pt != PRIMTYPE_LIST) mdl_error("Second arg to PUTREST must have primtype LIST");
    
    if (!head->v.p.cdr)
        mdl_error("Can't PUTREST on an empty list");
    head->v.p.cdr->v.p.cdr = tail->v.p.cdr;
    return head;
}

mdl_value_t *mdl_builtin_eval_cons(mdl_value_t *form, mdl_value_t *args)
{
    ARGSETUP(args);
    mdl_value_t *newfirst;
    mdl_value_t *list;

    GETNEXTARG(newfirst, args);
    GETNEXTREQARG(list, args);
    NOMOREARGS(args);

    if (list->pt != PRIMTYPE_LIST) mdl_error("Second arg to CONS must have primtype LIST");

    return mdl_make_list(mdl_cons_internal(newfirst, LREST(list,0)));
}

// ARRAY items (7.6.2)

mdl_value_t *mdl_builtin_eval_back(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *array;
    mdl_value_t *fix;
    mdl_value_t *result;
    int backup = 1;

    GETNEXTREQARG(array, args);
    GETNEXTARG(fix, args);
    NOMOREARGS(args);

    if (fix) backup = fix->v.w;
    if (backup < 1) mdl_error("Must BACK at least 1 element");
    
    switch (array->pt)
    {
    case PRIMTYPE_VECTOR:
        if (backup > (array->v.v.offset + array->v.v.p->startoffset))
            mdl_error("Offset to BACK too large");
        result = mdl_new_mdl_value();
        *result = *array;
        result->v.v.offset -= backup;
        break;
    case PRIMTYPE_UVECTOR:
        if (backup > (array->v.uv.offset + array->v.uv.p->startoffset))
            mdl_error("Offset to BACK too large");
        result = mdl_new_mdl_value();
        *result = *array;
        result->v.uv.offset -= backup;
        break;
    case PRIMTYPE_STRING:
    {
        int full_length = mdl_string_length(array);
        if (backup > (full_length - array->v.s.l))
            mdl_error("Offset to BACK too large");
        result = mdl_new_mdl_value();
        *result = *array;
        result->v.s.p -= backup;
        result->v.s.l += backup;
        break;
    }
    default:
        mdl_error("Bad type for BACK");
    }
    return result;
}

mdl_value_t *mdl_builtin_eval_top(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *array;
    mdl_value_t *result;

    GETNEXTREQARG(array, args);
    NOMOREARGS(args);
    
    switch (array->pt)
    {
    case PRIMTYPE_VECTOR:
        result = mdl_new_mdl_value();
        *result = *array;
        result->v.v.offset = -array->v.v.p->startoffset;
        break;
    case PRIMTYPE_UVECTOR:
        result = mdl_new_mdl_value();
        *result = *array;
        result->v.uv.offset = -array->v.v.p->startoffset;
        break;
    case PRIMTYPE_STRING:
    {
        int full_length = mdl_string_length(array);
        result = mdl_new_mdl_value();
        *result = *array;
        result->v.s.p = array->v.s.p + array->v.s.l - full_length;
        result->v.s.l = full_length;
        break;
    }
    default:
        mdl_error("Bad type for TOP");
    }
    return result;
}

template <class T, class R> R mdl_get_union(T);
template <class T> counted_string_t * mdl_get_string(T)
{
    return NULL;
}

template <> inline mdl_value_union *mdl_get_union<mdl_value_t *, mdl_value_union *>(mdl_value_t *v)
{
    return &v->v;
}

template <> inline uvector_element_t *mdl_get_union<uvector_element_t *, uvector_element_t *>(uvector_element_t *v)
{
    return v;
}

template <> inline counted_string_t *mdl_get_string<mdl_value_t *>(mdl_value_t *v)
{
    return &v->v.s;
}

// gets the cpos-th character of str, or null.  Sets notnull if not null
// hack, hack, kludge, kludge
char mdl_sort_pname_char(char *str, int cpos, bool *notnull)
{
    char *s = str;
    while (*s && cpos)
    {
        s++; cpos--;
    }
    if (*s) *notnull = true;
    return *s;
}

template <class T, class U>
void mdl_radix_exchange_1(T *array, int reclen, int keyoff, primtype_t primtype, int bitno, bool negate, int startrec, int nrecs, mdl_value_t *aux)
{
    T *front, *back;
    T tmp;
    MDL_INT mask;
    int newnrecs1 = 0;
    int i;
    
    if (nrecs < 2) return;
    front = array + startrec * reclen + keyoff;
    back = array + (startrec + nrecs - 1) * reclen + keyoff;

    switch (primtype)
    {
    case PRIMTYPE_ATOM:
    case PRIMTYPE_STRING:
    {
        int cpos = bitno >> 3;
        int bpos = (7-(bitno & 7));
        unsigned char mask = 1<<bpos;
        int frontbit, backbit;
        counted_string_t *frontstr, *backstr;
        char *frontpname, *backpname;
        
        bool didtest;

        while (front < back)
        {
            
            if (primtype == PRIMTYPE_STRING)
            {
                frontstr = mdl_get_string<T*>(front);
                frontbit = (frontstr->l > cpos) && (didtest = true) && (frontstr->p[cpos] & mask);
            }
            else
            {
                // this is very inefficient, as it must iterate each string
                // at each pass -- perhaps atoms should use counted 
                // strings as well
                frontpname = mdl_get_union<T*,U*>(front)->a->pname;
                frontbit = (mdl_sort_pname_char(frontpname, cpos, &didtest) & mask) != 0;
            }
            if (!frontbit) 
            {
                front += reclen;
                newnrecs1++;
            }
            else
            {
                if (primtype == PRIMTYPE_STRING)
                {
                    backstr = mdl_get_string<T*>(back);
                    backbit = (backstr->l > cpos) && (didtest = true) && (backstr->p[cpos] & mask);
                }
                else
                {
                    backpname = mdl_get_union<T*,U*>(back)->a->pname;
                    backbit = (mdl_sort_pname_char(backpname, cpos, &didtest) & mask) != 0;
                }
                if (backbit) 
                {
                    back -= reclen;
                }
                else
                {
                    for (i = -keyoff; i < (reclen - keyoff); i++)
                    {
                        tmp = front[i];
                        front[i] = back[i];
                        back[i] = tmp;
                    }
                    front += reclen;
                    newnrecs1++;
                    back -= reclen;
                }
            }
        }
        if (front == back)
        {
            if (primtype == PRIMTYPE_STRING)
            {
                frontstr = mdl_get_string<T*>(front);
                frontbit = (frontstr->l > cpos) && (didtest = true) && (frontstr->p[cpos] & mask);
            }
            else
            {
                frontpname = mdl_get_union<T*,U*>(front)->a->pname;
                frontbit = (mdl_sort_pname_char(frontpname, cpos, &didtest) & mask) != 0;
            }

            if (!frontbit)
            {
                newnrecs1++;
            }
        }
        if (!didtest) return;
        break;
    }
    case PRIMTYPE_WORD:
        if (bitno >= ((int)sizeof(MDL_INT) << 3)) return;
        mask = (MDL_INT)1 << ((sizeof(MDL_INT)<< 3) - bitno - 1);
        while (front < back)
        {
            if (negate ^ !(mdl_get_union<T*,U*>(front)->w & mask)) 
            {
                front += reclen;
                newnrecs1++;
            }
            else if (negate ^ ((mdl_get_union<T*,U*>(back)->w & mask) != 0)) back -= reclen;
            else
            {
                for (i = -keyoff; i < (reclen - keyoff); i++)
                {
                    tmp = front[i];
                    front[i] = back[i];
                    back[i] = tmp;
                }
                front += reclen;
                newnrecs1++;
                back -= reclen;
            }
        }
        if (negate ^ !(mdl_get_union<T*,U*>(front)->w & mask))
        {
            newnrecs1++;
        }
    }
    mdl_radix_exchange_1<T,U>(array, reclen, keyoff, primtype, bitno + 1, false, startrec, newnrecs1, aux);
    mdl_radix_exchange_1<T,U>(array, reclen, keyoff, primtype, bitno + 1, false, startrec + newnrecs1, nrecs - newnrecs1, aux);
}

template <class T, class U> void mdl_radix_exchange_0(T *array, int reclen, int keyoff, primtype_t primtype, int nrecs, mdl_value_t *aux)
{
    int i, off;
    int bitno = 0;
    MDL_INT pstandard = -1, nstandard = 0;
    MDL_UINT tdiff = 0;
    bool negate = false;

    if (primtype == PRIMTYPE_WORD)
    {
        for (i = 0, off = keyoff; i < nrecs; i++, off += reclen)
        {
            if (mdl_get_union<T*,U*>(&array[off])->w < 0)
            {
                if (nstandard >= 0) nstandard = mdl_get_union<T*,U*>(&array[off])->w;
                else tdiff |= (MDL_UINT)mdl_get_union<T*,U*>(&array[off])->w ^ (MDL_UINT)nstandard;
            }
            else
            {
                if (pstandard < 0) pstandard = mdl_get_union<T*,U*>(&array[off])->w;
                else tdiff |= (MDL_UINT)mdl_get_union<T*,U*>(&array[off])->w ^ (MDL_UINT)pstandard;
            }
        }
    }
    
    if (primtype == PRIMTYPE_WORD)
    {
        bitno = (sizeof(MDL_INT) << 3);
        while (tdiff)
        {
            bitno--;
            tdiff >>= 1;
        }
        if ((pstandard >= 0) && (nstandard < 0) && bitno) 
        {
            negate = true;
            bitno--;
        }
        if (bitno == (sizeof(MDL_INT) << 3)) return;
    }
    mdl_radix_exchange_1<T,U>(array, reclen, keyoff, primtype, bitno, negate, 0, nrecs, aux);
}

void mdl_radix_exchange_vector_tuple(mdl_value_t *array, int reclen, int keyoff, int nrecs, mdl_value_t *aux)
{
    int off, i;
    primtype_t primtype = array[keyoff].pt;

    for (i = 1, off = (keyoff + reclen); i < nrecs; i++, off += reclen)
    {
        if (array[off].pt != primtype)
            mdl_error("Mixed primtypes for keys not allowed with FALSE predicate in SORT");
    }
    mdl_radix_exchange_0<mdl_value_t, mdl_value_union>(array, reclen, keyoff, primtype, nrecs, aux);
}

void mdl_radix_exchange_uvector(mdl_value_t *uv, int reclen, int keyoff, int nrecs, mdl_value_t *aux)
{
    primtype_t primtype = mdl_type_primtype(UVTYPE(uv));
    uvector_element_t *elems = UVREST(uv, 0);

    mdl_radix_exchange_0<uvector_element_t, uvector_element_t>(elems, reclen, keyoff, primtype, nrecs, aux);
}

// VECTOR primtypes (7.6.3)
// GROW is missing
mdl_value_t *mdl_builtin_eval_sort(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *pred;
    mdl_value_t *s1;
    mdl_value_t *l1;
    mdl_value_t *off;
    mdl_value_t *arr1;
    int keyoffset = 0;
    mdl_value_t *auxlist;
    int reclen1 = 1;
    int nrecs;
    
    // FIXME -- does not support auxiliary values or predicates
    GETNEXTARG(pred, args);
    GETNEXTREQARG(s1, args);
    GETNEXTARG(l1, args);
    GETNEXTARG(off, args);
    auxlist = mdl_make_tuple(REMAINING_ARGS(args));
    if (s1->pt != PRIMTYPE_VECTOR &&
        s1->pt != PRIMTYPE_UVECTOR &&
        s1->pt != PRIMTYPE_TUPLE)
        mdl_error("SORT can sort vectors/tuples only");
    if (l1 && l1->type != MDL_TYPE_FIX)
        mdl_error("Length argument to SORT must be FIX");
    if (off && off->type != MDL_TYPE_FIX)
        mdl_error("Offset argument to SORT must be FIX");
    if (l1) reclen1 = l1->v.w;
    if (off) keyoffset = off->v.w;

    if (keyoffset >= reclen1) mdl_error("Keys outside record in SORT");
    
    switch (s1->pt)
    {
    case PRIMTYPE_VECTOR:
        if ((VLENGTH(s1) % reclen1) != 0)
            mdl_error("Bad record size in SORT");
        nrecs = VLENGTH(s1)/reclen1;
        arr1 = VREST(s1, 0);
        mdl_radix_exchange_vector_tuple(arr1, reclen1, keyoffset, nrecs, auxlist);
        break;
    case PRIMTYPE_TUPLE:
        if ((TPLENGTH(s1) % reclen1) != 0)
            mdl_error("Bad record size in SORT");
        nrecs = TPLENGTH(s1)/reclen1;
        arr1 = TPREST(s1, 0);
        mdl_radix_exchange_vector_tuple(arr1, reclen1, keyoffset, nrecs, auxlist);
        break;
    case PRIMTYPE_UVECTOR:
        if ((UVLENGTH(s1) % reclen1) != 0)
            mdl_error("Bad record size in SORT");
        nrecs = UVLENGTH(s1)/reclen1;
        mdl_radix_exchange_uvector(s1, reclen1, keyoffset, nrecs, auxlist);
        break;
    default:
        mdl_error("Primtype for <SORT <> ...> must be TUPLE, VECTOR, or UVECTOR");
    }
    return s1;
}
// 7.6.5 UVECTOR subrs
mdl_value_t *mdl_builtin_eval_utype(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *uv;

    GETNEXTREQARG(uv, args);
    NOMOREARGS(args);
    return mdl_newatomval(mdl_type_atom(UVTYPE(uv)));
}

mdl_value_t *mdl_builtin_eval_chutype(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *uv;
    mdl_value_t *newtype;
    int oldtypenum, newtypenum;
    primtype_t oldprim, newprim;
    
    GETNEXTARG(uv, args);
    GETNEXTREQARG(newtype, args);
    NOMOREARGS(args);

    oldtypenum = UVTYPE(uv);
    oldprim = mdl_type_primtype(oldtypenum);
    newtypenum = mdl_get_typenum(newtype);
    newprim = mdl_type_primtype(newtypenum);
    if (oldtypenum != MDL_TYPE_LOSE)
    {
        if (oldprim != newprim) mdl_error("Can't change primtypes with CHUTYPE");
    }
    else
    {
        if (!mdl_valid_uvector_primtype(newprim))
            mdl_error("Type not valid for UVECTOR");
    }
    UVTYPE(uv) = newtypenum;
    return uv;
}

// 7.6.6 STRING and character
mdl_value_t *mdl_builtin_eval_ascii(mdl_value_t *form, mdl_value_t *args)
{
    ARGSETUP(args);
    mdl_value_t *forc;
    mdl_value_t *result;

    GETNEXTREQARG(forc, args);
    NOMOREARGS(args);

    if (forc->type == MDL_TYPE_CHARACTER)
    {
        result = mdl_new_mdl_value();
        *result = *forc;
        result->type = MDL_TYPE_FIX;
    }
    else if (forc->type == MDL_TYPE_FIX)
    {
        if (forc->v.w < 0 || forc->v.w > 127) // MDL only does 7-bit ascii
            mdl_error("Value for ASCII out of range");
        result = mdl_new_mdl_value();
        *result = *forc;
        result->type = MDL_TYPE_CHARACTER;
    }
    else
        mdl_error("Argument to ASCII must be FIX or CHARACTER");
    return result;
}

mdl_value_t *mdl_builtin_eval_parse(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *parse_string = NULL;
    mdl_value_t *radix = NULL;
    mdl_value_t *lookup = NULL;
    mdl_value_t *parse_table = NULL;
    mdl_value_t *look_ahead = NULL;
    mdl_value_t *result;

    GETNEXTARG(parse_string, args);
    GETNEXTARG(radix, args);
    GETNEXTARG(parse_table, args);
    GETNEXTARG(look_ahead, args);
    NOMOREARGS(args);

    if (!parse_string)
    {
        mdl_error("FIXME -- use PARSE-STRING");
    }
    else if (parse_string->type != MDL_TYPE_STRING)
        mdl_error("Can't parse a non-string");
    int radixint = 10;
    if (radix)
    {
        if (radix->type == MDL_TYPE_FIX)
            radixint = radix->v.w;
        else
            mdl_error("Radix must be a FIX");
    }
    if (look_ahead && look_ahead->type != MDL_TYPE_CHARACTER)
        mdl_error("Look-ahead must be a character");

    if (lookup)
    {
        mdl_bind_local_symbol(atom_oblist, lookup, cur_frame, false);
    }
    if (parse_string)
    {
        mdl_value_t *mdl_value_atom_parse_string = mdl_get_atom("PARSE-STRING!-", true, NULL);
        mdl_bind_local_symbol(mdl_value_atom_parse_string->v.a, parse_string, cur_frame, false);
    }
    if (parse_table)
    {
        mdl_value_t *mdl_value_atom_parse_table = mdl_get_atom("PARSE-TABLE!-", true, NULL);
        mdl_bind_local_symbol(mdl_value_atom_parse_table->v.a, parse_table, cur_frame, false);
    }

    result = mdl_parse_string(parse_string, radixint, look_ahead);
    return result;
}

// FIXME: LPARSE is missing

mdl_value_t *mdl_builtin_eval_unparse(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *obj = NULL;
    mdl_value_t *radix = NULL;
    mdl_value_t *chan;
    mdl_value_t *result;
    mdl_value_t *mdl_value_atom_outchan;

    GETNEXTREQARG(obj, args);
    GETNEXTARG(radix, args);
    NOMOREARGS(args);

    int radixint = 10;
    if (radix)
    {
        if (radix->type == MDL_TYPE_FIX)
            radixint = radix->v.w;
        else
            mdl_error("Radix must be a FIX");
    }

    chan = mdl_create_internal_output_channel(INTERNAL_BUFSIZE, 0, NULL);
    mdl_value_atom_outchan = mdl_get_atom("OUTCHAN!-", true, NULL);
    mdl_bind_local_symbol(mdl_value_atom_outchan->v.a, chan, cur_frame, false);

    mdl_print_value_to_chan(chan, obj, false, false, NULL);
    result = mdl_get_internal_output_channel_string(chan);
    return result;
}

/// DEFINE and friends
mdl_value_t *mdl_builtin_eval_define(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    mdl_value_t *firstarg = LITEM(args, 0);
    if (!firstarg)
        mdl_error("DEFINE must have an argument");
    firstarg = mdl_eval(firstarg);
    if (!firstarg) return NULL;
    if (firstarg->type != MDL_TYPE_ATOM)
        mdl_error("First argument of DEFINE must be an atom");

    mdl_value_t *redefine = mdl_local_symbol_lookup(mdl_value_atom_redefine->v.a);
    if (!redefine || redefine->type == MDL_TYPE_UNBOUND ||
        !mdl_is_true(redefine))
    {
        mdl_value_t *result = mdl_global_symbol_lookup(firstarg->v.a);
        if (result && result->type != MDL_TYPE_UNBOUND)
        {
            mdl_print_value(stderr, firstarg);
            mdl_error("Atom is already bound in DEFINE");
        }
    }

    mdl_value_t *func = mdl_internal_shallow_copy_list(LREST(args,1));
    func = mdl_make_list(func, MDL_TYPE_FUNCTION);
    mdl_set_gval(firstarg->v.a, func);
    return firstarg;
}

mdl_value_t *mdl_builtin_eval_defmac(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    mdl_value_t *firstarg = LITEM(args, 0);
    if (!firstarg)
        mdl_error("DEFMAC must have an argument");
    firstarg = mdl_eval(firstarg);
    if (!firstarg) return NULL;
    if (firstarg->type != MDL_TYPE_ATOM)
        mdl_error("First argument of DEFMAC must be an atom");

    mdl_value_t *redefine = mdl_local_symbol_lookup(mdl_value_atom_redefine->v.a);
    if (!redefine || !mdl_is_true(redefine))
    {
        mdl_value_t *result = mdl_global_symbol_lookup(firstarg->v.a);
        if (result && result->type != MDL_TYPE_UNBOUND)
        {
            mdl_error("Atom is already bound in DEFMAC");
        }
    }

    mdl_value_t *func = mdl_internal_shallow_copy_list(LREST(args,1));
    func = mdl_make_list(func, MDL_TYPE_MACRO);
    mdl_set_gval(firstarg->v.a, func);
    return firstarg;
}

mdl_value_t *mdl_builtin_eval_expand(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *arg;

    GETNEXTREQARG(arg, args);
    NOMOREARGS(args);

    return mdl_internal_expand(arg);
}

mdl_value_t *mdl_builtin_eval_eval(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *arg;
    mdl_value_t *env;

    GETNEXTREQARG(arg, args);
    GETNEXTARG(env, args);
    NOMOREARGS(args);

    return mdl_eval(arg, false, env);
}

mdl_value_t *mdl_builtin_eval_apply(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *applier;

    GETNEXTREQARG(applier, args);

    return mdl_internal_apply(applier, args, true);
}

// LOOPING - PROG, REPEAT, BIND, RETURN, AGAIN
mdl_value_t *mdl_builtin_eval_bind(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    return mdl_internal_prog_repeat_bind(form, false, false);
}

mdl_value_t *mdl_builtin_eval_repeat(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    return mdl_internal_prog_repeat_bind(form, true, true);
}

mdl_value_t *mdl_builtin_eval_again(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *act;

    GETNEXTARG(act, args);
    NOMOREARGS(args);

    if (!act)
    {
        act = mdl_local_symbol_lookup_1_activation_only_please(mdl_value_atom_lastprog->v.a, cur_frame);
    }
    if (!act)
        mdl_error("No activation in AGAIN");
    
    mdl_longjmp_to(act->v.f, LONGJMP_AGAIN);
}

mdl_value_t *mdl_builtin_eval_return(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *val;
    mdl_value_t *act;

    GETNEXTARG(val, args);
    GETNEXTARG(act, args);
    NOMOREARGS(args);

    if (!val) val = mdl_value_T;
    if (!act)
    {
        act = mdl_local_symbol_lookup_1_activation_only_please(mdl_value_atom_lastprog->v.a, cur_frame);
    }
    if (!act)
        mdl_error("No activation in RETURN");
    
    act->v.f->result = val;
    mdl_longjmp_to(act->v.f, LONGJMP_RETURN);
}

mdl_value_t *mdl_builtin_eval_prog(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    return mdl_internal_prog_repeat_bind(form, true, false);
}

// MAPF/MAPR
mdl_value_t *mdl_builtin_eval_mapf(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_internal_eval_mapfr(form, args, false);
}

mdl_value_t *mdl_builtin_eval_mapr(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_internal_eval_mapfr(form, args, true);
}

mdl_value_t *mdl_builtin_eval_mapret(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *act;
    act = mdl_local_symbol_lookup(mdl_value_atom_lastmap->v.a, cur_frame);
    if (!act)
        mdl_error("No map in MAPRET");
    
    act->v.f->result = args;
    mdl_longjmp_to(act->v.f, LONGJMP_MAPRET);
}

mdl_value_t *mdl_builtin_eval_mapstop(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *act;
    act = mdl_local_symbol_lookup(mdl_value_atom_lastmap->v.a, cur_frame);
    if (!act)
        mdl_error("No map in MAPSTOP");
    
    act->v.f->result = args;
    mdl_longjmp_to(act->v.f, LONGJMP_MAPSTOP);
}

mdl_value_t *mdl_builtin_eval_mapleave(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *val;

    GETARG(val, 0, args);

    if (!val) val = mdl_value_T;
    mdl_value_t *act = mdl_local_symbol_lookup(mdl_value_atom_lastmap->v.a, cur_frame);

    if (!act)
        mdl_error("No map in MAPLEAVE");
    
    act->v.f->result = val;
    mdl_longjmp_to(act->v.f, LONGJMP_MAPLEAVE);
}

// Arithmetic predicates (8.2.1)

mdl_value_t *mdl_builtin_eval_zerop(mdl_value_t *form, mdl_value_t *args)
/* SUBR 0? */
{
    ARGSETUP(args);
    mdl_value_t *e1;
    GETNEXTREQARG(e1, args);
    NOMOREARGS(args);
    if (e1->type == MDL_TYPE_FIX)
        return mdl_boolean_value(e1->v.w == 0);
    else if (e1->type == MDL_TYPE_FLOAT)
        return mdl_boolean_value(e1->v.fl == 0.0);
    else
    {
        mdl_error("First arg to 0? must be FIX or FLOAT");
    }
}

mdl_value_t *mdl_builtin_eval_onep(mdl_value_t *form, mdl_value_t *args)
/* SUBR 1? */
{
    ARGSETUP(args);
    mdl_value_t *e1;
    GETNEXTREQARG(e1, args);
    NOMOREARGS(args);
    if (e1->type == MDL_TYPE_FIX)
        return mdl_boolean_value(e1->v.w == 1);
    else if (e1->type == MDL_TYPE_FLOAT)
        return mdl_boolean_value(e1->v.fl == 1.0);
    else
        mdl_error("First arg to 1? must be FIX or FLOAT");
}


#define MDL_COMPARE_NUMERIC(e1, e2, op) \
    (((e1)->type == MDL_TYPE_FIX)?(((e2)->type == MDL_TYPE_FIX)?((e1)->v.w op (e2)->v.w):((e1)->v.w op (e2)->v.fl)):(((e2)->type == MDL_TYPE_FIX)?((e1)->v.fl op (e2)->v.w):((e1)->v.fl op (e2)->v.fl)))

mdl_value_t *mdl_builtin_eval_greaterp(mdl_value_t *form, mdl_value_t *args)
/* SUBR G? */
{
    ARGSETUP(args);
    mdl_value_t *e1;
    mdl_value_t *e2;
    GETNEXTREQARG(e1, args);
    GETNEXTREQARG(e2, args);
    NOMOREARGS(args);

    if (e1->type != MDL_TYPE_FIX && e1->type != MDL_TYPE_FLOAT)
        mdl_error("First arg to G? must be FIX or FLOAT");
    if (e2->type != MDL_TYPE_FIX && e2->type != MDL_TYPE_FLOAT)
        mdl_error("Second arg to G? must be FIX or FLOAT");
    return mdl_boolean_value(MDL_COMPARE_NUMERIC(e1, e2, >));
}

mdl_value_t *mdl_builtin_eval_lessp(mdl_value_t *form, mdl_value_t *args)
/* SUBR L? */
{
    ARGSETUP(args);
    mdl_value_t *e1;
    mdl_value_t *e2;
    GETNEXTREQARG(e1, args);
    GETNEXTREQARG(e2, args);
    NOMOREARGS(args);

    if (e1->type != MDL_TYPE_FIX && e1->type != MDL_TYPE_FLOAT)
        mdl_error("First arg to L? must be FIX or FLOAT");
    if (e2->type != MDL_TYPE_FIX && e2->type != MDL_TYPE_FLOAT)
        mdl_error("Second arg to L? must be FIX or FLOAT");
    return mdl_boolean_value(MDL_COMPARE_NUMERIC(e1, e2, <));
}

mdl_value_t *mdl_builtin_eval_greaterequalp(mdl_value_t *form, mdl_value_t *args)
/* SUBR G=? */
{
    ARGSETUP(args);
    mdl_value_t *e1;
    mdl_value_t *e2;
    GETNEXTREQARG(e1, args);
    GETNEXTREQARG(e2, args);
    NOMOREARGS(args);

    if (e1->type != MDL_TYPE_FIX && e1->type != MDL_TYPE_FLOAT)
        mdl_error("First arg to G=? must be FIX or FLOAT");
    if (e2->type != MDL_TYPE_FIX && e2->type != MDL_TYPE_FLOAT)
        mdl_error("Second arg to G=? must be FIX or FLOAT");
    return mdl_boolean_value(!MDL_COMPARE_NUMERIC(e1, e2, <));
}

mdl_value_t *mdl_builtin_eval_lessequalp(mdl_value_t *form, mdl_value_t *args)
/* SUBR L=? */
{
    ARGSETUP(args);
    mdl_value_t *e1;
    mdl_value_t *e2;
    GETNEXTREQARG(e1, args);
    GETNEXTREQARG(e2, args);
    NOMOREARGS(args);

    if (e1->type != MDL_TYPE_FIX && e1->type != MDL_TYPE_FLOAT)
        mdl_error("First arg to L=? must be FIX or FLOAT");
    if (e2->type != MDL_TYPE_FIX && e2->type != MDL_TYPE_FLOAT)
        mdl_error("Second arg to L=? must be FIX or FLOAT");
    return mdl_boolean_value(!MDL_COMPARE_NUMERIC(e1, e2, >));
}

// Equality and membership (8.2.2)
mdl_value_t *mdl_builtin_eval_double_equalp(mdl_value_t *form, mdl_value_t *args)
/* SUBR ==? */
{
    ARGSETUP(args);
    mdl_value_t *e1;
    mdl_value_t *e2;
    GETNEXTREQARG(e1, args);
    GETNEXTREQARG(e2, args);
    NOMOREARGS(args);

    return mdl_boolean_value(mdl_value_double_equal(e1, e2));
}

mdl_value_t *mdl_builtin_eval_double_nequalp(mdl_value_t *form, mdl_value_t *args)
/* SUBR N==? */
{
    ARGSETUP(args);
    mdl_value_t *e1;
    mdl_value_t *e2;
    GETNEXTREQARG(e1, args);
    GETNEXTREQARG(e2, args);
    NOMOREARGS(args);

    return mdl_boolean_value(!mdl_value_double_equal(e1, e2));
}

mdl_value_t *mdl_builtin_eval_equalp(mdl_value_t *form, mdl_value_t *args)
/* SUBR =? */
{
    ARGSETUP(args);
    mdl_value_t *e1;
    mdl_value_t *e2;
    GETNEXTREQARG(e1, args);
    GETNEXTREQARG(e2, args);
    NOMOREARGS(args);

    return mdl_boolean_value(mdl_value_equal(e1, e2));
}

mdl_value_t *mdl_builtin_eval_nequalp(mdl_value_t *form, mdl_value_t *args)
/* SUBR N=? */
{
    ARGSETUP(args);
    mdl_value_t *e1;
    mdl_value_t *e2;
    GETNEXTREQARG(e1, args);
    GETNEXTREQARG(e2, args);
    NOMOREARGS(args);

    return mdl_boolean_value(!mdl_value_equal(e1, e2));
}

void *mdl_memmem(void *hp, int hl, void *np, int nl)
{
    char *sp = (char *)hp; // scan pointer
    char *se = (char *)hp + hl - nl + 1; // scan end
    char *ne = (char *)np + nl; // needle end
    char *shp, *snp; // inner scanners
    while (sp < se)
    {
        if (*sp == *(char *)np)
        {
            shp = sp;
            snp = (char *)np;
            while (snp < ne)
            {
                if (*snp != *shp) break;
                snp++;
                shp++;
            }
            if (snp == ne) return (void *)sp;
        }
        sp++;
    }
    return NULL;
}

mdl_value_t *mdl_builtin_eval_member(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *obj;
    mdl_value_t *structured;
    mdl_struct_walker_t w;
    mdl_value_t *elem;

    GETNEXTARG(obj, args);
    GETNEXTREQARG(structured, args);
    NOMOREARGS(args);
    if (mdl_primtype_nonstructured(structured->pt)) mdl_error("Second arg to MEMBER must be structured");
    
    if (structured->pt == PRIMTYPE_STRING && obj->pt == PRIMTYPE_STRING)
    {
        void *substr;
        substr = mdl_memmem(structured->v.s.p, structured->v.s.l,
                            obj->v.s.p, obj->v.s.l);
        if (substr)
        {
            return mdl_make_string(structured->v.s.l - ((char *)substr - structured->v.s.p), (char *)substr);
        }
        return &mdl_value_false;
    }
    mdl_init_struct_walker(&w, structured);
    elem = w.next(&w);
    while (elem)
    {
        if (mdl_value_equal(elem, obj))
        {
            return w.rest(&w);
        }
            
        elem = w.next(&w);
    }
    return &mdl_value_false;
}
// ARGSTOP

mdl_value_t *mdl_builtin_eval_memq(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *obj = LITEM(args, 0);
    mdl_value_t *structured = LITEM(args, 1);
    mdl_struct_walker_t w;
    mdl_value_t *elem;

    if (!obj) mdl_error("Not enough arguments to MEMQ");
    if (LHASITEM(args, 2))
        mdl_error("Too many args to MEMQ");
    if (mdl_primtype_nonstructured(structured->pt)) mdl_error("Second arg to MEMQ must be structured");
    
    mdl_init_struct_walker(&w, structured);
    elem = w.next(&w);
    while (elem)
    {
        if (mdl_value_double_equal(elem, obj))
        {
            return w.rest(&w);
        }
            
        elem = w.next(&w);
    }
    return &mdl_value_false;
}
// STRCOMP
mdl_value_t *mdl_builtin_eval_strcomp(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *e1 = LITEM(args, 0);
    mdl_value_t *e2 = LITEM(args, 1);
    if (!e2)
        mdl_error("Not enough args to STRCOMP");
    if (LHASITEM(args, 2))
        mdl_error("Too many args to STRCOMP");
    if (e1->type == MDL_TYPE_ATOM && e2->type == MDL_TYPE_ATOM)
    {
        int val = strcmp(e1->v.a->pname, e2->v.a->pname);
        
        if (val < 0) return mdl_new_fix(-1);
        else if (val > 0) return mdl_new_fix(1);
        else return mdl_new_fix(0);
    }
    else if (e1->type == MDL_TYPE_STRING && e2->type == MDL_TYPE_STRING)
    {
        int minlen = (e1->v.s.l < e2->v.s.l)?e1->v.s.l:e2->v.s.l;
        int val = memcmp(e1->v.s.p, e2->v.s.p, minlen);

        if (val < 0) return mdl_new_fix(-1);
        else if (val > 0) return mdl_new_fix(1);
        else if (e1->v.s.l < e2->v.s.l) return mdl_new_fix(-1);
        else if (e1->v.s.l > e2->v.s.l) return mdl_new_fix(1);
        else return mdl_new_fix(0);
    }
    else
    {
        mdl_error("Args to STRCOMP must be both ATOM or both STRING");
    }
}

// ARITHMETIC
mdl_value_t *mdl_builtin_eval_multiply(mdl_value_t *form, mdl_value_t *args)
/* SUBR * */
{
    MDL_INT accum = 1;
    MDL_FLOAT faccum = 1;
    bool floating = false;

    mdl_value_t *argp = LREST(args, 0);
    while (argp)
    {
        mdl_value_t *arg = argp->v.p.car;
        if (arg->type == MDL_TYPE_FLOAT)
        {
            if (!floating) 
            {
                faccum = accum;
                floating = true;
            }
            faccum *= arg->v.fl;
        }
        else 
        {
            if (arg->type != MDL_TYPE_FIX)
                mdl_error("Arguments to * must be FIX OR FLOAT ");
            
            if (floating)
                faccum *= arg->v.w;
            else
                accum *= arg->v.w;
        }
        argp = argp->v.p.cdr;
    }
    if (floating)
        return mdl_new_float(faccum);
    else
        return mdl_new_fix(accum);
}

mdl_value_t *mdl_builtin_eval_add(mdl_value_t *form, mdl_value_t *args)
/* SUBR + */
{
    MDL_INT accum = 0;
    MDL_FLOAT faccum = 0;
    bool floating = false;

    mdl_value_t *argp = LREST(args, 0);
    while (argp)
    {
        mdl_value_t *arg = argp->v.p.car;
        if (arg->type == MDL_TYPE_FLOAT)
        {
            if (!floating) 
            {
                faccum = accum;
                floating = true;
            }
            faccum += arg->v.fl;
        }
        else 
        {
            if (arg->type != MDL_TYPE_FIX)
                mdl_error("Arguments to + must be FIX OR FLOAT ");
            
            if (floating)
                faccum += arg->v.w;
            else
                accum += arg->v.w;
        }
        argp = argp->v.p.cdr;
    }
    if (floating)
        return mdl_new_float(faccum);
    else
        return mdl_new_fix(accum);
}

mdl_value_t *mdl_builtin_eval_subtract(mdl_value_t *form, mdl_value_t *args)
/* SUBR - */
{
    MDL_INT accum = 0;
    MDL_FLOAT faccum = 0;
    bool floating = false;
    bool firstarg = true;

    mdl_value_t *argp = LREST(args, 0);
    while (argp)
    {
        mdl_value_t *arg = argp->v.p.car;
        if (arg->type == MDL_TYPE_FLOAT)
        {
            if (!floating) 
            {
                faccum = accum;
                floating = true;
            }
            if (firstarg)
                faccum = arg->v.fl;
            else
                faccum = faccum - arg->v.fl;
        }
        else 
        {
            if (arg->type != MDL_TYPE_FIX)
                mdl_error("Arguments to - must be FIX OR FLOAT ");
            
            if (firstarg)
            {
                accum = arg->v.w;
            }
            else
            {
                if (floating)
                    faccum = faccum - arg->v.w;
                else
                    accum = accum - arg->v.w;
            }
        }
        argp = argp->v.p.cdr;
        if (firstarg && !argp)
        {
            if (floating)
                faccum = -faccum;
            else
                accum = -accum;
        }
        firstarg = false;
    }
    if (floating)
        return mdl_new_float(faccum);
    else
        return mdl_new_fix(accum);
}

mdl_value_t *mdl_builtin_eval_divide(mdl_value_t *form, mdl_value_t *args)
/* SUBR / */
{
    MDL_INT accum = 0;
    MDL_FLOAT faccum = 0;
    bool floating = false;
    bool firstarg = true;

    mdl_value_t *argp = LREST(args, 0);
    while (argp)
    {
        mdl_value_t *arg = argp->v.p.car;
        if (arg->type == MDL_TYPE_FLOAT)
        {
            if (!floating) 
            {
                faccum = accum;
                floating = true;
            }
            if (firstarg)
                faccum = arg->v.fl;
            else
            {
                if (arg->v.fl == 0.0) mdl_error("DIVIDE by 0");
                faccum = faccum / arg->v.fl;
            }
        }
        else 
        {
            if (arg->type != MDL_TYPE_FIX)
                mdl_error("Arguments to / must be FIX OR FLOAT ");
            
            if (firstarg)
            {
                accum = arg->v.w;
            }
            else
            {
                if (arg->v.w == 0.0) mdl_error("DIVIDE by 0");
                if (floating)
                    faccum = faccum / arg->v.w;
                else
                    accum = accum / arg->v.w;
            }
        }
        argp = argp->v.p.cdr;
        if (firstarg && !argp)
        {
            // unary divide
            if (floating)
                faccum = 1/faccum;
            else
                accum = 1/accum;
        }
        firstarg = false;
    }
    if (floating)
        return mdl_new_float(faccum);
    else
        return mdl_new_fix(accum);
}

mdl_value_t *mdl_builtin_eval_min(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    MDL_INT accum = MDL_INT_MAX;
    MDL_FLOAT faccum = MDL_FLOAT_MAX;
    bool floating = false;
    bool firstarg = true;

    mdl_value_t *argp = LREST(args, 0);
    while (argp)
    {
        mdl_value_t *arg = argp->v.p.car;
        if (arg->type == MDL_TYPE_FLOAT)
        {
            if (!floating)
            {
                if (!firstarg)
                    faccum = accum;
                floating = true;
            }
            if (faccum > arg->v.fl) faccum = arg->v.fl;
        }
        else 
        {
            if (arg->type != MDL_TYPE_FIX)
                mdl_error("Arguments to MIN must be FIX OR FLOAT ");
            
            if (floating)
            {
                if (faccum > arg->v.w) faccum = arg->v.w;
            }
            else
            {
                if (accum > arg->v.w) accum = arg->v.w;
            }
        }
        argp = argp->v.p.cdr;
        firstarg = false;
    }
    if (floating || firstarg)
        return mdl_new_float(faccum);
    else
        return mdl_new_fix(accum);
}

mdl_value_t *mdl_builtin_eval_max(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    MDL_INT accum = MDL_INT_MIN;
    MDL_FLOAT faccum = MDL_FLOAT_MIN;
    bool floating = false;
    bool firstarg = true;

    mdl_value_t *argp = LREST(args, 0);
    while (argp)
    {
        mdl_value_t *arg = argp->v.p.car;
        if (arg->type == MDL_TYPE_FLOAT)
        {
            if (!floating)
            {
                if (!firstarg)
                    faccum = accum;
                floating = true;
            }
            if (faccum < arg->v.fl) faccum = arg->v.fl;
        }
        else 
        {
            if (arg->type != MDL_TYPE_FIX)
                mdl_error("Arguments to MAX must be FIX OR FLOAT ");
            
            if (floating)
            {
                if (faccum < arg->v.w) faccum = arg->v.w;
            }
            else
            {
                if (accum < arg->v.w) accum = arg->v.w;
            }
        }
        argp = argp->v.p.cdr;
        firstarg = false;
    }
    if (floating || firstarg)
        return mdl_new_float(faccum);
    else
        return mdl_new_fix(accum);
}

mdl_value_t *mdl_builtin_eval_mod(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    MDL_INT numv,modv,result;

    mdl_value_t *num = LITEM(args, 0);
    mdl_value_t *modulus = LITEM(args, 1);

    if (LHASITEM(args, 2)) mdl_error("Too many arguments to MOD");
    if (num->type != MDL_TYPE_FIX || modulus->type != MDL_TYPE_FIX)
    {
       mdl_error("MOD arguments must be of type FIX");
    }
    numv = num->v.w;
    modv = modulus->v.w;

    if (modv == 0)
        mdl_error("MOD with 0");
    result = numv % modv;
    if ((result < 0 && modv > 0) || 
        (result > 0 && modv < 0))
    {
        result += modv;
    }
    return mdl_new_fix(result);
}

mdl_value_t *mdl_builtin_eval_random(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *seed1, *seed2;
    MDL_INT rvalue;
    unsigned short rseed[3];
    
    OARGSETUP(args, cursor);
    OGETNEXTARG(seed1, cursor);
    OGETNEXTARG(seed2, cursor);
    if (cursor) mdl_error("Too many args to RANDOM");
    if (seed1 && seed1->type != MDL_TYPE_FIX)
        mdl_error("RANDOM seeds must be type FIX");
    if (seed2 && seed2->type != MDL_TYPE_FIX)
        mdl_error("RANDOM seeds must be type FIX");
    if (seed1 && seed2)
    {
#ifdef MDL32
        uint64_t tot_seed = ((uint64_t)seed1->v.w << 16) ^ ((uint64_t)seed2->v.w);
        rseed[0] = tot_seed >> 32;
        rseed[1] = tot_seed >> 16;
        rseed[2] = tot_seed;
#else
        // treat the seed as two 36-bit numbers; XOR together for 48 bits
        uint64_t tot_seed = ((MDL_UINT)seed1->v.w << 12) ^ ((MDL_UINT)seed2->v.w);
        rseed[0] = tot_seed >> 32;
        rseed[1] = tot_seed >> 16;
        rseed[2] = tot_seed;
#endif
        seed48(rseed);
    }
    else if (seed1)
    {
#ifdef MDL32
        rseed[0] = seed1->v.w >> 16;
        rseed[1] = seed1->v.w;
        rseed[2] = 1;
#else
        // 36-bit seed
        rseed[0] = seed1->v.w >> 20;
        rseed[1] = seed1->v.w >> 4;
        rseed[2] = seed1->v.w & 0xF;
#endif
        seed48(rseed);
    }
#ifdef MDL32
    rvalue = mrand48();
#else
    rvalue = (MDL_INT)(((MDL_UINT)mrand48() << 32) ^ ((MDL_UINT)mrand48()));
#endif
    return mdl_new_fix(rvalue);

}

mdl_value_t *mdl_builtin_eval_float(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *arg = args->v.p.cdr->v.p.car;
    if (!arg) mdl_error("Not enough args to FLOAT");
    if (args->v.p.cdr->v.p.cdr) mdl_error("Too many args to FLOAT");
    if (arg->type != MDL_TYPE_FIX)
        mdl_error("Arg to FLOAT must be FIX");
    return mdl_new_float((MDL_FLOAT)arg->v.w);
}

mdl_value_t *mdl_builtin_eval_fix(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *arg = args->v.p.cdr->v.p.car;
    if (!arg) mdl_error("Not enough args to FLOAT");
    if (args->v.p.cdr->v.p.cdr) mdl_error("Too many args to FLOAT");
    if (arg->type != MDL_TYPE_FLOAT)
        mdl_error("Arg to FIX must be FLOAT");
    return mdl_new_fix((MDL_INT)arg->v.fl);
}
mdl_value_t *mdl_builtin_eval_abs(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *num;
    GETNEXTREQARG(num, args);
    NOMOREARGS(args);
    if (num->type == MDL_TYPE_FLOAT)
    {
#ifdef MDL32
        return mdl_new_float(fabsf(num->v.fl));
#else
        return mdl_new_float(fabs(num->v.w));
#endif
    }
    else if (num->type == MDL_TYPE_FIX)
    {
        return mdl_new_fix((num->v.w<0)?(-num->v.w):num->v.w);
    }
    return mdl_call_error("FIRST-ARG-WRONG-TYPE", NULL);
}


// Properties
mdl_value_t *mdl_builtin_eval_getprop(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *item = LITEM(args, 0);
    mdl_value_t *indicator = LITEM(args, 1);
    mdl_value_t *exp = LITEM(args, 2);
    if (indicator == NULL)
    {
        mdl_error("Not enough ARGS in GETPROP");
    }
    if (LHASITEM(args, 3))
    {
        mdl_error("Too many ARGS in GETPROP");
    }
    mdl_value_t *result =  mdl_internal_eval_getprop(item, indicator);
    if (result == NULL)
    {
        if (exp) result =  mdl_eval(exp);
        else result = &mdl_value_false;
    }
    return result;
}

mdl_value_t *mdl_builtin_eval_putprop(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *item = LITEM(args, 0);
    mdl_value_t *indicator = LITEM(args, 1);
    mdl_value_t *value = LITEM(args, 2);
    if (indicator == NULL)
    {
        mdl_error("Not enough ARGS in PUTPROP");
    }
    if (LHASITEM(args, 3))
    {
        mdl_error("Too many ARGS in PUTPROP");
    }
    mdl_value_t *result =  mdl_internal_eval_putprop(item, indicator, value);
    return result;
}

// Object lists
mdl_value_t *mdl_builtin_eval_moblist(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *oblname = LITEM(args, 0);
    mdl_value_t *fix = LITEM(args, 1);
    if (!oblname)
        mdl_error("Not enough arguments to MOBLIST");
    if (LHASITEM(args, 2))
        mdl_error("Too many arguments to MOBLIST");
    if (oblname->type != MDL_TYPE_ATOM)
        mdl_error("First argument to MOBLIST must be atom");
    if (fix && fix->type != MDL_TYPE_FIX)
        mdl_error("First argument to MOBLIST must be atom");
    MDL_INT buckets = MDL_OBLIST_HASHBUCKET_DEFAULT;
    if (fix) buckets = fix->v.w;
    if (buckets <= 0) 
        mdl_error("Number of buckets for MOBLIST must be > 0");
    return mdl_create_oblist(oblname, buckets);
}
mdl_value_t *mdl_builtin_eval_oblistp(mdl_value_t *form, mdl_value_t *args)
/* SUBR OBLIST? */
{
    mdl_value_t *a = LITEM(args, 0);
    if (!a)
        mdl_error("Not enough arguments to OBLIST?");
    if (LHASITEM(args, 1))
        mdl_error("Too many arguments to OBLIST?");
    if (a->type != MDL_TYPE_ATOM)
        return mdl_call_error("FIRST-ARG-WRONG-TYPE", cur_frame->subr, a, NULL);
    if (!a->v.a->oblist) return &mdl_value_false;
    return a->v.a->oblist;
}

mdl_value_t *mdl_builtin_eval_lookup(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *str = LITEM(args, 0);
    mdl_value_t *oblist = LITEM(args, 1);
    if (!oblist)
        mdl_error("Not enough arguments to LOOKUP");
    if (LHASITEM(args, 2))
        mdl_error("Too many arguments to LOOKUP");
    if (str->type != MDL_TYPE_STRING)
        mdl_error("First argument to LOOKUP must be string");
    if (oblist->type != MDL_TYPE_OBLIST)
        mdl_error("Second argument to LOOKUP must be oblist");
    mdl_value_t *result = mdl_get_atom_from_oblist(str->v.s.p, oblist);
    if (result) return result;
    return &mdl_value_false;
}

mdl_value_t *mdl_builtin_eval_atom(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *str = LITEM(args, 0);
    if (!str)
        mdl_error("Not enough arguments to ATOM");
    if (LHASITEM(args, 1))
        mdl_error("Too many arguments to ATOM");
    if (str->type != MDL_TYPE_STRING)
        mdl_error("First argument to ATOM must be string");
    mdl_value_t *result = mdl_create_atom(str->v.s.p);
    return result;
}

mdl_value_t *mdl_builtin_eval_remove(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *str = LITEM(args, 0);
    mdl_value_t *oblist = LITEM(args, 1);
    mdl_value_t *result;

    if (str->type == MDL_TYPE_ATOM)
    {
        if (oblist)
            mdl_error("Too many arguments to REMOVE (atom)");
        result = mdl_remove_atom_from_oblist(str->v.a->pname, str->v.a->oblist);
    }
    else
    {
        if (!oblist)
            mdl_error("Not enough arguments to REMOVE");
        if (LHASITEM(args, 2))
            mdl_error("Too many arguments to REMOVE");
        if (str->type != MDL_TYPE_STRING)
            mdl_error("First argument to REMOVE must be string if oblist specified");
        if (oblist->type != MDL_TYPE_OBLIST)
            mdl_error("Second argument to REMOVE must be oblist");
        result = mdl_remove_atom_from_oblist(str->v.s.p, oblist);
    }
    if (result) return result;
    return &mdl_value_false;
}

mdl_value_t *mdl_builtin_eval_insert(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *str = LITEM(args, 0);
    mdl_value_t *oblist = LITEM(args, 1);
    mdl_value_t *result = NULL;

    if (!oblist)
        mdl_error("Not enough arguments to INSERT");
    if (oblist->type != MDL_TYPE_OBLIST)
        mdl_error("Second argument to INSERT must be oblist");
    if (LHASITEM(args, 2))
        mdl_error("Too many arguments to INSERT");
    if (str->type == MDL_TYPE_ATOM)
    {
        if (str->v.a->oblist)
            return mdl_call_error_ext("ATOM-ALREADY-THERE", "Cannot INSERT, atom already on plist", str, mdl_internal_eval_getprop(oblist, mdl_value_oblist), NULL);
        if (mdl_get_atom_from_oblist(str->v.a->pname, oblist))
            return mdl_call_error_ext("ATOM-ALREADY-THERE", "Cannot INSERT, atom with same pname exists on oblist", str, mdl_internal_eval_getprop(oblist, mdl_value_oblist), NULL);
        mdl_put_atom_in_oblist(str->v.a->pname, oblist, str);
        str->v.a->oblist = oblist;
        result = str;
    }
    else if (str->type == MDL_TYPE_STRING)
    {
        result = mdl_create_atom_on_oblist(str->v.s.p, oblist);
        if (result == NULL)
            mdl_error("Cannot INSERT, atom with given pname exists on oblist");
    }
    else
        mdl_error("First argument to INSERT must be string or atom");
    if (result) return result;
    return &mdl_value_false;
}


mdl_value_t *mdl_builtin_eval_pname(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *a = LITEM(args,0);

    if (!a)
        mdl_error("Not enough arguments to PNAME");
    if (a->type != MDL_TYPE_ATOM)
        return mdl_call_error_ext("FIRST-ARG-WRONG-TYPE", "First argument to PNAME must be ATOM", NULL);
    if (LHASITEM(args, 1))
        mdl_error("Too many arguments to PNAME");
    return mdl_new_string(a->v.a->pname);
}

mdl_value_t *mdl_builtin_eval_spname(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *a = LITEM(args,0);

    if (!a)
        mdl_error("Not enough arguments to SPNAME");
    if (a->type != MDL_TYPE_ATOM)
        mdl_call_error("FIRST-ARG-WRONG-TYPE", cur_frame->subr, a, NULL);
    if (LHASITEM(args, 1))
        mdl_error("Too many arguments to SPNAME");
    return mdl_make_string(a->v.a->pname);
}

mdl_value_t *mdl_builtin_eval_root(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    if (LHASITEM(args, 0))
        mdl_error("Too many arguments to ROOT");
    return mdl_value_root_oblist;
}

mdl_value_t *mdl_builtin_eval_block(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *lookup = LITEM(args, 0);
    if (lookup == NULL)
        mdl_error("Too few arguments to BLOCK");
    if (LHASITEM(args, 1))
        mdl_error("Too many arguments to BLOCK");
    return mdl_push_oblist_lval(lookup);
}

mdl_value_t *mdl_builtin_eval_endblock(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    if (LHASITEM(args, 0))
        mdl_error("Too many arguments to ENDBLOCK");
    return mdl_pop_oblist_lval();
}

// Boolean operators (8.2.3)
mdl_value_t *mdl_builtin_eval_not(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *arg;

    GETNEXTREQARG(arg, args);
    NOMOREARGS(args);

    return mdl_boolean_value(!mdl_is_true(arg));
}

mdl_value_t *mdl_builtin_eval_and(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    mdl_value_t *rest = LREST(args, 0);
    mdl_value_t *result = mdl_value_T;

    while (rest)
    {
        result = mdl_eval(rest->v.p.car);
        if (!mdl_is_true(result)) break;
        rest = rest->v.p.cdr;
    }
    return result;
}

mdl_value_t *mdl_builtin_eval_andp(mdl_value_t *form, mdl_value_t *args)
/* SUBR AND? */
{
    mdl_value_t *rest = LREST(args, 0);
    mdl_value_t *result = mdl_value_T;

    while (rest)
    {
        result = rest->v.p.car;
        if (!mdl_is_true(result)) break;
        rest = rest->v.p.cdr;
    }
    return result;
}

mdl_value_t *mdl_builtin_eval_or(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    mdl_value_t *rest = LREST(args, 0);
    mdl_value_t *result = &mdl_value_false;

    while (rest)
    {
        result = mdl_eval(rest->v.p.car);
        if (mdl_is_true(result)) break;
        rest = rest->v.p.cdr;
    }
    return result;
}

mdl_value_t *mdl_builtin_eval_orp(mdl_value_t *form, mdl_value_t *args)
/* SUBR OR? */
{
    mdl_value_t *rest = LREST(args, 0);
    mdl_value_t *result = &mdl_value_false;

    while (rest)
    {
        result = rest->v.p.car;
        if (mdl_is_true(result)) break;
        rest = rest->v.p.cdr;
    }
    return result;
}

// Object properties (8.2.4)

mdl_value_t *mdl_builtin_eval_typep(mdl_value_t *form, mdl_value_t *args)
/* SUBR TYPE? */
{
    mdl_value_t *arg = LITEM(args, 0);
    mdl_value_t *rest = LREST(args, 1);
    
    mdl_value_t *result = &mdl_value_false;

    if (arg == NULL)
        mdl_error("Not enough arguments to TYPE?");
    atom_t *mtype = mdl_get_type_name(arg->type);
    while (rest)
    {
        if (mdl_value_equal_atom(rest->v.p.car, mtype))
        {
            result = rest->v.p.car;
            break;
        }
        rest = rest->v.p.cdr;
    }
    return result;
}

mdl_value_t *mdl_builtin_eval_applicablep(mdl_value_t *form, mdl_value_t *args)
/* SUBR APPLICABLE? */
{
    mdl_value_t *arg = LITEM(args, 0);
    if (!arg)
        mdl_error("Not enough args to APPLICABLE?");
    if (LHASITEM(args, 1))
        mdl_error("Too many args to APPLICABLE?");
    return mdl_boolean_value(mdl_type_is_applicable(mdl_apply_type(arg->type)));
}

mdl_value_t *mdl_builtin_eval_monadp(mdl_value_t *form, mdl_value_t *args)
/* SUBR MONAD? */
{
    mdl_value_t *arg = LITEM(args, 0);
    if (!arg)
        mdl_error("Not enough args to MONAD?");
    if (LHASITEM(args, 1))
        mdl_error("Too many args to MONAD?");
    return mdl_boolean_value(mdl_primtype_nonstructured(arg->pt) || mdl_internal_struct_is_empty(arg));
}

mdl_value_t *mdl_builtin_eval_structuredp(mdl_value_t *form, mdl_value_t *args)
/* SUBR STRUCTURED? */
{
    mdl_value_t *arg = LITEM(args, 0);
    if (!arg)
        mdl_error("Not enough args to STRUCTURED?");
    if (LHASITEM(args, 1))
        mdl_error("Too many args to STRUCTURED?");
    return mdl_boolean_value(!mdl_primtype_nonstructured(arg->pt));
}

mdl_value_t *mdl_builtin_eval_emptyp(mdl_value_t *form, mdl_value_t *args)
/* SUBR EMPTY? */
{
    mdl_value_t *arg = LITEM(args, 0);
    if (!arg) mdl_error("Not enough arguments to EMPTY?");
    if (LHASITEM(args, 1))
        mdl_error("Too many args to EMPTY?");
    
    if (mdl_primtype_nonstructured(arg->pt)) return mdl_call_error_ext("FIRST-ARG-WRONG_TYPE","First arg to EMPTY? must be structured",NULL);

    return mdl_boolean_value(mdl_internal_struct_is_empty(arg));
}

mdl_value_t *mdl_builtin_eval_lengthp(mdl_value_t *form, mdl_value_t *args)
/* SUBR LENGTH? */
{
    mdl_value_t *arg = LITEM(args, 0);
    mdl_value_t *max = LITEM(args, 1);
    mdl_value_t *cursor;
    int count, maxv;

    if (!max) mdl_error("Not enough arguments to LENGTH?");
    if (LHASITEM(args, 2))
        mdl_error("Too many args to LENGTH?");
    if (mdl_primtype_nonstructured(arg->pt)) mdl_error("First arg to LENGTH? must be structured");

    if (max->type != MDL_TYPE_FIX) 
        mdl_error("Second arg to LENGTH? must be FIX");
    maxv = max->v.w;
    
    if (arg->pt == PRIMTYPE_LIST)
    {
        count = 0;
        cursor = arg->v.p.cdr;
        while (count < maxv && cursor)
        {
            count++;
            cursor = cursor->v.p.cdr;
        }
        if (cursor) return &mdl_value_false;
    }
    else
    {
        count = mdl_internal_struct_length(arg);
        if (count > maxv) return &mdl_value_false;
    }
    return mdl_new_fix(count);
}
// INPUT/OUTPUT
// arguments for "modep" and "funcp" may be skipped by passing NULL (for FLOAD)
// returns any arguments following the channel arguments
mdl_value_t *mdl_get_check_channel_args(mdl_value_t *args, mdl_value_t **modep, mdl_value_t **name1p, mdl_value_t **name2p, mdl_value_t **devicep, mdl_value_t **dirp, mdl_value_t **funcp)
{
    mdl_value_t *mode = NULL;
    mdl_value_t *name1 = NULL;
    mdl_value_t *name2 = NULL;
    mdl_value_t *device = NULL;
    mdl_value_t *dir = NULL;
    mdl_value_t *func = NULL;
    mdl_value_t *cursor = args->v.p.cdr;

    OARGSETUP(args, cursor);
    if (modep) OGETNEXTARG(mode, cursor);
    OGETNEXTARG(name1, cursor);
    OGETNEXTARG(name2, cursor);
    OGETNEXTARG(device, cursor);
    OGETNEXTARG(dir, cursor);
    if (funcp) OGETNEXTARG(func, cursor);

    if (mode && mode->type != MDL_TYPE_STRING)
        mdl_error("MODE arg to OPEN/CHANNEL must be string");
    if (name1 && name1->type != MDL_TYPE_STRING)
        mdl_error("NAME1 arg to OPEN/CHANNEL must be string");
    if (name2 && name2->type != MDL_TYPE_STRING)
        mdl_error("NAME2 arg to OPEN/CHANNEL must be string");
    if (device && device->type != MDL_TYPE_STRING)
        mdl_error("DEVICE arg to OPEN/CHANNEL must be string");
    if (dir && dir->type != MDL_TYPE_STRING)
        mdl_error("DIR arg to OPEN/CHANNEL must be string");
    if (func && !mdl_string_equal_cstr(&device->v.s, "INT"))
        mdl_error("FUNC arg to OPEN/CHANNEL allowed only for INT device");
    if (func && func->type != MDL_TYPE_FUNCTION)
        mdl_error("FUNC arg to OPEN/CHANNEL must be FUNCTION");
    if (modep) *modep = mode;
    *name1p = name1;
    *name2p = name2;
    *devicep = device;
    *dirp = dir;
    if (funcp )*funcp = func;
    return cursor;
}

mdl_value_t *mdl_builtin_eval_channel(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *mode;
    mdl_value_t *name1;
    mdl_value_t *name2;
    mdl_value_t *device;
    mdl_value_t *dir;
    mdl_value_t *func;
    mdl_value_t *chan;

    
    if (mdl_get_check_channel_args(args, &mode, &name1, &name2, &device, &dir, &func))
        mdl_error("Too many args to OPEN or CHANNEL");
    chan = mdl_internal_create_channel();
    if (!mode)
    {
        mode = mdl_new_string("READ");
    }
    mdl_decode_file_args(&name1, &name2, &device, &dir);
    chan = mdl_internal_create_channel();
    *VITEM(chan,CHANNEL_SLOT_MODE) = *mode;
    *VITEM(chan,CHANNEL_SLOT_FNARG1) = *name1;
    *VITEM(chan,CHANNEL_SLOT_FNARG2) = *name2;
    *VITEM(chan,CHANNEL_SLOT_DEVNARG) = *device;
    *VITEM(chan,CHANNEL_SLOT_DIRNARG) = *dir;
    if (mdl_string_equal_cstr(&mode->v.s, "READ") || 
        mdl_string_equal_cstr(&mode->v.s, "READB"))
    {
        mdl_set_chan_eof_object(chan, NULL);
    }
    return chan;
}

mdl_value_t *mdl_builtin_eval_open(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *chan;
    chan = mdl_builtin_eval_channel(form, args);
    return mdl_internal_open_channel(chan);
                               
}

mdl_value_t *mdl_builtin_eval_file_existsp(mdl_value_t *form, mdl_value_t *args)
/* SUBR FILE-EXISTS?*/
{
    mdl_value_t *argt[4] = {NULL, NULL, NULL, NULL};
    mdl_value_t *cursor = args->v.p.cdr;
    int nargs = 0;
    int err;
    char *pathname;
    mdl_value_t *errfalse;
    struct stat stbuf;

    while (cursor && nargs < 4)
    {
        argt[nargs] = cursor->v.p.car;
        if (argt[nargs]->type != MDL_TYPE_STRING)
            mdl_error("All args to FILE-EXISTS must be string");
        cursor = cursor->v.p.cdr;
    }
    if (cursor)
        mdl_error("Too many args to FILE-EXISTS");
    mdl_decode_file_args(&argt[0], &argt[1], &argt[2], &argt[3]);
    pathname = mdl_build_pathname(argt[0], argt[1], argt[2], argt[3]);
    err = stat(pathname, &stbuf);

    if (!err) return mdl_value_T;
    errfalse = mdl_cons_internal(mdl_new_fix(errno), NULL);
    errfalse = mdl_cons_internal(mdl_new_string(strerror(errno)), errfalse);
    errfalse = mdl_make_list(errfalse, MDL_TYPE_FALSE);
    return errfalse;
}

mdl_value_t *mdl_builtin_eval_close(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *chan = LITEM(args, 0);

    if (!chan) mdl_error("Not enough args to CLOSE");
    if (LITEM(args, 1)) mdl_error("Too many args to CLOSE");
    if (chan->type != MDL_TYPE_CHANNEL)
        mdl_error("Argument to close must be of type CHANNEL");
    mdl_internal_close_channel(chan);
    return chan;
}

mdl_value_t *mdl_builtin_eval_reset(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *chan = LITEM(args, 0);

    if (!chan) mdl_error("Not enough args to RESET");
    if (LITEM(args, 1)) mdl_error("Too many args to RESET");
    if (chan->type != MDL_TYPE_CHANNEL)
        mdl_error("Argument to RESET must be of type CHANNEL");
    return mdl_internal_reset_channel(chan);
}

mdl_value_t *mdl_builtin_eval_access(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *chan = LITEM(args, 0);
    mdl_value_t *seek_to = LITEM(args, 1);
    mdl_value_t *mode;
    int chnum;

    if (!seek_to) mdl_error("Not enough args to ACCESS");
    if (LITEM(args, 2)) mdl_error("Too many args to CLOSE");
    if (chan->type != MDL_TYPE_CHANNEL)
        mdl_error("First argument to ACCESS must be of type CHANNEL");
    if (seek_to->type != MDL_TYPE_FIX)
        mdl_error("Second argument to ACCESS must be of type FIX");

    mode = VITEM(chan,CHANNEL_SLOT_MODE);
    chnum = VITEM(chan,CHANNEL_SLOT_CHNUM)->v.w;
    if (chnum == 0)
        mdl_error("Can't ACCESS closed or internal channels");
    if (mdl_string_equal_cstr(&mode->v.s, "PRINT"))
        mdl_error("Can't ACCESS on PRINT channels");
    
    // FIXME -- do the seek right for binary streams too
    // FIXME -- any other buffers
    if (mdl_string_equal_cstr(&mode->v.s, "READ") || 
        mdl_string_equal_cstr(&mode->v.s, "READB"))
        mdl_clear_chan_flags(chan,ICHANNEL_HAS_LOOKAHEAD | ICHANNEL_AT_EOF);
    fseek(mdl_get_channum_file(chnum), seek_to->v.w, SEEK_SET);
    return chan;
}
// Conversion I/O
void mdl_setup_frame_for_read(mdl_value_t **chanp, mdl_value_t *look_up, mdl_value_t *read_table)
{
    mdl_value_t *mdl_value_atom_inchan  = mdl_get_atom("INCHAN!-", true, NULL);
    if (!*chanp)
    {
        *chanp = mdl_local_symbol_lookup_pname("INCHAN!-", cur_frame);
        if (!*chanp) 
            mdl_error("No channel for READ");
    }
    mdl_bind_local_symbol(mdl_value_atom_inchan->v.a, *chanp, cur_frame, false);
    if ((*chanp)->type != MDL_TYPE_CHANNEL)
    {
        mdl_error("Error: Attempt to read from non-channel");
    }
    // FIXME -- when I need look_up and read_table, they should probably be
    // bound regardless of whether they are specified (affects SET)
    // Very low priority...
    if (look_up)
    {
        mdl_bind_local_symbol(atom_oblist, look_up, cur_frame, false);
    }

    if (read_table)
    {
        mdl_value_t *mdl_value_atom_read_table = mdl_get_atom("READ-TABLE!-", true, NULL);
        
        mdl_bind_local_symbol(mdl_value_atom_read_table->v.a, read_table, cur_frame, false);
    }
}

mdl_value_t *mdl_builtin_eval_read(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *argstup = mdl_make_tuple(LREST(args, 0));
    mdl_value_t *chan = TPITEM(argstup, 0); // rebinds .INCHAN
    mdl_value_t *eof_routine = TPITEM(argstup, 1); // Sets EOF routine in channel
    mdl_value_t *look_up = TPITEM(argstup, 2); // Rebinds .OBLIST 
    mdl_value_t *read_table = TPITEM(argstup, 3); // Rebinds .READ-TABLE
    mdl_value_t *result;
    
    if (TPHASITEM(argstup, 4))
        mdl_error("Too many args to READ");

    mdl_setup_frame_for_read(&chan, look_up, read_table);

    if (!mdl_chan_mode_is_input(chan))
        mdl_error("Channel for READ must be input channel");
        
    mdl_set_chan_eof_object(chan, eof_routine);

    result = mdl_read_object(chan);
    return result;
}

mdl_value_t *mdl_builtin_eval_readchr(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *chan = LITEM(args, 0); // rebinds .INCHAN
    mdl_value_t *eof_routine = LITEM(args, 1); // Sets EOF routine in channel
    mdl_value_t *result;

    mdl_setup_frame_for_read(&chan, NULL, NULL);
    if (!mdl_chan_mode_is_input(chan))
        mdl_error("Channel for READCHR must be input channel");

    if (LITEM(args, 2)) mdl_error("Too many args to READCHR");

    mdl_set_chan_eof_object(chan, eof_routine);
    result = mdl_read_character(chan);
    return result;
}

mdl_value_t *mdl_builtin_eval_nextchr(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *chan = LITEM(args, 0); // rebinds .INCHAN
    mdl_value_t *eof_routine = LITEM(args, 1); // Sets EOF routine in channel
    mdl_value_t *result;
    
    if (!mdl_chan_mode_is_input(chan))
        mdl_error("Channel for NEXTCHR must be input channel");

    if (LITEM(args, 2)) mdl_error("Too many args to nextchr");
    mdl_setup_frame_for_read(&chan, NULL, NULL);
    mdl_set_chan_eof_object(chan, eof_routine);
    result = mdl_next_character(chan);
    return result;
}
// Conversion output
void mdl_setup_frame_for_print(mdl_value_t **chanp)
{
    mdl_value_t *mdl_value_atom_outchan  = mdl_get_atom("OUTCHAN!-", true, NULL);
    if (!*chanp)
    {
        *chanp = mdl_local_symbol_lookup(mdl_value_atom_outchan->v.a, cur_frame);
        if (!*chanp) 
            mdl_error("No channel for PRINT");
    }
    mdl_bind_local_symbol(mdl_value_atom_outchan->v.a, *chanp, cur_frame, false);
    if ((*chanp)->type != MDL_TYPE_CHANNEL)
    {
        mdl_error("Error: Attempt to write to non-channel");
    }
}

mdl_value_t *mdl_builtin_eval_print(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *obj, *chan;
    bool binary;

    OARGSETUP(args, cursor);
    OGETNEXTARG(obj, cursor);
    OGETNEXTARG(chan, cursor);
    if (!obj)
        mdl_error("Too few arguments to PRINT");
    if (cursor)
        mdl_error("Too many arguments to PRINT");
    mdl_setup_frame_for_print(&chan);

    binary = mdl_chan_mode_is_print_binary(chan);
    if (!binary && !mdl_chan_mode_is_output(chan))
        mdl_error("Channel for PRINT must be output channel");

    mdl_print_newline_to_chan(chan, binary?MDL_PF_BINARY:MDL_PF_NONE, NULL);
    mdl_print_value_to_chan(chan, obj, false, false, NULL);
    mdl_print_char_to_chan(chan, ' ', binary?MDL_PF_BINARY:MDL_PF_NONE, NULL);
    return obj;
}

mdl_value_t *mdl_builtin_eval_prin1(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *obj, *chan;

    GETNEXTARG(obj, args);
    GETNEXTARG(chan, args);
    NOMOREARGS(args);

    mdl_setup_frame_for_print(&chan);

    if (!mdl_chan_mode_is_output(chan))
        mdl_error("Channel for PRIN1 must be output channel");

    mdl_print_value_to_chan(chan, obj, false, false, NULL);
    fflush(stdout);
    return obj;
}

mdl_value_t *mdl_builtin_eval_princ(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *obj, *chan;

    OARGSETUP(args, cursor);
    OGETNEXTARG(obj, cursor);
    OGETNEXTARG(chan, cursor);
    if (!obj)
        mdl_error("Too few arguments to PRINC");
    if (cursor)
        mdl_error("Too many arguments to PRINC");
    mdl_setup_frame_for_print(&chan);

    if (!mdl_chan_mode_is_output(chan))
        mdl_error("Channel for PRINC must be output channel");

    mdl_print_value_to_chan(chan, obj, true, false, NULL);
    return obj;
}

mdl_value_t *mdl_builtin_eval_terpri(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *chan;
    bool binary;

    OARGSETUP(args, cursor);
    OGETNEXTARG(chan, cursor);
    if (cursor)
        mdl_error("Too many args to TERPRI/CRLF");
    mdl_setup_frame_for_print(&chan);

    binary = mdl_chan_mode_is_print_binary(chan);
    if (!binary && !mdl_chan_mode_is_output(chan))
        mdl_error("Channel for TERPRI/CRLF must be output channel");

    mdl_print_newline_to_chan(chan, binary?MDL_PF_BINARY:MDL_PF_NONE, NULL);
    return &mdl_value_false;
}

mdl_value_t *mdl_builtin_eval_flatsize(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *obj = NULL;
    mdl_value_t *radix = NULL;
    mdl_frame_t *frame = mdl_new_frame();
    mdl_frame_t *prev_frame = cur_frame;
    mdl_value_t *chan;
    mdl_value_t *max;
    mdl_value_t *result;
    int jumpval;
    mdl_value_t *cursor;
    mdl_value_t *mdl_value_atom_outchan;

    OARGSETUP(args, cursor);
    OGETNEXTARG(obj, cursor);
    OGETNEXTARG(max, cursor);
    OGETNEXTARG(radix, cursor);
    if (!max) mdl_error("Not enough args to FLATSIZE");
    if (cursor) mdl_error("Too many args to FLATSIZE");
    int radixint = 10;
    if (radix)
    {
        if (radix->type == MDL_TYPE_FIX)
            radixint = radix->v.w;
        else
            mdl_error("Radix must be a FIX");
    }

    frame->subr = cur_frame->subr;
    frame->prev_frame = prev_frame;
    mdl_push_frame(frame);

    chan = mdl_create_internal_output_channel(0, max->v.w, mdl_make_frame_value(frame));
    mdl_value_atom_outchan = mdl_get_atom("OUTCHAN!-", true, NULL);
    mdl_bind_local_symbol(mdl_value_atom_outchan->v.a, chan, frame, false);

    if ((jumpval = mdl_setjmp(frame->interp_frame)) != 0)
    {
        if (jumpval == LONGJMP_FLATSIZE_EXCEEDED)
        {
            return &mdl_value_false;
        }
        else
        {
            // Pass it up the chain
            mdl_longjmp_to(prev_frame, jumpval);
        }
    }

    mdl_print_value_to_chan(chan, obj, false, false, NULL);
    result = mdl_new_fix(mdl_get_internal_output_channel_length(chan));
    mdl_pop_frame(prev_frame);
    return result;
}

mdl_value_t *mdl_builtin_eval_crlf(mdl_value_t *form, mdl_value_t *args)
{
    mdl_builtin_eval_terpri(form, args);
    return mdl_value_T;
}

// Image (Binary) input
mdl_value_t *mdl_builtin_eval_readb(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *buffer = LITEM(args, 0);
    mdl_value_t *chan = LITEM(args, 1); // rebinds .INCHAN
    mdl_value_t *eof_routine = LITEM(args, 2); // Sets EOF routine in channel
    mdl_value_t *result;

    mdl_setup_frame_for_read(&chan, NULL, NULL);
    if (buffer == NULL) mdl_error("Not enough arguments to READB");
    if (LITEM(args, 3)) mdl_error("Too many args to READB");
    
    if (!mdl_chan_mode_is_read_binary(chan))
        mdl_error("Channel for READB must be binary input channel");

    mdl_set_chan_eof_object(chan, eof_routine);
    result = mdl_read_binary(chan, buffer);
    return result;
}

mdl_value_t *mdl_builtin_eval_readstring(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *buffer = LITEM(args, 0);
    mdl_value_t *chan = LITEM(args, 1); // rebinds .INCHAN
    mdl_value_t *stop = LITEM(args, 2); 
    mdl_value_t *eof_routine = LITEM(args, 3); // Sets EOF routine in channel
    mdl_value_t *result;

    mdl_setup_frame_for_read(&chan, NULL, NULL);
    if (buffer == NULL) mdl_error("Not enough arguments to READSTRING");
    if (LITEM(args, 4)) mdl_error("Too many args to READSTRING");
    
    if (!mdl_chan_mode_is_input(chan))
        mdl_error("Channel for READSTRING must be input channel");

    mdl_set_chan_eof_object(chan, eof_routine);
    result = mdl_read_string(chan, buffer, stop);
    return result;
}

// Imaged (Binary) output
mdl_value_t *mdl_builtin_eval_printb(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *buffer;
    mdl_value_t *chan;

    OARGSETUP(args, cursor);
    OGETNEXTARG(buffer, cursor);
    OGETNEXTARG(chan, cursor);
    if (!chan)
        mdl_error("Too few arguments to PRINTB");
    if (cursor)
        mdl_error("Too many arguments to PRINTB");

    if (!mdl_chan_mode_is_print_binary(chan))
        mdl_error("Channel for PRINTB must be binary output channel");

    if (buffer->type != MDL_TYPE_UVECTOR)
        mdl_error("Buffer for PRINTB must be UVECTOR");
    if (mdl_type_primtype(UVTYPE(buffer)) != MDL_TYPE_WORD)
        mdl_error("Buffer for PRINTB must be UVECTOR containing WORDs");
    mdl_print_binary(chan, buffer);
    return buffer;
}

mdl_value_t *mdl_builtin_eval_printstring(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *buffer;
    mdl_value_t *count;
    mdl_value_t *chan;
    int len;

    OARGSETUP(args, cursor);
    OGETNEXTARG(buffer, cursor);
    OGETNEXTARG(chan, cursor);
    OGETNEXTARG(count, cursor);
    if (!buffer)
        mdl_error("Too few arguments to PRINTSTRING");
    if (cursor)
        mdl_error("Too many arguments to PRINTSTRING");

    mdl_setup_frame_for_print(&chan);

    if (chan->type != MDL_TYPE_CHANNEL)
        mdl_error("Channel wrong type in PRINTSTRING");
        

    if (!mdl_chan_mode_is_output(chan))
        mdl_error("Channel for PRINTSTRING must be output channel");

    if (buffer->type != MDL_TYPE_STRING)
        mdl_error("Buffer for PRINTSTRING must be STRING");

    if (count && count->v.w < 0)
        mdl_error("Count for PRINTSTRING must be >= 0");
    len = buffer->v.s.l;
    if (count && count->v.w < len) len = count->v.w;
    mdl_print_string_to_chan(chan, buffer->v.s.p, len, 0, false, false);
    return buffer;
}

mdl_value_t *mdl_builtin_eval_image(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *ch;
    mdl_value_t *chan;

    GETNEXTREQARG(ch, args);
    GETNEXTARG(chan, args);
    NOMOREARGS(args);

    if (ch->type != MDL_TYPE_FIX)
        return mdl_call_error("FIRST-ARG-WRONG-TYPE", NULL);
    mdl_setup_frame_for_print(&chan);
    mdl_print_char_to_chan(chan, (int)ch->v.w, MDL_PF_NOADVANCE, NULL);
    return ch;
}
// Other IO (LOAD/FLOAD)
mdl_value_t *mdl_builtin_eval_load(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *chan = LITEM(args, 0); // rebinds .INCHAN
    mdl_value_t *look_up = LITEM(args, 1); // Rebinds .OBLIST 
    
    if (LHASITEM(args, 2))
        mdl_error("Too many args to LOAD");

    mdl_setup_frame_for_read(&chan, look_up, NULL);

    if (!mdl_chan_mode_is_input(chan))
        mdl_error("Channel for LOAD must be input channel");
        
    mdl_set_chan_eof_object(chan, NULL);

    mdl_load_file_from_chan(chan);
    mdl_internal_close_channel(chan);
    return mdl_new_string(4, "DONE");
}

mdl_value_t *mdl_builtin_eval_fload(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *name1;
    mdl_value_t *name2;
    mdl_value_t *device;
    mdl_value_t *dir;
    mdl_value_t *look_up;
    mdl_value_t *chan;
    mdl_frame_t *prev_frame;
    mdl_value_t *close_form;
    int jumpval;
    
    look_up = mdl_get_check_channel_args(args, NULL, &name1, &name2, &device, &dir, NULL);
    if (look_up)
    {
        if (look_up->v.p.cdr)
            mdl_error("Too many args to LOAD");
        else
            look_up = look_up->v.p.car;
    }

    chan = mdl_internal_create_channel();
    mdl_decode_file_args(&name1, &name2, &device, &dir);

    *VITEM(chan,CHANNEL_SLOT_MODE) = *mdl_new_string(4, "READ");
    *VITEM(chan,CHANNEL_SLOT_FNARG1) = *name1;
    *VITEM(chan,CHANNEL_SLOT_FNARG2) = *name2;
    *VITEM(chan,CHANNEL_SLOT_DEVNARG) = *device;
    *VITEM(chan,CHANNEL_SLOT_DIRNARG) = *dir;
    mdl_set_chan_eof_object(chan, NULL);
    if (!mdl_is_true(mdl_internal_open_channel(chan)))
        mdl_error("Couldn't open file in FLOAD"); // FIXME by passing FALSE to ERROR

    // frame for fake UNWIND
    prev_frame = cur_frame;
    mdl_push_frame(mdl_new_frame());
    cur_frame->subr = prev_frame->subr;
    cur_frame->prev_frame = prev_frame;
    mdl_setup_frame_for_read(&chan, look_up, NULL);
    cur_frame->args = mdl_new_empty_tuple(2, MDL_TYPE_TUPLE);
    cur_frame->frame_flags = MDL_FRAME_FLAGS_UNWIND;

    close_form = mdl_cons_internal(chan, NULL);
    close_form = mdl_cons_internal(mdl_get_atom_from_oblist("CLOSE", mdl_value_root_oblist), close_form);
    close_form = mdl_make_list(close_form, MDL_TYPE_FORM);
    *TPREST(cur_frame->args,1) = *close_form;
    if ((jumpval = mdl_setjmp(cur_frame->interp_frame) != 0))
    {
        // Pass it up the chain
        mdl_longjmp_to(prev_frame, jumpval);
    }
    
    mdl_load_file_from_chan(chan);
    mdl_internal_close_channel(chan);
    mdl_pop_frame(prev_frame);
    return mdl_new_string(4, "DONE");
}

mdl_value_t *mdl_builtin_eval_sname(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *sname;

    GETNEXTARG(sname, args);
    NOMOREARGS(args);

    if (!sname)
    {
        sname = mdl_global_symbol_lookup(mdl_get_atom("SNM", true, NULL)->v.a);
        if (!sname)
        {
            char *cwdp = mdl_getcwd();
            if (!cwdp)
                mdl_error("Unable to determine a working directory");
            sname = mdl_new_string(cwdp);
        }
        return sname;
    }
    else
    {
        return mdl_set_gval(mdl_get_atom("SNM", true, NULL)->v.a, sname);
    }
}

// 11.6 SAVE/RESTORE (these are partially implemented)
mdl_value_t *mdl_builtin_eval_save(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *name1;
    mdl_value_t *name2;
    mdl_value_t *dev;
    mdl_value_t *dir;
    char *pathname;
    mdl_value_t *nm1;
    mdl_value_t *nm2;
    mdl_value_t *gc;
    FILE *f;

    GETNEXTARG(name1, args);
    GETNEXTARG(name2, args);
    GETNEXTARG(dev, args);
    GETNEXTARG(dir, args);
    GETNEXTARG(gc, args);
    NOMOREARGS(args);
    
    // NM1, NM2 -- root or current?
    nm1 = mdl_get_atom("NM1", true, NULL);
    nm2 = mdl_get_atom("NM2", true, NULL);
    mdl_bind_local_symbol(nm1->v.a, mdl_new_string(6, "MUDDLE"), cur_frame, false);
    mdl_bind_local_symbol(nm2->v.a, mdl_new_string(4, "SAVE"), cur_frame, false);

    mdl_decode_file_args(&name1, &name2, &dev, &dir);
    pathname = mdl_build_pathname(name1, name2, dev, dir);
//    fprintf(stderr, "Saving to %s\n", pathname);
    f = fopen(pathname, "wb");
    if (f)
    {
        mdl_write_image(f, NULL);
        fclose(f);
        return mdl_new_string(5, "SAVED");
    }
    return &mdl_value_false;
}

// SAVE-EVAL is like save, but evals the expression given as 1st arg 
// upon restore
mdl_value_t *mdl_builtin_eval_save_eval(mdl_value_t *form, mdl_value_t *args)
/* SUBR SAVE-EVAL */
{
    ARGSETUP(args);
    mdl_value_t *save_arg;
    mdl_value_t *name1;
    mdl_value_t *name2;
    mdl_value_t *dev;
    mdl_value_t *dir;
    char *pathname;
    mdl_value_t *nm1;
    mdl_value_t *nm2;
    mdl_value_t *gc;
    FILE *f;

    GETNEXTREQARG(save_arg, args);
    GETNEXTARG(name1, args);
    GETNEXTARG(name2, args);
    GETNEXTARG(dev, args);
    GETNEXTARG(dir, args);
    GETNEXTARG(gc, args);
    NOMOREARGS(args);
    
    // NM1, NM2 -- root or current?
    nm1 = mdl_get_atom("NM1", true, NULL);
    nm2 = mdl_get_atom("NM2", true, NULL);
    mdl_bind_local_symbol(nm1->v.a, mdl_new_string(6, "MUDDLE"), cur_frame, false);
    mdl_bind_local_symbol(nm2->v.a, mdl_new_string(4, "SAVE"), cur_frame, false);

    mdl_decode_file_args(&name1, &name2, &dev, &dir);
    pathname = mdl_build_pathname(name1, name2, dev, dir);
    f = fopen(pathname, "wb");
    if (f)
    {
        mdl_write_image(f, save_arg);
        fclose(f);
        return mdl_new_string(5, "SAVED");
    }
    return &mdl_value_false;
}

mdl_value_t *mdl_builtin_eval_restore(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *name1;
    mdl_value_t *name2;
    mdl_value_t *dev;
    mdl_value_t *dir;
    char *pathname;
    mdl_value_t *nm1;
    mdl_value_t *nm2;
    mdl_value_t *gc;
    FILE *f;

    GETNEXTARG(name1, args);
    GETNEXTARG(name2, args);
    GETNEXTARG(dev, args);
    GETNEXTARG(dir, args);
    GETNEXTARG(gc, args);
    NOMOREARGS(args);
    
    // NM1, NM2 -- root or current?
    nm1 = mdl_get_atom("NM1", true, NULL);
    nm2 = mdl_get_atom("NM2", true, NULL);
    mdl_bind_local_symbol(nm1->v.a, mdl_new_string(6, "MUDDLE"), cur_frame, false);
    mdl_bind_local_symbol(nm2->v.a, mdl_new_string(4, "SAVE"), cur_frame, false);

    mdl_decode_file_args(&name1, &name2, &dev, &dir);
    pathname = mdl_build_pathname(name1, name2, dev, dir);
    f = fopen(pathname, "rb");
    if (f)
    {
        bool ok = mdl_read_image(f);
        fclose(f);
        if (ok) return mdl_new_string(8, "RESTORED");
    }
    return &mdl_value_false;
}

// 11.7.5 FILE-LENGTH
mdl_value_t *mdl_builtin_eval_file_length(mdl_value_t *form, mdl_value_t *args)
/* SUBR FILE-LENGTH */
{
    ARGSETUP(args);
    mdl_value_t *chan;
    int channum;
    FILE *f;
    fpos_t savepos;
    off_t endpos;

    GETNEXTREQARG(chan, args);
    NOMOREARGS(args);
    
    if (!mdl_chan_mode_is_input(chan))
        return mdl_call_error("WRONG-DIRECTION-CHANNEL", NULL);
    channum = mdl_get_chan_channum(chan);
    if (!channum)
        return mdl_call_error("CHANNEL-CLOSED", NULL); // or maybe internal.
    f = mdl_get_channum_file(channum);
    if (!f) 
        return mdl_call_error_ext("CHANNEL-CLOSED", "Channel closed but nonzero", NULL); // shouldn't happen
    if (fgetpos(f,&savepos) == -1) 
        return mdl_call_error("FILE-LENGTH-UNAVAILABLE", NULL); // not an original MDL error
    if (fseek(f, 0, SEEK_END) == -1)
        return mdl_call_error("FILE-LENGTH-UNAVAILABLE", NULL); // not an original MDL error
    endpos = ftello(f);
    fsetpos(f, &savepos);
    if (mdl_chan_mode_is_read_binary(chan))
        return mdl_new_fix((MDL_INT)(endpos / sizeof(MDL_INT)));
    else
        return mdl_new_fix((MDL_INT)endpos);
}

// 14.7.4 DECL?
mdl_value_t *mdl_builtin_eval_declp(mdl_value_t *form, mdl_value_t *args)
/* SUBR DECL? */
{
    ARGSETUP(args);
    mdl_value_t *val;
    mdl_value_t *decl;
    bool error;

    GETNEXTARG(val, args);
    GETNEXTREQARG(decl, args);
    return mdl_check_decl(val, decl, &error);
}

// 16.1-16.6 LISTEN, ERROR, ERRET, UNWIND, RETRY, etc
mdl_value_t *mdl_builtin_eval_listen(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_internal_listen_error(args, false);
}

mdl_value_t *mdl_builtin_eval_error(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_internal_listen_error(args, true);
}

mdl_value_t *mdl_builtin_eval_erret(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *result;
    mdl_value_t *frame;

    OARGSETUP(args,cursor);
    OGETNEXTARG(result, cursor);
    OGETNEXTARG(frame, cursor);
    if (cursor) mdl_error("Too many args to erret");

    mdl_internal_erret(result, frame);
}

mdl_value_t *mdl_builtin_eval_retry(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *frame;

    OARGSETUP(args,cursor);
    OGETNEXTARG(frame, cursor);
    if (cursor) mdl_error("Too many args to erret");

    if (!frame) frame = mdl_local_symbol_lookup_pname("L-ERR !-INTERRUPTS!-", cur_frame);
    if (!frame) mdl_error("No frame in RETRY!");
    mdl_longjmp_to(frame->v.f, LONGJMP_RETRY);
}

mdl_value_t *mdl_builtin_eval_unwind(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *stdexpr;
    mdl_value_t *errexpr;

    OARGSETUP(args,cursor);
    OGETNEXTARG(stdexpr, cursor);
    OGETNEXTARG(errexpr, cursor);
    
    if (!errexpr)
        mdl_error("Not enough args to UNWIND");
    cur_frame->frame_flags |= MDL_FRAME_FLAGS_UNWIND;

    return mdl_eval(stdexpr);
 }

mdl_value_t *mdl_builtin_eval_funct(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *frame;

    OARGSETUP(args,cursor);
    OGETNEXTARG(frame, cursor);
    if (cursor) mdl_error("Too many args to FUNCT");
    if (!frame) mdl_error("Not enough args to FUNCT");
    return frame->v.f->subr;
}

mdl_value_t *mdl_builtin_eval_args(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *frame;

    OARGSETUP(args,cursor);
    OGETNEXTARG(frame, cursor);
    if (cursor) mdl_error("Too many args to ARGS");
    if (!frame) mdl_error("Not enough args to ARGS");
    return frame->v.f->args;
}

mdl_value_t *mdl_builtin_eval_frame(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *frame;
    mdl_frame_t *f;

    OARGSETUP(args,cursor);
    OGETNEXTARG(frame, cursor);
    if (cursor) mdl_error("Too many args to FRAME");

    if (!frame) frame = mdl_local_symbol_lookup_pname("L-ERR !-INTERRUPTS!-", cur_frame);
    if (!frame) mdl_error("No frame in FRAME!");
    f = frame->v.f->prev_frame;
    while (f && !(f->frame_flags & MDL_FRAME_FLAGS_TRUEFRAME))
        f = f->prev_frame;
    if (!f) mdl_error("No previous frame found");
    return mdl_make_frame_value(f);
}

// FFRAME did not exist in the original MDL.  It returns the frames
// of not just compiled subroutines, but also functions called by atom name
mdl_value_t *mdl_builtin_eval_fframe(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *frame;
    mdl_frame_t *f;

    OARGSETUP(args,cursor);
    OGETNEXTARG(frame, cursor);
    if (cursor) mdl_error("Too many args to FFRAME");

    if (!frame) frame = mdl_local_symbol_lookup_pname("L-ERR !-INTERRUPTS!-", cur_frame);
    if (!frame) mdl_error("No frame in FFRAME!");
    f = frame->v.f->prev_frame;
    while (f && !(f->frame_flags & (MDL_FRAME_FLAGS_TRUEFRAME|MDL_FRAME_FLAGS_NAMED_FUNC)))
        f = f->prev_frame;
    if (!f) mdl_error("No previous frame found");
    return mdl_make_frame_value(f);
}

// TFFRAME returns the top FFRAME (excluding its own)
// (Also not in the original MDL)
mdl_value_t *mdl_builtin_eval_tfframe(mdl_value_t *form, mdl_value_t *args)
{
    mdl_frame_t *f;
    if (args->v.p.cdr) mdl_error("Too many args to TFFRAME");

    f = cur_frame->prev_frame;
    while (f && !(f->frame_flags & (MDL_FRAME_FLAGS_TRUEFRAME|MDL_FRAME_FLAGS_NAMED_FUNC)))
        f = f->prev_frame;
    if (!f) mdl_error("No previous frame found");
    return mdl_make_frame_value(f);
}
// REP -- the Read/evaluate/print SUBR
mdl_value_t *mdl_builtin_eval_rep(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *readform;
    mdl_value_t *noargs;
    mdl_value_t *terpriform;
    mdl_value_t *printargs;
    mdl_value_t *printform;
    mdl_value_t *readresult;
    mdl_value_t *evalresult;
    mdl_value_t *dummy = mdl_new_fix(69152);
    atom_t *atom_last_out;
    if (args->v.p.cdr)
        mdl_error("Too many args to REP");
    mdl_value_t *mdl_value_atom_read;
    mdl_value_t *mdl_value_atom_terpri;
    mdl_value_t *mdl_value_atom_print;

    mdl_value_atom_read = mdl_get_atom_from_oblist("READ", mdl_value_root_oblist);
    mdl_value_atom_terpri = mdl_get_atom_from_oblist("TERPRI", mdl_value_root_oblist);
    mdl_value_atom_print = mdl_get_atom_from_oblist("PRINT", mdl_value_root_oblist);
    readform = mdl_make_list(mdl_cons_internal(mdl_value_atom_read, NULL));
    terpriform = mdl_make_list(mdl_cons_internal(mdl_value_atom_terpri, NULL));
    noargs = mdl_make_list(NULL);
    printform = mdl_cons_internal(dummy, NULL);
    printform = mdl_cons_internal(mdl_value_atom_print, printform);
    printform = mdl_make_list(printform);
    printargs = mdl_cons_internal(dummy, NULL);
    printargs = mdl_make_list(printargs);
    atom_last_out = mdl_get_atom("LAST-OUT!-", true, NULL)->v.a;

// ZORK's behavior implies this while loop is not here,
// though the documentation suggests it is
//    while (1)
    {
        readresult = mdl_builtin_eval_read(readform, noargs);
        evalresult = mdl_eval(readresult);
        mdl_set_lval(atom_last_out, evalresult, cur_frame);
        LREST(printform, 1)->v.p.car = evalresult;
        LREST(printargs, 0)->v.p.car = evalresult;
        mdl_builtin_eval_prin1(printform, printargs);
        mdl_builtin_eval_terpri(terpriform, noargs);
    }
    return evalresult;
}

// 18.2-18.4 BITS, GETBITS, PUTBITS
mdl_value_t *mdl_builtin_eval_bits(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *width;
    mdl_value_t *right_edge;
    int val;

    OARGSETUP(args, cursor);
    OGETNEXTARG(width, cursor);
    OGETNEXTARG(right_edge, cursor);
    if (!width) mdl_error("Not enough args to BITS");
    if (cursor) mdl_error("Too many args to BITS");
    if (width->type != MDL_TYPE_FIX)
        mdl_error("Width in BITS must be FIX");
    if (right_edge && right_edge->type != MDL_TYPE_FIX)
        mdl_error("Right edge in BITS must be FIX");
    val = (width->v.w & 0xFF);
    if (right_edge) val |= ((right_edge->v.w & 0xFF) << 8);
    return mdl_new_word(val, MDL_TYPE_BITS);
}

mdl_value_t *mdl_builtin_eval_getbits(mdl_value_t *form, mdl_value_t *args)
{
    mdl_value_t *cursor;
    mdl_value_t *from;
    mdl_value_t *bits;
    int right_edge;
    int width;
    MDL_UINT mask;

    OARGSETUP(args, cursor);
    OGETNEXTARG(from, cursor);
    OGETNEXTARG(bits, cursor);
    if (!bits) mdl_error("Not enough args to GETBITS");
    if (cursor) mdl_error("Too many args to GETBITS");
    if (from->pt != PRIMTYPE_WORD)
        mdl_error("First arg to GETBITS must have primtype WORD");
    if (bits->type != MDL_TYPE_BITS)
        mdl_error("Second arg to GETBITS must be type BITS");
    right_edge = (bits->v.w >> 8)&0xFF;
    width = bits->v.w & 0xFF;
    mask = ((((MDL_UINT)1)<<width)-1) << right_edge;
    return mdl_new_word((MDL_INT)(((MDL_UINT)from->v.w & mask)>>right_edge), MDL_TYPE_WORD);
}

mdl_value_t *mdl_builtin_eval_putbits(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
// Oddly, unlike the other bit operations, PUTBITS does not return a WORD
// in all cases.  Rather, it returns a value with the same type as the
// TO argument.

    mdl_value_t *cursor;
    mdl_value_t *from, *to;
    mdl_value_t *bits;
    int right_edge;
    int width;
    MDL_UINT mask1, mask2, fromint;

    OARGSETUP(args, cursor);
    OGETNEXTARG(to, cursor);
    OGETNEXTARG(bits, cursor);
    OGETNEXTARG(from, cursor);
    if (!bits) mdl_error("Not enough args to PUTBITS");
    if (cursor) mdl_error("Too many args to PUTBITS");
    if (to->pt != PRIMTYPE_WORD)
        mdl_error("First arg to PUTBITS must have primtype WORD");
    if (from && from->pt != PRIMTYPE_WORD)
        mdl_error("Third arg to PUTBITS must have primtype WORD");
    if (bits->type != MDL_TYPE_BITS)
        mdl_error("Second arg to PUTBITS must be type BITS");
    fromint = 0;
    if (from) fromint = (MDL_UINT)from->v.w;
    right_edge = (bits->v.w >> 8)&0xFF;
    width = bits->v.w & 0xFF;
    mask1 = (((MDL_UINT)1)<<width)-1;
    mask2 = ~(mask1 << right_edge);
    return mdl_new_word((MDL_INT)(((MDL_UINT)to->v.w & mask2) | 
                                  ((fromint & mask1) << right_edge)), to->type);
}

// 18.5 Bitwise booleans -- ANDB, ORB, XORB, EQUVB
mdl_value_t *mdl_builtin_eval_andb(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *rest = LREST(args, 0);
    MDL_INT result = ~0;
    mdl_value_t *arg;
    
    while (rest)
    {
        arg = rest->v.p.car;
        if (arg->pt != PRIMTYPE_WORD)
            mdl_error("Args to ANDB must be of PRIMTYPE WORD");
        result &= arg->v.w;
        rest = rest->v.p.cdr;
    }
    return mdl_new_word(result, MDL_TYPE_WORD);
}

mdl_value_t *mdl_builtin_eval_orb(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *rest = LREST(args, 0);
    MDL_INT result = 0;
    mdl_value_t *arg;
    
    while (rest)
    {
        arg = rest->v.p.car;
        if (arg->pt != PRIMTYPE_WORD)
            mdl_error("Args to ORB must be of PRIMTYPE WORD");
        result |= arg->v.w;
        rest = rest->v.p.cdr;
    }
    return mdl_new_word(result, MDL_TYPE_WORD);
}

mdl_value_t *mdl_builtin_eval_xorb(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *rest = LREST(args, 0);
    MDL_INT result = 0;
    mdl_value_t *arg;
    
    while (rest)
    {
        arg = rest->v.p.car;
        if (arg->pt != PRIMTYPE_WORD)
            mdl_error("Args to XORB must be of PRIMTYPE WORD");
        result ^= arg->v.w;
        rest = rest->v.p.cdr;
    }
    return mdl_new_word(result, MDL_TYPE_WORD);
}

mdl_value_t *mdl_builtin_eval_eqvb(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    // FIXME
    // this may be wrong. Should <EQVB 0 0 0> be 
    // <EQVB <EQVB 0 0> 0> or should it be 0, for instance?
    // this implementation assumes the former
    mdl_value_t *rest = LREST(args, 0);
    MDL_INT result = ~0;
    mdl_value_t *arg;
    
    while (rest)
    {
        arg = rest->v.p.car;
        if (arg->pt != PRIMTYPE_WORD)
            mdl_error("Args to EQVB must be of PRIMTYPE WORD");
        result = ~(result ^ arg->v.w);
        rest = rest->v.p.cdr;
    }
    return mdl_new_word(result, MDL_TYPE_WORD);
}

mdl_value_t *mdl_builtin_eval_lsh(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
/* Note -- LOGICAL shift, not LEFT shift.  Positive shift is left and
   negative shift is right
 */
{
    ARGSETUP(args);
    mdl_value_t *shiftme;
    mdl_value_t *shiftby;
    MDL_UINT result;

    GETNEXTARG(shiftme, args);
    GETNEXTREQARG(shiftby, args);
    NOMOREARGS(args);

    if (shiftme->pt != PRIMTYPE_WORD)
        mdl_error("First arg to LSH must be of PRIMTYPE WORD");
    if (shiftby->type != MDL_TYPE_FIX)
        mdl_error("Second arg to LSH must be FIX");
    if (shiftby->v.w < 0)
        result = ((MDL_UINT)shiftme->v.w) >> -shiftby->v.w;
    else
        result = ((MDL_UINT)shiftme->v.w) << shiftby->v.w;
    return mdl_new_word(result, MDL_TYPE_WORD);
}
// 22 GC
mdl_value_t *mdl_builtin_eval_gc(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    ARGSETUP(args);
    mdl_value_t *min,*exhaustive, *ms_freq;
    GETNEXTARG(min, args);
    GETNEXTARG(exhaustive, args);
    GETNEXTARG(ms_freq, args);
    NOMOREARGS(args);

    // only partially implemented.
    GC_gcollect();
    return mdl_value_T;
}

// 23.1 - 23.4 MDL as a system process
mdl_value_t *mdl_builtin_eval_time(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    MDL_FLOAT cputime;
    // TIME args are evaled but ignored
    struct rusage ru;
    
    getrusage(RUSAGE_SELF, &ru);
    timeradd(&ru.ru_utime, &ru.ru_stime, &ru.ru_utime); // a, b, result
    cputime = ru.ru_utime.tv_sec + (ru.ru_utime.tv_usec/(MDL_FLOAT)1000000);
    return mdl_new_float(cputime);
}

mdl_value_t *mdl_builtin_eval_logout(mdl_value_t *form, mdl_value_t *args)
{
    // Unix-specific -- if this process has init as its parent, it is
    // running "disowned", so can logout.  In practice this will probably
    // never happen

    if (getppid() == 1) exit(0);
    return &mdl_value_false;
}
mdl_value_t *mdl_builtin_eval_quit(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    if (args->v.p.cdr) mdl_error("Too many arguments to QUIT");
#ifdef GC_DEBUG
    GC_gcollect();
#endif
    exit(0);
}

// New routines for MDL as a system process (not in original MDL)
// GETTIMEOFDAY returns a uvector of FIX with time since the Unix epoch
// in seconds and microseconds
// (note that original MDL is older than the Unix epoch!)
// (also note that the 32 bit version won't be very happy soon -- if
//  I really care about it I need to implement an XWORD type)
mdl_value_t *mdl_builtin_eval_gettimeofday(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *result;
    struct timeval now;
    uvector_element_t *elem;
    
    if (args->v.p.cdr) mdl_error("Too many args to gettimeofday");
    gettimeofday(&now, NULL);
    result = mdl_new_empty_uvector(2, MDL_TYPE_UVECTOR);
    UVTYPE(result) = MDL_TYPE_FIX;
    elem = UVREST(result, 0);
    elem[0].w = now.tv_sec;
    elem[1].w = now.tv_usec;
    return result;
}

// GETTIMEDATE takes two arguments, both optional.  The first is 
// a time value (either a FIX, or a UVECTOR from GETTIME)
// to convert to broken-down time format.  The second
// is a boolean specifying whether the time should be GMT (TRUE)
// or local (FALSE).  Default is current time and FALSE.
// Passing a false for the first arg also means "current time",
// so <GETTIMEDATE <> T> returns breakdown of current GMT time.
// The broken-down time format is a UVECTOR of type FIX
// 1: Seconds
// 2: Minutes
// 3: Hours
// 4: Day of month (1-31)
// 5: Month (1-12)
// 6: Year (full year, not year-1900)
// 7: Fractional time in microseconds
// Programs should not depend on there being exactly 7 elements; there
// could be more (e.g. day of week, day of year)
mdl_value_t *mdl_builtin_eval_gettimedate(mdl_value_t *form, mdl_value_t *args)
{
    mdl_value_t *cursor;
    mdl_value_t *timeuv;
    mdl_value_t *isgmt;
    mdl_value_t *result;
    uvector_element_t *elems;
    struct timeval tv;
    struct tm broketime;

    OARGSETUP(args, cursor);
    OGETNEXTARG(timeuv, cursor);
    OGETNEXTARG(isgmt, cursor);
    if (cursor) mdl_error("Too many args to GETTIMEDATE");

    if (!timeuv || !mdl_is_true(timeuv))
    {
        gettimeofday(&tv, NULL);
    }
    else if (timeuv->type == MDL_TYPE_FIX)
    {
        tv.tv_sec = timeuv->v.w;
        tv.tv_usec = 0;
    }
    else if ((timeuv->type == MDL_TYPE_UVECTOR) && 
             (UVTYPE(timeuv) == MDL_TYPE_FIX) && 
             (UVLENGTH(timeuv) == 2)
        )
    {
        elems = UVREST(timeuv,0);
        tv.tv_sec = elems[0].w;
        tv.tv_usec = elems[1].w;
    }
    else
        mdl_error("Wrong type of time to GETTIMEDATE");

    if (!isgmt || !mdl_is_true(isgmt))
    {
        localtime_r(&tv.tv_sec, &broketime);
    }
    else
    {
        gmtime_r(&tv.tv_sec, &broketime);
    }
    
    result = mdl_new_empty_uvector(7, MDL_TYPE_UVECTOR);
    UVTYPE(result) = MDL_TYPE_FIX;
    elems = UVREST(result, 0);
    elems[0].w = broketime.tm_sec;
    elems[1].w = broketime.tm_min;
    elems[2].w = broketime.tm_hour;
    elems[3].w = broketime.tm_mday;
    elems[4].w = broketime.tm_mon + 1;
    elems[5].w = broketime.tm_year + 1900;
    elems[6].w = tv.tv_usec;
    return result;
}
// UNIMPLEMENTED subroutines
// 14.5 Declaration checking
mdl_value_t *mdl_builtin_eval_gdecl(mdl_value_t *form, mdl_value_t *args)
/* FSUBR */
{
    // Don't know what this is supposed to return
    return mdl_value_T;
}
// No compiler, so no MANIFEST
mdl_value_t *mdl_builtin_eval_manifest(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_value_T;
}

// 22.2.1 FREEZE
// Just returns a copy ; the GC is non-moving anyway
mdl_value_t *mdl_builtin_eval_freeze(mdl_value_t *form, mdl_value_t *args)
{
    mdl_value_t *cursor;
    mdl_value_t *freezeme, *frozen;

    OARGSETUP(args, cursor);
    OGETNEXTARG(freezeme, cursor);
    
    if (!freezeme) mdl_error("Not enough args to FREEZE");
    if (cursor) mdl_error("Too many args to FREEZE");
    frozen = mdl_internal_copy_structured(freezeme);
    if (!frozen) mdl_error("Object not of a FREEZEable type");
    return frozen;
}
// 22.6 BLOAT
mdl_value_t *mdl_builtin_eval_bloat(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    mdl_value_t *cursor;
    mdl_value_t *fre;

    OARGSETUP(args, cursor);
    OGETNEXTARG(fre, cursor);
    
    if (fre && fre->type != MDL_TYPE_FIX)
        mdl_error("Args to BLOAT must be type FIX");
    
    // Values are bogus, but should indicate lots of free storage
    if (fre) return fre;
    else return mdl_new_fix(65536);
}

// 21.3 - 21.7 INTERRUPTS 
mdl_value_t *mdl_builtin_eval_off(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_value_T;
}

mdl_value_t *mdl_builtin_eval_event(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_value_T;
}

mdl_value_t *mdl_builtin_eval_handler(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_value_T;
}

// 21.6 More interrupts
mdl_value_t *mdl_builtin_eval_on(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_value_T;
}

mdl_value_t *mdl_builtin_eval_enable(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_value_T;
}

mdl_value_t *mdl_builtin_eval_disable(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    return mdl_value_T;
}

mdl_value_t *mdl_builtin_eval_int_level(mdl_value_t *form, mdl_value_t *args)
/* SUBR INT-LEVEL */
{
    mdl_value_t *atom_intlevel;
    mdl_value_t *arg;
    mdl_value_t *result;
    
    arg = LITEM(args, 0);
    if (LHASITEM(args, 1))
        mdl_error("Too many args to INT-LEVEL");
    if (arg && arg->type != MDL_TYPE_FIX)
        mdl_error("INT-LEVEL argument must be FIX");

    atom_intlevel = mdl_get_atom("INT-LEVEL!-INTERRUPTS!-", true, NULL);
    result = mdl_global_symbol_lookup(atom_intlevel->v.a);
    if (!result) result = mdl_new_fix(0);
    if (arg) mdl_set_gval(atom_intlevel->v.a, arg);
    return result;
}

mdl_value_t *mdl_builtin_eval_sleep(mdl_value_t *form, mdl_value_t *args)
{
    /* sleeps, but pred arg is ignored as there are no interrupts*/
    mdl_value_t *fix;
    mdl_value_t *pred;
    ARGSETUP(args);
    GETNEXTREQARG(fix, args);
    GETNEXTARG(pred, args);
    NOMOREARGS(args);

    if (fix->type != MDL_TYPE_FIX)
        return mdl_call_error("FIRST-ARG-WRONG-TYPE", NULL);

    if (fix->v.w < 0)
        return mdl_call_error_ext("ARGUMENT-OUT-OF-RANGE", "SLEEP time negative", NULL);
    fflush(stdout); // let the user see while we rest
    sleep(fix->v.w);

    return mdl_value_T;
}

// GPL implementing functions
mdl_value_t *mdl_builtin_eval_warranty(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    extern const char no_warranty[];
    mdl_value_t *chan = NULL;
    ARGSETUP(args);
    NOMOREARGS(args);

    mdl_setup_frame_for_print(&chan);
    mdl_print_string_to_chan(chan, no_warranty, strlen(no_warranty), 0, false, false);
    mdl_print_newline_to_chan(chan, false, NULL);
    return &mdl_value_false;
}

mdl_value_t *mdl_builtin_eval_copying(mdl_value_t *form, mdl_value_t *args)
/* SUBR */
{
    extern const char copying[];
    mdl_value_t *chan = NULL;
    ARGSETUP(args);
    NOMOREARGS(args);

    mdl_setup_frame_for_print(&chan);
    mdl_print_string_to_chan(chan, copying, strlen(copying), 0, false, false);
    mdl_print_newline_to_chan(chan, false, NULL);
    return mdl_value_T;
}
