#!/bin/sh

thresholdPercentage=85
emailAddress=jonas@jonaskoperdraat.nl

df -H | grep -vE '^Filesystem|tmpfs' | awk '{ print $5 " " $1 }' | while read output
do
	usagePercentage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1 )
	partition=$(echo $output | awk '{ print $2 }')
	if [ $usagePercentage -ge $thresholdPercentage ] ; then
		echo "Running out of space \"${partition} (${usagePercentage}%)\" on $(hostname) as on $(date)" |
		mail -s "Almost out of disk space (${partition} - ${usagePercentage})" ${emailAddress}
		echo -n "\033[0;31m"
	fi
	echo "${output}\033[0m" 
done
