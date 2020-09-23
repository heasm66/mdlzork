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
$nomoreprims = 0;
open(OLDBI, "<", "mdl_builtins.h") || die "mdl_builtins.h not found";
while (<OLDBI>)
{
    if (/\*mdl_value_builtin_([a-zA-Z_0-9]*)/)
    {
        $oldbi{"atom_$1"} = 1;
    }
}
close(OLDBI);

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
print '#include <string.h>'."\n";
print '#include "macros.hpp"'."\n";
print '#include "mdl_internal_defs.h"'."\n";
print '#include "mdl_builtins.h"'."\n";
print '#include "mdl_builtin_types.h"'."\n";
while(<>)
{
    chomp;
    $comment = "";
    if ( m;(.*?)//(.*); )
    {
        $comment = $2;
        $_ = $1;
    }
    last if /MDL_BUILTIN_TYPE_LAST/;
    $nomoreprims = 1 if /PRIMTYPE_MAX/;
    if (!$nomoreprims && /(?:^| )PRIMTYPE_(.*),/)
    {
        $ptname = $1;
        $atom_name = "atom_".lc($ptname);
        $atom_string = $ptname;
        $atom_string =~ s/_/-/;
#        print HEADER "extern struct atom_t *$atom_name;\n" if $headerout;
        print HEADER "#define MDL_TYPE_$ptname PRIMTYPE_$ptname\n" if $headerout;
        $atom_strings[$#atom_strings + 1] = $atom_string;
        $pt_names[$#pt_names + 1] = $ptname;
        $atom_names[$#atom_names + 1] = $atom_name;
        $btt .= "$indent"."{ PRIMTYPE_$ptname, NULL, NULL, NULL, NULL },\n";
    }
    if (/(?:^| )MDL_TYPE_(\w+)(?: = \w+)?,/)
    {
        $tname = $1;
        $atom_name = "atom_".lc($tname);
        $atom_string = $tname;
        $atom_string =~ s/_/-/;
#        print HEADER "extern struct atom_t *$atom_name;\n" if $headerout;
        $comment=~/([A-Za-z]+)/;
        $ptname = $1;
        $atom_strings[$#atom_strings + 1] = $atom_string;
        $pt_names[$#pt_names + 1] = $ptname;
        $atom_names[$#atom_names + 1] = $atom_name;
        $btt .= "$indent"."{ PRIMTYPE_$ptname, NULL, NULL, NULL, NULL },\n";
    }
}
print HEADER "void mdl_init_built_in_types();\n" if $headerout;
print "void mdl_init_built_in_types()\n";
print "{\n";
print $indent."atom_t *bi_atom;\n";
print $indent."mdl_type_table_entry_t tte;\n";
print $indent."memset(&tte, 0, sizeof(tte));\n";
foreach $i (0..$#atom_names)
{
    $atom_name = $atom_names[$i];
    $atom_string = $atom_strings[$i];
    $pt_name = $pt_names[$i];
#    print $indent."$atom_name = mdl_create_atom_on_oblist(\"$atom_string\", mdl_value_root_oblist)->v.a;\n" unless $oldbi{"$atom_name"};
#    print $indent."$atom_name->typenum = $i;\n";
#    print $indent."tte.a = $atom_name;\n";
    print $indent."bi_atom = mdl_create_atom_on_oblist(\"$atom_string\", mdl_value_root_oblist)->v.a;\n" unless $oldbi{"$atom_name"};
    print $indent."bi_atom = mdl_get_atom_from_oblist(\"$atom_string\", mdl_value_root_oblist)->v.a;\n" if $oldbi{"$atom_name"};
    
    print $indent."bi_atom->typenum = $i;\n";
    print $indent."tte.a = bi_atom;\n";
    print $indent."tte.pt = PRIMTYPE_$pt_name;\n";
    print $indent."mdl_type_table.push_back(tte);\n";
}
print "}\n";

foreach $atom_name (@atom_names)
{
#    print "atom_t *$atom_name;\n" unless $oldbi{"$atom_name"};
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
