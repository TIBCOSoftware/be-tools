#!/usr/bin/perl 

#
# Copyright (c) 2019. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

package be_docker_install;

use strict;
local $/ ;

##PROPERTIES-----------------------------------------------------------------------------------------------------------

# SCRIPT CONSTANTS-----------------------------------------------
my $DEBUG_ENABLE      = 0; #Set it to 1 to enable debug logs
my $PACKAGE_PLATFORM  = "linux";


# CONSTANTS----------------------------------------------------------
my $ROOT_FOLDER       = ".";
my $TIBCO_HOME        = "TIBCO_HOME";
my $TIBCO_HOME_LOC    = "/opt/tibco";
my $TRA_LOC           = $TIBCO_HOME_LOC."/be/##be_version##/bin/be-engine.tra";
my $RMS_TRA_LOC       = $TIBCO_HOME_LOC."/be/##be_version##/rms/bin/be-rms.tra";
my $TIBCO_HOME_DESC   = "BE Docker Home";
my $CUSTOM_CP         = "/opt/tibco/be/ext";
my $JMX_PORT          = "5555";
my $FILE_PCKG_LIST	  = "package_files.txt";

# REGEXES--------------------------------------------------------
my $REGEX_VERSION     = "_(\\d+(?:\\.\\d+)*)_";
my $REGEX_CUSTOM_CP   = "tibco\.env\.CUSTOM_EXT_PREPEND_CP=.*";
my $REGEX_JMX_PORT    = "#java\.property\.be\.engine\.jmx\.connector\.port=.*";
my $REGEX_LD_LIB_PATH = "tibco.env.LD_LIBRARY_PATH(.*)[\s]*";

my $REGEX_AS_INSTALLER  = "*activespaces";
my $REGEX_BE_INSTALLER  = "*businessevents";
my $REGEX_FTL_INSTALLER  = "*ftl";
my $REGEX_AS3X_INSTALLER  = "*as";

my %REGEX_SLNT_FILE_TOKENS = (
  '(<entry key="installationRoot">)([\s\S]*?)(<\/entry>)' => $TIBCO_HOME_LOC,
  '(<entry key="environmentName">)([\s\S]*?)(<\/entry>)' => $TIBCO_HOME,
  '(<entry key="environmentDesc">)([\s\S]*?)(<\/entry>)' => $TIBCO_HOME_DESC
);

# INSTALLATION---------------------------------------------------
my $FOLDER_BE_INSTALLER = "be_installers";
my $FOLDER_AS_INSTALLER = "as_installers";

#The order in the following map denotes which base product/addon has preference
my @ADDON_PRECEDENCE_MAP = (
  ['businessevents-enterprise' => 'businessevents-process,businessevents-views']
);
  
my %CONSTANTS_MAP = (
  'enterprise'            => 'businessevents-enterprise',
  'process'               => 'businessevents-process',
  'views'                 => 'businessevents-views',
  'hf'                    => 'businessevents-hf',
  'as-hf'                 => 'activespaces',
  'as'                    => 'activespaces' 
);
  
my %AS_VERSION_MAP  = (
 '5.6.0' => '2.3.0',
 '5.6.1' => '2.3.0',
 '6.0.0' => '2.3.0'
);

my %AS_VERSION_MAP_MAX  = (
 '5.6.0' => '2.4.0',
 '5.6.1' => '2.4.1',
 '6.0.0' => '2.4.1'
);

my %FTL_VERSION_MAP  = (
 '6.0.0' => '6.2.0'
);

my %FTL_VERSION_MAP_MAX  = (
 '6.0.0' => '6.X.X'
);

my %AS3X_VERSION_MAP  = (
 '6.0.0' => '4.2.0'
);

my %AS3X_VERSION_MAP_MAX  = (
 '6.0.0' => '4.X.X'
);

# OTHERS---------------------------------------------------------
my $VALUE_CUSTOM_CP = "tibco.env.CUSTOM_EXT_PREPEND_CP=".$CUSTOM_CP;

my $VALUE_JMX_PORT  = "java.property.be.engine.jmx.connector.port=%jmx_port%";

my $VALUE_LD_LIB_PATH = "/opt/tibco/be/ext";
##-------------------------------------------------------------------------------------------------------------------------

my @FILES_LIST	 	= ();

