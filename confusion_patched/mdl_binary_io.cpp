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
#include "mdl_builtin_types.h"
#include "mdl_assoc.hpp"
#include <vector>
#include <map>
#include <unordered_set>
#include <string.h>

using std::unordered_set;
using std::vector;
using std::map;
using std::pair;

//#define MDL_DEBUG_BINARY_IO

typedef enum objtype_t
{
    OBJTYPE_MDL_VALUE = 0,
    OBJTYPE_MDL_ROOT_OBLIST, // a MDL_VALUE
    OBJTYPE_MDL_INITIAL_OBLIST, // also a MDL_VALUE
    OBJTYPE_ATOM,
    OBJTYPE_RAWSTRING,
    OBJTYPE_VECTOR_BLOCK,
    OBJTYPE_UVECTOR_BLOCK,
    OBJTYPE_TYPE_TABLE, // only one of these
    OBJTYPE_BUILT_IN_TABLE, // only one of these
    OBJTYPE_ASOC_TABLE, // only one of these
    OBJTYPE_SAVE_ARG
    // no frames-- frames are to be dropped on the floor
    // no tuples for a similar reason
} objtype_t;

#define OBJTYPE_IS_VALUE(ot) ((ot == OBJTYPE_MDL_VALUE) || (ot == OBJTYPE_MDL_ROOT_OBLIST) || (ot == OBJTYPE_MDL_INITIAL_OBLIST) || (ot == OBJTYPE_SAVE_ARG))

typedef struct obj_in_image_t
{
    void *ptr;
    objtype_t objtype;
    int objnum;
    int len; // needed for strings

    bool operator == (const obj_in_image_t &that) const
        {
            return this->ptr == that.ptr;
        }
} obj_in_image_t;

class hash_obj_in_image
{
public:
    size_t operator () (const obj_in_image_t &o) const
    {
        return (size_t)o.ptr;
    }
};

typedef unordered_set<struct obj_in_image_t, hash_obj_in_image> obj_image_hash_t;
typedef vector<struct obj_in_image_t, traceable_allocator<struct obj_in_image_t> > obj_image_list_t;
typedef map<intptr_t, struct mdl_value_t *> chan_map_t;

obj_image_hash_t image_objects;
obj_image_list_t image_object_list;
chan_map_t chanmap;

// it is not possible to do fixups in a hash table as the keys are const
// So read into this temporary vector, do fixups, then put in hash table
typedef struct mdl_tmp_assoc_entry_t
{
    mdl_value_t *item;
    mdl_value_t *indicator;
    mdl_value_t *value;
} mdl_tmp_assoc_entry_t;

typedef std::vector<mdl_tmp_assoc_entry_t, traceable_allocator<mdl_tmp_assoc_entry_t> > mdl_tmp_assoc_table_t;

static obj_in_image_t null_obj = {0, OBJTYPE_MDL_VALUE,0};
static obj_in_image_t builtin_obj;

static obj_in_image_t *find_obj_by_num(int objnum, objtype_t objtype)
{
    if (objnum == 0) return &null_obj;
    if (objnum < 0)
    {
        if (!OBJTYPE_IS_VALUE(objtype)) return NULL;
        builtin_obj.objtype = OBJTYPE_MDL_VALUE;
        builtin_obj.ptr = built_in_table[-objnum-1].v;
        builtin_obj.objnum = objnum;
        return &builtin_obj;
    }
    if ((image_object_list[objnum-1].objtype == objtype) ||
        (OBJTYPE_IS_VALUE(image_object_list[objnum-1].objtype) && 
         OBJTYPE_IS_VALUE(objtype)))
    {
        return &image_object_list[objnum - 1];
    }
    return NULL;
}

int mdl_write_encint(FILE *f, intmax_t val, bool is_signed)
{
    unsigned char ibuf[(sizeof(intmax_t) * 8 + 7) / 7];
    unsigned char *bufp;
    int len;
    uintmax_t uval;

    if (is_signed)
    {
        // uval = rotate left of sign-magnitude form of val
        // negative zero indicates most negative value
        if (val < 0)
        {
            uval = ((uintmax_t)(-val) << 1) | 1;
        }
        else
        {
            uval = (uintmax_t)val << 1;
        }
    }
    else
        uval = (uintmax_t)val;

    if (uval < 128)
    {
        len = 1;
        ibuf[0] = uval;
    }
    else
    {
        uintmax_t mask = ~(uintmax_t)0x7F;
        int shift;
        len = 1;
        while(uval & mask)
        {
            len++;
            mask <<= 7;
        }
        shift = (len - 1) * 7;
        bufp = ibuf;
        while (shift >= 0)
        {
            *bufp++ = (shift?(((uval >> shift) & 0x7F)| 0x80):(uval & 0x7F));
            shift -= 7;
        }
    }
    return fwrite(ibuf, 1, len, f);
}

int mdl_read_encint(FILE *f, intmax_t *val, bool is_signed)
{
    uintmax_t uval = 0;
    int ch;
    do
    {
        uval <<= 7;
        ch = fgetc(f);
        if (ch < 0) return ch;
        uval |= ch & 0x7F;
    }
    while (ch & 0x80);
    if (is_signed)
    {
        // reverse transformation from earlier
        // convert sign-magnitude with sign bit at end to 2s-complement
        if (uval & 1) uval = ~(uval >> 1) + 1;
        else uval = uval >> 1;
    }
    *val = (uintmax_t)uval;
    return 0;
}

// the mdl_read_x functions return 0 for success, nonzero for failure
// the mdl_write_x functions return < 0 for failure > 0 for success
static int mdl_write_primtype(FILE *f, primtype_t primtype)
{
#ifdef MDL_DEBUG_BINARY_IO
    return fprintf(f, "PT %d\n", (int)primtype);
#else
    return mdl_write_encint(f, (intmax_t)primtype, false);
//    return fwrite((void *)&primtype, sizeof(primtype), 1, f);
#endif
}

static int mdl_read_primtype(FILE *f, primtype_t *primtype)
{
#ifdef MDL_DEBUG_BINARY_IO
    int pt_as_int;
    if (fscanf(f, "PT %d\n", &pt_as_int) == 1)
    {
        *primtype = (primtype_t)pt_as_int;
        return 0;
    }
    else 
        return -1;
#else
    intmax_t tmp = 0;
    int err;

    err = mdl_read_encint(f, &tmp, false);
    *primtype = (primtype_t)tmp;
    return err;
//    return fread(primtype, sizeof(primtype), 1, f) != 1;
#endif
}

static int mdl_write_objtype(FILE *f, objtype_t objtype)
{
#ifdef MDL_DEBUG_BINARY_IO
    return fprintf(f, "OT %d\n", (int)objtype);
#else
    return mdl_write_encint(f, (intmax_t)objtype, false);
//    return fwrite((void *)&objtype, sizeof(objtype), 1, f);
#endif
}

