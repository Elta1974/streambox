#!/bin/bash

http_log=
ram_path=
istreamdev_log=

timeout_seconds=1800

#78.31.46.6 - - [07/Jun/2012:18:40:20 +0200] "GET /ram/sessions/session0/stream-5.ts HTTP/1.1" 200 857766

for session in `\ls $ram_path/sessions/ | grep session`;
do
	# Check last time session was accessed
	last_get="`cat $http_log | grep "GET /ram/sessions/$session/stream.m3u8" | tail -n 1`"
	last_date="`echo "$last_get" | awk -F\[ '{ print $2 }' | awk -F\] '{ print $1 }'`"
	last_date="`echo $last_date | sed -e 's/\//\ /g' | sed -e 's/\:/\ /'`"

	last_date_num="`LANG= date -d "$last_date" +%s`"
	current_date_num="`LANG= date +%s`"

	if [ $((current_date_num - last_date_num)) -gt $timeout_seconds ]
	then
		echo "`date +"[%Y/%m/%d %H:%M:%S]"` Killing inactive session $session" >> $istreamdev_log
		find $ram_path -type l -name "$session" -exec rm {} \;
		rm $ram_path/sessions/$session/*
		rmdir $ram_path/sessions/$session
	fi
done