sub install_be {

  my $arg_beVersion = shift;
  my $arg_beEdition = shift;
  my $arg_beAddons  = shift;
  my $arg_beHotfix  = shift;
  my $arg_asHotfix  = shift;
  my $asVersion     = shift;
  
  my $baseProdRegex="*$CONSTANTS_MAP{$arg_beEdition}_$arg_beVersion*zip";
  
  my (@baseProd) = glob "$ROOT_FOLDER/$baseProdRegex";
  if ($arg_beAddons eq "na" ) {
    $arg_beAddons = "";
  }
  if ( $asVersion ne "na" ) {
  	
		my $asProdRegex = "*$CONSTANTS_MAP{'as'}_$asVersion" . "_linux*zip";
		my (@asProd)    = glob "$ROOT_FOLDER/$asProdRegex";
		my @asHfPkg     = ();
		if ( $arg_asHotfix ne "na" ) {
			my $regex =
			    "*$CONSTANTS_MAP{'as-hf'}_"
			  . $asVersion . "_HF-*"
			  . $arg_asHotfix . "*zip";
			@asHfPkg = glob "$ROOT_FOLDER/$regex";

		}

		my $asHfPkgVal = "na";

		if ( scalar @asHfPkg == 1 ) {
			$asHfPkgVal = $asHfPkg[0];
		}

		#-------------------------------------------------------------------
		print "\nINFO:Installing ActiveSpaces $asVersion...\n";
    my $asInstallResult =
		  extractAndInstall( $ROOT_FOLDER, $asVersion, $asProd[0], 0,
			$asHfPkgVal, $FOLDER_AS_INSTALLER, 'as', 0, $arg_asHotfix );

		if ( $asInstallResult == 0 ) {
			print "\nERROR : Error occurred while installating AS.Aborting\n";
			exit 0;
		}
		print "\nINFO:Installing ActiveSpaces $asVersion...DONE\n\n";

		#-------------------------------------------------------------------
	}else{
		my $shortVersion=getShortVersion($arg_beVersion);
		my $token=$shortVersion.".";
		my $blank="";
		my $spversion=$arg_beVersion;
		$spversion=~s/$token/$blank/g;	
		
		#Disable datagrid
		if($spversion eq "0"){
			$REGEX_SLNT_FILE_TOKENS{'(<entry key="feature_TIBCO BusinessEvents DataGrid_businessevents-enterprise">)([\s\S]*?)(<\/entry>)'} = "false";
		}else{	
			$REGEX_SLNT_FILE_TOKENS{'(<entry key="feature_TIBCO BusinessEvents DataGrid SP '.$spversion.'_businessevents-enterprise">)([\s\S]*?)(<\/entry>)'} = "false";
		}
	}
  
  
  
  my @addonList = split(/,/, $arg_beAddons);
  my @addonPkgList = ();
  
  for my $addon(@addonList){
    if($addon ne "na"){
      my $addonRegex="*$CONSTANTS_MAP{$addon}_$arg_beVersion*zip";
      my (@addonPkg) = glob "$ROOT_FOLDER/$addonRegex";
      push(@addonPkgList, ($addonPkg[0]));
    }
  }

  my @beHfPkg=();

  if($arg_beHotfix ne "na"){
    my $regex="*$CONSTANTS_MAP{'hf'}_".$arg_beVersion."_HF-*$arg_beHotfix*zip";
    @beHfPkg = glob "$ROOT_FOLDER/$regex";
  }
  
  my $beHfPkgVal="na";
  if(scalar @beHfPkg == 1){
    $beHfPkgVal=$beHfPkg[0];
  }
  
  #-------------------------------------------------------------------
  print "\nINFO:Installing BusinessEvents $arg_beVersion...\n";
  my $beInstallResult = extractAndInstall($ROOT_FOLDER,$arg_beVersion,$baseProd[0],\@addonPkgList,$beHfPkgVal,$FOLDER_BE_INSTALLER,$arg_beEdition,\@addonList,$arg_beHotfix);
  if($beInstallResult == 0){
    print "\nERROR : Error occurred while installing BE. Aborting\n";
    exit 0;
  }
  #-------------------------------------------------------------------
  
  my $parsedTraLoc=getTraLoc($arg_beVersion,$TRA_LOC);
  my $parsedRMSTraLoc=getTraLoc($arg_beVersion,$RMS_TRA_LOC);
  
  #replace TRA CUSTOM CP Path token
  replaceTraToken($parsedTraLoc,$VALUE_CUSTOM_CP,$REGEX_CUSTOM_CP);
  
  #replace JMX Port property
  replaceTraToken($parsedTraLoc,$VALUE_JMX_PORT,$REGEX_JMX_PORT);
  
  #add Default LD_LIBRARY_PATH
  appendTraToken($parsedTraLoc,$VALUE_LD_LIB_PATH,$REGEX_LD_LIB_PATH);
  
  #replace TRA CUSTOM CP Path token for RMS
  replaceTraToken($parsedRMSTraLoc,$VALUE_CUSTOM_CP,$REGEX_CUSTOM_CP);
  
  #allow JMX port for RMS
  allowJmxPortForRms($parsedRMSTraLoc,$VALUE_JMX_PORT,$REGEX_JMX_PORT);
  
  #add Default LD_LIBRARY_PATH for RMS
  appendTraToken($parsedRMSTraLoc,$VALUE_LD_LIB_PATH,$REGEX_LD_LIB_PATH);
   
  print "\nINFO:Installing BusinessEvents $arg_beVersion...DONE\n\n";
  
  print "\nINFO:Performing cleanup...\n";
  my $beShortVersion = getShortVersion($arg_beVersion);
  `rm -rf as_installers be_installers *.zip`;
  `rm -rf /opt/tibco/tools`;
  #`ls -d /opt/tibco/be/$beShortVersion/examples/* | grep -v standard | xargs rm -rf`;
  #`ls -d /opt/tibco/be/$beShortVersion/examples/standard/* | grep -v WebStudio | xargs rm -rf`;
  `rm -rf /opt/tibco/be/$beShortVersion/admin-plugins`;
  `rm -rf /opt/tibco/be/$beShortVersion/api`;
  #`rm -rf /opt/tibco/be/$beShortVersion/cloud`;
  #`rm -rf /opt/tibco/be/$beShortVersion/decisionmanager`;
  #`rm -rf /opt/tibco/be/$beShortVersion/docker`;
  #`rm -rf /opt/tibco/be/$beShortVersion/maven`;
  #`rm -rf /opt/tibco/be/$beShortVersion/mm`;
  `rm -rf /opt/tibco/be/$beShortVersion/uninstaller_scripts`;
  
  print "\n\nINFO:Product Installation Complete\n\n";
  print "----------------------------------------------\n\n";

}

sub install_ftl {
  my $arg_ftlVersion = shift;
  my $arg_ftlHotfix = shift;

  if($arg_ftlVersion == "na"){
    return 1;
  }

  print "\nINFO:Installing FTL $arg_ftlVersion...\n";
  
  my $baseProdRegex="*ftl_$arg_ftlVersion*zip";
  my (@baseProd) = glob "$ROOT_FOLDER/$baseProdRegex";

  my $result=extractPackages($ROOT_FOLDER,$arg_ftlVersion,$baseProd[0],'ftl_installers');
  if($result == 0){
    print "\nERROR : Error occurred while extracting FTL installer package - $baseProd[0]. Aborting\n";
    return 0;
  }

  my $result=installFTLORAS3XPackages($arg_ftlVersion,'ftl_installers',"TIB_ftl_");
  if($result == 0){
    print "\nERROR : Error occurred while installing FTL. Aborting\n";
    return 0;
  }
  print "\nINFO:Installing FTL $arg_ftlVersion...DONE\n\n";

  if($arg_ftlHotfix ne "na"){
    print "\nINFO:Installing FTL $arg_ftlVersion HF $arg_ftlHotfix ...\n";
  
    my $baseFtlHfRegex="*ftl_$arg_ftlVersion*$arg_ftlHotfix*zip";
    my (@baseFtlHf) = glob "$ROOT_FOLDER/$baseFtlHfRegex";

    my $hfResult=extractHfPackage($ROOT_FOLDER,$arg_ftlVersion,$baseFtlHf[0],'ftl_installers_hf');
    if($hfResult == 0){
      print "\nERROR : Error occurred while extracting FTL HF installer package - $baseFtlHf[0]. Aborting\n";
      return 0;
    }

    my $hfResult=installFTLORAS3XPackages($arg_ftlVersion,'ftl_installers_hf',"TIB_ftl_");
    if($hfResult == 0){
      print "\nERROR : Error occurred while installing FTL HF. Aborting\n";
      return 0;
    }
    print "\nINFO:Installing FTL $arg_ftlVersion HF $arg_ftlHotfix ...DONE\n\n";
  }

}

