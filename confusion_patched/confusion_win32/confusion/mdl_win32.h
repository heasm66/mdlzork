#include <stdio.h>
#include <direct.h>
#include <io.h>
#include <malloc.h>
#include <stdlib.h>
#include <sys/types.h>

#define WIN32_LEAN_AND_MEAN
#include <winsock2.h>

#define _longjmp longjmp
#define RUSAGE_SELF 0

typedef __int64 int64_t;
typedef unsigned __int64 uint64_t;
typedef __int64 intmax_t;
typedef unsigned __int64 uintmax_t;

struct rusage
{
  struct timeval ru_utime;
  struct timeval ru_stime;
};

extern char* optarg;

off_t ftello(FILE*);
int getopt(int, char**, const char*);
int getppid(void);
unsigned int sleep(unsigned int);
void swab(const void*, void*, size_t);

int getrusage(int, struct rusage*);
int gettimeofday(struct timeval*, void*);
struct tm* gmtime_r(const time_t*, struct tm*);
struct tm* localtime_r(const time_t*, struct tm*);
void timeradd(struct timeval*, struct timeval*, struct timeval*);

long mrand48(void);
void srand48(long);
unsigned short* seed48(unsigned short*);
