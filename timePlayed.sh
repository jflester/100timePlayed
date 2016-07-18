#!/bin/bash

clear

########################################
####    the100.io TimePlayed v2.6   ####
####  Calls Bungie API to get grim  ####
#### 	  the100:  /u/L0r3          ####
####      Reddit:  /u/L0r3_Titan    ####
####      Twitter: @L0r3_Titan      ####
########################################


#### INCLUDE FILE WITH YOUR BUNGIE API KEY ####
source ${BASH_SOURCE[0]/%timePlayed.sh/apiKey.sh}
source ${BASH_SOURCE[0]/%timePlayed.sh/hundredMembers.sh}

#######################################
#### BEGIN 100 MEMBER LIST SECTION ####
#######################################

#### CALL FUNCTION TO SCRAPE THE100 MEMBERS ####
hundredMembers

#####################################
#### END 100 MEMBER LIST SECTION ####
#####################################

#### XBOX OR PSN ####
selectedAccountType='1'

#### SOURCE OF USERS TO PROCESS (this is produced by scraper) ####
playerList="/tmp/100_usersClean.txt"
echo

### MEMBER ID ###
funcMemID ()
{
getUser=`curl -s -X GET \
-H "Content-Type: application/json" -H "Accept: application/xml" -H "$authKey" \
"https://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/$selectedAccountType/$player/"`
memID=`echo "$getUser" | grep -o 'membershipId.*' | cut -c 16- | sed 's/displayName.*[^displayName]*//' | rev | cut -c 4- | rev`
}

funcTimePlayed ()
{
getCharacterData=`curl -s -X GET \
-H "Content-Type: application/json" -H "Accept: application/xml" -H "$authKey" \
"https://www.bungie.net/Platform/Destiny/$selectedAccountType/Account/$memID/"`
charID_A=`echo "$getCharacterData" | grep -o 'characterId.*' | cut -c 15- | sed 's/dateLastPlayed.*[^dateLastPlayed]*//' | rev | cut -c 4- | rev`
charID_B=`echo "$getCharacterData" | grep -o "$charID_A.*" | cut -c 20- | grep -o 'characterId.*' | cut -c 15- | sed 's/dateLastPlayed.*[^dateLastPlayed]*//' | rev | cut -c 4- | rev`
charID_C=`echo "$getCharacterData" | grep -o "$charID_B.*" | cut -c 20- | grep -o 'characterId.*' | cut -c 15- | sed 's/dateLastPlayed.*[^dateLastPlayed]*//' | rev | cut -c 4- | rev`
characterAtime=`echo "$getCharacterData" | grep -o "$charID_A.*" | cut -c 1- | sed 's/powerLevel.*[^powerLevel]*//' | rev | cut -c 4- | sed 's/latoTdeyalPsetunim.*[^latoTdeyalPsetunim]*//' | rev | cut -c 4-`
characterBtime=`echo "$getCharacterData" | grep -o "$charID_B.*" | cut -c 1- | sed 's/powerLevel.*[^powerLevel]*//' | rev | cut -c 4- | sed 's/latoTdeyalPsetunim.*[^latoTdeyalPsetunim]*//' | rev | cut -c 4-`
characterCtime=`echo "$getCharacterData" | grep -o "$charID_C.*" | cut -c 1- | sed 's/powerLevel.*[^powerLevel]*//' | rev | cut -c 4- | sed 's/latoTdeyalPsetunim.*[^latoTdeyalPsetunim]*//' | rev | cut -c 4-`
let totalMins=$characterAtime+$characterBtime+$characterCtime
let totalHours=$totalMins/60
let totalDays=$totalHours/24
}

let playerCnt='0'

while read 'player'; do
	funcMemID
	#funcGrimAll
	funcTimePlayed
	#grimCurrent=`echo "$grimAll" | grep -o 'score":.*'| sed 's/cardCollection.*[^cardCollection]*//' | cut -c 8- | rev | cut -c 3- | rev`
	memberHours="$totalHours,$player"
	let playerCnt=playerCnt+1
	grimArr[$playerCnt]="$memberHours"
done < "$playerList"

function arrSort 
{ for i in ${grimArr[@]}; do echo "$i"; done | sort -n -r -s ; }

grimScoresSort=( $(arrSort) )
printf '%s\n' "${grimScoresSort[@]}"

exit



