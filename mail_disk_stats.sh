#!/bin/bash
#
# Script written by Jan-Bernard Marsman
# To send mail regarding statistics on disk usage
#
# NeuroImaging Center, Dept. of Neuroscience
# UMCG
#
# 14/12/2017
#
# J.B.C.Marsman@umcg.nl
#

# Circumvent bug in sendmail which prevents multiple recipients...
TO=( fmri@umcg.nl j.b.c.marsman@umcg.nl )


REPLYTO="j.b.c.marsman@umcg.nl"
SUBJECT="[XNAT_UMCG] Disk usage on XNAT UMCG"

# Calculate disk statistics via du (disk usage)
stats1=`du -h --max-depth=1 /data/xnat/ | grep "pre\|cache\|ftp" | sort -h -r`
stats2=`du -h --max-depth=1 /data/xnat/archive/ | sort -h -r`

IFS=$'\n'
 
# Calculate in percentage of disk space
percentage=`df -h  | grep xnat_mic | awk '{print $5}'`
number=`echo $percentage | awk -F '%' '{print $1} '`

# Rule based mailing whether action is needed
if [ "$number" -lt "90" ]; then
    pcolor="#FF7F50"
    action="You might want to consider some cleanup."
    if [ "$number" -lt "80" ]; then
	pcolor="#008000"
	action="No action needed."
    fi
else
    pcolor="#FF2020"
    action="Immediate actions required to prevent the system from crashing/malfunctioning"
fi 

TEXT+="<li><h3><b>Archive usage (disk usage <font color=$pcolor>$percentage</font>)</b></h3>"
TEXT+="<hr>"
TEXT+="<ul>"

# Generate mail body
for line in ${stats2[*]} 
do
    SIZE1=`echo $line | awk '{print $1}'`
    SIZE2=`printf '%10s' "$SIZE1"`
    TEXT+="<li>"
    TEXT+=$SIZE2

    TEXT+="&nbsp; &nbsp; &nbsp; "
    TEXT+=`echo $line | awk '{print $2}'`
    TEXT+="</li>" 
done

TEXT+="</ul><hr>"

TEXT+="<b><li>Other XNAT System usage :</b>"
TEXT+="<ul>" 

for line in ${stats1[*]}
do
    TEXT+="<li>$line</li>"
done

TEXT+="</ul></li>" 
TEXT+="<p>$action</p>"
TEXT+="<p>Yours truly,</p>"
TEXT+="Jan-Bernard Marsman"
TEXT+="</html>"


# Send to each recipient in TO the generated email
for TO_item in ${TO[*]}
do
    echo -e "From: "XNAT UMCG - MRI Imaging Archive" <${USER}@${HOSTNAME}>\nTo: <${TO_item}>\nSubject: ${SUBJECT}\nReply-To: ${REPLYTO}\nDate: $(date "+%a, %d %b %Y %H:%M:%S %z")\nContent-Type: text/html; charset=utf-8\n\n<!DOCTYPE html>\n$TEXT" | sendmail -i ${TO_item}
done



