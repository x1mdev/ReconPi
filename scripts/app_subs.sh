while read -r line
do
    echo "$line.$2" >> $3
done < $1