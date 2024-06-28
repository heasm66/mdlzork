#include <string.h>
#include "macros.hpp"
#include "mdl_internal_defs.h"
#include "mdl_builtins.h"
#include "mdl_builtin_types.h"
void mdl_init_built_in_types()
{
    atom_t *bi_atom;
    mdl_type_table_entry_t tte;
    memset(&tte, 0, sizeof(tte));
    bi_atom = mdl_get_atom_from_oblist("ATOM", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 0;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_ATOM;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("WORD", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 1;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("LIST", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 2;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LIST;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("STRING", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 3;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_STRING;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("VECTOR", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 4;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_VECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("UVECTOR", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 5;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_UVECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("TUPLE", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 6;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_TUPLE;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("FRAME", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 7;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_FRAME;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("ASOC", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 8;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_ASOC;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("BYTES", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 9;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_BYTES;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("OFFSET", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 10;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_OFFSET;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("INTERNAL-TYPE", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 11;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_INTERNAL_TYPE;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOCA", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 12;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LOCA;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOCAS", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 13;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LOCAS;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOCB", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 14;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LOCB;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOCD", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 15;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LOCD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOCL", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 16;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LOCL;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOCR", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 17;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LOCR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOCS", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 18;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LOCS;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOCT", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 19;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LOCT;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOCU", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 20;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LOCU;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOCV", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 21;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LOCV;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("PROCESS", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 22;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_PROCESS;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("STORAGE", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 23;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_STORAGE;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("TEMPLATE", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 24;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_TEMPLATE;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("ACTIVATION", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 25;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_FRAME;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("BITS", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 26;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("CHANNEL", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 27;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_VECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("CHARACTER", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 28;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("CLOSURE", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 29;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LIST;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("CODE", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 30;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_UVECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("DECL", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 31;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LIST;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("DISMISS", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 32;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_ATOM;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("ENVIRONMENT", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 33;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_FRAME;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("FALSE", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 34;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LIST;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("FIX", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 35;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("FLOAT", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 36;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("FORM", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 37;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LIST;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("FSUBR", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 38;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("FUNCTION", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 39;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LIST;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("HANDLER", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 40;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_VECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("IHEADER", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 41;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_VECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("ILLEGAL", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 42;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("INTERNAL-LIST", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 43;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LIST;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LINK", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 44;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_ATOM;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("LOSE", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 45;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("MACRO", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 46;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LIST;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("OBLIST", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 47;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_UVECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("PCODE", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 48;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("PRIMTYPE-C", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 49;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("QUICK-ENTRY", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 50;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_VECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("QUICK-RSUBR", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 51;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_VECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("READA", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 52;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_FRAME;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("RSUBR", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 53;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_VECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("RSUBR-ENTRY", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 54;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_VECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("SEGMENT", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 55;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LIST;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("SPLICE", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 56;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_LIST;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("SUBR", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 57;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("TAG", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 58;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_VECTOR;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_get_atom_from_oblist("TIME", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 59;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("TYPE-C", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 60;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("TYPE-W", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 61;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
    bi_atom = mdl_create_atom_on_oblist("UNBOUND", mdl_value_root_oblist)->v.a;
    bi_atom->typenum = 62;
    tte.a = bi_atom;
    tte.pt = PRIMTYPE_WORD;
    mdl_type_table.push_back(tte);
}