sub install_as3x {
  my $arg_as3xVersion = shift;
  my $arg_as3xHotfix  = shift;

  if($arg_as3xVersion == "na"){
    return 1;
  }

  print "\nINFO:Installing AS3X $arg_as3xVersion...\n";
  
  my $baseProdRegex="*as_$arg_as3xVersion*zip";
  my (@baseProd) = glob "$ROOT_FOLDER/$baseProdRegex";

  my $result=extractPackages($ROOT_FOLDER,$arg_as3xVersion,$baseProd[0],'as3x_installers');
  if($result == 0){
    print "\nERROR : Error occurred while extracting AS3X installer package - $baseProd[0]. Aborting\n";
    return 0;
  }

  my $result=installFTLORAS3XPackages($arg_as3xVersion,'as3x_installers',"TIB_as_");
  if($result == 0){
    print "\nERROR : Error occurred while installing AS3X. Aborting\n";
    return 0;
  }
  print "\nINFO:Installing AS3X $arg_as3xVersion...DONE\n\n";

  if($arg_as3xHotfix ne "na"){
    print "\nINFO:Installing AS3X $arg_as3xVersion HF $arg_as3xHotfix ...\n";
    
    my $baseAs3xHfRegex="*as_$arg_as3xVersion*$arg_as3xHotfix*zip";
    my (@baseAs3xHf) = glob "$ROOT_FOLDER/$baseAs3xHfRegex";

    my $hfResult=extractHfPackage($ROOT_FOLDER,$arg_as3xVersion,$baseAs3xHf[0],'as3x_installers_hf');
    if($hfResult == 0){
      print "\nERROR : Error occurred while extracting AS3X HF installer package - $baseAs3xHf[0]. Aborting\n";
      return 0;
    }

    my $hfResult=installFTLORAS3XPackages($arg_as3xVersion,'as3x_installers_hf',"TIB_as_");
    if($hfResult == 0){
      print "\nERROR : Error occurred while installing AS3X HF. Aborting\n";
      return 0;
    }
    print "\nINFO:Installing AS3X $arg_as3xVersion HF $arg_as3xHotfix ...DONE\n\n";
  }

}
#----------------------------------------------------------------------------------------

sub extractAndInstall{
  my $rootFolder         = shift;
  my $version          = shift;
  my $pkg            = shift;
  my $addonsRef        = shift;
  my $hfPkg          = shift;
  my $pkgTargetFolder      = shift;
  my $product          = shift;
  my $addonListRef      = shift;
  my $hotfix          = shift;
  my $pkgTargetFolderHf=$pkgTargetFolder."-hf";
  
  #PERFORMING EXTRACTION OF PACKAGES --------------------------------------------------
  #Extract packages in the root folder
  my $result=extractPackages($rootFolder,$version,$pkg,$pkgTargetFolder);
  if($result == 0){
    #Abort : 0 Signifies error
    return 0;
  }
  
  #Extract addons in the root folder
  if($addonsRef ne 0){
    my @addonPkgs=@{$addonsRef};
    $result=extractAddons($rootFolder,$version,\@addonPkgs,$pkgTargetFolder);
    if($result == 0){
      #Abort : 0 Signifies error
      return 0;
    }
  }
  #---------------------------------------------------------------------------------------------
  
  #Replacing Tokens in all Silent files
  #---------------------------------------------------------------------------------------------
  my (@silentFiles) = glob "$pkgTargetFolder/*.silent";
  foreach my $file (@silentFiles) {  
    replaceToken($file,\%REGEX_SLNT_FILE_TOKENS);
  }
  #---------------------------------------------------------------------------------------------
  
  #Installing base package
  my $result=installPackages($rootFolder,$version,$product,$pkgTargetFolder);
  if($result == 0)
  {  #Abort : 0 Signifies error
    return 0;
  }
  
  #Installing Addons
  if($addonListRef ne 0){
    my @addonList  = @{$addonListRef};
    for my $addon (@addonList){
      $result=installPackages($rootFolder,$version,$addon,$pkgTargetFolder);
      if($result == 0)
      {  #Abort : 0 Signifies error
        return 0;
      }
    }
  }
  
  
  if($hfPkg ne "na"){
    $result=extractHfPackage($rootFolder,$version,$hfPkg,$pkgTargetFolderHf);
	my $copyInstallerToHf=`cp $pkgTargetFolder/TIBCOUniversalInstaller-lnx-x86-64.bin $pkgTargetFolderHf`;
  }
  
  
  #Replacing Tokens in all Silent files for HF
  #---------------------------------------------------------------------------------------------
  my (@silentFiles) = glob "$pkgTargetFolderHf/*.silent";
  foreach my $file (@silentFiles) {  
    replaceToken($file,\%REGEX_SLNT_FILE_TOKENS);
  }
  #---------------------------------------------------------------------------------------------
  
  #Installing HFs
  if($hotfix ne "na" ){
        $result=installHotfix($rootFolder,$version,$hotfix,$pkgTargetFolderHf);
      if($result == 0)
      {  #Abort : 0 Signifies error
        return 0;
      }
  }
  #----------------------------------------------------------------------------------------
  
  return 1;
}