static int mdl_read_objtype(FILE *f, objtype_t *objtype)
{
#ifdef MDL_DEBUG_BINARY_IO
    int ot_as_int;
    if (fscanf(f, "OT %d\n", &ot_as_int) == 1)
    {
        *objtype = (objtype_t)ot_as_int;
        return 0;
    }
    else 
        return -1;
#else
    intmax_t tmp = 0;
    int err;

    err = mdl_read_encint(f, &tmp, false);
    *objtype = (objtype_t)tmp;
    return err;
//    return fread((void *)objtype, sizeof(objtype), 1, f) != 1;
#endif
}

static int mdl_write_intptr(FILE *f, intptr_t val)
{
#ifdef MDL_DEBUG_BINARY_IO
    // no printf string for intptr_t, ptrdiff_t probably works in most cases
    // anyway I don't expect to leave this text stuff around
    return fprintf(f, "IP %td\n", (ptrdiff_t)val);
#else
    return mdl_write_encint(f, val, false);
//    return fwrite((void *)&val, sizeof(intptr_t), 1, f);
#endif
}

static int mdl_read_intptr(FILE *f, intptr_t *val)
{
#ifdef MDL_DEBUG_BINARY_IO
    // no scanf string for intptr_t, ptrdiff_t probably works in most cases
    // anyway I don't expect to leave this text stuff around
    return (fscanf(f, "IP %td\n", (ptrdiff_t *)val) != 1);
#else
    int err;
    intmax_t tmp = 0;
    err = mdl_read_encint(f, &tmp, false);
    *val = (intptr_t)tmp;
    return err;
//    return fread((void *)val, sizeof(intptr_t), 1, f) != 1;
#endif
}

static int mdl_write_int(FILE *f, int val)
{
#ifdef MDL_DEBUG_BINARY_IO
    // no printf string for intptr_t, ptrdiff_t probably works in most cases
    // anyway I don't expect to leave this text stuff around
    return fprintf(f, "I %d\n", val);
#else
    return mdl_write_encint(f, (intmax_t)val, true);
//    return fwrite((void *)&val, sizeof(int), 1, f);
#endif
}

static int mdl_read_int(FILE *f, int *val)
{
#ifdef MDL_DEBUG_BINARY_IO
    return (fscanf(f, "I %d\n", val) != 1);
#else
    intmax_t tmp = 0;
    int err;

    err = mdl_read_encint(f, &tmp, true);
    *val = (int)tmp;
    return err;
//    return fread((void *)val, sizeof(int), 1, f) != 1;
#endif
}

static int mdl_write_MDL_INT(FILE *f, MDL_INT val)
{
#ifdef MDL_DEBUG_BINARY_IO
 #ifdef MDL32
    return fprintf(f, "MI32 %d\n", val);
 #else
    return fprintf(f, "MI64 %lld\n", val);
 #endif
#else
    return mdl_write_encint(f, (intmax_t)val, true);
//    return fwrite((void *)&val, sizeof(MDL_INT), 1, f);
#endif

}

static int mdl_read_MDL_INT(FILE *f, MDL_INT *val)
{
#ifdef MDL_DEBUG_BINARY_IO
 #ifdef MDL32
    return (fscanf(f, "MI32 %d\n", val) != 1);
 #else
    return (fscanf(f, "MI64 %lld\n", val) != 1);
 #endif
#else
    int err;
    intmax_t tmp = 0;

    err = mdl_read_encint(f, &tmp, true);
    *val = (MDL_INT)tmp;
    return err;
//    return fread((void *)val, sizeof(MDL_INT), 1, f) != 1;
#endif

}

int mdl_schedule_for_write(obj_in_image_t &obj)
{
    pair<obj_image_hash_t::iterator, bool> oldval;

    obj.objnum = image_object_list.size() + 1;
    oldval = image_objects.insert(obj);
    if (oldval.second)
    {
        image_object_list.push_back(obj);
    }
    return oldval.first->objnum;
}

int mdl_schedule_atom_for_write(atom_t *atom)
{
    obj_in_image_t obj;
    
    if (!atom) return 0;
    obj.ptr = (void *)atom;
    obj.objtype = OBJTYPE_ATOM;
    return mdl_schedule_for_write(obj);
}

int mdl_schedule_value_for_write(const mdl_value_t *val, objtype_t objtype = OBJTYPE_MDL_VALUE);
int mdl_schedule_value_for_write(const mdl_value_t *val, objtype_t objtype)
{
    obj_in_image_t obj;

    if (!val) return 0;
    obj.ptr = (void *)val;
    obj.objtype = objtype;
    return mdl_schedule_for_write(obj);
}

int mdl_schedule_string_for_write(counted_string_t *s)
{
    obj_in_image_t obj;
    MDL_INT truelen;

    if (!s->p) return 0; // shouldn't happen
    truelen = *(MDL_INT *)ALIGN_MDL_INT(s->p + s->l + 1);
    if (truelen < 0) truelen = ~truelen;
    obj.ptr = (void *)(s->p + s->l - truelen);
    obj.objtype = OBJTYPE_RAWSTRING;
    obj.len = truelen;
    return mdl_schedule_for_write(obj);
}

int mdl_schedule_pname_for_write(char *s)
{
    counted_string_t tmp;
    tmp.p = s;
    tmp.l = strlen(s);
    return mdl_schedule_string_for_write(&tmp);
}

int mdl_schedule_vector_block_for_write(mdl_vector_block_t *blk)
{
    obj_in_image_t obj;

    if (!blk) return 0;
    obj.ptr = (void *)blk;
    obj.objtype = OBJTYPE_VECTOR_BLOCK;
    return mdl_schedule_for_write(obj);
}

int mdl_schedule_uvector_block_for_write(mdl_uvector_block_t *blk)
{
    obj_in_image_t obj;

    if (!blk) return 0;
    obj.ptr = (void *)blk;
    obj.objtype = OBJTYPE_UVECTOR_BLOCK;
    return mdl_schedule_for_write(obj);
}

