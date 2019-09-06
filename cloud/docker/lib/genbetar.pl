#!/usr/bin/perl

# This is a script to create a tar file of relevant folders of BE to post to a Docker image
# It has to be run inside a BE installation.
#

use strict;

my $TEMP_FOLDER = $ARGV[0];
my $BE_HOME = $ARGV[1];

my ($dir, $baseDir, $beDir, $beVer, $asVer, $asDir);

# Current directory from where this script is invoked. Check to see if it is a BE/AS installation
if (! defined $BE_HOME) {
  print "WARN: BE_HOME not provided, using current BE_HOME.\n";
  $dir = `pwd`;
  chomp $dir;
} else {
  print "INFO: BE_HOME $BE_HOME\n";
  $dir = $BE_HOME;
}

# Path upto "be" Eg. if current directory is /opt/tibco/be/5.4 , then /opt/tibco

if ($dir =~ /(.*?)\/(be\/\d\.\d)/) {
  $baseDir = $1;
  $beDir = $2;
  #if ( ! ($beDir =~ /\/$/) ) {
    #$beDir = $beDir."\/";
  #}
} else {
  print "BE folder be/<be-version> not found in the specified BE_HOME $dir, exiting.\n";
  exit 1;
}

# Get BE version eg 5.5
if ($beDir =~ /be\/(\d\.\d)/) {
  $beVer = $1;
  chomp $beVer;
} else {
  print "BE version not found, exiting. \n";
  exit 1;
}

# AS directory /opt/tibco/as
$asDir = $baseDir."/as";

my $AS_FOUND = 1; #Set it to 0 if AS is not found
# Check if AS directory exists
if ( ! (-e $asDir and -d $asDir)) {
  print "WARN: AS installation not found.\n";
  $AS_FOUND = 0;
}

if ($AS_FOUND==1) {
  # Get AS version
  $asVer = `ls $asDir`;
  chop $asVer;
  
  # as/X.Y where X.Y is the version as determined above
  $asDir = "as/".$asVer;
  
  if (!($asDir =~ /as\/(\d\.\d)/)) {
    $AS_FOUND = 0;
	print "WARN: AS installation not found.\n";
  }
}


print "BASEDIR     : $baseDir\n";
print "BE_DIR      : $beDir\n";
print "BE_VERSION  : $beVer\n";
if ($AS_FOUND==1) {
  print "AS_DIR      : $asDir\n";
  print "AS_VERSION  : $asVer\n";
}

my $DOCKER_BIN_DIR = "$TEMP_FOLDER";
#Create a TAR file of relevant folders
my $TARCMD = "tar -C $baseDir -cf $DOCKER_BIN_DIR/be.tar tibcojre64 $beDir/lib $beDir/bin $beDir/cloud/docker/lib $beDir/teagent $beDir/mm";
if ($AS_FOUND==1) {
  $TARCMD = "$TARCMD $beDir/rms $beDir/studio $beDir/eclipse-platform $beDir/examples/standard/WebStudio $asDir/lib $asDir/bin ";
  if (-e "$asDir/hotfix" and -d "$asDir/hotfix") {
    $TARCMD = "$TARCMD $asDir/hotfix";
  }
}
execCmd ($TARCMD);

#Add hotfix folders if present
if (-e "$beDir/hotfix"){
        $TARCMD = "tar -C $baseDir -rf $DOCKER_BIN_DIR/be.tar  $beDir/hotfix";
        execCmd ($TARCMD);
}

# Exract it, so that we can replace baseDir to /opt/tibco for preparation to copy into the image

# Create a temporary directory $tempLocation to extract the tar file
my $tempLocation = randomName();
`mkdir $DOCKER_BIN_DIR/$tempLocation`;

# Exract it
$TARCMD = "tar -C $DOCKER_BIN_DIR/$tempLocation -xf $DOCKER_BIN_DIR/be.tar";
execCmd ($TARCMD);

# Replace occurances of baseDir to /opt/tibco in the files in the untarred area
print "Replacing base directory in the files from $baseDir to /opt/tibco\n";

