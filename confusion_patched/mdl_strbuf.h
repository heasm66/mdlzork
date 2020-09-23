#ifndef MDL_STRBUF_H
#define MDL_STRBUF_H

#ifdef __cplusplus
extern "C" {
#endif
typedef struct mdl_strbuf_t
{
    int stringlen;
    int bufsize;
    char buf[1];
} mdl_strbuf_t;

#define mdl_strbuf_len(b) ((b)->stringlen)
extern mdl_strbuf_t *mdl_new_strbuf(int isize);
extern mdl_strbuf_t *mdl_strbuf_grow(mdl_strbuf_t *buf, int minsize);
extern mdl_strbuf_t *mdl_strbuf_prepend_cstr(const char *cs, mdl_strbuf_t *buf);
extern mdl_strbuf_t *mdl_strbuf_append_cstr(mdl_strbuf_t *buf, const char *cs);
extern mdl_strbuf_t *mdl_strbuf_append_cstr_len(mdl_strbuf_t *buf, const char *cs, int len);
extern mdl_strbuf_t *mdl_strbuf_append_strbuf(mdl_strbuf_t *buf, mdl_strbuf_t *buf2);
extern const char *mdl_strbuf_to_const_cstr(mdl_strbuf_t *buf);
extern char *mdl_strbuf_to_new_cstr(mdl_strbuf_t *buf);

#ifdef __cplusplus
}
#endif

#endif /* MDL_STRBUF_H */
