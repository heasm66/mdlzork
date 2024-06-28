#include <stdio.h>
#include <time.h>
#include <sys/timeb.h>
#include <sys/types.h>
#include "mdl_win32.h"

off_t ftello(FILE* f)
{
  return ftell(f);
}

char* optarg = 0;

int getopt(int argc, char** argv, const char* optstring)
{
  static int i = 1;

  if (argc > i+1)
  {
    if ((argv[i][0] == '-') && (argv[i][1] == optstring[0]))
    {
      optarg = argv[i+1];
      i += 2;
      return optstring[0];
    }
  }
  return -1;
}

int getppid(void)
{
  return 0;
}

unsigned int sleep(unsigned int s)
{
  Sleep(1000*s);
  return 0;
}

void swab(const void* s, void* d, size_t n)
{
  swab((char*)s,(char*)d,(int)n);
}

int getrusage(int, struct rusage*)
{
  return 0;
}

int gettimeofday(struct timeval* t, void*)
{
  struct _timeb tb;
  _ftime(&tb);
  t->tv_sec = tb.time;
  t->tv_usec = tb.millitm*1000;
  return 0;
}

struct tm* gmtime_r(const time_t* t, struct tm* r)
{
  *r = *(gmtime(t));
  return r;
}

struct tm* localtime_r(const time_t* t, struct tm* r)
{
  *r = *(localtime(t));
  return r;
}

void timeradd(struct timeval*, struct timeval*, struct timeval*)
{
}

// 48-bit LCG taken from NewLib

#define _RAND48_SEED_0 0x330e
#define _RAND48_SEED_1 0xabcd
#define _RAND48_SEED_2 0x1234
#define _RAND48_MULT_0 0xe66d
#define _RAND48_MULT_1 0xdeec
#define _RAND48_MULT_2 0x0005
#define _RAND48_ADD    0x000b

unsigned short r48_mult[3];
unsigned short r48_seed[3];
unsigned short r48_add;

long mrand48(void)
{
  unsigned short temp[2];

  unsigned long accu = (unsigned long)r48_mult[0] * (unsigned long)r48_seed[0] + (unsigned long)r48_add;
  temp[0] = (unsigned short)accu;
  accu >>= sizeof(unsigned short) * 8;
  accu += (unsigned long)r48_mult[0] *
    (unsigned long)r48_seed[1] + (unsigned long)r48_mult[1] * (unsigned long)r48_seed[0];
  temp[1] = (unsigned short)accu;
  accu >>= sizeof(unsigned short) * 8;
  accu += r48_mult[0] * r48_seed[2] + r48_mult[1] * r48_seed[1] + r48_mult[2] * r48_seed[0];
  r48_seed[0] = temp[0];
  r48_seed[1] = temp[1];
  r48_seed[2] = (unsigned short)accu;

  return ((long)r48_seed[2] << 16) + (long)r48_seed[1];
}

void srand48(long seed)
{
  r48_seed[0] = _RAND48_SEED_0;
  r48_seed[1] = (unsigned short)seed;
  r48_seed[2] = (unsigned short)((unsigned long)seed >> 16);
  r48_mult[0] = _RAND48_MULT_0;
  r48_mult[1] = _RAND48_MULT_1;
  r48_mult[2] = _RAND48_MULT_2;
  r48_add = _RAND48_ADD;
}

unsigned short* seed48(unsigned short* xseed)
{
  static unsigned short sseed[3];

  sseed[0] = r48_seed[0];
  sseed[1] = r48_seed[1];
  sseed[2] = r48_seed[2];
  r48_seed[0] = xseed[0];
  r48_seed[1] = xseed[1];
  r48_seed[2] = xseed[2];
  r48_mult[0] = _RAND48_MULT_0;
  r48_mult[1] = _RAND48_MULT_1;
  r48_mult[2] = _RAND48_MULT_2;
  r48_add = _RAND48_ADD;

  return sseed;
}
