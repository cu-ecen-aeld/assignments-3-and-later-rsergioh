#!/bin/sh

# Check that two arguments were given
if [ ! $# -eq 2 ]
then
  echo "Error. Enter file directory and string to search as parameters"
  exit 1
fi

filesdir=$1
searchstr=$2

# Check that both arguments are correct
if [ ! -d $filesdir ]
then
  echo "Error $filesdir is not a directory."
  exit 1
elif [ -z $searchstr ]
then
  echo "Error empty or invalid search pattern."
  exit 1
fi

filesdir="${filesdir}/*"

matchnum=$(grep -o -i $searchstr $filesdir | wc -l)
filenum=$(grep -l -i $searchstr $filesdir | wc -l)

echo "The number of files are $filenum and the number of matching lines are $matchnum."
exit 0