sub installPackages{
  
  my $rootFolder         = shift;
  my $version          = shift;
  my $intallPkg          = shift;
  my $pkgTargetFolder      = shift;
  
  my (@silentFiles) = glob "$pkgTargetFolder/*$CONSTANTS_MAP{$intallPkg}_$version*.silent";
  foreach my $file (@silentFiles){
  
    $DEBUG_ENABLE==1?print "\nDEBUG:Performing installation with Silent file : $file\n":"";
    my $Command_3_install=`cd $pkgTargetFolder;./TIBCOUniversalInstaller-lnx-x86-64.bin -silent -V responseFile="$file"`;
    $DEBUG_ENABLE==1?print "\nDEBUG:$Command_3_install\n":"";
    last;
  }
  return 1;
}

sub installFTLORAS3XPackages{
  
  my $version = shift;
  my $pkgSourceRoot= shift;
  my $installerType = shift;

  my $pkgSourceFolder = "$pkgSourceRoot/" . "$installerType" . "$version";
  
  my $installCmd = "cd $pkgSourceFolder;";

  my $installerdpkg = `which dpkg`;
  chomp($installerdpkg);
  my $installeryum = `command -v yum`;
  chomp($installeryum);
  if($installerdpkg eq "/usr/bin/dpkg"){
    $installCmd = "$installCmd"."dpkg -i deb/*.deb";
  }elsif($installeryum eq "/usr/bin/yum"){
    $installCmd = "$installCmd"."yum install -y rpm/*.rpm";
  }else{
    $installCmd = "$installCmd"."for f in tar/*; do tar -C / -xvf \$f; done";
  }
  
  $DEBUG_ENABLE==1?print "\nDEBUG:Performing installation with command: $installCmd\n":"";
  my $installResult = `$installCmd` ;
  $DEBUG_ENABLE==1?print "\nDEBUG: $installResult":"";

  return 1;
}

sub installHotfix{
  
  my $rootFolder       = shift;
  my $version          = shift;
  my $product          = shift;
  my $pkgTargetFolder  = shift;
  
  my (@silentFiles) = glob "$pkgTargetFolder/TIBCOUniversalInstaller.silent";
  foreach my $file (@silentFiles) {
  
    $DEBUG_ENABLE==1?print "\nDEBUG:Performing installation with Silent file : $file\n":"";
    my $Command_3_install=`cd $pkgTargetFolder;./TIBCOUniversalInstaller-lnx-x86-64.bin -silent -V responseFile="$file"`;
    $DEBUG_ENABLE==1?print "\nDEBUG:$Command_3_install\n":"";
    last;
  }
  return 1;
}

sub extractPackages{
  my $rootFolder       = shift;
  my $version          = shift;
  my $pkg              = shift;
  my $pkgTargetFolder  = shift;

  $DEBUG_ENABLE==1?print "\nDEBUG: Extracting package='$pkg' to '$pkgTargetFolder'.\n":"";
  my $Command_1_extract_str="cd $rootFolder;unzip -o $pkg -d $pkgTargetFolder";
  my $Command_1_extract=`$Command_1_extract_str`;
  $DEBUG_ENABLE==1?print "\nDEBUG:Result : $Command_1_extract\n":"";
  $DEBUG_ENABLE==1?print "\nDEBUG:Extraction complete\n":"";
  return 1;
}

sub extractAddons{
  my $rootFolder       = shift;
  my $version          = shift;
  my $addonPkgsRef     = shift;
  my $pkgTargetFolder  = shift;
  
  $DEBUG_ENABLE==1?print "\nDEBUG: Extracting addons\n":"";
  
  my @addonPkgs =@{$addonPkgsRef};
  
  for my $addonPkg (@addonPkgs)
  {
    $DEBUG_ENABLE==1?print "\nDEBUG:Extracting addon : $addonPkg in $pkgTargetFolder...\n":"";
    my $Command_1_extract_str="cd $rootFolder;unzip -o $addonPkg -d $pkgTargetFolder";
    my $Command_1_extract=`$Command_1_extract_str`;
    $DEBUG_ENABLE==1?print "\nDEBUG:Result : $Command_1_extract\n":"";
    $DEBUG_ENABLE==1?print "\nDEBUG:Extraction complete for addon : $addonPkg \n":"";
  }
  
  return 1;
}

sub extractHfPackage{

  my $rootFolder         = shift;
  my $version          = shift;
  my $hfPkg          = shift;
  my $pkgTargetFolder      = shift;

  $DEBUG_ENABLE==1?print "\nDEBUG:Extracting for HF package : $hfPkg in $pkgTargetFolder...\n":"";
  my $Command_1_extract_str="cd $rootFolder;unzip -o $hfPkg -d $pkgTargetFolder";
  my $Command_1_extract=`$Command_1_extract_str`;
  $DEBUG_ENABLE==1?print "\nDEBUG:Result : $Command_1_extract\n":"";
  $DEBUG_ENABLE==1?print "\nDEBUG:Extraction complete\n":"";
  return 1;
}

#----------------------------------------------------------------------------------------

sub replaceToken{
  
  my $fileName    = shift;
  my $tokensMapRef  = shift;
  my %tokensMap    = %{$tokensMapRef};
  
  $DEBUG_ENABLE==1?print "\nDEBUG:Replacing tokens for file : $fileName":"";
  
  open (IN, $fileName) || die "Cannot open file ".$fileName." for read";     
  my @lines=<IN>;
  close IN;
    
  #Renaming the file to backup file
  rename $fileName, $fileName . ".bkp";
  
  open (OUT, ">", $fileName) || die "Cannot open file ".$fileName." for write";
  foreach my $line (@lines)
  {  
    foreach my $tokenRegex (keys %tokensMap)
    {
         $line =~ s/$tokenRegex/$1$tokensMap{$tokenRegex}$3/g;
    }
    print OUT $line;
  }
  close OUT;
}

