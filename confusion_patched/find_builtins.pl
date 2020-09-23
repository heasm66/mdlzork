#   'Confusion', a MDL intepreter
#   Copyright 2009 Matthew T. Russotto
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, version 3 of 29 June 2007.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

$indent="    ";
print '#include <string.h>'."\n";
print '#include "mdl_builtin_macro.hpp"'."\n";
print '#include "mdl_builtins.h"'."\n";
print '#include "mdl_internal_defs.h"'."\n";
print "void mdl_create_builtins()\n{\n";
if ($#ARGV > -1)
{
    $headerout = shift @ARGV;
    if (-r $headerout)
    {
        $headerbackup = $headerout.".bak";
        undef $headerbackup if (!rename($headerout, $headerbackup));
    }
    open(HEADER, ">", $headerout) || die "Couldn't open $headerout";
}
while (<>)
{
    last if m;BEGIN BUILT-INS;;
}
while (<>)
{
    if (/\*(mdl_builtin_eval_([A-Za-z0-9_]*))\(/)
    {
        $procname = $1;
        $biname = $2;
        $atomname = uc($biname);
        $proctype = "SUBR";
        $nl = <>;
        if ($nl =~ m;/\* ([-A-Z0-9?_]+)\s+([^ \n\ta-z(){}\[\]]+)?\s*\*/;)
        {
            $proctype = $1;
            $atomname = $2 if $2;
        }
#        print HEADER "extern atom_t *atom_$biname;\n"  if $headerout;
        print HEADER "extern mdl_value_t *mdl_value_builtin_$biname;\n"  if $headerout;
        $bi_names[$#bi_names+1] = "$biname";
        print $indent."MDL_BUILTIN($atomname, $biname, $proctype, $procname);\n";
    }
}
print "}\n";
foreach $biname (@bi_names)
{
#    print "atom_t *atom_$biname;\n";
    print "mdl_value_t *mdl_value_builtin_$biname;\n";
}
if ($headerout)
{
    close(HEADER);
    if ($headerbackup)
    {
        $cmpresult = system { "cmp" } "cmp", "-s", $headerout, $headerbackup;
#        print STDERR "cmpresult = $cmpresult";
#        print STDERR "headers are identical\n" if (!$cmpresult);
        rename($headerbackup, $headerout) unless $cmpresult;
        unlink $headerbackup;
        
    }
}
