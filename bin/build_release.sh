#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http:# www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function quit {
    exit 1
}
trap quit 1 2 3 15  #Ctrl+C exits.

RELEASE=`cat VERSION`
LEIN=`which lein2 || which lein` 
export LEIN_ROOT=1

echo Making release $RELEASE

DIR=`pwd`/_release/storm-$RELEASE

rm -rf _release
rm -f *.zip
rm -f *.tar.gz
#$LEIN pom || exit 1
mkdir -p $DIR/lib

#sh bin/build_modules.sh
MODULES=storm-core
#for module in $(cat MODULES)
for module in $MODULES
do
	echo cd $module
	cd $module
	mvn dependency:copy-dependencies || exit 1
	cp -f target/dependency/*.jar $DIR/lib/
    rm -f target/original-storm-core-*.jar
	rm -f target/storm-core*-javadoc.jar
	rm -f target/storm-core*-sources.jar
	cp -f target/storm-core*.jar $DIR/lib/
	cd ..
done

# remove unused dependencies
rm -f $DIR/lib/jackson*.jar
rm -f $DIR/lib/clojure-complete*.jar
rm -f $DIR/lib/conjure-*.jar
rm -f $DIR/lib/mockito*.jar
rm -f $DIR/lib/netty-3.2.2*.jar
rm -f $DIR/lib/nrepl*.jar
rm -f $DIR/lib/libthrift-*.jar

cd _release/storm-$RELEASE
for i in *.jar
do
	echo rm -f lib/$i
done 
cd ../..

cp CHANGELOG.md $DIR/

echo $RELEASE > $DIR/RELEASE

mkdir -p $DIR/logback
mkdir -p $DIR/logs
cp -R logback/cluster.xml $DIR/logback/cluster.xml

mkdir $DIR/conf
cp conf/storm.yaml.example $DIR/conf/storm.yaml

cp -R storm-core/src/ui/public $DIR/

cp -R bin $DIR/

cp README.markdown $DIR/
cp LICENSE.html $DIR/

cd _release
zip -r storm-$RELEASE.zip *
mv storm-*.zip ../
tar -cvzf ../storm-$RELEASE.tar.gz ./

cd ..

#rm -rf _release

