#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

# getInstallPkgs will take list of packages as input and returns list of packages which are not installed.
getInstallPkgs() {
  INSTALLPKGS_LIST=""
  REQUIRED_PKGS="$1"
  for pkg in ${REQUIRED_PKGS}; do
      PKG_STATUS=$( which $pkg )
      if [ "$PKG_STATUS" = "" ]; then
          INSTALLPKGS_LIST="$INSTALLPKGS_LIST $pkg"
      fi
  done
  echo $INSTALLPKGS_LIST
}

# getCleanupPkgs will return list of packages which needs to be uninstalled.
getCleanupPkgs() {
  CLEANUPPKGS_LIST=""
  BUILDTIME_PKGS="$1"
  INSTALLPKGS_LIST="$2"
  for pkg in ${BUILDTIME_PKGS}; do
      if [[ " $INSTALLPKGS_LIST " =~ .*" $pkg "*. ]]; then
          CLEANUPPKGS_LIST="$CLEANUPPKGS_LIST $pkg"
      fi
  done
  echo $CLEANUPPKGS_LIST
}
