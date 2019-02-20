#!/bin/bash
#
# Copyright 2017 Istio Authors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

set -o errexit

if [ "$#" -ne 1 ]; then
    echo Missing version parameter
    echo Usage: build-services.sh \<version\>
    exit 1
fi

VERSION=$1
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

pushd "$SCRIPTDIR/productpage"
  docker build -t "bookinfo-bench/examples-bookinfo-productpage:${VERSION}" -t bookinfo-bench/examples-bookinfo-productpage:latest .
popd

pushd "$SCRIPTDIR/reviews"
  #java build the app.
  docker run --rm -v "$(pwd)":/home/gradle/project -w /home/gradle/project gradle:4.8.1 gradle clean build
  #Docker for Windows
  #docker run --rm -v c:/Users/hhiroshell/Development/bookinfo-bench/bookinfo-bench/src/reviews:/home/gradle/project -w /home/gradle/project gradle:4.8.1 gradle clean build
  pushd reviews-wlpcfg
    #with ratings red stars
    docker build -t "bookinfo-bench/examples-bookinfo-reviews:${VERSION}" -t bookinfo-bench/examples-bookinfo-reviews:latest --build-arg service_version=v3 \
	   --build-arg enable_ratings=true --build-arg star_color=red .
  popd
popd

pushd "$SCRIPTDIR/ratings"
  docker build -t "bookinfo-bench/examples-bookinfo-ratings:${VERSION}" -t bookinfo-bench/examples-bookinfo-ratings:latest --build-arg service_version=v2 .
popd

pushd "$SCRIPTDIR/mysql"
  docker build -t "bookinfo-bench/examples-bookinfo-mysqldb:${VERSION}" -t bookinfo-bench/examples-bookinfo-mysqldb:latest .
popd
