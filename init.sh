#!/bin/sh
DEMO="Install Demo"
AUTHORS="Andrew Block, Eric D. Schabell"
PROJECT="git@github.com:jbossdemocentral/bpms-install-demo.git"
PRODUCT="JBoss BPM Suite"
TARGET=./target
JBOSS_HOME=$TARGET/jboss-eap-7.0
SERVER_DIR=$JBOSS_HOME/standalone/deployments
SERVER_CONF=$JBOSS_HOME/standalone/configuration/
SERVER_BIN=$JBOSS_HOME/bin
SRC_DIR=./installs
SUPPORT_DIR=./support
PRJ_DIR=./projects
BPMS=jboss-bpmsuite-6.4.0.GA-deployable-eap7.x.zip
EAP=jboss-eap-7.0.0-installer.jar
#EAP_PATCH=jboss-eap-6.4.4-patch.zip
VERSION=6.4

# wipe screen.
clear

echo
echo "#################################################################"
echo "##                                                             ##"
echo "##  Setting up the ${DEMO}                                ##"
echo "##                                                             ##"
echo "##                                                             ##"
echo "##     ####  ####   #   #      ### #   # ##### ##### #####     ##"
echo "##     #   # #   # # # # #    #    #   #   #     #   #         ##"
echo "##     ####  ####  #  #  #     ##  #   #   #     #   ###       ##"
echo "##     #   # #     #     #       # #   #   #     #   #         ##"
echo "##     ####  #     #     #    ###  ##### #####   #   #####     ##"
echo "##                                                             ##"
echo "##                                                             ##"
echo "##  brought to you by,                                         ##"
echo "##             ${AUTHORS}                  ##"
echo "##                                                             ##"
echo "##  ${PROJECT}      ##"
echo "##                                                             ##"
echo "#################################################################"
echo


# make some checks first before proceeding.
if [ -r $SRC_DIR/$EAP ] || [ -L $SRC_DIR/$EAP ]; then
		echo Product sources are present...
		echo
else
		echo Need to download $EAP package from http://developers.redhat.com
		echo and place it in the $SRC_DIR directory to proceed...
		echo
		exit
fi

#if [ -r $SRC_DIR/$EAP_PATCH ] || [ -L $SRC_DIR/$EAP_PATCH ]; then
#		echo Product patches are present...
#		echo
#else
#		echo Need to download $EAP_PATCH package from the Customer Portal
#		echo and place it in the $SRC_DIR directory to proceed...
#		echo
#		exit
#fi

if [ -r $SRC_DIR/$BPMS ] || [ -L $SRC_DIR/$BPMS ]; then
		echo Product sources are present...
		echo
else
		echo Need to download $BPMS package from http://developers.redhat.com
		echo and place it in the $SRC_DIR directory to proceed...
		echo
		exit
fi

# Remove the old JBoss instance, if it exists.
if [ -x $JBOSS_HOME ]; then
		echo "  - removing existing JBoss product..."
		echo
		rm -rf $JBOSS_HOME
fi

# Run installers.
echo "JBoss EAP installer running now..."
echo
java -jar $SRC_DIR/$EAP $SUPPORT_DIR/installation-eap -variablefile $SUPPORT_DIR/installation-eap.variables

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during JBoss EAP installation!
	exit
fi

#echo
#echo "Applying JBoss EAP 6.4.4 patch now..."
#echo
#$JBOSS_HOME/bin/jboss-cli.sh --command="patch apply $SRC_DIR/$EAP_PATCH"
#
#if [ $? -ne 0 ]; then
#	echo
#	echo Error occurred during JBoss EAP patching!
#	exit
#fi

echo
echo "Deploying JBoss BPM Suite now..."
echo
unzip -qo $SRC_DIR/$BPMS -d $TARGET
#java -jar $SRC_DIR/$BPMS $SUPPORT_DIR/installation-bpms -variablefile $SUPPORT_DIR/installation-bpms.variables
if [ $? -ne 0 ]; then
	echo
	echo Error occurred during $PRODUCT installation!
	exit
fi

echo
echo "  - enabling demo accounts setup ..."
echo
$JBOSS_HOME/bin/add-user.sh -a -r ApplicationRealm -u bpmsAdmin -p bpmsuite1! -ro analyst,admin,manager,user,kie-server,kiemgmt,rest-all --silent
$JBOSS_HOME/bin/add-user.sh -a -r ApplicationRealm -u erics -p bpmsuite1! -ro analyst,admin,manager,user,kie-server,kiemgmt,rest-all --silent

echo "  - setting up standalone.xml configuration adjustments..."
echo
cp $SUPPORT_DIR/standalone.xml $SERVER_CONF

echo "  - copying files needed when using external database ..."
echo 
mkdir -p $JBOSS_HOME/modules/org/postgres/main/
cp $SUPPORT_DIR/postgresql-42.1.1.jar $JBOSS_HOME/modules/org/postgres/main/
cp $SUPPORT_DIR/module.xml $JBOSS_HOME/modules/org/postgres/main/
cp $SUPPORT_DIR/persistence.xml $SERVER_DIR/business-central.war/WEB-INF/classes/META-INF/
cp $SUPPORT_DIR/jboss-web.xml $SERVER_DIR/dashbuilder.war/WEB-INF/

echo "  - setup email task notification users..."
echo
cp $SUPPORT_DIR/userinfo.properties $SERVER_DIR/business-central.war/WEB-INF/classes/

# Add execute permissions to the standalone.sh script.
echo "  - making sure standalone.sh for server is executable..."
echo
chmod u+x $JBOSS_HOME/bin/standalone.sh

echo "You can now start the $PRODUCT with $SERVER_BIN/standalone.sh"
echo
echo "Login to http://localhost:8080/business-central   (u:bpmsAdmin / p:bpmsuite1!)"
echo

echo "$PRODUCT $VERSION $DEMO Setup Complete."
echo
