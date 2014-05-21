#!/bin/bash

datafile=$1
fitykfile=$datafile.fit

###############
function tofit() {
echo -e $@ >> $fitykfile
}
##############

# init fit file
echo -e "">$fitykfile
#first load the file
tofit "@+ < ’${datafile}’"


#tofit "s=sqrt(abs(y))"
tofit "s=sqrt(abs(y-0.9))"

#when we have negative values some can be close to zero causing them to have far too much weight!
#fix this problem not here. !
#having our BG around 1 we take the lowest value as reference resulting in \pm 1 as scatter and finally shifting that to 1+eps=0.2
#tofit "s=(y-1)/abs(min(y-1))+2.2"
#tofit "s=s/min(s)"

tofit "info @0 (x, y, s) > ’${datafile}.weighted.dat’"

tofit "quit"

fityk $fitykfile
remove_comments.sh ${datafile}.weighted.dat
