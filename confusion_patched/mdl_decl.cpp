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

// MDL DECL checking... work in progress
// some errors are wrongly generic at the moment
#define RATOM(X) mdl_get_atom_from_oblist(#X, mdl_value_root_oblist)
#define DECL_ERROR(MSG)                         \
        do { \
            *error = true; \
            return mdl_call_error(MSG, NULL); \
        } while (0)

static mdl_value_t *
mdl_check_struct_decl(mdl_value_t *val, mdl_value_t *decl, bool *error);

mdl_value_t *mdl_check_decl(mdl_value_t *val, mdl_value_t *decl, bool *error)
{
    mdl_value_t *result;
    mdl_value_t *type;
    bool standin;
    int typenum;

    *error = false;
    do
    {
        standin = false;
        if (decl->type == MDL_TYPE_ATOM)
        {
            if (mdl_value_equal(decl, RATOM(ANY)))
                return mdl_value_T;
            if (mdl_value_equal(decl, RATOM(STRUCTURED)))
                return mdl_boolean_value(mdl_primtype_structured(decl->pt));
            if (mdl_value_equal(decl, RATOM(LOCATIVE)))
                return mdl_boolean_value(decl->pt >= PRIMTYPE_LOCA &&
                                         decl->pt <= PRIMTYPE_LOCV);
            if (mdl_value_equal(decl, RATOM(APPLICABLE)))
                return mdl_boolean_value(mdl_type_is_applicable(mdl_apply_type(decl->type)));
            typenum = mdl_get_typenum(decl);
            if (typenum != MDL_TYPE_NOTATYPE)
            {
                if (val->type != typenum)
                {
                    // FIXME: no fancy falses
                    mdl_value_t *f;
                    f = mdl_cons_internal(decl, NULL);
                    f = mdl_cons_internal(val, f);
                    return mdl_make_list(f, MDL_TYPE_FALSE);
                }
                return mdl_boolean_value(val->type == typenum);
            }
            decl = mdl_internal_eval_getprop(decl, RATOM(DECL));
            if (!decl)
                DECL_ERROR("BAD-TYPE-SPECIFICATION1");
            standin = true;
        }
    }
    while (standin);

    if (decl->type == MDL_TYPE_FORM)
    {
        mdl_value_t *firstitem = LITEM(decl, 0);
        if (firstitem == NULL)
            DECL_ERROR("BAD-TYPE-SPECIFICATION2");

        // quoted value
        if (mdl_value_equal(firstitem, RATOM(QUOTE)))
        {
            type = LITEM(decl, 1);
            if (!type || LHASITEM(decl, 2))
                DECL_ERROR("BAD-TYPE-SPECIFICATION3");
            return mdl_boolean_value(mdl_value_equal(val, type));
        }

        // primtype
        if (mdl_value_equal(firstitem, RATOM(PRIMTYPE)))
        {
            int typenum; 

            type = LITEM(decl, 1);
            if (!type)
                DECL_ERROR("EMPTY-OR/PRIMTYPE_FORM");
            if (LHASITEM(decl, 2))
                DECL_ERROR("TOO-MANY-ARGS-TO-PRIMTYPE-DECL");

            if ((typenum = mdl_get_typenum(type)) == MDL_TYPE_NOTATYPE)
                DECL_ERROR("NON-TYPE-FOR-PRIMTYPE-ARG");

            return mdl_boolean_value(val->pt == mdl_type_primtype(typenum));
        }
        // OR
        if (mdl_value_equal(firstitem, RATOM(OR)))
        {
            mdl_value_t *typecursor;

            typecursor = LREST(decl, 1);
            if (!typecursor)
                DECL_ERROR("EMPTY-OR/PRIMTYPE_FORM");
            do
            {
                result = mdl_check_decl(val, typecursor->v.p.car, error);
                if (*error || mdl_is_true(result))
                    return result;
                typecursor = typecursor->v.p.cdr;
            } while (typecursor);
            return result;
        }
        if (firstitem->type == MDL_TYPE_ATOM &&
            (typenum = mdl_get_typenum(firstitem)) != MDL_TYPE_NOTATYPE &&
            mdl_primtype_structured(mdl_type_primtype(typenum)))
        {
            if (val->type != typenum) 
                return &mdl_value_false;
            
            result = mdl_check_struct_decl(val, decl, error);
            return result;
        }
    }
    else if (decl->type == MDL_TYPE_SEGMENT)
    {
        mdl_value_t *firstitem = LITEM(decl, 0);

        if (firstitem->type == MDL_TYPE_ATOM &&
            (typenum = mdl_get_typenum(firstitem)) != MDL_TYPE_NOTATYPE &&
            mdl_primtype_structured(mdl_type_primtype(typenum)))
        {
            if (val->type != typenum) return &mdl_value_false;
            
            result = mdl_check_struct_decl(val, decl, error);
            return result;
        }
    }
    DECL_ERROR("DECL-ELEMENT-NOT-FORM-OR-ATOM");
}

