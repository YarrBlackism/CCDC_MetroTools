#!/bin/bash


function usetools {
  clear
  echo -e "\t Make sure to use sudo apt update before running"
  echo -e "\t installing rkhunter/rkhunter...."
  apt install -y clamav rkhunter
  echo -e "\t updating rkhunter"
  rkhunter --update

  echo "running rkhunter scan"
  rkhunter --check --sk --nocolors

  echo "running clamav scan"
  clamscan -r --bell -i 2>/dev/null
  echo
  read -n 1 -p "Scan complete press any key to return to menu..."
}

function checkps {
  clear
  P=/root/ps
  ps --ppid 2 -p 2 -N -o user=,args= | sort -u >$P.now
  if [ ! -f $P.base ]; then
    cp $P.now $P.base
    echo "Baseline saved. Run this again later to see what's new."
  else
    comm -13 $P.base $P.now >$P.new
    if [ -s $P.new ]; then
      echo -e "NEW since baseline:\n"
      cat $P.new
      echo
      read -n 1 -p "Add these to the baseline as normal? (y/n) " ans
      [ "$ans" = y ] && sort -u $P.base $P.new -o $P.base
    else
      echo "Nothing new since baseline."
    fi
  fi
  echo
  read -n 1 -p "Press any key to return to menu"

}


function checkcron {
  clear
  C=/root/cron
  grep -H '^[^#]' /etc/crontab /etc/cron.d/* /etc/anacrontab /var/spool/cron/crontabs/* 2>/dev/null > $C.now
  md5sum /etc/cron.*/* /var/spool/cron/*/* 2>/dev/null >> $C.now
  systemctl list-timers --all --no-legend 2>/dev/null | awk '{print "timer:", $(NF-1), $NF}' >> $C.now
  sort -u $C.now -o $C.now
  if [ ! -f $C.base ]; then
    cp $C.now $C.base
    echo -e "Baseline saved.\n"
    cat -v $C.base
  else
    comm -13 $C.base $C.now > $C.new
    if [ -s $C.new ]; then
      echo -e "NEW since baseline:\n"
      cat -v $C.new
      echo
      read -n 1 -p "Add to baseline (y/n) " ans
      [ "$ans" = y ] && sort -u $C.base $C.new -o $C.base
    else
      echo "Nothing new since baseline."
    fi
  fi
  echo
  read -n 1 -p "Press any key to return to menu..."
}

function checksock {
  clear
  echo "....packet/raw sockets...."
  ss -0pa
  ss -wpa
  echo
  read -n 1 -p "Press any key to return to menu..."    
}

function checklocked {
clear
echo "check for locked files"
lsattr -Ra /etc /root /home /var/spool/cron /usr/local /usr/bin /usr/sbin 2>/dev/null | grep -E '^[-a-zA-Z]*[ia][-a-zA-Z]* /'
echo
read -n 1 -p "Press any key to return to menu..."
}

function menu {
  clear
  echo
    cat << 'EOF'
  
   ▄▀▄▄▄▄   ▄▀▄▄▄▄   ▄▀▀█▄▄   ▄▀▄▄▄▄  
  █ █    ▌ █ █    ▌ █ ▄▀   █ █ █    ▌ 
  ▐ █      ▐ █      ▐ █    █ ▐ █      
    █        █        █    █   █      
   ▄▀▄▄▄▄▀  ▄▀▄▄▄▄▀  ▄▀▄▄▄▄▀  ▄▀▄▄▄▄▀ 
  █     ▐  █     ▐  █     ▐  █     ▐  
  ▐        ▐        ▐        ▐        
  
      Blacksim ccdc toolkit
EOF
  
  echo -e "\t\t\t Toolkit MENU:\n"
  echo -e "\t1. check sockets."
  echo -e "\t2. check ps."
  echo -e "\t3. check cron"
  echo -e "\t4. check locked files"
  echo -e "\t5. usetools rkhunter/clamAV:"
  echo -e "\t\t Enter option:"
  echo -e "\t. press q to quit:"
  read -n 1 option
  case $option in
  1) checksock ;;
  2) checkps ;;
  3) checkcron ;;
  4) checklocked ;;
  5) usetools ;;
  q) exit ;;
  esac
}

while true; do menu; done


[ $EUID = 0 ] || { echo "Whats the magic word "; exit 1; }
export LC_ALL=C
