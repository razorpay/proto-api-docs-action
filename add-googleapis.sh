#!/bin/sh
set -e

mkdir /googleapis
cd /googleapis
git init
git config --local gc.auto 0
git config core.sparseCheckout true
git remote add origin https://github.com/googleapis/googleapis.git
echo "google/" > .git/info/sparse-checkout
git -c protocol.version=2 fetch --no-tags --prune --depth=1 origin master
git checkout master
ls
rm -rf .git
cd ../proto
ls
ln -s ../googleapis/google google