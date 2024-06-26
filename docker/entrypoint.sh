#!/bin/bash

if [ "$1" == version ]; then
  . $USER_VENV/bin/activate

  set -e

  cd /home/gdal
  git clone https://${GITHUB_TOKEN}:@github.com/dustymugs/gdal-venv.git gdal-venv

  cd gdal-venv
  git remote set-url origin "https://${GITHUB_TOKEN}:@github.com/dustymugs/gdal-venv.git"

  VERSION="$2"
  PUBLISH="$3"
  BRANCH="v$VERSION"
  MESSAGE="Add GDAL $VERSION"

  ARCHIVE="v$VERSION.tar.gz"
  URL="https://github.com/OSGeo/gdal/archive/$ARCHIVE"
  LOCAL="/tmp/$ARCHIVE"
  wget $URL -O $LOCAL

  git checkout -b "$BRANCH"
  python import.py "$VERSION"
  echo "$VERSION" >> VERSIONS
  git add .
  git commit -m "$MESSAGE"
  git push origin "$BRANCH"
  gh pr create -B main --title "$MESSAGE" --body "Done by deploy docker image"
  gh pr merge -m -b "automated merge" "$BRANCH"

  if [ -n "$PUBLISH" ]; then
    cd /tmp
    mkdir gdal
    tar xf $LOCAL -C gdal --strip-components=1
    cd gdal
    if [ -d ./gdal ]; then
      cd gdal
    fi
    if [ -f ./CMakeLists.txt ]; then
      mkdir build
      cd build
      cmake ..
      cmake --build .
    else
      ./autogen.sh
      ./configure
      make
    fi
    export PATH="$(pwd)/apps:$PATH"

    cd /home/gdal/gdal-venv
    ./publish $VERSION
  fi
else
  exec "$@"
fi
