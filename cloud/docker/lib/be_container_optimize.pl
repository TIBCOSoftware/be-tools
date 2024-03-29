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
my $CDD_DATA = "";
my $CHANNEL_DATA = "";

# use this var for identifying os type
my $INPUT_VAR1 = shift;
my $INPUT_VAR2 = shift;
my $INPUT_VAR3 = shift;
my $INPUT_VAR4 = shift;
my $INPUT_VAR5 = shift;

if ("$INPUT_VAR1" eq "win"){
    $OPTIMIZE_DATA = `type .\\lib\\optimize.json`;
}else{
    $OPTIMIZE_DATA = `cat ./lib/optimize.json`;
}

if ("$INPUT_VAR2" eq "printfriendly"){
    print get_all_modules_print_friendly();
}
if ("$INPUT_VAR2" eq "createfile"){
    prepare_delete_list("$INPUT_VAR4",".\\$INPUT_VAR3");
}
if ("$INPUT_VAR2" eq "readcdd"){
    print parse_optimize_modules("$INPUT_VAR3","$INPUT_VAR4","$INPUT_VAR5");
}

sub prepare_delete_list{
    my $optimize_for_modules = shift;
    my $delete_file_name = shift;
    my @required_modules = split(/,/, $optimize_for_modules);
    @required_modules = unique(@required_modules);
    my @all_modules = get_all_modules();
    open(DELETELISTFILE, '>>', $delete_file_name) or die $!;
    
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

sub get_all_modules{
    my @MODULES_DATA = $OPTIMIZE_DATA =~ /"modules":\s*(\{[\s\S]*\}),\s*"dependencies"/g;
    my @modules = @MODULES_DATA[0] =~ /\s*"(\S*)":\s*\[/g;
    return sort(@modules);
}

sub get_all_modules_print_friendly{
    my @all_modules = get_all_modules();
    # remove module "java" from the list
    my @modules = ();
    foreach my $m (@all_modules) {
        if ($m ne "java") {
            push(@modules, $m);
        }
    }
    my $result = join(", ", @modules[0..$#modules-1]);
    $result = "$result & @modules[$#modules]";
    return $result;
}

sub get_deps_by_module{
    my $module_name = shift;
    my $depsregex = '\s*"'.$module_name.'":\s*\[([\w\s"\/.\-\,*]*)\]\s*';
    my @deps;
    if ($OPTIMIZE_DATA =~ /$depsregex/) {
        @deps = $1 =~ /"([\w.\/*-]*)",?/g;
    }
    return @deps;
}

sub get_all_deps{
    my @DEPS_DATA = $OPTIMIZE_DATA =~ /"dependencies":\s*(\{[\s\S]*\})\s*\}/g;
    my @deps = @DEPS_DATA[0] =~ /\s*"(\S*)":\s*\[/g;
    return sort(@deps);
}

sub get_modules_by_dep{
    my $dep_name = shift;
    $dep_name =~ s/\*/\\\*/g;
    $dep_name =~ s/\./\\\./g;
    $dep_name =~ s/\//\\\//g;
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
    
    my $arg_ear_file = shift;
    if ($arg_ear_file ne "na") {
        my $channellistresult =  get_modules_from_ear($arg_ear_file,$arg_cdd_file);
        if ($channellistresult ne "") {
            if ($arg_optimize_for ne "") {
                $arg_optimize_for = join(",",$arg_optimize_for,$channellistresult)
            } else {
                $arg_optimize_for = $channellistresult
            }
        }
    }

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

    if ("$INPUT_VAR1" eq "win"){
        $CDD_DATA = `type $arg_cdd_file`;
    } else {
        $CDD_DATA = `cat $arg_cdd_file`;
    }
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

sub get_modules_from_ear{
    my $arg_ear_file = shift;
    my $arg_cdd_file = shift;
    my @cnuris = ();
    
    if ("$INPUT_VAR1" eq "win"){
        $CDD_DATA = `type $arg_cdd_file`;
    } else {
        $CDD_DATA = `cat $arg_cdd_file`;
    }

    my @agentClassesData = $CDD_DATA =~ /<agent-classes>[\s\S](.*?)[\s\S]<\/agent-classes>/s;
    my @destinationtags = @agentClassesData[0] =~ /<destinations>(.*?)<\/destinations>/sg;

    foreach my $dt (@destinationtags) {
        # added below for direct destination group in agent class section under cdd
        my @cnuridirectdest = $dt =~ /<uri>(.*)<\/uri>/g;
        foreach my $dt1 (@cnuridirectdest) {
            push(@cnuris, (split '\/',$dt1)[-1]);
        }
        my @refTags = $dt =~ /<ref>(.*?)<\/ref>/sg;
        foreach my $rftag (@refTags) {
            if ($rftag ne "") {
                my @cnurimatches = $CDD_DATA =~ /<destination-groups>.*<destinations id="$rftag">(.*?)<\/destinations>.*<\/destination-groups>/gs;
                if (@cnurimatches[0] ne ""){
                    $dt = @cnurimatches[0];
                }
            }
            my @cnuri = $dt =~ /<uri>(.*)<\/uri>/g;
            foreach my $eachcnuri (@cnuri) {
                push(@cnuris, (split '\/',$eachcnuri)[-1]);
            }
        }
    }

    my $randnum = int(rand(1000000)) ;
    my @channels = ();
    my @channelfiles = ();

    if ("$INPUT_VAR1" eq "win"){
        my $wincmd1=`mkdir C:\\tmp\\$randnum\\channelsdata && "C:\\Program Files\\7-Zip\\7z.exe"  e $arg_ear_file -oC:\\tmp\\$randnum &&  "C:\\Program Files\\7-Zip\\7z.exe"  e "C:\\tmp\\$randnum\\Shared Archive.sar" -oC:\\tmp\\$randnum\\channelsdata `;
        my @checkFile =split "\n", `if exist  C:\\tmp\\$randnum\\channelsdata\\*.channel  echo exists`;
        if (@checkFile[0] eq "exists"){
            @channelfiles=split "\n", `dir  C:\\tmp\\$randnum\\channelsdata\\*.channel /s /b /o`;
        }
    } else {
        my $Command_1_extract=`mkdir -p /tmp/$randnum/channelsdata ; unzip -o $arg_ear_file -d /tmp/$randnum ; unzip -o "/tmp/$randnum/Shared Archive.sar" -d /tmp/$randnum/channelsdata `;
        if (-e "/tmp/$randnum/channelsdata/Channels")
        {
            @channelfiles=`ls /tmp/$randnum/channelsdata/Channels/*.channel`;
        }
    }

    foreach my $cf (@channelfiles) {
        if ("$INPUT_VAR1" eq "win"){
            $CHANNEL_DATA = `type $cf`;
        } else {
            $CHANNEL_DATA = `cat $cf`;
        }
        my @channelName = $CHANNEL_DATA =~ /driverTypeName="(.*?)"/;
        if ((@channelName[0] ne "")) {
            my @channelUriNames = $CHANNEL_DATA =~ /destinations.*name="(.*?)".*\>/g;
            if ((@channelUriNames[0] ne "")) {
                my $addtochannels = "false";
                foreach my $cun (@channelUriNames) {
                    if ($addtochannels eq "true"){
                        last;
                    }
                    foreach my $cddCuri (@cnuris) {
                        if ($cddCuri eq $cun ){
                            $addtochannels = "true";
                            my $cName = lc(@channelName[0]);
                            if ($cName eq "activespaces"){
                                $cName = "as4";
                            } elsif ($cName eq "legacy activespaces") {
                                $cName = "as2";
                            } elsif ($cName eq "kafka streams") {
                                $cName = "kafka";
                            }
                            push(@channels, $cName);
                            last;
                        }
                    }
                }
            }
        }
    }

    if ("$INPUT_VAR1" eq "win"){
        my $Command_1_extract=`rmdir /s /q C:\\tmp\\$randnum`;
    } else {
        my $Command_1_extract=`rm -rf /tmp/$randnum`;
    }

    my $channelList = "" ;

    if (@channels == 1){
        $channelList = @channels[0] ;
    } elsif (@channels > 1) {
        $channelList = join(",",@channels) ;
    }

    return $channelList;
}

sub unique{
    my %datamap;
    my @result = ();
    foreach my $i (@_) {
        if (! $datamap{$i} ) {
            push @result, $i;
            $datamap{$i} = 1;
        }
    }
    return @result;
}

1;