sub replaceRunbeVersionToken{
  
  my $arg_version      = shift;
  my $arg_runBe_path    = shift;
  
  $DEBUG_ENABLE==1?print "\nDEBUG:Replacing tokens for file : $arg_runBe_path":"";
  
  open (IN, $arg_runBe_path) || die "Cannot open file ".$arg_runBe_path." for read";     
  my @lines=<IN>;
  close IN;
  
  open (OUT, ">", $arg_runBe_path) || die "Cannot open file ".$arg_runBe_path." for write";
  foreach my $line (@lines)
  {  
    if($line =~ m/\%\%\%BE_VERSION\%\%\%/g){
         $line =~ s/\%\%\%BE_VERSION\%\%\%/$arg_version/g;
    }
    print OUT $line;
  }
  close OUT;
}

sub generateAnnotationIndexes{

  my $BE_HOME       = shift;
  my $JRE_HOME      = shift;
  my $CLASSPATH     = "$BE_HOME/lib/*:$BE_HOME/lib/ext/tpcl/*:$BE_HOME/lib/ext/tpcl/aws/*:$BE_HOME/lib/ext/tpcl/gwt/*:$BE_HOME/lib/ext/tpcl/apache/*:$BE_HOME/lib/ext/tpcl/emf/*:$BE_HOME/lib/ext/tpcl/tomsawyer/*:$BE_HOME/lib/ext/tibco/*:$BE_HOME/lib/eclipse/plugins/*:$BE_HOME/rms/lib/*:$BE_HOME/mm/lib/*:$BE_HOME/studio/eclipse/plugins/*:$BE_HOME/lib/eclipse/plugins/*:$BE_HOME/rms/lib/*:$JRE_HOME/lib/*:$JRE_HOME/lib/ext/*:$JRE_HOME/lib/security/policy/unlimited/*";
  
  print "\nBuilding annotation indexes..";
  `$JRE_HOME/bin/java -Dtibco.env.BE_HOME=$BE_HOME -cp $CLASSPATH com.tibco.be.model.functions.impl.JavaAnnotationLookup`;
}

sub allowJmxPortForRms{

  my $fileName  = shift;
  my $tokenValue   = shift;
  my $tokenRegex  = shift;
  my $propertyPresent = 0;
  open IN, $fileName;
  my @string = <IN>;
  close IN;

  for (@string) {
    if ($_ =~ /$tokenRegex/) {
        $propertyPresent = 1;
    }
 }
  
 if($propertyPresent==1){
   replaceTraToken($fileName,$tokenValue,$tokenRegex);
 }else{
   addJMXProperty($fileName,$tokenValue);
 }

}

sub addJMXProperty{
  my $fileName  = shift;
  my $tokenValue   = shift;
  open(my $fd, ">>$fileName");
  print $fd "\n$tokenValue\n";
  close $fd;
}


sub replaceTraToken{
  my $fileName  = shift;
  my $tokenValue   = shift;
  my $tokenRegex  = shift;

  $DEBUG_ENABLE==1?print "\nDEBUG:Replacing tokens for file : $fileName\n":"";
  
  open (IN, $fileName) || die "Cannot open file ".$fileName." for read";     
  my @lines=<IN>;
  close IN;
  
  my $fileIndex=backupFile($fileName,1);
  `mv $fileName $fileName.$fileIndex`;
  
  open (OUT, ">", $fileName) || die "Cannot open file ".$fileName." for write";
  foreach my $line (@lines)
  {  
       $line =~ s/$tokenRegex/$tokenValue/;
    print OUT $line;
  }
  close OUT;
}

sub appendTraToken{
  my $fileName    = shift;
  my $tokenValue  = shift;
  my $tokenRegex  = shift;

  $DEBUG_ENABLE==1?print "\nDEBUG:Appending tokens for file : $fileName\n":"";
  
  open (IN, $fileName) || die "Cannot open file ".$fileName." for read";     
  my @lines=<IN>;
  close IN;
  
  my $fileIndex=backupFile($fileName,1);
  `mv $fileName $fileName.$fileIndex`;
  
  open (OUT, ">", $fileName) || die "Cannot open file ".$fileName." for write";
  foreach my $line (@lines)
  {    
       if($line =~ m/$tokenRegex/g){
		 $line =~ s/\s+$//;
         $line = $line."%PSP%".$tokenValue;
	   }
    print OUT $line;
  }
  close OUT;
}



#----------------------------------------------------------------------------------------

sub validate{
  $| = 1;
  my $targetDir  =shift;
  my $version    =shift;
  my $edition    =shift;
  my $addons     =shift;
  my $beHotfix   =shift;
  my $asHotfix   =shift;
  my $ftlHotfix   =shift;
  my $as3xHotfix   =shift;
  my $tempdir  = shift;
  
  @FILES_LIST	 = ();
  
  print "\n";
  
  my @addonList  =split(/,/, $addons);

  my $result=validateCorrectNaming($edition,\@addonList);

  if($result == 0){
    exit 0;
  }

  $result=validateVersion($version);

  if($result == 0){
    exit 0;
  }

  $result=validateActivespace($version,$asHotfix,$targetDir);

  if($result == 0){
    exit 0;
  }


  $result=validateBaseProduct($version,$edition,$targetDir);

  if($result == 0){
    exit 0;
  }

  $result=validateAddons($version,\@addonList,$targetDir,$edition);

  if($result == 0){
    exit 0;
  }
		
  my $hf="na";
  if($beHotfix ne "na"){
    $hf=formatHotfixNumber($beHotfix);
    $result=validateHotfix($version,$hf,$targetDir);
  }
  

  if($result == 0){
    exit 0;
  }

  $result=validateFTL($version,$ftlHotfix,$targetDir);

  if($result == 0){
    exit 0;
  }

  $result=validateAS3X($version,$as3xHotfix,$targetDir);

  if($result == 0){
    exit 0;
  }
  
  writeToFile(\@FILES_LIST,"$tempdir/$FILE_PCKG_LIST");
  print "\n";
  exit 1;
}


#----------------------------------------------------------------------------------------------------------------