void mdl_write_mdl_value(FILE *f, mdl_value_t *v, objtype_t objtype = OBJTYPE_MDL_VALUE);
void mdl_write_mdl_value(FILE *f, mdl_value_t *v, objtype_t objtype)
{
    mdl_write_objtype(f, objtype);
    mdl_write_primtype(f, v->pt);
    mdl_write_int(f, v->type);
    int onum;
    switch (v->pt)
    {
    case PRIMTYPE_ATOM:
        onum = mdl_schedule_atom_for_write(v->v.a);
        mdl_write_intptr(f, onum);
        break;
    case PRIMTYPE_WORD:
        mdl_write_MDL_INT(f, v->v.w);
        break;
    case PRIMTYPE_LIST:
        onum = mdl_schedule_value_for_write(v->v.p.car);
        mdl_write_intptr(f, onum);
        onum = mdl_schedule_value_for_write(v->v.p.cdr);
        mdl_write_intptr(f, onum);
        break;
    case PRIMTYPE_STRING:
        // strings will need extra fix-up on read, basically 
        // adjusting the pointer so the length is right
        onum = mdl_schedule_string_for_write(&v->v.s);
        mdl_write_intptr(f, onum);
        mdl_write_int(f, v->v.s.l);
        break;
    case PRIMTYPE_VECTOR:
        if (v->type == MDL_TYPE_CHANNEL)
        {
            FILE *f;
            int channum = mdl_get_chan_channum(v);
            if (channum > 1)
            {
                f = mdl_get_channum_file(channum);
                
                VITEM(v,CHANNEL_SLOT_PTR)->v.w = (MDL_INT)ftell(f);
            }
        }
        onum = mdl_schedule_vector_block_for_write(v->v.v.p);
        mdl_write_intptr(f, onum);
        mdl_write_int(f, v->v.v.offset);
        break;
    case PRIMTYPE_UVECTOR:
        onum = mdl_schedule_uvector_block_for_write(v->v.uv.p);
        mdl_write_intptr(f, onum);
        mdl_write_int(f, v->v.v.offset);
        break;
    case PRIMTYPE_TUPLE:
        fprintf(stderr, "Can't write tuples");
        break;
    case PRIMTYPE_FRAME:
        fprintf(stderr, "Can't write frames");
        break;
    }
}

int mdl_read_mdl_value(FILE *f, mdl_value_t **vp)
{
    // objtype will already have been read at this point
    mdl_value_t *v;

    // evil kludge for vectors...
    if (*vp == NULL)
        *vp = v = mdl_new_mdl_value();
    else
        v = *vp;

    if (mdl_read_primtype(f, &v->pt) != 0) return -1;
    if (mdl_read_int(f, &v->type) != 0) return -1;
    intptr_t onum;
    switch (v->pt)
    {
    case PRIMTYPE_ATOM:
        if (mdl_read_intptr(f, &onum) != 0) return -1;
        v->v.a = (atom_t *)onum;
        break;
    case PRIMTYPE_WORD:
        if (mdl_read_MDL_INT(f, &v->v.w) != 0) return -1;
        break;
    case PRIMTYPE_LIST:
        if (mdl_read_intptr(f, &onum) != 0) return -1;
        v->v.p.car = (mdl_value_t *)onum;
        if (mdl_read_intptr(f, &onum) != 0) return -1;
        v->v.p.cdr = (mdl_value_t *)onum;
        break;
    case PRIMTYPE_STRING:
        // strings will need extra fix-up on read, basically 
        // adjusting the pointer so the length is right
        if (mdl_read_intptr(f, &onum) != 0) return -1;
        v->v.s.p = (char *)onum;
        if (mdl_read_int(f, &v->v.s.l) != 0) return -1;
        break;
    case PRIMTYPE_VECTOR:
        if (mdl_read_intptr(f, &onum) != 0) return -1;
        v->v.v.p = (mdl_vector_block_t *)onum;
        if (mdl_read_int(f, &v->v.v.offset) != 0) return -1;
        break;
    case PRIMTYPE_UVECTOR:
        if (mdl_read_intptr(f, &onum) != 0) return -1;
        v->v.uv.p = (mdl_uvector_block_t *)onum;
        if (mdl_read_int(f, &v->v.uv.offset) != 0) return -1;
        break;
    case PRIMTYPE_TUPLE:
        fprintf(stderr, "Can't read tuples");
        return -1;
        break;
    case PRIMTYPE_FRAME:
        fprintf(stderr, "Can't read frames");
        return -1;
        break;
    }
    return 0;
}

int mdl_fixup_mdl_value(FILE *f, mdl_value_t *v)
{
    intptr_t onum;
    obj_in_image_t *obj;
    switch (v->pt)
    {
    case PRIMTYPE_ATOM:
        onum = (intptr_t)v->v.a;
        obj = find_obj_by_num(onum, OBJTYPE_ATOM);
        if (obj == NULL)  return -1;
        v->v.a = (atom_t *)obj->ptr;
        break;
    case PRIMTYPE_WORD:
        // no fixup needed
        break;
    case PRIMTYPE_LIST:
        onum = (intptr_t)v->v.p.car;
        obj = find_obj_by_num(onum, OBJTYPE_MDL_VALUE);
        if (!obj) return -1;
        v->v.p.car = (mdl_value_t *)obj->ptr;
        onum = (intptr_t)v->v.p.cdr;
        obj = find_obj_by_num(onum, OBJTYPE_MDL_VALUE);
        if (!obj) return -1;
        v->v.p.cdr = (mdl_value_t *)obj->ptr;
        break;
    case PRIMTYPE_STRING:
    {
        int truelen;
        // strings need extra fix-up on read, basically 
        // adjusting the pointer so the length is right
        onum = (intptr_t)v->v.s.p;
        obj = find_obj_by_num(onum, OBJTYPE_RAWSTRING);
        if (!obj) return -1;
        v->v.s.p = (char *)obj->ptr;
        truelen = obj->len;
        v->v.s.p = v->v.s.p + truelen - v->v.s.l;
        break;
    }
    case PRIMTYPE_VECTOR:
        onum = (intptr_t)v->v.v.p;
        obj = find_obj_by_num(onum, OBJTYPE_VECTOR_BLOCK);
        if (!obj) return -1;
        v->v.v.p = (mdl_vector_block_t *)obj->ptr;
        if (v->type == MDL_TYPE_CHANNEL)
            chanmap.insert(pair<intptr_t,mdl_value_t *>(onum, v));
        break;
    case PRIMTYPE_UVECTOR:
        onum = (intptr_t)v->v.uv.p;
        obj = find_obj_by_num(onum, OBJTYPE_UVECTOR_BLOCK);
        v->v.uv.p = (mdl_uvector_block_t *)obj->ptr;
        break;
    case PRIMTYPE_TUPLE:
        fprintf(stderr, "Can't fixup tuples");
        return -1;
        break;
    case PRIMTYPE_FRAME:
        fprintf(stderr, "Can't fixup frames");
        return -1;
        break;
    }
    return 0;
}

void mdl_write_rawstring(FILE *f, char *raw, int len)
{
    mdl_write_objtype(f, OBJTYPE_RAWSTRING);
    int truelen = *(MDL_INT *)ALIGN_MDL_INT(raw + len + 1);
    
    mdl_write_int(f, truelen);
    if (truelen < 0) truelen = ~truelen;
    fputc('%', f);
    fwrite(raw, truelen, 1, f);
}

int mdl_read_rawstring(FILE *f, char **rawp, int *lenp)
{
    // objtype is already read
    int len;
    bool immut = false;
    char pct;

    if (mdl_read_int(f, &len) != 0) return -1;
    pct = fgetc(f);
    if (pct != '%') return -1;
    *lenp = len;
    if (len < 0) 
    {
        len = ~len;
        immut = true;
    }
    *rawp = mdl_new_raw_string(len, immut);
    if (fread(*rawp, len, 1, f) != 1) return -1;
    return 0;
}

