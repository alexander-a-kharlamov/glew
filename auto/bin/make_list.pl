#!/usr/bin/perl
##
## Copyright (C) 2004, 2003 Marcelo E. Magallon <mmagallo[at]debian org>
## Copyright (C) 2004, 2003 Milan Ikits <milan ikits[at]ieee org>
##
## This program is distributed under the terms and conditions of the GNU
## General Public License Version 2 as published by the Free Software
## Foundation or, at your option, any later version.

use strict;
use warnings;

do 'bin/make.pl';

#---------------------------------------------------------------------------------------

# function pointer definition
sub make_init_call($%)
{
    my $name = prefixname($_[0]);
    return "  r = r || (ctx->" . $name . " = (PFN" . (uc $_[0]) . "PROC)glewGetProcAddress(\"" . $name . "\")) == NULL;";
}

#---------------------------------------------------------------------------------------

my @extlist = ();
my %extensions = ();

if (@ARGV)
{
    @extlist = @ARGV;
} else {
    local $/;
    @extlist = split "\n", (<>);
}

foreach my $ext (sort @extlist)
{
    my ($extname, $exturl, $types, $tokens, $functions, $exacts) = parse_ext($ext);

    my $extvar = $extname;
    $extvar =~ s/GL(X*)_/GL$1EW_/;

    my $extpre = $extname;
    $extpre =~ s/^(W?)GL(X?).*$/\l$1gl\l$2ew/;

    my $pextvar = prefix_varname($extvar);

    print "#ifdef $extname\n";
    print "  ctx->" . $pextvar . "= " . $extpre . "GetExtension((const GLubyte*)\"$extname\");\n";
    if (keys %$functions)
    {
        if ($extname =~ /WGL_.*/)
        {
            print "  if (glewExperimental || ctx->" . $pextvar . "|| crippled) ctx->" . $pextvar . "= !_glewInit_$extname(ctx);\n";
        }
        else
        {
            print "  if (glewExperimental || ctx->" . $pextvar . ") ctx->" . $pextvar . " = !_glewInit_$extname(ctx);\n";
        }
    }
    print "#endif /* $extname */\n";
}