sub validateCorrectNaming{
  
  my $arg_edition         =shift;
  my $arg_addonsListRef   =shift;
  my @arg_addonsList      =@{$arg_addonsListRef};
  
  if(exists $CONSTANTS_MAP{$arg_edition}){
    $DEBUG_ENABLE==1?print "\nDEBUG:Base Product edition : $CONSTANTS_MAP{$arg_edition}\n":"";
  }
  else{
    print "\nERROR: Invalid value for Edition :: $arg_edition .Should be either of standard|enterprise.\n";
    return 0;
  }

  for my $addon_val (@arg_addonsList){
    if(exists $CONSTANTS_MAP{$addon_val}){
      $DEBUG_ENABLE==1?print "\nDEBUG:Addon to be installed : $CONSTANTS_MAP{$addon_val}\n":"";
    }
    else
    {  
      if($addon_val ne "na"){
        print "\nERROR: Invalid value for addon :: $addon_val.Should be 
        either of process|views.Aborting\n";
        return 0;
      }
    }
  }
  return 1;
}


sub validateBaseProduct{

  my $arg_version    =shift;
  my $arg_edition    =shift;
  my $arg_targetDir  =shift;

  my $regex="*$CONSTANTS_MAP{$arg_edition}_$arg_version*zip";
  my (@baseProd) = glob "$arg_targetDir/$regex";
  
  if(scalar @baseProd == 0){
    print "\nERROR :No package found with Edition : $arg_edition with version: $arg_version in the installer location.\n";
    return 0;
  }
  elsif(scalar @baseProd==1){
    $DEBUG_ENABLE==1?print "\nDEBUG:Base Product : $baseProd[0]\n":"";
	push @FILES_LIST, "$baseProd[0]\n";
    return 1;
  }
  else{
    print "\nERROR :More than one base product($arg_edition) are present in the installer location.There should be only one.\n";
    return 0;
  }

}

sub validateAddons{

  my $arg_version   =shift;
  my $arg_addonsRef =shift;
  my $arg_targetDir =shift;
  my $arg_edition   =shift;
  
  my @arg_addonsList =@{$arg_addonsRef};
  my $present=0;
  
  for my $addonVal (@arg_addonsList){
    if($addonVal ne "na"){
      $present=0;  
      my $regex="*$CONSTANTS_MAP{$addonVal}_$arg_version*zip";
      my (@addonPkg) = glob "$arg_targetDir/$regex";

      if(scalar @addonPkg == 0){
        print "\nERROR :No package found for Addon : $addonVal with version: $arg_version in the installer location.\n";
        return 0;
      }
      elsif(scalar @addonPkg==1){

        for my $mapVal (@ADDON_PRECEDENCE_MAP){  
          my ($key, $value) = @$mapVal;

          if($key eq $CONSTANTS_MAP{$arg_edition}){
          my @validAddonList = split(/,/, $value);
          foreach my $validAddon(@validAddonList)
          {  
            if($validAddon eq $CONSTANTS_MAP{$addonVal} ){
              $present=1;  
              $DEBUG_ENABLE==1?print "\nDEBUG:Addon : $addonPkg[0]\n":"";
			  push @FILES_LIST, "$addonPkg[0]\n";
            }
          }
          }
          else{
          next;
          }
        }
        if($present==0){
          print "\nERROR :The specified addon : $addonVal is not valid for edition : $arg_edition. \n";  
          return 0;  
        }
      }
      else{
        print "\nERROR :More than one addon($addonVal) are present in the installer location.There should be only one.\n";
        return 0;
      }
    }
  }
  return 1;
}

sub validateVersion{
  
  my $arg_version=shift;
  if($arg_version =~ m/\d{1}\.\d{1}\.\d{1}/g){
    return 1;
  }
  else{
    print "\nERROR :Invalid value for be version: $arg_version.Make sure you provide the fully qualified version.Ex- 5.4.0\n";
    return 0;
  }
}

sub validateHotfix{
  
  my $arg_version    =shift;
  my $arg_beHotfix   =shift;  
  my $arg_targetDir  =shift;
  
  
  if($arg_beHotfix ne "na"){
    if($arg_beHotfix =~ m/\d{3}/){
      my $regex="*$CONSTANTS_MAP{'hf'}_".$arg_version."_HF-$arg_beHotfix*zip";
      my (@hfPkg) = glob "$arg_targetDir/$regex";
      if(scalar @hfPkg == 0){
        print "\nERROR :No package found for HF : $arg_beHotfix with version: $arg_version in the installer location.\n";
        return 0;
      }
      elsif(scalar @hfPkg==1){
        $DEBUG_ENABLE==1?print "\nDEBUG: HF : $hfPkg[0]\n":"";
		push @FILES_LIST, "$hfPkg[0]\n";
      }
      else{
        print "\nERROR :More than one HFs($arg_beHotfix) are present in the installer location.There should be only one.\n";
        return 0;
      }
    }
    else{
      print "\nERROR :Invalid value for be hotfix: $arg_beHotfix.Make sure you provide fully qualified hotfix number as an argument.Ex- 005\n";
      return 0;
    }
  }
  return 1;
}


