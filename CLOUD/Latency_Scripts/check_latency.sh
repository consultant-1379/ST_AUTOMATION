#!/bin/bash

function check_latency_code ()
{
        code=$1
        FILE_LAT=$2
	if [ -f $FILE_LAT ]
	then
	     echo "==============  Calculating Latency for code $code  ===================="
	else
	     echo "$FILE_LAT does not exist. Please verify."
	     exit
	fi

awk ' BEGIN{min_n=99999; max_n=0; sum=0} 
      $2=="'$code'" {
            if ($3 < min_n) {min_n=$3}; 
            if ($3 > max_n) {max_n=$3}; 
            x[NR] = $3; 
            sum+=$3} 
      END {
           print "MIN = "min_n; 
           print "MAX = "max_n;
           a=sum/NR; for (i in x){ss += (x[i]-a)^2} sd = sqrt(ss/NR); print "STANDARD DEVIATION = "sd; 
           a=sum/NR; ss=0; for (i in x){if (x[i]>a) {ss += (x[i]-a)} else {ss += (a-x[i])}}; md = ss/NR; print "AVERAGE DEVIATION = "md; 
           med=sum/NR; print "AVERAGE = "med }  
     ' $FILE_LAT

}


FILE=$1
if [ -f $FILE ]
then
     echo "Processing file $FILE"
else
     echo "$FILE does not exist. Please verify."
     exit
fi
awk ' NR>2 && NF==3 { print $0} ' $FILE >$FILE.DAT
sort -k 2 $FILE.DAT >$FILE.DAT2

list_codes=`awk ' BEGIN{code_lat=0} 
      		{ if ($2 != code_last) {code_last=$2; print code_last};} 
     		' $FILE.DAT2 `
for code in $list_codes
do
        awk ' $2=="'$code'" {print $0} ' $FILE.DAT >$FILE.$code
	check_latency_code $code $FILE.$code
        rm $FILE.$code
done

echo "==============  Calculating TOTAL Latency  ===================="
awk ' BEGIN{min_n=99999; max_n=0; sum=0} 
      NF==3 {
            if ($3 < min_n) {min_n=$3}; 
            if ($3 > max_n) {max_n=$3}; 
            x[NR] = $3; 
            sum+=$3} 
      END {
           print "MIN = "min_n; 
           print "MAX = "max_n;
           a=sum/NR; for (i in x){ss += (x[i]-a)^2} sd = sqrt(ss/NR); print "STANDARD DEVIATION = "sd; 
           a=sum/NR; ss=0; for (i in x){if (x[i]>a) {ss += (x[i]-a)} else {ss += (a-x[i])}}; md = ss/NR; print "AVERAGE DEVIATION = "md; 
           med=sum/NR; print "AVERAGE = "med }  
     ' $FILE.DAT
rm $FILE.DAT $FILE.DAT2 2>/dev/null