int mdl_fixup_rawstring(FILE *f, char *rawp)
{
    // nothing to be done
    return 0;
}

void mdl_write_atom(FILE *f, atom_t *a)
{
    // atom is pname(obj), type, oblist(obj), globalsym(obj), localsym(obj)
    int objnum;
    mdl_value_t *binding;
    mdl_write_objtype(f, OBJTYPE_ATOM);

    objnum = mdl_schedule_pname_for_write(a->pname);
    mdl_write_intptr(f, objnum);

    mdl_write_int(f, a->typenum);

    objnum = mdl_schedule_value_for_write(a->oblist);
    mdl_write_intptr(f, objnum);

    binding = mdl_global_symbol_lookup(a);
    objnum = mdl_schedule_value_for_write(binding);
    mdl_write_intptr(f, objnum);

    // top level local binding only
    binding = mdl_local_symbol_lookup(a, initial_frame);
    objnum = mdl_schedule_value_for_write(binding);
    mdl_write_intptr(f, objnum);
}

int mdl_read_atom(FILE *f, atom_t **ap, mdl_symbol_table_t *global, mdl_local_symbol_table_t *local)
{
    // atom is pname(obj), type, oblist(obj), globalsym(obj), localsym(obj)
    intptr_t objnum;
    //OBJTYPE will have been read already
    mdl_symbol_t sym;
    mdl_local_symbol_t lsym;
    atom_t *a;

    *ap = a = (atom_t *)GC_MALLOC(sizeof(atom_t));

    if (mdl_read_intptr(f, &objnum) != 0) return -1;
    a->pname = (char *)objnum;
    if (mdl_read_int(f, &a->typenum) != 0) return -1;

    if (mdl_read_intptr(f, &objnum) != 0) return -1;
    a->oblist = (mdl_value_t *)objnum;

    if (mdl_read_intptr(f, &objnum) != 0) return -1;

    sym.atom = a;
    sym.binding = (mdl_value_t *)objnum;
    if (objnum != 0)
        global->insert(std::pair<const atom_t *, mdl_symbol_t>(a, sym));

    if (mdl_read_intptr(f, &objnum) != 0) return -1;

    lsym.atom = a;
    lsym.binding = (mdl_value_t *)objnum;
    if (objnum != 0)
        local->insert(std::pair<const atom_t *, mdl_local_symbol_t>(a, lsym));
    return 0;
}

int mdl_fixup_atom(FILE *f, atom_t *a, mdl_symbol_table_t *global, mdl_local_symbol_table_t *local)
{
    // atom is pname(obj), type, oblist(obj), globalsym(obj), localsym(obj)
    intptr_t objnum;
    mdl_symbol_table_t::iterator iter;
    mdl_local_symbol_table_t::iterator liter;
    obj_in_image_t *obj;

    objnum = (intptr_t)a->pname;
    obj = find_obj_by_num(objnum, OBJTYPE_RAWSTRING);
    if (!obj) return -1;
    a->pname = (char *)obj->ptr; // pnames don't need length adjustment

    objnum = (intptr_t)a->oblist;
    obj = find_obj_by_num(objnum, OBJTYPE_MDL_VALUE);
    if (!obj) return -1;
    a->oblist = (mdl_value_t *)obj->ptr; // pnames don't need length adjustment

    iter = global->find(a);
    if (iter != global->end())
    {
        objnum = (intptr_t)iter->second.binding;
        obj = find_obj_by_num(objnum, OBJTYPE_MDL_VALUE);
        if (!obj) return -1;
        iter->second.binding = (mdl_value_t *)obj->ptr;
    }

    liter = local->find(a);
    if (liter != local->end())
    {
        objnum = (intptr_t)liter->second.binding;
        obj = find_obj_by_num(objnum, OBJTYPE_MDL_VALUE);
        if (!obj) return -1;
        liter->second.binding = (mdl_value_t *)obj->ptr;
    }

    return 0;
}

void mdl_write_vector_block(FILE *f, mdl_vector_block_t *blk)
{
    int i;
    mdl_value_t *elems;

    mdl_write_objtype(f, OBJTYPE_VECTOR_BLOCK);
    mdl_write_int(f, blk->size);
    mdl_write_int(f, blk->startoffset);
    // write elements directly in the block
    elems = blk->elements;
    for (i = 0; i < blk->size; i++)
    {
        mdl_write_mdl_value(f, elems++);
    }
}

int mdl_read_vector_block(FILE *f, mdl_vector_block_t **blkp)
{
    int i;
    mdl_value_t *elems;
    mdl_vector_block_t *blk;

    // objtype has already been read
    *blkp = blk = (mdl_vector_block_t *)GC_MALLOC(sizeof(mdl_vector_block_t));
    if (mdl_read_int(f, &blk->size) != 0) return -1;
    if (mdl_read_int(f, &blk->startoffset) != 0) return -1;
    // write elements directly in the block
    blk->elements = (mdl_value_t *)GC_MALLOC(sizeof(mdl_value_t) * blk->size);
    elems = blk->elements;
    for (i = 0; i < blk->size; i++)
    {
        objtype_t objtype;

        if (mdl_read_objtype(f, &objtype) != 0) return (i+1);
        if (objtype != OBJTYPE_MDL_VALUE &&
            objtype != OBJTYPE_MDL_ROOT_OBLIST &&
            objtype != OBJTYPE_MDL_INITIAL_OBLIST)
        {
            fprintf(stderr, "Bad objtype in vector\n");
            return i+1;
        }
        if (mdl_read_mdl_value(f, &elems) != 0) return (i+1);
        elems++;
    }
    return 0;
}

int mdl_fixup_vector_block(FILE *f, mdl_vector_block_t *blk)
{
    int i;
    mdl_value_t *elems;

    elems = blk->elements;
    for (i = 0; i < blk->size; i++)
    {
        mdl_fixup_mdl_value(f, elems++);
    }
    return 0;
}

void mdl_write_uvector_element(FILE *f, primtype_t pt, uvector_element_t *elem)
{
    int onum;
    switch(pt)
    {
    case PRIMTYPE_ATOM:
        onum = mdl_schedule_atom_for_write(elem->a);
        mdl_write_intptr(f, onum);
        break;
    case PRIMTYPE_WORD:
        mdl_write_MDL_INT(f, elem->w);
        break;
    case PRIMTYPE_LIST:
        onum = mdl_schedule_value_for_write(elem->l);
        mdl_write_intptr(f, onum);
        break;
    case PRIMTYPE_VECTOR:
        onum = mdl_schedule_vector_block_for_write(elem->v.p);
        mdl_write_intptr(f, onum);
        mdl_write_int(f, elem->v.offset);
        break;
    case PRIMTYPE_UVECTOR:
        onum = mdl_schedule_uvector_block_for_write(elem->uv.p);
        mdl_write_intptr(f, onum);
        mdl_write_int(f, elem->uv.offset);
        break;
    default:
        fprintf(stderr, " BOGUS UVECTOR PRIMTYPE %d\n", pt);
    }
}

