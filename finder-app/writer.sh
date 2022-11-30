#!/bin/bash

# Check that two arguments were given
if [ ! $# -eq 2 ]
then
  echo "Error. Enter file path and string to write as parameters"
  exit 1
fi

writefile=$1
writestr=$2

# Check that both arguments are correct
if [ -z $writestr ]
then
  echo "Error empty or invalid string."
  exit 1
elif [ ! -e $writefile ]
then
  echo "File does not exist. Creating file and directory at $writedir."
  filedir=${writefile%/*}
  if [ ! -d $filedir ]
  then
    mkdir $filedir
  fi
fi

echo "Writing $writestr to $writefile."
echo $writestr > $writefile
exit 0
