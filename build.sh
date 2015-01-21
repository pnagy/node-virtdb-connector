#!/bin/bash

PACKAGE=node-virtdb-connector

if [ "X" == "X$GITHUB_USER" ]; then echo "Need GITHUB_USER environment variable"; exit 10; fi
if [ "X" == "X$GITHUB_PASSWORD" ]; then echo "Need GITHUB_PASSWORD environment variable"; exit 10; fi
if [ "X" == "X$GITHUB_EMAIL" ]; then echo "Need GITHUB_EMAIL environment variable"; exit 10; fi
if [ "X" == "X$HOME" ]; then echo "Need HOME environment variable"; exit 10; fi

cd build-result

rm -rf $PACKAGE/*
rm -rf $PACKAGE/.*

git clone --recursive https://$GITHUB_USER:$GITHUB_PASSWORD@github.com/starschema/$PACKAGE.git $PACKAGE
if [ $? -ne 0 ]; then echo "Failed to clone $PACKAGE repository"; exit 10; fi
echo Creating build $BUILDNO

echo >>$HOME/.netrc
echo machine github.com >>$HOME/.netrc
echo login $GITHUB_USER >>$HOME/.netrc
echo password $GITHUB_PASSWORD >>$HOME/.netrc
echo >>$HOME/.netrc

cd $HOME/build-result/$PACKAGE

PROTOC_PATH=$(which protoc)
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:${PROTOC_PATH%/bin/protoc}/lib/pkgconfig

git --version
git config --global push.default simple
git config --global user.name $GITHUB_USER
git config --global user.email $GITHUB_EMAIL

echo "Building $PACKAGE"
npm install
if [ $? -ne 0 ]; then echo "npm install"; exit 10; fi
node_modules/gulp/bin/gulp.js coffee
node_modules/mocha/bin/mocha --compilers=coffee:coffee-script/register test/*.coffee --reporter=tap > test-report.xml
node_modules/gulp/bin/gulp.js coverage
if [ $? -ne 0 ]; then echo "Tests failed"; exit 10; fi
VERSION=`npm version patch`
echo $VERSION
git add package.json
git add lib/*.js
git commit -m"Adding built javascript files."
git push origin master
