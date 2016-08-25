#!/bin/bash

# Updates nodejs-distributions to the given nodejs version.
# requires: sh, curl, tar (only tested on macOS).

# IMPORTANT NOTE: this script does some removal of directories. Handle with care!

NODEJS_VERSION=$1

DOWNLOAD_URL_PREFIX="http://nodejs.org/dist/v$NODEJS_VERSION"

NPM_URL_PREFIX="http://nodejs.org/dist/npm"

function error_exit
{
	echo "$1" 1>&2
	exit 1
}


## Downloads nodejs and extracts it into the current directory
downloadNodeJs(){
  local platform=$1

  local filename="node-v$NODEJS_VERSION-$platform"
  local downloadUrl="$DOWNLOAD_URL_PREFIX/$filename.tar.gz"
  echo "downloading $downloadUrl"
  rm -f temp_tar
  mkdir temp_tar
  cd temp_tar
  curl -# -f -o nodejs.tar.gz $downloadUrl || error_exit "Error while downloading $downloadUrl"

  echo "Extracting node binary from tarfile.."

  tar zxf nodejs.tar.gz || error_exit "Error while extracting node binary from downloaded .tar.gz"
  cp $filename/bin/node ../node || error_exit "Error while copying node binary"
  cp -r $filename/lib .. || error_exit "Error while copying node_modules"
  cd ..
  rm -Rf temp_tar || error_exit "Error while cleaning up download directory"
}

downloadAndExtractNodeJsWindows(){
  local platform=$1

  local filename="node-v$NODEJS_VERSION-$platform"
  local downloadUrl="$DOWNLOAD_URL_PREFIX/$filename.zip"

  echo "downloading node.exe $downloadUrl"
  rm -f temp_tar
  mkdir temp_tar
  cd temp_tar

  curl -# -f -o node.zip $downloadUrl || error_exit "Error while downloading $downloadUrl"
  unzip -qq node.zip || error_exit "Cannot unzip windows version"
  cp $filename/node.exe ../node.exe || error_exit "Error while copying node binary"
  cp -r $filename/node_modules .. || error_exit "Error while copying node_modules"

  rm -r $filename
  cd ..
  rm -Rf temp_tar || error_exit "Error while cleaning up download directory"
}


# enter a dist subdir, clear contents and download & extract nodejs into it
updateDistDirectory() {
  local directory=$1
  local platform=$2

  cd $1 || error_exit "Could not change to $directory"
  rm -Rf * || error_exit "Could not delete contents of directory $directory"

  if [[ "$platform" == win* ]]; then
    downloadAndExtractNodeJsWindows $platform
  else
    downloadNodeJs $platform
  fi

  cd ..
}

if [ -z "$1" ]
  then
    error_exit "Please supply a nodejs version to download"
fi

updateDistDirectory "macos-x64" "darwin-x64"

updateDistDirectory "linux-x86" "linux-x86"
updateDistDirectory "linux-x64" "linux-x64"

updateDistDirectory "win-x86" "win-x86"
updateDistDirectory "win-x64" "win-x64"


echo "finished!"