int mdl_read_uvector_element(FILE *f, primtype_t pt, uvector_element_t *elem)
{
    intptr_t onum;
    switch(pt)
    {
    case PRIMTYPE_ATOM:
        if(mdl_read_intptr(f, &onum) != 0) return -1;
        elem->a = (atom_t *)onum;
        break;
    case PRIMTYPE_WORD:
        if (mdl_read_MDL_INT(f, &elem->w) != 0) return -1;
        break;
    case PRIMTYPE_LIST:
        if(mdl_read_intptr(f, &onum) != 0) return -1;
        elem->l = (mdl_value_t *)onum;
        break;
    case PRIMTYPE_VECTOR:
        if(mdl_read_intptr(f, &onum) != 0) return -1;
        elem->v.p = (mdl_vector_block_t *)onum;
        if (mdl_read_int(f, &elem->v.offset) != 0) return -1;
        break;
    case PRIMTYPE_UVECTOR:
        if(mdl_read_intptr(f, &onum) != 0) return -1;
        elem->uv.p = (mdl_uvector_block_t *)onum;
        if (mdl_read_int(f, &elem->uv.offset) != 0) return -1;
        break;
    default:
        fprintf(stderr, " BOGUS UVECTOR PRIMTYPE %d\n", pt);
        return -1;
    }
    return 0;
}

int mdl_fixup_uvector_element(FILE *f, primtype_t pt, uvector_element_t *elem)
{
    int onum;
    obj_in_image_t *obj;
    switch(pt)
    {
    case PRIMTYPE_ATOM:
        onum = (intptr_t)elem->a;
        obj = find_obj_by_num(onum, OBJTYPE_ATOM);
        if (!obj) return -1;
        elem->a = (atom_t *)obj->ptr;
        break;
    case PRIMTYPE_WORD:
        // nothing to do
        break;
    case PRIMTYPE_LIST:
        onum = (intptr_t)elem->l;
        obj = find_obj_by_num(onum, OBJTYPE_MDL_VALUE);
        if (!obj) return -1;
        elem->l = (mdl_value_t *)obj->ptr;
        break;
    case PRIMTYPE_VECTOR:
        onum = (intptr_t)elem->v.p;
        obj = find_obj_by_num(onum, OBJTYPE_VECTOR_BLOCK);
        if (!obj) return -1;
        elem->v.p = (mdl_vector_block_t *)obj->ptr;
        break;
    case PRIMTYPE_UVECTOR:
        onum = (intptr_t)elem->uv.p;
        obj = find_obj_by_num(onum, OBJTYPE_UVECTOR_BLOCK);
        if (!obj) return -1;
        elem->uv.p = (mdl_uvector_block_t *)obj->ptr;
        break;
    default:
        fprintf(stderr, " BOGUS UVECTOR PRIMTYPE %d\n", pt);
        return -1;
    }
    return 0;
}

void mdl_write_uvector_block(FILE *f, mdl_uvector_block_t *blk)
{
    int i;
    uvector_element_t *elems;
    primtype_t pt = mdl_type_primtype(blk->type);

    if (blk->type == MDL_TYPE_CHANNEL)
    {
        mdl_error("Can't handle UVECTOR of channels just yet");
    }
    mdl_write_objtype(f, OBJTYPE_UVECTOR_BLOCK);
    mdl_write_int(f, blk->type);
    mdl_write_int(f, blk->size);
    mdl_write_int(f, blk->startoffset);
    // write elements directly in the block
    elems = blk->elements;
    for (i = 0; i < blk->size; i++)
    {
        mdl_write_uvector_element(f, pt, elems++);
    }
}

int mdl_read_uvector_block(FILE *f, mdl_uvector_block_t **blkp, mdl_type_table_t *tt)
{
    int i;
    uvector_element_t *elems;
    primtype_t pt;
    mdl_uvector_block_t *blk;

    //objtype has already been read
    *blkp = blk = (mdl_uvector_block_t *)GC_MALLOC(sizeof(mdl_uvector_block_t));
    if (mdl_read_int(f, &blk->type) != 0) return -1;
    if (mdl_read_int(f, &blk->size) != 0) return -1;
    if (mdl_read_int(f, &blk->startoffset) != 0) return -1;
    // read elements directly into the block
    blk->elements = (uvector_element_t *)GC_MALLOC(sizeof(uvector_element_t) * blk->size);
    elems = blk->elements;
    pt = (*tt)[blk->type].pt;
    for (i = 0; i < blk->size; i++)
    {
        mdl_read_uvector_element(f, pt, elems++);
    }
    return 0;
}

int mdl_fixup_uvector_block(FILE *f, mdl_uvector_block_t *blk, mdl_type_table_t *tt)
{
    int i;
    uvector_element_t *elems;
    primtype_t pt = (*tt)[blk->type].pt;

    elems = blk->elements;
    for (i = 0; i < blk->size; i++)
    {
        if (mdl_fixup_uvector_element(f, pt, elems++) != 0) return -1;
    }
    return 0;
}

void mdl_write_type_table_entry(FILE *f, struct mdl_type_table_entry_t *tt)
{
    int objnum;

    mdl_write_primtype(f, tt->pt);
    objnum = mdl_schedule_atom_for_write(tt->a);
    mdl_write_intptr(f, objnum);
    objnum = mdl_schedule_value_for_write(tt->printtype);
    mdl_write_intptr(f, objnum);
    objnum = mdl_schedule_value_for_write(tt->evaltype);
    mdl_write_intptr(f, objnum);
    objnum = mdl_schedule_value_for_write(tt->applytype);
    mdl_write_intptr(f, objnum);
}

int mdl_read_type_table_entry(FILE *f, struct mdl_type_table_entry_t *tte)
{
    intptr_t objnum;
    int err;

    if ((err = mdl_read_primtype(f, &tte->pt)) != 0) return err;
    if ((err = mdl_read_intptr(f, &objnum)) != 0) return err;
    tte->a = (atom_t *)objnum;
    if ((err = mdl_read_intptr(f, &objnum)) != 0) return err;
    tte->printtype = (mdl_value_t *)objnum;
    if ((err = mdl_read_intptr(f, &objnum)) != 0) return err;
    tte->evaltype = (mdl_value_t *)objnum;
    if ((err = mdl_read_intptr(f, &objnum)) != 0) return err;
    tte->applytype = (mdl_value_t *)objnum;
    return 0;
}