my $REGEX_CUSTOM_CP = 'tibco\.env\.CUSTOM_EXT_PREPEND_CP=.*';
my $VALUE_CUSTOM_CP = 'tibco.env.CUSTOM_EXT_PREPEND_CP=\/opt\/tibco\/be\/ext';

my $srch = $baseDir;
$srch =~ s/\//\\\//g;
my $repl = '\/opt\/tibco';

# Replace in TRA files using find, xargs, sed -i
my $FINDRPLCMD = "find $DOCKER_BIN_DIR/$tempLocation -name '*.tra' -print0 | xargs -0 sed -i.bak  's/$srch/$repl/g'";
execCmd ($FINDRPLCMD); 

# Replace in CDD files using find, xargs, sed -i
$FINDRPLCMD = "find $DOCKER_BIN_DIR/$tempLocation -name '*.cdd' -print0 | xargs -0 sed -i.bak  's/$srch/$repl/g'";
execCmd ($FINDRPLCMD);

# Replace in TRA files using find, xargs, sed -i
my $FINDRPLCMD = "find $DOCKER_BIN_DIR/$tempLocation -name '*.tra' -print0 | xargs -0 sed -i.bak  's/$REGEX_CUSTOM_CP/$VALUE_CUSTOM_CP/g'";
execCmd ($FINDRPLCMD);

# Replace in be props file files using find, xargs, sed -i
$FINDRPLCMD = "find $DOCKER_BIN_DIR/$tempLocation -name 'be-teagent.props' -print0 | xargs -0 sed -i.bak 's/$srch/$repl/g'";
execCmd ($FINDRPLCMD);

# Replace in be props file files using find, xargs, sed -i
$FINDRPLCMD = "find $DOCKER_BIN_DIR/$tempLocation -name 'log4j.properties' -print0 | xargs -0 sed -i.bak 's/$srch/$repl/g'";
execCmd ($FINDRPLCMD);

# Remove the annotations file
my $RMCMD = "rm $DOCKER_BIN_DIR/$tempLocation/$beDir/bin/_annotations.idx";
if (-e "$DOCKER_BIN_DIR/$tempLocation/$beDir/bin/_annotations.idx") {
  execCmd ($RMCMD);
}
# TODO: generate annotations idx.

# Append JMX port at the end of the TRA files
$FINDRPLCMD = "find $DOCKER_BIN_DIR/$tempLocation -name '*.tra' -print0 | xargs -0 sed -i.bak  '\$a\\
'java.property.be.engine.jmx.connector.port=%jmx_port%''";
execCmd ($FINDRPLCMD);

# Re-create TAR file
$TARCMD = "tar -C $DOCKER_BIN_DIR/$tempLocation -cf $DOCKER_BIN_DIR/be.tar be tibcojre64";
if ($AS_FOUND==1) {
  $TARCMD = "tar -C $DOCKER_BIN_DIR/$tempLocation -cf $DOCKER_BIN_DIR/be.tar as be tibcojre64";
}
execCmd ($TARCMD);

# Remove temp dir that we created
if ( -e "$DOCKER_BIN_DIR/$tempLocation" and -d "$DOCKER_BIN_DIR/$tempLocation" ) {
  if ($tempLocation ne "") { # extra check to ensure we only delete the temp folder
    `rm -rf $DOCKER_BIN_DIR/$tempLocation`;
  }
}

print "Done..\n";

# Return a 0 code indicating success
0;

#
# Function to return a random string
#
sub randomName () {
  my @chars = ("A".."Z", "a".."z");
  my $string;
  $string .= $chars[rand @chars] for 1..8;
  my $dtm = time;
  $string.$dtm;
}

#
# Function to execute a shell script that exits upon error
# arg[0] : Command string to execute
# return : return status of the command
# exits perl script if error (equiv to set -e)
#
sub execCmd {
  my ($cmd) = @_;
  print "$cmd\n";
  my $res = system($cmd);
  if ($res != 0) {
    $res = $res >> 8;
    print "$res\n";
    exit $res;
  }
  $res;
}