sub validateActivespace{
  
  my $arg_version    =shift;  
  my $arg_asHotfix   =shift;
  my $arg_targetDir  =shift;
  
  my @asPckg=glob "$arg_targetDir/$REGEX_AS_INSTALLER*.zip";
  
  my @asHfPckg=glob "$arg_targetDir/$REGEX_AS_INSTALLER*_HF*.zip";
  
  
  my $asCount = @asPckg;
  my $asHFCount = @asHfPckg;
  
  my $countAS=$asCount-$asHFCount;
  
  if($countAS == 0){
    print "\nWarning :TIBCO Activespaces will not be installed as no package found for activespaces in the installer location.\n";
    #return 0;
  }
  elsif($countAS == 1){
    
	my @asPckgFiltered = grep(/.*activespaces.*([\d]\.[\d]\.[\d])_linux.*/g, @asPckg);
	
    if($asPckgFiltered[0] =~ m/.*activespaces.*([\d]\.[\d]\.[\d])_linux.*/g){
      my ($asVersion) = $1;
      
	  my $isLess=isLessThan($asVersion, $AS_VERSION_MAP{$arg_version});
	  my $isGreater=isGreaterThan($asVersion, $AS_VERSION_MAP_MAX{$arg_version});
	  
      if($isLess > 0 or $isGreater > 0 ){
print "argver: $arg_version, asver: $AS_VERSION_MAP{$arg_version}, asver:$asVersion \n";
        print "\nERROR :BE Version :$arg_version is not compatible with Activespace version $asVersion.\n";
		return 0;
      }
      else{
        $DEBUG_ENABLE==1?print "\nDEBUG: AS VERSION : $asPckgFiltered[0]\n":"";
		push @FILES_LIST, "$asPckgFiltered[0]\n";
		
        if($arg_asHotfix ne "na"){
	  my $arg_asHotfix=formatHotfixNumber($arg_asHotfix);
          if($arg_asHotfix =~ m/\d{3}/){
            my $regex="*$CONSTANTS_MAP{'as-hf'}_".$asVersion."_HF-$arg_asHotfix*zip";
            my (@hfPkg) = glob "$arg_targetDir/$regex";
            if(scalar @hfPkg == 0){
              print "\nERROR :No package found for HF : $arg_asHotfix with version: $asVersion in the installer location.\n";
              return 0;
            }
            elsif(scalar @hfPkg==1){
              if($hfPkg[0] =~ m/.*activespaces.*($asVersion).*/g){
                $DEBUG_ENABLE==1?print "\nDEBUG: HF : $hfPkg[0]\n":"";
				push @FILES_LIST, "$hfPkg[0]\n";
              }
              else{
                print "\nERROR :Activespace version does not match with the hotfix version.
                Make sure both the packages are of same version. \n";
              }
            }
            else{
              print "\nERROR :More than one HFs($arg_asHotfix) are present in the target directory.There should be only one.\n";
              return 0;
            }
          }
          else{
            print "\nERROR :Invalid value for be hotfix: $arg_asHotfix.Make sure you provide correct hotfix number as an argument.Ex- 5\n";
            return 0;
          }
        }
      }
    }
  }
  else{
    print "\nERROR :More than one Activespace Packages are present in the target directory.There should be only one.\n";
    return 0;
  }
  return 1;
}

sub validateFTL{
  
  my $arg_version    =shift;
  my $arg_ftlHotfix  =shift;
  my $arg_targetDir  =shift;
  
  my @ftlPckg=glob "$arg_targetDir/$REGEX_FTL_INSTALLER*.zip";
  my @ftlHfPckg=glob "$arg_targetDir/$REGEX_FTL_INSTALLER*_HF*.zip";

  my $ftlCount = @ftlPckg;
  my $ftlHFCount = @ftlHfPckg;
  
  my $countFTL=$ftlCount-$ftlHFCount;

  if($countFTL == 1){
    my @ftlPckgFiltered = grep(/.*ftl.*([\d]\.[\d]\.[\d])_linux.*/g, @ftlPckg);
	
    if($ftlPckgFiltered[0] =~ m/.*ftl.*([\d]\.[\d]\.[\d])_linux.*/g){
      my ($ftlVersion) = $1;
      my $isLess=isLessThan($ftlVersion, $FTL_VERSION_MAP{$arg_version});
      my $isGreater=isGreaterThan($ftlVersion, $FTL_VERSION_MAP_MAX{$arg_version});
      if($isLess > 0 or $isGreater > 0 ){
        print "argver: $arg_version, ftlver: $FTL_VERSION_MAP{$arg_version}, ftlver:$ftlVersion \n";
        print "\nERROR :BE Version :$arg_version is not compatible with FTL version $ftlVersion.\n";
        return 0;
      }else{
        $DEBUG_ENABLE==1?print "\nDEBUG: FTL VERSION : $ftlPckgFiltered[0]\n":"";
        push @FILES_LIST, "$ftlPckgFiltered[0]\n";

        if($arg_ftlHotfix ne "na"){
          my $arg_ftlHotfix=formatHotfixNumber($arg_ftlHotfix);
          if($arg_ftlHotfix =~ m/\d{3}/){
            my $regex="*ftl_".$ftlVersion."_HF-$arg_ftlHotfix*zip";
            my (@hfPkg) = glob "$arg_targetDir/$regex";
            if(scalar @hfPkg == 0){
              print "\nERROR :No package found for HF : $arg_ftlHotfix with version: $ftlVersion in the installer location.\n";
              return 0;
            }elsif(scalar @hfPkg==1){
              if($hfPkg[0] =~ m/.*ftl.*($ftlVersion).*/g){
                $DEBUG_ENABLE==1?print "\nDEBUG: HF : $hfPkg[0]\n":"";
				        push @FILES_LIST, "$hfPkg[0]\n";
              }else{
                print "\nERROR :ftl version does not match with the hotfix version.
                Make sure both the packages are of same version. \n";
              }
            }else{
              print "\nERROR :More than one HFs($arg_ftlHotfix) are present in the target directory.There should be only one.\n";
              return 0;
            }
          }else{
            print "\nERROR :Invalid value for be hotfix: $arg_ftlHotfix.Make sure you provide correct hotfix number as an argument.Ex- 5\n";
            return 0;
          }
        }

      }
    }
  }elsif($ftlCount != 0){
    print "\nERROR :More than one FTL Packages are present in the target directory. There should be only one.\n";
    return 0;
  }
  return 1;
}