mdl_value_t *
mdl_check_struct_decl(mdl_value_t *val, mdl_value_t *decl, bool *error)
{
    // at this point it is assumed DECL is a FORM or a SEGMENT and 
    // the overall type matches
    mdl_value_t *declcursor = LREST(decl, 1);
    mdl_value_t *valcursor = val;
    mdl_value_t *curval;
    mdl_value_t *curdecl;
    mdl_value_t *curidecl;
    mdl_value_t *result = mdl_value_T;
    mdl_value_t *firstitem;
    bool optfound = false;
    int i,j;
    
    while (declcursor)
    {
        curdecl = declcursor->v.p.car;
        if (curdecl->type == MDL_TYPE_VECTOR)
        {
            if (VLENGTH(curdecl) < 2)
                DECL_ERROR("VECTOR-LESS-THAN-2-ELEMENTS");
            firstitem = VITEM(curdecl, 0);
            if (firstitem->type == MDL_TYPE_FIX)
            {
                if (optfound || firstitem->v.w <= 0)
                    DECL_ERROR("BAD-TYPE-SPECIFICATION4");
                for (i = 0; i < firstitem->v.w; i++)
                {
                    curidecl = VITEM(curdecl, 1);
                    for (j = 1; j < VLENGTH(curdecl); j++)
                    {
                        if (mdl_internal_struct_is_empty(valcursor))
                            return &mdl_value_false;
                        curval = mdl_internal_eval_nth(valcursor, NULL);
                        result = mdl_check_decl(curval, curidecl, error);
                        if (*error || mdl_is_false(result)) return result;
                        valcursor = mdl_internal_eval_rest_i(valcursor, 1);
                        curidecl++;
                    }
                }
            }
            else if (mdl_value_equal(firstitem, RATOM(REST)))
            {
                if (declcursor->v.p.cdr)
                    DECL_ERROR("BAD-TYPE-SPECIFICATION5");
                while (1)
                {
                    curidecl = VITEM(curdecl, 1);
                    for (j = 1; j < VLENGTH(curdecl); j++)
                    {
                        if (mdl_internal_struct_is_empty(valcursor))
                            return result;
                        curval = mdl_internal_eval_nth(valcursor, NULL);
                        result = mdl_check_decl(curval, curidecl, error);
                        if (*error || mdl_is_false(result)) return result;
                        valcursor = mdl_internal_eval_rest_i(valcursor, 1);
                        curidecl++;
                    }
                }
            }
            else if (mdl_value_equal(firstitem, RATOM(OPT)))
            {
                if (optfound)
                    DECL_ERROR("BAD-TYPE-SPECIFICATION6");

                optfound = true;
                curidecl = VITEM(curdecl, 1);
                fprintf(stderr, "O1\n");
                for (j = 1; j < VLENGTH(curdecl); j++)
                {
                    if (mdl_internal_struct_is_empty(valcursor))
                        break;
                    fprintf(stderr, "O2 %d\n", j);
                    curval = mdl_internal_eval_nth(valcursor, NULL);
                    result = mdl_check_decl(curval, curidecl, error);
                    if (*error || mdl_is_false(result)) return result;
                    valcursor = mdl_internal_eval_rest_i(valcursor, 1);
                    curidecl++;
                }
            }
        }
        else
        {
            if (mdl_internal_struct_is_empty(valcursor))
                return &mdl_value_false;
            curval = mdl_internal_eval_nth(valcursor, NULL); // nth(1) by default
            if (optfound)
                DECL_ERROR("BAD-TYPE-SPECIFICATION7");
            result = mdl_check_decl(curval, curdecl, error);
            if (*error || mdl_is_false(result)) return result;
            valcursor = mdl_internal_eval_rest_i(valcursor, 1);
        }
        declcursor = declcursor->v.p.cdr;
    }
    if ((decl->type == MDL_TYPE_SEGMENT) && !mdl_internal_struct_is_empty(valcursor))
        result = &mdl_value_false;
    return result;
}
