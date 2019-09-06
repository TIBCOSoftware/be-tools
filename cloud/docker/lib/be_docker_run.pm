#!/usr/bin/perl 

package be_docker_run;

use strict;
local $/ ;

my $DEBUG_ENABLE      = 0; #Set it to 1 to enable debug logs
my $GV_GROUP_DELIMITER ="_gv_";
my $BE_GV_GROUP_DELIMITER="/";
sub makeBeProps{
  
  my $fileName        = shift;
  my $propDirectory   = shift;
  my $beHome          = shift;
  
  
  my $beHomeRegex1	= "([\\s\\S]*=)([\\s\\S]*?\/be\/[\\d].[\\d]\/)([\\s\\S]*)";
  
  my $beHomeRegex2	= "([\\s\\S]*=)([\\s\\S]*?\\\\be\\\\[\\d].[\\d]\\\\)([\\s\\S]*)";
  
  
  open(my $fh, '>', $fileName);

  #Get the Enviroment Variable value for delimitor
  foreach my $env (keys %ENV) {
    my $value = $ENV{$env};
     if($env eq "GV_GROUP_DELIMITER"){
    	$GV_GROUP_DELIMITER=$value;
     }
  }
  #Process the environment variables without $GV_GROUP_DELIMITER
  my %envMap;
  foreach my $env (keys %ENV) {
    	if($env ne "GV_GROUP_DELIMITER" && $env  !~ m/$GV_GROUP_DELIMITER/){
		$envMap{$env}=$ENV{$env};
        }
   }
 #Process the environment variables with $GV_GROUP_DELIMITER
 foreach my $env (keys %ENV) {
    	if($env ne "GV_GROUP_DELIMITER" && $env  =~ m/$GV_GROUP_DELIMITER/){
 		my $value = $ENV{$env};
                $env=~ s/$GV_GROUP_DELIMITER/$BE_GV_GROUP_DELIMITER/g;
		$envMap{$env}=$value;
        }
   }

  foreach my $env (keys %envMap) {
    my $value = $envMap{$env};
    if ($value eq "localhost") {
      $value = `hostname`;
      chomp $value;
    }
   #Added code to exclude adding prefix 'tibco.clientVar' for environment variable prefixed with "tra"
   if($env  =~ /^tra/){
	 print $fh "$env=$value\n";    	
    }else{
	 print $fh "tibco.clientVar.$env=$value\n";
    }   
  }

  print $fh "\n-----------------\n";

  #Merging prop files
  my (@propFiles) = glob "$propDirectory/*.props";

  if(scalar @propFiles > 0){
    for my $file (@propFiles){
      if($file ne ""){
        open (FILE, $file) || die "Cannot open file ".$file." for read";     
        while(my $line =<FILE>) {
          print $fh $line;
        }
        print $fh "\n\n";
        close FILE;
      }
    }
  }

  close ($fh);
  
  #Reading file
  my @lines=readFromFile($fileName);
  
  #Replacing be_home loc
  @lines=replaceCddToken($beHome,$beHomeRegex1,\@lines);
  @lines=replaceCddToken($beHome,$beHomeRegex2,\@lines);
  
  #Finally Write to file
  writeToFile(\@lines,$fileName);
}

