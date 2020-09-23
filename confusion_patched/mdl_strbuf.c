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
#include <string.h>
#include <assert.h>
#include "mdl_strbuf.h"

mdl_strbuf_t *mdl_new_strbuf(int isize)
{
    mdl_strbuf_t *result;
    result = (mdl_strbuf_t *)GC_MALLOC_ATOMIC(sizeof(mdl_strbuf_t) + isize - 1);
    result->stringlen = 0;
    result->bufsize = isize;
    result->buf[0] = '\0';
    return result;
}

mdl_strbuf_t *mdl_strbuf_grow(mdl_strbuf_t *buf, int minsize)
{
    int newsize = buf->bufsize;

    while (newsize > 0 && newsize < minsize)
        newsize <<= 1;
    assert (newsize > 0);
    buf = (mdl_strbuf_t *)GC_REALLOC(buf, sizeof(mdl_strbuf_t) + newsize - 1);
    buf->bufsize = newsize;
    return buf;
}

mdl_strbuf_t *mdl_strbuf_append_cstr(mdl_strbuf_t *buf, const char *cs)
{
    return mdl_strbuf_append_cstr_len(buf, cs, strlen(cs));
}

mdl_strbuf_t *mdl_strbuf_append_cstr_len(mdl_strbuf_t *buf, const char *cs, int clen)
{
    if ((clen + buf->stringlen + 1) > buf->bufsize)
    {
        buf = mdl_strbuf_grow(buf, (clen + buf->stringlen + 1));
    }
    memcpy(buf->buf + buf->stringlen, cs, clen);
    buf->stringlen += clen;
    buf->buf[buf->stringlen] = '\0';
    return buf;
}

mdl_strbuf_t *mdl_strbuf_append_strbuf(mdl_strbuf_t *buf, mdl_strbuf_t *buf1)
{
    if ((buf1->stringlen + buf->stringlen + 1) > buf->bufsize)
    {
        buf = mdl_strbuf_grow(buf, (buf1->stringlen + buf->stringlen + 1));
    }
    memcpy(buf->buf + buf->stringlen, buf1->buf, buf1->stringlen + 1);
    buf->stringlen += buf1->stringlen;
    return buf;
}

mdl_strbuf_t *mdl_strbuf_prepend_cstr_len(const char *cs, int clen, mdl_strbuf_t *buf)
{
    if ((clen + buf->stringlen + 1) > buf->bufsize)
    {
        int newsize;
        mdl_strbuf_t *nbuf;

        newsize = buf->bufsize;
        while (newsize > 0 && newsize < (clen + buf->stringlen + 1))
            newsize <<= 1;
        assert(newsize > 0);
        
        nbuf = mdl_new_strbuf(newsize);
        nbuf->stringlen = (clen + buf->stringlen + 1);
        memcpy(nbuf->buf, cs, clen);
        memcpy(nbuf->buf + clen, buf->buf, buf->stringlen);
        nbuf->buf[nbuf->stringlen] = '\0';
        return nbuf;
    }
    memmove(buf->buf + clen, buf->buf, buf->stringlen + 1);
    memcpy(buf->buf, cs, clen);
    buf->stringlen += clen;
    return buf;
}

mdl_strbuf_t *mdl_strbuf_prepend_cstr(const char *cs, mdl_strbuf_t *buf)
{
    return mdl_strbuf_prepend_cstr_len(cs, strlen(cs), buf);
}

const char *mdl_strbuf_to_const_cstr(mdl_strbuf_t *buf)
{
    return (const char *)buf->buf;
}

char *mdl_strbuf_to_new_cstr(mdl_strbuf_t *buf)
{
    char * result = (char *)GC_MALLOC_ATOMIC(buf->stringlen + 1);
    memcpy(result, buf->buf, buf->stringlen + 1);
    return result;
}
