#!/bin/bash

readonly BASEDIR=$HOME
readonly WORKDIR=$BASEDIR/Documents/

rsync -avOpg --delete --exclude=".git" $WORKDIR/myblog/public/ $WORKDIR/taylor840326.github.io/