#---------------------------------------------------------------------------------
sub updateCddFile {

  my $cddPath   =  shift;
  my $beStore   =  shift;
  my $logStore  =  shift;
  my $version	=  shift;
  my $beHome	=  shift;

  my $beStoreRegex = "(<backing-store>[\\s\\S]*?<persistence-option>Shared Nothing<\/persistence-option>[\\s\\S]*?)(<data-store-path\/>)([\\s\\S]*?<\/backing-store>)";
  my $beStoreRegex2 = "(<backing-store>[\\s\\S]*?<persistence-option>Shared Nothing<\/persistence-option>[\\s\\S]*?)(<data-store-path>[\\s\\S]*?<\/data-store-path>)([\\s\\S]*?<\/backing-store>)";

  my $logsDirRegex = "(<log-config.*>[\\s\\S]*?<\/enabled>[\\s\\S]*?)(<dir>[\\s\\S]*?<\/dir>)([\\s\\S]*?<\/log-config>)";
  my $logsDirRegex2 = "(<log-config.*>[\\s\\S]*?)(<dir\/>)([\\s\\S]*?<\/log-config>)";

  my $beStoreTag    = "<data-store-path>".$beStore."</data-store-path>";
  my $logsStoreTag  = "<dir>".$logStore."</dir>";
  
  my $beHomeRegex1	= "(<property[\\s\\S]*?value=\")([\\s\\S]*?\/be\/[\\d].[\\d]\/)([\\s\\S]*?\"\/>)";
  
  my $beHomeRegex2	= "(<property[\\s\\S]*?value=\")([\\s\\S]*?\\\\be\\\\[\\d].[\\d]\\\\)([\\s\\S]*?\"\/>)";	

  my $winPathRegex	= "(<property[\\s\\S]*?value=\")(.:)([\\s\\S]*?\"\/>)";	
	
  $DEBUG_ENABLE==1?print "\nDEBUG: Updating Cdd file : $cddPath\n":"";
  
  my $cddPathOrig=$cddPath.".bkp.orig";
  
  if(-e $cddPathOrig){
	`rm $cddPath`;
	`cp $cddPathOrig $cddPath`;
  }
  else{
  	`cp $cddPath $cddPathOrig`;
  }
  
  
  #Backing up file
  my $fileIndex=backupFile($cddPath,1);
  `cp $cddPath $cddPath.$fileIndex`;
  
  #Reading file
  my @lines=readFromFile($cddPath);

  #Replacing be store value
  @lines=replaceCddTokenAll($beStoreTag,$beStoreRegex,\@lines);
  @lines=replaceCddTokenAll($beStoreTag,$beStoreRegex2,\@lines);

  #Replacing Logs store value
  @lines=replaceCddTokenAll($logsStoreTag,$logsDirRegex,\@lines);
  @lines=replaceCddTokenAll($logsStoreTag,$logsDirRegex2,\@lines);
  
  #Replacing be_home loc
  @lines=replaceCddToken($beHome,$beHomeRegex1,\@lines);
  @lines=replaceCddToken($beHome,$beHomeRegex2,\@lines);
  
  #Replacing win drive letter
  @lines=replaceCddToken("",$winPathRegex,\@lines);
  
  #Finally Write to file
  writeToFile(\@lines,$cddPath);

  $DEBUG_ENABLE==1?print "\nProcessing complete for file : $cddPath\n":"";
}
#-------------------------------------------------------------------------------------

sub replaceCddToken{
  my $value      = shift;
  my $regexStr   = shift;
  my $linesRef      = shift;
  my @lines        = @{$linesRef};

  foreach my $line (@lines){  
    $line =~ s/$regexStr/$1$value$3/g;
  }
  
  return @lines;
}

sub replaceCddTokenAll{
  my $value      = shift;
  my $regexStr   = shift;
  my $linesRef      = shift;
  my @allLines        = @{$linesRef};
  
  my $lines = join("\n", @allLines);

  if ($lines !~ m/$regexStr/g){
   	return @allLines;
  }
  $lines =~ s/$regexStr/$1$value$3/g;  
  @allLines=split /\n/,$lines;
  return @allLines;
}

sub readFromFile{
  #local $/ = undef;
  my $fileName=shift;
  #open (IN, $filePath) || die "Cannot open file ".$filePath." for read";     
  #my $lines=<IN>;
  #close IN;
  #return $lines;  
  open (IN, $fileName) || die "Cannot open file ".$fileName." for read";     
  my @lines=<IN>;
  close IN;
  
  return @lines;  
}
#-------------------------------------------------------------------------------------

sub writeToFile{
  my $linesRef     = shift;
  my $fileName     = shift;
  my @lines        = @{$linesRef};
  
  open (OUT, ">", $fileName) || die "Cannot open file ".$fileName." for write";
  foreach my $line (@lines){  
    print OUT $line;
  }
  close OUT;
}
#-------------------------------------------------------------------------------------
sub backupFile {
  my $file =shift;
  my $i    =shift;
  my $bkpFile = $file.".".$i;
  if (-e $bkpFile) {
    $i++;
    return backupFile($file,$i);
  }
  else {
    return $i;
  }
}

#---------------------------------------------------------------------------------

1;
