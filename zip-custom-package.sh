# pgn4web javascript chessboard
# copyright (C) 2009-2016 Paolo Casaschi
# see README file and http://pgn4web.casaschi.net
# for credits, license and more details

# bash script to create a custom pgn4web package
# run as "bash script.sh"

set +o posix

pgn4webBaseFiles="README.txt pgn4web.js pgn4web-help.html license-gpl-2.0.txt pawn.ico pawn.png pawns.png index.html"

case "$1" in

  "board-minimal" ) pgn4webPackageFileList="$pgn4webBaseFiles board.html fide-lookup.js pgn-decoder.js images/index.html images/uscf/index.html images/uscf/README.txt images/uscf/20/* fonts/index.html fonts/README.txt fonts/chess-informant-NAG-symbols.js fonts/LiberationSans* fonts/pgn4web-font-LiberationSans.css fonts/ChessSansPiratf* fonts/pgn4web-font-ChessSansPiratf.css fonts/ChessInformantReader* fonts/pgn4web-font-ChessInformantReader.css";;

  "library-minimal" ) pgn4webPackageFileList="$pgn4webBaseFiles images/index.html images/*.png live/index.html live/*.pgn pgn4web-server-config.js";;

  "library-full" ) pgn4webPackageFileList="$pgn4webBaseFiles fide-lookup.js fonts/* images/* libs/README.txt libs/index.html libs/garbochess/* engine.* live/index.html live/*.pgn pgn4web-server-config.js";;

  "live-minimal" ) pgn4webPackageFileList="$pgn4webBaseFiles dynamic-frame.html live-compact.* live-fullscreen.html live-mosaic* live-results.html blank.html fide-lookup.js crc32.js demoLiveGames.pgn images/index.html images/alpha/index.html images/alpha/README.txt images/alpha/24/* images/alpha/26/* images/alpha/32/* images/alpha/96/* images/merida/index.html images/merida/README.txt images/merida/96/* images/uscf/index.html images/uscf/README.txt images/uscf/96/* fonts/index.html fonts/README.txt fonts/chess-informant-NAG-symbols.js fonts/LiberationSans* fonts/pgn4web-font-LiberationSans.css fonts/ChessSansPiratf* fonts/pgn4web-font-ChessSansPiratf.css fonts/ChessInformantReader* fonts/pgn4web-font-ChessInformantReader.css libs/README.txt libs/index.html libs/garbochess/* engine.* live/index.html live/live-simulation.sh live/*.pgn";;

  "live-games-app" ) pgn4webPackageFileList="$pgn4webBaseFiles dynamic-frame.html fide-lookup.js fonts/index.html fonts/chess-informant-NAG-symbols.js fonts/LiberationSans* fonts/pgn4web-font-LiberationSans.css fonts/pgn4web-font-ChessInformantReader.css fonts/ChessInformantReader.* images/index.html images/alpha/index.html images/alpha/96/* libs/README.txt libs/index.html libs/garbochess/* engine.* live-games-app*";;

  * ) echo "bash `basename $0` [board-minimal | library-minimal | library-full | live-minimal]"; exit 0 ;;

esac

pgn4webVer=$(grep "var pgn4web_version = " pgn4web.js | awk -F "'" '{print$2}')

pgn4webPackageFilename="pgn4web-$pgn4webVer-$1.zip"

if [ -e "$pgn4webPackageFilename" ]; then
  echo "Error: pgn4web package already exists ($pgn4webPackageFilename)"
  exit 1
fi

zip -9r "$pgn4webPackageFilename" $pgn4webPackageFileList -x *.svn/*

echo
if [ $? -eq 0 ];
then
  echo "Package $pgn4webPackageFilename ready"
else
 echo "Error creating package $pgn4webPackageFilename"
fi