int mdl_fixup_type_table_entry(struct mdl_type_table_entry_t *tte)
{
    intptr_t objnum;
    obj_in_image_t *obj;

    objnum = (intptr_t)tte->a;
    obj = find_obj_by_num(objnum, OBJTYPE_ATOM);
    if (!obj) return -1;
    tte->a = (atom_t *)obj->ptr;

    objnum = (intptr_t)tte->printtype;
    obj = find_obj_by_num(objnum, OBJTYPE_MDL_VALUE);
    if (!obj) return -1;
    tte->printtype = (mdl_value_t *)obj->ptr;

    objnum = (intptr_t)tte->evaltype;
    obj = find_obj_by_num(objnum, OBJTYPE_MDL_VALUE);
    if (!obj) return -1;
    tte->evaltype = (mdl_value_t *)obj->ptr;

    objnum = (intptr_t)tte->applytype;
    obj = find_obj_by_num(objnum, OBJTYPE_MDL_VALUE);
    if (!obj) return -1;
    tte->applytype = (mdl_value_t *)obj->ptr;

    return 0;
}

void mdl_write_type_table(FILE *f, mdl_type_table_t *tt)
{
    int size = tt->size();
    mdl_type_table_t::iterator iter;

    mdl_write_objtype(f, OBJTYPE_TYPE_TABLE);
    mdl_write_int(f, size);
    for (iter = tt->begin(); iter != tt->end(); iter++)
    {
        mdl_write_type_table_entry(f, &*iter);
    }
}

int mdl_read_type_table(FILE *f, mdl_type_table_t *tt)
{
    int size;
    int i;
    objtype_t objtype;

    if (mdl_read_objtype(f, &objtype) != 0)
    {
        return -1;
    }
    if (objtype != OBJTYPE_TYPE_TABLE)
    {
        fprintf(stderr, "Didn't find type table\n");
        return -1;
    }

    if (mdl_read_int(f, &size) != 0)
    {
        return -1;
    }
    if (size < 0) return -1;
    tt->reserve(size);
    for (i = 0; i < size; i++)
    {
        mdl_type_table_entry_t tte;
        if (mdl_read_type_table_entry(f, &tte) != 0)
        {
            return i + 1;
        }
        tt->push_back(tte);
    }
    return 0;
}

int mdl_fixup_type_table(mdl_type_table_t *tt)
{
    mdl_type_table_t::iterator iter;
    int i;

    for (i = 0, iter = tt->begin(); iter != tt->end(); iter++, i++)
    {
        if (mdl_fixup_type_table_entry(&*iter) != 0) return i+1;
    }
    return 0;
}

void mdl_write_asoc_table(FILE *f)
{
    int size;
    mdl_assoc_iterator_t *iter;

    mdl_assoc_clean(mdl_assoc_table); // clean out dead references before writing
    size = mdl_assoc_table_size(mdl_assoc_table);
    mdl_write_objtype(f, OBJTYPE_ASOC_TABLE);
    mdl_write_int(f, size);
    for (iter = mdl_assoc_iterator_first(mdl_assoc_table);
         !mdl_assoc_iterator_at_end(iter);
         mdl_assoc_iterator_increment(iter))
    {
        int onum;
        const mdl_assoc_key_t *key = mdl_assoc_iterator_get_key(iter);
        mdl_value_t *value = mdl_assoc_iterator_get_value(iter);
        onum = mdl_schedule_value_for_write(key->item);
        mdl_write_intptr(f, onum);
        onum = mdl_schedule_value_for_write(key->indicator);
        mdl_write_intptr(f, onum);
        onum = mdl_schedule_value_for_write(value);
        mdl_write_intptr(f, onum);
    }
}

int mdl_read_asoc_table(FILE *f, mdl_tmp_assoc_table_t *tmptable)
{
    int size;
    int i;
    objtype_t objtype;

    if (mdl_read_objtype(f, &objtype) != 0)
    {
        fprintf(stderr, "Couldn't read assoc table objtype\n");
        return -1;
    }

    if (objtype != OBJTYPE_ASOC_TABLE)
    {
        fprintf(stderr, "Didn't find association table\n");
        return -1;
    }
    mdl_read_int(f, &size);

    tmptable->reserve(size);
    for (i = 0; i < size; i++)
    {
        intptr_t onum;
        mdl_tmp_assoc_entry_t entry;
        if (mdl_read_intptr(f, &onum) != 0) return i + 1;
        entry.item = (mdl_value_t *)onum;
        if (mdl_read_intptr(f, &onum) != 0) return i + 1;
        entry.indicator = (mdl_value_t *)onum;
        if (mdl_read_intptr(f, &onum) != 0) return i + 1;
        entry.value = (mdl_value_t *)onum;
        tmptable->push_back(entry);
    }
    return 0;
}

int mdl_fixup_asoc_table(mdl_tmp_assoc_table_t *tmptable)
{
    int i;
    mdl_tmp_assoc_table_t::iterator iter;

    for (iter = tmptable->begin(), i = 0; iter != tmptable->end(); iter++, i++)
    {
        intptr_t onum;
        obj_in_image_t *obj;

        onum = (intptr_t)iter->item;
        obj = find_obj_by_num(onum, OBJTYPE_MDL_VALUE);
        if (!obj) return i+1;
        iter->item = (mdl_value_t *)obj->ptr;

        onum = (intptr_t)iter->indicator;
        obj = find_obj_by_num(onum, OBJTYPE_MDL_VALUE);
        if (!obj) return i+1;
        iter->indicator = (mdl_value_t *)obj->ptr;

        onum = (intptr_t)iter->value;
        obj = find_obj_by_num(onum, OBJTYPE_MDL_VALUE);
        if (!obj) return i+1;
        iter->value = (mdl_value_t *)obj->ptr;
    }
    return 0;
}

void mdl_write_built_in_table(FILE *f)
{
    mdl_built_in_table_t::iterator biter;
    int valueobjnum = -1;

    mdl_write_objtype(f, OBJTYPE_BUILT_IN_TABLE);
    mdl_write_int(f, (int)built_in_table.size());
    for (biter = built_in_table.begin(); biter != built_in_table.end(); biter++)
    {
        obj_in_image_t obj;
        int objnum;
        
        // invent an object number for the value
        obj.ptr = (void *)biter->v;
        obj.objtype = OBJTYPE_UVECTOR_BLOCK;
        obj.objnum = valueobjnum--;
        image_objects.insert(obj);

        // write just the atom -- proc and value are immutable (hopefully)

        objnum = mdl_schedule_value_for_write(biter->a);
        mdl_write_intptr(f, objnum);

    }
}

int mdl_read_built_in_table(FILE *f, mdl_built_in_table_t *new_table)
{
    mdl_built_in_table_t::iterator biter;
    int valueobjnum = -1;
    int tablesize;
    objtype_t objtype;

    if (mdl_read_objtype(f, &objtype) != 0)
    {
        return -1;
    }

    if (objtype != OBJTYPE_BUILT_IN_TABLE)
    {
        fprintf(stderr, "Didn't find built-in table\n");
        return -1;
    }

    if (mdl_read_int(f, &tablesize) != 0) return -1;
    if (tablesize != (int)built_in_table.size())
    {
        fprintf(stderr, "Built-in table size does not match\n");
        return -1;
    }
    new_table->reserve(tablesize);
    //iterating the old table is effective as the sizes must match
    for (biter = built_in_table.begin(); biter != built_in_table.end(); biter++)
    {
        mdl_built_in_t elem;
        obj_in_image_t obj;
        intptr_t objnum;
        
        // invent an object number for the value, just as in write
        obj.ptr = (void *)biter->v;
        obj.objtype = OBJTYPE_UVECTOR_BLOCK;
        obj.objnum = valueobjnum--;
//        image_objects.insert(obj);

        elem.proc = biter->proc;
        elem.v = biter->v;

        // read just the atom -- proc and value are from the current table

        if (mdl_read_intptr(f, &objnum) != 0)
            return (new_table->size() + 1);
        elem.a = (mdl_value_t *)objnum;
        new_table->push_back(elem);
    }
    return 0;
}

