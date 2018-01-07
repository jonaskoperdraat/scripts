#!/bin/sh

db_user=$1
shift
db_pass=$1

#
# Dit script is bedoelt om actuele waarnemingen van de KNMI website te halen.

content=$(wget -q --no-cache -O - http://www.knmi.nl/nederland-nu/weer/waarnemingen)
#echo ${content}


# Controleer of de kolommen nog overeen komen met de situatie toen dit script opgesteld werd:I
if [ $(echo ${content} | grep -c '<thead> <tr> <th scope="col" data-sorted="true" class="">Station</th> <th scope="col" data-sorted="false" class="">Weer</th> <th scope="col" data-sorted="false" class="">Temp (&deg;C)</th> <th scope="col" data-sorted="false" class="">Chill (&deg;C)</th> <th scope="col" data-sorted="false" class="">RV (%)</th> <th scope="col" data-sorted="false" class="">Wind</th> <th scope="col" data-sorted="false" class="">Wind (m/s)</th> <th scope="col" data-sorted="false" class="">Zicht (m)</th> <th scope="col" data-sorted="false" class="">Druk (hPa)</th> </tr> </thead>') -ne 1 ]
then
	echo "Columns no longer match grep definitions. Time to revisit this script".
	exit 1;
fi

#Tijd van waarneming
tijdstip=$(echo ${content} | grep -oP 'Waarnemingen \K\d.*?uur')

#Temperatuur
temperatuur=$(echo ${content} | grep -oP '<tr> <td class="">De Bilt</td> <td class="">[\w ]*</td> <td class="">\K[\d\.]+')

# Vochtigheid
rv=$(echo ${content} | grep -oP '<tr> <td class="">De Bilt</td>( <td class="">[\w \d\.-]*</td>){3} <td class="">\K[\d\.]+')

# Druk
druk=$(echo ${content} | grep -oP '<tr> <td class="">De Bilt</td>( <td class="">[\w \d\.-]*</td>){7} <td class="">\K[\d\.]+')

echo "Meting KNMI station De Bilt"
echo "Tijdstip   : ${tijdstip}"
echo "Temp (C)   : ${temperatuur}"
echo "RV (%)     : ${rv}"
echo "Druk (hPa) : ${druk}"

query='insert into Measurement (sensorStationId, tsMeasured, temperature, humidity, pressure, remark) values (1, now(), '${temperatuur}', '${rv}', '${druk}', '"\"${tijdstip}\""' );' 

echo "query: ${query}"

# Store the data into the database
mysql -u ${db_user} --password=${db_pass} -e "${query}" climate

# Controleer of het statement juist is uitgevoerd
if [ "$?" = "0" ]; then
	echo "De gegevens zijn opgeslagen in de database."
	exit 0
else
	echo "Er is een fout opgetreden bij het wegschrijven van de gegevens naar de database."
	exit 1
fi
