#!/usr/bin/bash

CURRENT_PAGE=1
TERM=$(echo "$*" | tr " " "+")
RESULT=()

query () {
	QUERY="https://fitgirl-repacks.site/page/$CURRENT_PAGE/?s=$TERM"
	RESULTS=($(curl -s "$QUERY" | grep -E "entry-title" |\
		grep -Eo "https://fitgirl-repacks.site/[^\"]*"))
}

show_results () {
	for i in ${!RESULTS[@]}
	do
		option=${RESULTS[$i]}
		name=$(echo "$option" | cut -d "/" -f4 | tr "-" " ")
		echo "$i - $name"
	done
}

query
show_results

if [ ${#RESULTS[@]} -eq 0 ]
then
	echo "No results"
	exit
fi

echo -n "Chose one (page: $CURRENT_PAGE n: next/p: prev): "
read SELECTION

while [ $SELECTION == "n" ] || [ $SELECTION == "p" ]
do

	if [ $SELECTION == "n" ]
	then
		CURRENT_PAGE=$(($CURRENT_PAGE + 1))
	else
		CURRENT_PAGE=$(($CURRENT_PAGE - 1))
	fi

	if [ $CURRENT_PAGE -lt 1 ]
	then
		CURRENT_PAGE=1
	fi

	query
	show_results
	
	if [ ${#RESULTS[@]} -eq 0 ]
	then
		echo "No more results"
		SELECTION="p"
	else
		echo -n "Chose one (page: $CURRENT_PAGE | n: next | p: prev): "
		read SELECTION
	fi
done

MAGNET=$(curl -s ${RESULTS[$SELECTION]} | grep -Eo "magnet:\?[^\"]*")

qbittorrent "$MAGNET" &
