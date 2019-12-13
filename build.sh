#! /bin/bash


case $1 in

    release | R)
        echo "start build release files."
        DEPLOY_TYPE="R"
    ;;

    snapshot | S)
        echo "start build snapshot files."
        DEPLOY_TYPE="S"
    ;;

    *)
        echo "Please input release(R) or snapshot(S) to select the deploy type."
        exit
    ;;

esac

TEMP_REPO=/tmp/tempLocalRepo
CD=$(dirname $(pwd)/$0)

# M2_REPO is "git clone https://github.com/tomoncle/m2" path
# BUILD_PROJECT is deploy project path 
#
# export M2_REPO=/home/tomoncle/workspace/java/m2
# export BUILD_PROJECT=/home/tomoncle/workspace/java/spring-boot-config

if [ -z $M2_REPO ] || [ -z $BUILD_PROJECT ]
then  
   echo -e "
ERROR: not found env 'M2_REPO' and 'BUILD_PROJECT'

M2_REPO      : 'git clone https://github.com/tomoncle/m2' path
BUILD_PROJECT: deploy project path

for example, you need set env for same as:

   $ export M2_REPO=/home/tomoncle/workspace/bash/m2
   $ export BUILD_PROJECT=/home/tomoncle/workspace/java/github.com/tomoncle/spring-boot-config
"
   exit
fi 

if [ ! -d $M2_REPO ]
then 
   echo "ERROR: $M2_REPO not exists."
   exit
fi

if [ ! -d $BUILD_PROJECT ]
then
   echo "ERROR: $BUILD_PROJECT not exists."
   exit
fi

if [ ! -d $TEMP_REPO ]
then
    mkdir $TEMP_REPO
else
    rm -rf $TEMP_REPO/*
fi

cd $BUILD_PROJECT

# deploy jar files to tmp dir
mvn clean deploy -Dmaven.test.skip  -DaltDeploymentRepository=self-mvn-repo::default::file:$TEMP_REPO

# overwrite or create deploy files
# if snapshots : "$ cp -rf $TEMP_REPO/* $M2_REPO/snapshots/"
if [ "$DEPLOY_TYPE" == "R" ] 
then
    cp -rf $TEMP_REPO/* $M2_REPO/repository/
else
    cp -rf $TEMP_REPO/* $M2_REPO/snapshots/
fi 

# commit your new files
cd $M2_REPO
git pull origin master
git add ./
git commit -am "commit new files"
git push origin master

rm -rf $TEMP_REPO
echo "success."
cd $CD
