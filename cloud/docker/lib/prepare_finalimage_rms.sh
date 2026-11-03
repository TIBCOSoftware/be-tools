#!/bin/bash

#
# Assembles /tibco_home for the Quarkus RMS image (native installer, BE 7.0.0 and above).
# Counterpart of prepare_finalimage.sh, which prepares the legacy BE-engine RMS.
#
# The native installer has already laid down, under /opt/tibco:
#   jrehome/<java major version>/        bundled JRE (RMS needs Java 25)
#   be/<short version>/                  BE libraries, studio plugins, maven repository and rms-server/
#   rms-instance/be/<short version>/     instance directory written by the RMS post-install hook
#

set -e

TIBCO=/opt/tibco
BE_SRC=$TIBCO/be/${BE_SHORT_VERSION}
INSTANCE=$TIBCO/rms-instance/be/${BE_SHORT_VERSION}
SEED=/tibco_home/rms-instance-seed

if [ ! -d "$BE_SRC/rms-server" ]; then
    echo "ERROR: $BE_SRC/rms-server not found. The native installer did not install the RMS pack."
    exit 1
fi
if [ ! -d "$TIBCO/jrehome" ]; then
    echo "ERROR: $TIBCO/jrehome not found. The native installer did not install its bundled JRE."
    exit 1
fi
if [ ! -d "$INSTANCE/config" ]; then
    echo "ERROR: RMS instance directory $INSTANCE/config not found. The RMS post-install hook did not run."
    exit 1
fi

mkdir -p /tibco_home/be
cp -a $TIBCO/jrehome /tibco_home/jrehome
cp -a $BE_SRC /tibco_home/be/

# RMS needs the BE libraries, the studio decision table plugin and the maven repository (EAR builds).
# Everything below is install bookkeeping or content a running RMS never reads.
cd /tibco_home/be/${BE_SHORT_VERSION}
rm -rf examples .history .installer Uninstaller admin-plugins api uninstaller_scripts

# The instance directory is operator-owned and is a volume at run time. Keep the installer's output as the seed that
# run-rms.sh copies into an empty instance directory on first start.
mkdir -p $SEED
cp -a $INSTANCE/. $SEED/
rm -rf $SEED/logs/* $SEED/rms-server.pid

# The installer's post-install hook ran 'be-rms-server init', so the seed holds JWT and token-encryption keys generated
# here, at image build time. Put the key-less template back: every container then generates its own keys on first start
# (run-rms.sh runs init), instead of all containers of this image sharing one signing key.
cp $BE_SRC/rms-server/config/rms-secrets.properties $SEED/config/rms-secrets.properties

# The installer resolved the DT plugin qualifier and the install paths into the launcher; confirm nothing is left over.
# JAVA_ADD_OPENS is the launcher's optional token and is deliberately left as is.
if grep -nE '^[^#]*%TIBCO_[A-Z_]+%' /tibco_home/be/${BE_SHORT_VERSION}/rms-server/bin/be-rms-server.sh; then
    echo "ERROR: be-rms-server.sh still holds unsubstituted installer tokens (see above)."
    exit 1
fi

rm -rf /home/tibco/be/be_installers-hf /home/tibco/be/*.py /home/tibco/be/run_teagent.sh
