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

sub prepare_delete_list{
    my $optimize_for_modules = shift;
    my $delete_file_name = shift;
    my @required_modules = split(/,/, $optimize_for_modules);
    my @all_modules = get_all_modules();
    open(DELETELISTFILE, '>', $delete_file_name) or die $!;
    
    # process optimize.json -> "modules" section
    foreach my $m (@all_modules) {
        my $append_to_deletefile = 1;   # 1: append, 0: dont append
        foreach my $rm (@required_modules) {
            if ($m eq $rm) {
                $append_to_deletefile = 0;
                last;
            }
        }
        if ($append_to_deletefile) {
            my @deps = get_deps_by_module($m);
            foreach my $d (@deps) {
                print DELETELISTFILE "$d\n";
            }
        }
    }

    # process optimize.json -> "dependencies" section
    my @all_deps = get_all_deps();
    foreach my $d (@all_deps) {
        my $append_to_deletefile = 1;   # 1: append, 0: dont append
        my @modules = get_modules_by_dep($d);
        foreach my $m (@modules) {
            foreach my $rm (@required_modules) {
                if ($m eq $rm) {
                    $append_to_deletefile = 0;
                    last;
                }
            }
            if (!$append_to_deletefile) {
                last;
            }
        }
        if ($append_to_deletefile) {
            print DELETELISTFILE "$d\n";
        }
    }

    close(DELETELISTFILE);
}

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
    my @MODULES_DATA = $OPTIMIZE_DATA =~ /"modules":\s*(\{[\s\S]*\}),\s*"dependencies"/g;
    my @modules = @MODULES_DATA[0] =~ /\s*"(\S*)":\s*\[/g;
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
        @deps = $1 =~ /"([\w.\/*-]*)",?/g;
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

sub get_all_deps{
    my $OPTIMIZE_DATA = `cat ./lib/optimize.json`;
    my @DEPS_DATA = $OPTIMIZE_DATA =~ /"dependencies":\s*(\{[\s\S]*\})\s*\}/g;
    my @deps = @DEPS_DATA[0] =~ /\s*"(\S*)":\s*\[/g;
    return sort(@deps);
}

sub get_modules_by_dep{
    my $dep_name = shift;
    $dep_name =~ s/\*/\\\*/g;
    $dep_name =~ s/\./\\\./g;
    $dep_name =~ s/\//\\\//g;
    my $OPTIMIZE_DATA = `cat ./lib/optimize.json`;
    my $modulessregex = '\s*"'.$dep_name.'":\s*\[([\w\s"\/.\-\,*]*)\]\s*';
    my @modules;
    if ($OPTIMIZE_DATA =~ /$modulessregex/) {
        @modules = $1 =~ /"([\w.\/*-]*)",?/g;
    }
    return @modules;
}

sub parse_optimize_modules{
    my $arg_optimize_for = shift;
    my $arg_cdd_file = shift;
    my @modules = split(/,/, $arg_optimize_for);

    if ($arg_cdd_file ne "na") {
        my @modules_from_cdd = get_modules_from_cdd($arg_cdd_file);
        push(@modules, @modules_from_cdd);
    }

    @modules = sort(@modules);
    @modules = unique(@modules);
    my $result = join(",", @modules);
    return $result;
}

sub get_modules_from_cdd{
    my $arg_cdd_file = shift;
    my $CDD_DATA = `cat $arg_cdd_file`;
    my @modules = ();
    
    # XPATH="provider/type"
    my @cluster_manager = $CDD_DATA =~ /<provider>[\s\S]*<type>(.*)<\/type>[\s\S]*<\/provider>/g;
    if (@cluster_manager[0] eq "AS2x") {
        push(@modules, "as2");
    } elsif (@cluster_manager[0] eq "Ignite") {
        push(@modules, "ignite");
    } elsif (@cluster_manager[0] eq "FTL") {
        push(@modules, "ftl");
    }

    # XPATH="object-management/cache-manager/type"
    my @object_manager = $CDD_DATA =~ /<cache-manager>\s*<type>(\w*)<\/type>/g;
    if (@object_manager[0] eq "AS2x") {
        push(@modules, "as2");
    } elsif (@object_manager[0] eq "Ignite") {
        push(@modules, "ignite");
    }

    # XPATH="object-management/cache-manager/backing-store/persistence-option"
    my @persistence_option = $CDD_DATA =~ /<backing-store>[\s\S]*<persistence-option>(.*)<\/persistence-option>/g;
    if (@persistence_option[0] eq "Store") {
        push(@modules, "store");
        # XPATH="object-management/cache-manager/backing-store/type"
        my @backing_store = $CDD_DATA =~ /<object-management>[\s\S]*<cache-manager>[\s\S]*<backing-store>[\s\S]*<type>(.*)<\/type>[\s\S]*<\/backing-store>[\s\S]*<\/cache-manager>[\s\S]*<\/object-management>/g;
        if (@backing_store[0] eq "SQL Server") {
            push(@modules, "sqlserver");
        } elsif (@backing_store[0] eq "Cassandra") {
            push(@modules, "cassandra");
        } elsif (@backing_store[0] eq "ActiveSpaces") {
            push(@modules, "as4");
        }
    }

    # XPATH="object-management/store-manager/type"
    my @store_provider = $CDD_DATA =~ /<object-management>[\s\S]*<store-manager>[\s\S]*<type>(.*)<\/type>[\s\S]*<\/store-manager>[\s\S]*<\/object-management>/g;
    if (@store_provider[0] eq "Cassandra") {
        push(@modules, "store");
        push(@modules, "cassandra");
    } elsif (@store_provider[0] eq "ActiveSpaces") {
        push(@modules, "store");
        push(@modules, "as4");
    }

    # XPATH="app-metrics-config/store-provider/type"
    my @metrics_store_provider = $CDD_DATA =~ /<app-metrics-config>[\s\S]*<store-provider>[\s\S]*<type>(.*)<\/type>[\s\S]*<\/store-provider>[\s\S]*<\/app-metrics-config>/g;
    if (@metrics_store_provider[0] eq "LDM") {
        push(@modules, "liveview");
    } elsif (@metrics_store_provider[0] eq "InfluxDB") {
        push(@modules, "influx");
    }

    # XPATH="telemetry-config/sampler"
    my @telemetry_sampler = $CDD_DATA =~ /<telemetry-config>[\s\S]*<sampler>(.*)<\/sampler>[\s\S]*<\/telemetry-config>/g;
    if ((@telemetry_sampler[0] ne "") and (@telemetry_sampler[0] ne "always_off")) {
        push(@modules, "opentelemetry");
    }

    return @modules;
}

sub unique{
    my %datamap;
    my @result = ();
    foreach my $i (@_) {
        if (! %datamap{$i} ) {
            push @result, $i;
            $datamap{$i} = 1;
        }
    }
    return @result;
}

1;
