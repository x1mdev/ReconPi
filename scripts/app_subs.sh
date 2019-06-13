#! /bin/sh
# @rub003 <3
while read -r line
do
    echo "$line.$2" >> $3
done < $1