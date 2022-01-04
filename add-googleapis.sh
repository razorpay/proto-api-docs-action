#!/bin/sh
set -e

mkdir /googleapis
cd /googleapis
git init
git config --local gc.auto 0
git config core.sparseCheckout true
git remote add origin https://github.com/googleapis/googleapis.git
echo "google/" > .git/info/sparse-checkout
git fetch --no-tags --prune --depth=1 origin master
git checkout master
rm -rf .git
cd /proto
ln -s /googleapis/google google