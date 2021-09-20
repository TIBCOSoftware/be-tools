#!/usr/bin/perl 

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

package be_container_optimize;

use strict;
local $/ ;

my $OPTIMIZE_DATA = "";
my $SPACE_SEP_DATA = "";

sub print_all_deps{
    my @modules = get_all_modules();
    my $modules_count = @modules;
    print "TOTAL NUMBER OF MODULES: $modules_count\n";
    foreach (@modules) {
        print "====================\n";
        print "Module[$_]\n";
        print "====================\n";
        my @deps = get_deps_by_module($_);
        foreach (@deps) {
            print "$_\n";
        }
    }
}

sub print_all_deps_summary{
    my @modules = get_all_modules();
    my $modules_count = @modules;
    my $total_deps_count = 0;
    print "\t==========\t\t==============\n";
    print "\tMODULE\t\t\tDPENDENCIES(#)\n";
    print "\t==========\t\t==============\n";
    foreach (@modules) {
        my @deps = get_deps_by_module($_);
        my $deps_count = @deps;
        $total_deps_count += $deps_count;
        print "\t$_\t\t\t$deps_count\n"
    }
    print "\nTOTAL NUMBER OF MODULES:\t $modules_count";
    print "\nTOTAL NUMBER OF DEPENDENCIES:\t $total_deps_count\n\n";
}

sub get_all_modules{
    my $OPTIMIZE_DATA = `cat ./lib/optimize.json`;
    my @modules = $OPTIMIZE_DATA =~ /\s*"(\S*)":\s*\[/g;
    return sort(@modules);
}

sub get_all_modules_print_friendly{
    my @modules = get_all_modules();
    my $result = join(", ", @modules[0..$#modules-1]);
    $result = "$result & @modules[$#modules]";
    return $result;
}

sub get_all_modules_spacesep{
    my @modules = get_all_modules();
    for my $d (@modules) {
        $SPACE_SEP_DATA="$d $SPACE_SEP_DATA";
    }
    return $SPACE_SEP_DATA
}

sub get_deps_by_module{
    my $module_name = shift;
    my $OPTIMIZE_DATA = `cat ./lib/optimize.json`;
    my $depsregex = '\s*"'.$module_name.'":\s*\[([\w\s"\/.\-\,*]*)\]\s*';
    my @deps;
    if ($OPTIMIZE_DATA =~ /$depsregex/) {
        @deps = $1 =~ /("[\w.\/*-]*"),?/g;
    }
    return @deps;
}

sub get_deps_by_module_spacesep{
    my $module_name = shift;
    my @files = get_deps_by_module($module_name);
    for my $d (@files) {
        $SPACE_SEP_DATA="$d $SPACE_SEP_DATA";
    }
    return $SPACE_SEP_DATA
}

1;