sub validateAS3X{
  
  my $arg_version    =shift;
  my $arg_as3xHotfix  =shift;  
  my $arg_targetDir  =shift;
  
  my @as3xPckg=glob "$arg_targetDir/$REGEX_AS3X_INSTALLER*.zip";
  my @as3xHfPckg=glob "$arg_targetDir/$REGEX_AS3X_INSTALLER*_HF*.zip";

  my $as3xCount = @as3xPckg;
  my $as3xHFCount = @as3xHfPckg;

  my $countAS3X=$as3xCount-$as3xHFCount;
  
  if($countAS3X == 1){
    my @as3xPckgFiltered = grep(/.*as.*([\d]\.[\d]\.[\d])_linux.*/g, @as3xPckg);
	
    if($as3xPckgFiltered[0] =~ m/.*as.*([\d]\.[\d]\.[\d])_linux.*/g){
      my ($as3xVersion) = $1;
      my $isLess=isLessThan($as3xVersion, $AS3X_VERSION_MAP{$arg_version});
      my $isGreater=isGreaterThan($as3xVersion, $AS3X_VERSION_MAP_MAX{$arg_version});
      if($isLess > 0 or $isGreater > 0 ){
        print "argver: $arg_version, as3xver: $AS3X_VERSION_MAP{$arg_version}, as3xver:$as3xVersion \n";
        print "\nERROR :BE Version :$arg_version is not compatible with AS3X version $as3xVersion.\n";
        return 0;
      }else{
        $DEBUG_ENABLE==1?print "\nDEBUG: AS3X VERSION : $as3xPckgFiltered[0]\n":"";
        push @FILES_LIST, "$as3xPckgFiltered[0]\n";

        if($arg_as3xHotfix ne "na"){
          my $arg_as3xHotfix=formatHotfixNumber($arg_as3xHotfix);
          if($arg_as3xHotfix =~ m/\d{3}/){
            my $regex="*as_".$as3xVersion."_HF-$arg_as3xHotfix*zip";
            my (@hfPkg) = glob "$arg_targetDir/$regex";
            if(scalar @hfPkg == 0){
              print "\nERROR :No package found for HF : $arg_as3xHotfix with version: $as3xVersion in the installer location.\n";
              return 0;
            }elsif(scalar @hfPkg==1){
              if($hfPkg[0] =~ m/.*as.*($as3xVersion).*/g){
                $DEBUG_ENABLE==1?print "\nDEBUG: HF : $hfPkg[0]\n":"";
				        push @FILES_LIST, "$hfPkg[0]\n";
              }else{
                print "\nERROR :as3x version does not match with the hotfix version.
                Make sure both the packages are of same version. \n";
              }
            }else{
              print "\nERROR :More than one HFs($arg_as3xHotfix) are present in the target directory.There should be only one.\n";
              return 0;
            }
          }else{
            print "\nERROR :Invalid value for be hotfix: $arg_as3xHotfix.Make sure you provide correct hotfix number as an argument.Ex- 5\n";
            return 0;
          }
        }

      }
    }
  }elsif($as3xCount != 0){
    print "\nERROR :More than one AS Packages are present in the target directory. There should be only one.\n";
    return 0;
  }
  return 1;
}

sub formatHotfixNumber{
  my $num=shift;
	
  if($num =~ m/\d{3}/){
    return "$num";	
  }
  elsif($num =~ m/\d{2}/){
    return "0"."$num";	
  }
  elsif($num =~ m/\d{1}/){
    return "00"."$num";	
  }	
}


## isLessThan()
## Arguments:
##    $arg_version: version string. Ex: 4.5.1
##    $arg_minVersion: minimum version string. Ex: 6.4.1
##
## Returns:
##    1 - if $arg_version lessthan $arg_minVersion OR in case of any error
##    0 - for all other cases
##
sub isLessThan {
  my $arg_version    = shift;
  my $arg_minVersion = shift;

  my @version    = $arg_version =~ /(^\d+)\.(\d+)\.(\d+$)/g;
  my @minVersion = $arg_minVersion =~ /(^\d+)\.(\d+)\.(\d+$)/g;

  if ( $#version != 2 ) {
    print "\nERROR: isLessThan() arg1 $arg_version is not a valid version string \n";
    return 1;
  }
  if ( $#minVersion != 2 ) {
    print "\nERROR: isLessThan() arg2 $arg_minVersion is not a valid version string \n";
    return 1;
  }

  for ( my $i = 0 ; $i < 3 ; $i++ ) {
    my $v  = @version[$i];
    my $mv = @minVersion[$i];
    if ( $v < $mv ) {
      return 1;
    }
  }
  return 0;
}

## isGreaterThan()
## Arguments:
##    $arg_version: version string. Ex: 4.5.1
##    $arg_maxVersion: maximum version string. Ex: 6.4.1 / 6.X.X / 7.x.x
##
## Returns:
##    1 - if $arg_version greaterthan $arg_maxVersion OR in case of any error
##    0 - all other cases
##
sub isGreaterThan {
  my $arg_version    = shift;
  my $arg_maxVersion = shift;

  my @version = $arg_version =~ /(^\d+)\.(\d+)\.(\d+$)/g;
  my @maxVersion = $arg_maxVersion =~ /(^\d+|^x?|^X?)\.(\d+|x?|X?)\.(\d+$|x?$|X?$)/g;

  if ( $#version != 2 ) {
    print "\nERROR: isGreaterThan() arg1 $arg_version is not a valid version string \n";
    return 1;
  }
  if ( $#maxVersion != 2 ) {
    print "\nERROR: isGreaterThan() arg2 $arg_maxVersion is not a valid version string \n";
    return 1;
  }

  for ( my $i = 0 ; $i < 3 ; $i++ ) {
    my $v  = @version[$i];
    my $mv = @maxVersion[$i];

    if ( ( $mv == "X" ) || ( $mv == "x" ) ) {
      last;
    }

    if ( $v > $mv ) {
      return 1;
    }
  }
  return 0;
}

#--------------------------------------------------------------------------------

sub isIn{
  my $arg_versionList =shift;
  my $arg_asVersion  =shift;
  
  my @compatibleVersions  = split(/,/, $arg_versionList);
  
  for my $ver (@compatibleVersions){
  	 if($arg_asVersion eq $ver){
	   return 1;
	 }
  }
  return 0;
}

#---------------------------------------------------------------------------------
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

sub getTraLoc{
  my $version = shift;
  my $traLoc  = shift;
  
  if($version =~ m/([\d]\.[\d]).*/g){
    my ($beVersion) = $1;
    $traLoc =~ s/(.*)(##.*##)(.*)/$1$beVersion$3/g;
  }
  return $traLoc;    
}

sub getShortVersion{
  my $version = shift;
  
  if($version =~ m/([\d]\.[\d]).*/g){
    my ($beVersion) = $1;
	
    return $beVersion;
  }
  return $version;
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

1;