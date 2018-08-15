#!/bin/bash

if ! which curl > /dev/null 2> /dev/null; then
  echo "curl not installed" 1>&2
  exit 2
fi

nsupdate() {
  true
}

. "$CONFIG" # pre-load config

get_last() {
  file="/tmp/nsupdate-sh-v$1"
  if [ -e "$file" ]; then
    cat "$file"
  else
    echo "none"
  fi
}

set_last() {
  file="/tmp/nsupdate-sh-v$1"
  ip="$2"
  if [ -z "$ip" ]; then
    ip="none"
  fi

  echo "$ip" > "$file"
}

send_update() {
  upurl="https://$name:$pw@ipv$1.nsupdate.info/nic/$2$3"
  echo -n "Sending update for IPv$1 $name (action $2)... "
  cmdok=false
  ex=0
  out=$(curl -s "$upurl" || ex=$?)
  if [ "$ex" -ne 0 ]; then
    echo "ERROR: Curl error $ex"
  elif [[ "$out" == "good"* ]] || [[ "$out" == "nochg"* ]]; then
    cmdok=true
    echo "ok"
  else
    echo "ERROR: response was '$out'"
  fi
}

nsupdate() {
  name="$1"
  pw="$2"
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Must be 'nsupdate $name $pw'"
  fi

  lv4=$(get_last 4-$name)
  lv6=$(get_last 6-$name)

  echo "Update $name..."

  if $v4fail && [ "$lv4" != "none" ]; then
    send_update 4 delete
  elif ! $v4fail && [ "$lv4" != "$v4" ]; then
    send_update 4 update "?myip=$v4"
  fi

  if $cmdok; then
    set_last "4-$name" "$v4"
  fi

  if $v6fail && [ "$lv6" != "none" ]; then
    send_update 6 delete
  elif ! $v6fail && [ "$lv6" != "$v6" ]; then
    send_update 6 update "?myip=$v6"
  fi

  if $cmdok; then
    set_last "6-$name" "$v6"
  fi
}

main() {
  v4fail=false
  v6fail=false
  v4=$(curl -s https://ipv4.nsupdate.info/myip || (v4fail=true && echo none))
  v6=$(curl -s https://ipv6.nsupdate.info/myip || (v6fail=true && echo none))

  if $v4fail && $v6fail; then
    echo "Looks like you're offline... not doing anything"
    return 0
  fi

  echo "Updating..."

  . "$CONFIG"

  echo "Done!"
}

if [ -z "$LOOP" ]; then
  main
else
  echo "Updating every $LOOP..."
  while true; do
    main
    sleep "$LOOP"
  done
fi
