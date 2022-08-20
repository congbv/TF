
#!/usr/bin/bash
configFile=$(mktemp)

cat <<EOF> $configFile
comment="""
#comment here 
# NumberColumeConfig is fix colume config
#2022-08-18-21


"""
formatDate="%Y-%m-%d"

NumberColumeConfig=3

configLogs="""

path|zip after days|remove after days
/home/ubuntu/logs|30|700
/home/ubuntu/logKafka|30|700



"""

EOF
source $configFile
rm -f $configFile

checkConfig() {
  numCol=`echo $1|awk -F "|" {'print NF'}`
  if [ $numCol == $NumberColumeConfig ]; then
    echo 1
  else
    echo 0
  fi
}

getDayDelete() {
  dayGrep=""
  for num in `seq $1 800`
    do
      DATE=`date --date="$num days ago" "+$formatDate"`
      dayGrep="$DATE\|$dayGrep"
    done
  dayGrep="$dayGrep NOPE"
  echo $dayGrep
}

for cf in $configLogs
  do  
    chkcf=`checkConfig $cf`
    if [ $chkcf == 1 ]; then
      logpath=`echo $cf|awk -F "|" {'print $1'}`
      zipnum=`echo $cf|awk -F "|" {'print $2'}`
      delnum=`echo $cf|awk -F "|" {'print $3'}`
      if [ -d $logpath ]; then
        cd $logpath
        find . -maxdepth 1 -type f -mtime +$zipnum ! -name "tar.gz"|while read line
          do
            if [ -f $logpath/$fileName]; then
              fileName=`echo $line|awk -F "/" {'print $(NF)'}`
              su - root -c "cd $logpath && tar -czf $fileName.tar.gz $fileName"
              rm -f $fileName    
            fi
          done
        strGrep=`getDayDelete $delnum`
        ls|grep "$strGrep"|while read line
          do
            if [ -f $logpath/$line ]; then
            rm -f $line
            fi
          done
      fi
    fi
  done

