# pgn4web javascript chessboard
# copyright (C) 2009-2016 Paolo Casaschi
# see README file and http://pgn4web.casaschi.net
# for credits, license and more details

# bash script to package the pgn4web release
# run as "bash script.sh"

set +o posix

pgn4webVer=$(grep "var pgn4web_version = " pgn4web.js | awk -F "'" '{print$2}')

pgn4webFilename="pgn4web-$pgn4webVer.zip"

if [ -e ../"$pgn4webFilename" ]; then
  echo "Error: pgn4web package already exists (../$pgn4webFilename)"
  exit 1
fi

pgn4webDirectory="pgn4web-$pgn4webVer"
if [ -e ../"$pgn4webDirectory" ]; then
  echo "Error: pgn4web directory already exists (../$pgn4webDirectory)"
  exit 1
fi

ln -s "$(pwd)" ../"$pgn4webDirectory"

cd ..
zip -9r "$pgn4webFilename" "$pgn4webDirectory" -x *.svn/*

rm $pgn4webDirectory

