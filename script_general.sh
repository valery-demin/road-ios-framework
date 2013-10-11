#!/bin/bash

# =================     Set environment variables     ===========
export WORKSPACE="-workspace Framework/ROADFramework.xcworkspace"
export PROJECT="-project tools/ROADAttributesCodeGenerator/ROADAttributesCodeGenerator.xcodeproj"
if [[ $PROJECT_SCHEME == ROADAttributesCodeGenerator ]]; then export PATCH_FOR_PROJECT_OR_WORKSPACE=$PROJECT; else export PATCH_FOR_PROJECT_OR_WORKSPACE=$WORKSPACE; fi

# =================     Install cpp-coveralls    ===========
sudo easy_install cpp-coveralls > /dev/null

# =================     Run build, test and oclint check     ===========
xctool $PATCH_FOR_PROJECT_OR_WORKSPACE -scheme $PROJECT_SCHEME -reporter pretty -reporter json-compilation-database:compile_commands.json build
if [[ $PROJECT_SCHEME != ROADAttributesCodeGenerator ]]; then xctool $WORKSPACE -scheme $PROJECT_SCHEME test -sdk iphonesimulator; fi	

# =================     Download oclint, unzip    ===========
wget http://archives.oclint.org/releases/0.7/oclint-0.7-x86_64-apple-darwin-10.tar.gz > /dev/null
tar xzf oclint-0.7-x86_64-apple-darwin-10.tar.gz > /dev/null

# =================     Remove necessary rules from "lib/oclint/rules/" folder of oclint     ===========
rm $('pwd')/oclint-0.7-x86_64-apple-darwin-10/lib/oclint/rules/libUnusedMethodParameterRule.dylib
# ======================================================================================================

# =================     Setup oclint    ===========
OCLINT_HOME=$('pwd')/oclint-0.7-x86_64-apple-darwin-10
PATH=$OCLINT_HOME/bin:$PATH

# =================     Run oclint    ===========
oclint-json-compilation-database -- -rc=LONG_LINE=500 -rc=LONG_VARIABLE_NAME=50 -max-priority-2 30 -max-priority-3 80
