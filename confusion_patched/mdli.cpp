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
#include <stdio.h>
#include <stdlib.h>
#include <gc/gc.h>
#include "macros.hpp"
#include "mdl_internal_defs.h"
#include <set>
#include <string>
#ifdef _WIN32
#include "mdl_win32.h"
#else
#include <unistd.h>
#endif

using namespace std;

const char copyright_notice[] = 
    "Welcome to 'Confusion', a MDL interpreter.\n"
    "Copyright 2009 Matthew T. Russotto"
    "\nThis program comes with ABSOLUTELY NO WARRANTY; for details type <WARRANTY>.\n"
    "This is free software, and you are welcome to distribute under certain conditions; type <COPYING> for details\n";

extern const char no_warranty[] = "THERE IS NO WARRANTY FOR THIS PROGRAM, TO THE EXTENT PERMITTED BY\n"
"APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT\n"
 "HOLDERS AND/OR OTHER PARTIES PROVIDE THIS PROGRAM \"AS IS\" WITHOUT WARRANTY\n"
 "OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,\n"
 "THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR\n"
 "PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM\n"
 "IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF\n"
 "ALL NECESSARY SERVICING, REPAIR OR CORRECTION.";

int main(int argc, char *argv[])
{
    static const char *optstring = "r:";
    int optchar;
    FILE * restorefile = NULL;

    GC_INIT();
    mdl_interp_init();

    while ((optchar = getopt(argc, argv, optstring)) != -1)
    {
        switch (optchar)
        {
        case 'r':
            restorefile = fopen(optarg, "rb");
            if (!restorefile) 
            {
                fprintf(stderr, "Couldn't open restore file %s", optarg);
                exit(-1);
            }
            break;
        }
    }
        
//    mdl_rep_loop();
    puts(copyright_notice);
    mdl_toplevel(restorefile);
}