int mdl_fixup_built_in_table(mdl_built_in_table_t *new_table)
{
    mdl_built_in_table_t::iterator biter;
    int i;

    for (i = 0, biter = new_table->begin(); biter != new_table->end(); biter++, i++)
    {
        obj_in_image_t *obj;
        intptr_t objnum;

        // fixup just the atom -- proc and value are from the current table
        
        objnum = (intptr_t)biter->a;
        obj = find_obj_by_num(objnum, OBJTYPE_MDL_VALUE);
        if (!obj) return (i+1);
        biter->a = (mdl_value_t *)obj->ptr;
    }
    return 0;
}

// Root objects for MDL
// ROOT oblist ("!-")
// INITIAL oblist (internally accessible in error cases)
// ERRORS and INTERRUPTS oblists (neither completely implemented, 
//             but normally accessible through ROOT)
// OBLIST atom
// Associations
// Type vector
// built-in SUBR/FSUBRS (not written, considered immutable)
void mdl_write_image(FILE *f, mdl_value_t *save_arg)
{
    size_t index;
    obj_in_image_t *obj;

    image_objects.clear();
    image_object_list.clear();
    
    // must schedule these first, lest they get scheduled without their
    // tags
    mdl_schedule_value_for_write(mdl_value_root_oblist, OBJTYPE_MDL_ROOT_OBLIST);
    mdl_schedule_value_for_write(mdl_value_initial_oblist, OBJTYPE_MDL_INITIAL_OBLIST);
    mdl_schedule_value_for_write(save_arg, OBJTYPE_SAVE_ARG);

    mdl_write_built_in_table(f);
    mdl_write_type_table(f, &mdl_type_table);
    mdl_write_asoc_table(f);

    mdl_schedule_value_for_write(mdl_value_oblist);
    
    for (index = 0; index < image_object_list.size(); index++)
    {
        // note iterators cannot be used because they can be invalidated
        // at any time.  could check if capacity has changed but.. meh
#ifdef MDL_DEBUG_BINARY_IO
        fprintf(f, "\n-----OBJECT %zu-----\n\n", index + 1);
#else
        mdl_write_int(f, (int)index+1);
#endif
        obj = &image_object_list[index];
        switch(obj->objtype)
        {
        case OBJTYPE_SAVE_ARG:
        case OBJTYPE_MDL_INITIAL_OBLIST:
        case OBJTYPE_MDL_ROOT_OBLIST:
        case OBJTYPE_MDL_VALUE:
            mdl_write_mdl_value(f, (mdl_value_t *)obj->ptr, obj->objtype);
            break;
        case OBJTYPE_ATOM:
            mdl_write_atom(f, (atom_t *)obj->ptr);
            break;
        case OBJTYPE_RAWSTRING:
            mdl_write_rawstring(f, (char *)obj->ptr, obj->len);
            break;
        case OBJTYPE_VECTOR_BLOCK:
            mdl_write_vector_block(f, (mdl_vector_block_t *)obj->ptr);
            break;
        case OBJTYPE_UVECTOR_BLOCK:
            mdl_write_uvector_block(f, (mdl_uvector_block_t *)obj->ptr);
            break;
       }
    }
    image_objects.clear();
    image_object_list.clear();
}

