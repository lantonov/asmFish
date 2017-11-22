# pgn4web javascript chessboard
# copyright (C) 2009-2016 Paolo Casaschi
# see README file and http://pgn4web.casaschi.net
# for credits, license and more details

# bash script to create a custom live games app bundle
# run as "bash script.sh"

set +o posix

pre="lga"

if [ "$1" == "--delete" ] || [ "$1" == "-d" ]; then
  id=$2
  if [[ $id =~ [^a-zA-Z0-9] ]]; then
    echo "error: id must be only letters and numbers: $id"
    exit 2
  fi
  del="$pre-$id"*
  if ls -1 $del 2> /dev/null; then
    echo
    read -p "Delete the $del file listed above (type YES to proceed)? " -r
    if [ "$REPLY" == "YES" ]; then
      rm -f $del
      echo "info: deleted $del files"
    else
      echo "info: $del files not deleted"
    fi
  else
    echo "info: $del files not found"
  fi
  exit 0
fi

id=$1
if [ -z "$id" ] || [ "$id" == "--help" ]; then
  echo "usage: $(basename $0) [--delete] id [pgn] [name] [appopt] [engopt] [userguide]"
  echo "please note: you can only deploy one bundle per domain (more bundles on the same domain would conflict on local storage)"
  exit 1
fi
if [[ $id =~ [^a-zA-Z0-9] ]]; then
  echo "error: id must be only letters and numbers: $id"
  exit 2
fi

pgn=$2
if [ -z "$pgn" ]; then
  pgn="live/live.pgn"
fi
# if [ ! -f "$pgn" ]; then
#  echo "error: pgn file not found: $pgn"
#  exit 3
# fi