bool mdl_read_image(FILE *f)
{
    size_t index;
    obj_in_image_t obj;
    mdl_built_in_table_t new_built_ins;
    mdl_type_table_t new_types;
    mdl_tmp_assoc_table_t new_assocs;
    mdl_assoc_table_t *new_assoc_hash;
    mdl_symbol_table_t newglobal;
    mdl_local_symbol_table_t newlocal;
    mdl_value_t *new_root_oblist = NULL;
    mdl_value_t *new_initial_oblist = NULL;
    mdl_value_t *save_arg = NULL;
    int err;

    image_object_list.clear();
    chanmap.clear();
    
    if ((err = mdl_read_built_in_table(f, &new_built_ins)) != 0)
    {
        fprintf(stderr, "Unable to read built_in table %d\n", err);
        return false;
    }

    if ((err = mdl_read_type_table(f, &new_types)) !=0 )
    {
        fprintf(stderr, "Unable to read type table %d\n", err);
        return false;
    }
    
    if ((err = mdl_read_asoc_table(f, &new_assocs)) != 0)
    {
        fprintf(stderr, "Unable to read assoc table %d\n", err);
        return false;
    }

    index = 0;
    while (!feof(f))
    {
#ifdef MDL_DEBUG_BINARY_IO
        size_t check_index;
        // note iterators cannot be used because they can be invalidated
        // at any time.  could check if capacity has changed but.. meh
        if (fscanf(f, "\n-----OBJECT %zu-----\n\n", &check_index) != 1)
        {
            fprintf(stderr, "Unable to read object header %zd\n", index);
            return false;
        }
#else
        size_t check_index;
        int tmp;


        if (mdl_read_int(f, &tmp) != 0)
        {
            if (feof(f)) break;
            fprintf(stderr, "Unable to read object header %zd\n", index);
            return false;
        }
        check_index = (size_t)tmp;
#endif

        if (check_index != (index + 1))
        {
            fprintf(stderr, "Wrong object index %zd != %zd\n", check_index, index + 1);
            return false;
            
        }
        obj.objnum = check_index;

        if (mdl_read_objtype(f, &obj.objtype) != 0)
        {
            fprintf(stderr, "Unable to read object type %zd\n", index);
            return false;
        }

        switch(obj.objtype)
        {
        case OBJTYPE_SAVE_ARG:
        case OBJTYPE_MDL_INITIAL_OBLIST:
        case OBJTYPE_MDL_ROOT_OBLIST:
        case OBJTYPE_MDL_VALUE:
        {
            mdl_value_t *v = NULL;
            mdl_read_mdl_value(f, &v);
            obj.ptr = (void *)v;
            break;
        }
        case OBJTYPE_ATOM:
        {
            atom_t *a = NULL;
            mdl_read_atom(f, &a, &newglobal, &newlocal);
            obj.ptr = (void *)a;
            break;
        }
        case OBJTYPE_RAWSTRING:
        {
            char *str = NULL;
            int len;

            mdl_read_rawstring(f, &str, &len);
            obj.ptr = (void *)str;
            obj.len = len;
            break;
        }
        case OBJTYPE_VECTOR_BLOCK:
        {
            mdl_vector_block_t *vb = NULL;
            mdl_read_vector_block(f, &vb);
            obj.ptr = (void *)vb;
            break;
        }
        case OBJTYPE_UVECTOR_BLOCK:
        {
            mdl_uvector_block_t *uvb = NULL;
            mdl_read_uvector_block(f, &uvb, &new_types);
            obj.ptr = (void *)uvb;
            break;
        }
        }
        if (obj.ptr == NULL)
        {
            fprintf(stderr, "Failed to read object %zd\n", index);
            return false;
        }
        image_object_list.push_back(obj);
        if (image_object_list.size() != check_index)
        {
            fprintf(stderr, "Wrong double-check object index %zd != %zd\n", image_object_list.size(), check_index);
            return false;
        }

        index++;
    }
// Everything's read, now restore the pointers
    if ((err = mdl_fixup_built_in_table(&new_built_ins)) != 0)
    {
        fprintf(stderr, "Unable to fixup built_in table %d\n", err);
        return false;
    }

    if ((err = mdl_fixup_type_table(&new_types)) !=0 )
    {
        fprintf(stderr, "Unable to fixup type table %d\n", err);
        return false;
    }
    
    if ((err = mdl_fixup_asoc_table(&new_assocs)) != 0)
    {
        fprintf(stderr, "Unable to fixup assoc table %d\n", err);
        return false;
    }


    obj_image_list_t::iterator iter;
    for (index = 0, iter = image_object_list.begin();
         iter != image_object_list.end();
         iter++, index++)
    {
        switch(iter->objtype)
        {
        case OBJTYPE_SAVE_ARG:
        case OBJTYPE_MDL_INITIAL_OBLIST:
        case OBJTYPE_MDL_ROOT_OBLIST:
        case OBJTYPE_MDL_VALUE:
        {
            err = mdl_fixup_mdl_value(f, (mdl_value_t *)iter->ptr);
            if (iter->objtype == OBJTYPE_MDL_ROOT_OBLIST)
            {
                new_root_oblist = (mdl_value_t *)iter->ptr;
            }
            else if (iter->objtype == OBJTYPE_MDL_INITIAL_OBLIST)
            {
                new_initial_oblist = (mdl_value_t *)iter->ptr;
            }
            else if (iter->objtype == OBJTYPE_SAVE_ARG)
            {
                save_arg = (mdl_value_t *)iter->ptr;
            }
            break;
        }
        case OBJTYPE_ATOM:
        {
            err = mdl_fixup_atom(f, (atom_t *)iter->ptr, &newglobal, &newlocal);
            break;
        }
        case OBJTYPE_RAWSTRING:
        {
            err = mdl_fixup_rawstring(f, (char *)iter->ptr);
            break;
        }
        case OBJTYPE_VECTOR_BLOCK:
        {
            err = mdl_fixup_vector_block(f, (mdl_vector_block_t *)iter->ptr);
            break;
        }
        case OBJTYPE_UVECTOR_BLOCK:
        {
            err = mdl_fixup_uvector_block(f, (mdl_uvector_block_t *)iter->ptr, &new_types);
            break;
        }
        }
        if (err != 0)
        {
            fprintf(stderr, "Failed to fixup object %zd (type %d)\n", index, (int) iter->objtype);
            return false;
        }
    }

    mdl_value_t *new_mdl_value_atom_oblist = mdl_get_atom_from_oblist("OBLIST", new_root_oblist);
    if (!new_mdl_value_atom_oblist)
    {
        fprintf(stderr, "OBLIST!- atom missing in save image\n");
        return -1;
    }
    mdl_value_t *mdl_value_atom_interrupts = mdl_get_atom_from_oblist("INTERRUPTS", new_root_oblist);
    if (!mdl_value_atom_interrupts)
    {
        fprintf(stderr, "INTERRUPTS!- atom missing in save image\n");
        return -1;
    }

    // Build the new association table
    mdl_tmp_assoc_table_t::iterator aiter;
    mdl_assoc_key_t key;
    
    new_assoc_hash = mdl_create_assoc_table();

    for (aiter = new_assocs.begin(); aiter != new_assocs.end(); aiter++)
    {
        key.item = aiter->item;
        key.indicator = aiter->indicator;
        mdl_add_assoc(new_assoc_hash, &key, aiter->value);
    }
    // find the interrupts oblist
    key.item = mdl_value_atom_interrupts;
    key.indicator = new_mdl_value_atom_oblist;
    mdl_value_t *mdl_value_interrupts_oblist = mdl_assoc_find_value(new_assoc_hash, &key);
    if (mdl_value_interrupts_oblist == NULL)
    {
        fprintf(stderr, "INTERRUPTS!- oblist missing in save image");
        return -1;
    }

    // RESTORE is committed after this point -- errors must be fatal
    // fix up the static references
    mdl_value_root_oblist = new_root_oblist;
    mdl_value_initial_oblist = new_initial_oblist;
    mdl_value_oblist = new_mdl_value_atom_oblist;
    atom_oblist = mdl_value_oblist->v.a;
    mdl_value_atom_redefine = mdl_get_or_create_atom_on_oblist("REDEFINE", mdl_value_root_oblist);
    mdl_value_atom_default = mdl_get_or_create_atom_on_oblist("DEFAULT", mdl_value_root_oblist);
    mdl_value_T = mdl_get_or_create_atom_on_oblist("T", mdl_value_root_oblist);
        
    mdl_value_atom_lastprog = mdl_get_or_create_atom_on_oblist("LPROG ", mdl_value_interrupts_oblist);
    mdl_value_atom_lastmap = mdl_get_or_create_atom_on_oblist("LPROG ", mdl_value_interrupts_oblist);
    
    // swap in the new structures
    built_in_table.clear();
    built_in_table.swap(new_built_ins);
    
    mdl_type_table.clear();
    mdl_type_table.swap(new_types);
    
    global_syms.clear();
    global_syms.swap(newglobal);

    initial_frame->syms->clear();
    initial_frame->syms->swap(newlocal);

    mdl_clear_assoc_table(mdl_assoc_table);
    mdl_swap_assoc_table(mdl_assoc_table, new_assoc_hash);

    image_object_list.clear();

    // fix up the channels
    chan_map_t::iterator citer;
    for (citer = chanmap.begin(); citer != chanmap.end(); citer++)
    {
        mdl_value_t *chan = citer->second;
        if (mdl_get_chan_channum(chan) > 2) // 0 is internal/closed, 1/2 are standard ttys
            mdl_internal_reopen_channel(chan);
    }
    chanmap.clear();
    cur_frame = initial_frame;
    initial_frame->result = save_arg;
    fclose(f); // no one else will do it, until channel GC is implemented
#ifdef GC_DEBUG
    GC_gcollect();
#endif
    longjmp(initial_frame->interp_frame, LONGJMP_RESTORE);
    return true;
}