name=$3
if [[ $name =~ [^a-zA-Z0-9\ \'#-] ]]; then
  echo "error: name must be only letters, numbers and spaces: $name"
  exit 4
fi

appopt=$4
if [[ -n $appopt ]]; then
  if [[ $appopt != \&* ]]; then
    echo "error: appopt must start with ampersand: $appopt"
    exit 5
  fi
  if [[ $appopt =~ [^a-zA-Z0-9.\&=] ]]; then
    echo "error: appopt must be only letters, numbers, dot, ampersand and equal: $appopt"
    exit 5
  fi
fi

engopt=$5
if [[ -n $engopt ]]; then
  if [[ $engopt != \&* ]]; then
    echo "error: engopt must start with ampersand: $engopt"
    exit 6
  fi
  if [[ $engopt =~ [^a-zA-Z0-9.\&=] ]]; then
    echo "error: engopt must be only letters, numbers, dot, ampersand and equal: $engopt"
    exit 6
  fi
fi

userguide=$6

cp live-games-app.php "$pre-$id.php"
sed -i.bak 's/live-games-app.appcache/'"$pre-$id.appcache"'/g' "$pre-$id.php"
sed -i.bak 's/live-games-app.json/'"$pre-$id.json"'/g' "$pre-$id.php"
sed -i.bak 's/live-games-app-engine/'"$pre-$id-engine"'/g' "$pre-$id.php"
sed -i.bak 's/live-games-app-icon-\([0-9]\+\)x\([0-9]\+\).\(png\|ico\)/'"$pre-$id-icon-\1x\2.\3"'/g' "$pre-$id.php"
sed -i.bak 's/live-games-app.pgn/'"$pre-$id.pgn"'/g' "$pre-$id.php"
if [[ -n $name ]]; then
  nameescaped=$(echo $name | sed -e 's/[\/&]/\\&/g')
  sed -i.bak "s/^\(\$appName = '\).*\(';$\)/\1$nameescaped\2/g" "$pre-$id.php"
fi
if [[ -n $appopt ]]; then
  sed -i.bak "s/\(\&pf=a' . '\)[^']*\('\)/\1${appopt//&/\\&}\2/g" "$pre-$id.php"
fi
if [[ -n $userguide ]]; then
  userguideescaped=$(echo $userguide | sed -e 's/[\/&]/\\&/g')
  sed -i.bak "s/^\(\$appUserGuide = '\).*\(';$\)/\1$userguideescaped\2/g" "$pre-$id.php"
fi
# sed -i.bak 's/enableLogging = false;/enableLogging = true;/g' "$pre-$id.php"
# set TZ=UTC
# echo $(date +"%Y-%m-%d %H:%M:%S +") >> "$pre-$id.log"
rm -f "$pre-$id.php.bak"

cp live-games-app-engine.php "$pre-$id-engine.php"
sed -i.bak 's/live-games-app-icon-\([0-9]\+\)x\([0-9]\+\).\(png\|ico\)/'"$pre-$id-icon-\1x\2.\3"'/g' "$pre-$id-engine.php"
if [[ -n $name ]]; then
  nameescaped=$(echo $name | sed -e 's/[\/&]/\\&/g')
  sed -i.bak "s/^\(\$appName = '\).*\(';$\)/\1$nameescaped\2/g" "$pre-$id-engine.php"
fi
if [[ -n $engopt ]]; then
  sed -i.bak "s/\(\&pf=a' . '\)[^']*\('\)/\1${engopt//&/\\&}\2/g" "$pre-$id-engine.php"
fi
rm -f "$pre-$id-engine.php.bak"

cp live-games-app.appcache "$pre-$id.appcache"
sed -i.bak 's/live-games-app.php/'"$pre-$id.php"'/g' "$pre-$id.appcache"
sed -i.bak 's/live-games-app-engine.php/'"$pre-$id-engine.php"'/g' "$pre-$id.appcache"
sed -i.bak 's/live-games-app-icon-\([0-9]\+\)x\([0-9]\+\).\(png\|ico\)/'"$pre-$id-icon-\1x\2.\3"'/g' "$pre-$id.appcache"
echo "# $(date)" >> "$pre-$id.appcache"
if [[ -n $name ]]; then
  sed -i.bak 's/Live Games/'"$name"'/g' "$pre-$id.appcache"
fi
rm -f "$pre-$id.appcache.bak"

cp live-games-app.json "$pre-$id.json"
sed -i.bak 's/live-games-app.php/'"$pre-$id.php"'/g' "$pre-$id.json"
sed -i.bak 's/live-games-app-icon-\([0-9]\+\)x\([0-9]\+\).\(png\|ico\)/'"$pre-$id-icon-\1x\2.\3"'/g' "$pre-$id.json"
if [[ -n $name ]]; then
  sed -i.bak 's/Live Games/'"$name"'/g' "$pre-$id.json"
fi
rm -f "$pre-$id.json.bak"

cp live-games-app.webapp "$pre-$id.webapp"
sed -i.bak 's/live-games-app.php/'"$pre-$id.php"'/g' "$pre-$id.webapp"
sed -i.bak 's/live-games-app-icon-\([0-9]\+\)x\([0-9]\+\).\(png\|ico\)/'"$pre-$id-icon-\1x\2.\3"'/g' "$pre-$id.webapp"
if [[ -n $name ]]; then
  sed -i.bak 's/Live Games/'"$name"'/g' "$pre-$id.webapp"
fi
rm -f "$pre-$id.webapp.bak"

cp live-games-app-icon-128x128.png "$pre-$id-icon-128x128.png"
cp live-games-app-icon-16x16.ico "$pre-$id-icon-16x16.ico"
cp live-games-app-icon-60x60.png "$pre-$id-icon-60x60.png"

rm -f "$pre-$id.pgn"
ln -s $pgn "$pre-$id.pgn"

echo -en "info: done $pre-$id.php with id=\"$id\""
if [[ -n $pgn ]]; then
  echo -n " pgn=\"$pgn\""
fi
if [[ -n $name ]]; then
  echo -n " name=\"$name\""
fi
if [[ -n $appopt ]]; then
  echo -n " appopt=\"$appopt\""
fi
if [[ -n $appopt ]]; then
  echo -n " appopt=\"$appopt\""
fi
if [[ -n $engopt ]]; then
  echo -n " engopt=\"$engopt\""
fi
if [[ -n $userguide ]]; then
  echo -n " userguide=\"$userguide\""
fi
echo

