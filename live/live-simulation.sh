# pgn4web javascript chessboard
# copyright (C) 2009-2016 Paolo Casaschi
# see README file and http://pgn4web.casaschi.net
# for credits, license and more details

# bash script to create a pgn file over time, same as a live broadcast
# more realistic than simulating the live broadcast within pgn4web
# run as "bash script.sh"

set +o posix

if [ "$1" == "--help" ]
then
   echo
   echo "$(basename $0)"
   echo
   echo "Shell script to create a pgn file over time, same as a live broadcast"
   echo "and more realistic than simulating the live broadcast within pgn4web"
   echo
   echo "Needs to be run using bash"
   echo
   exit
fi

if [ "$1" == "--no-shell-check" ]
then
   shift 1
else
   if [ "$(basename $SHELL)" != "bash" ]
   then
      echo "ERROR: $(basename $0) should be run with bash. Prepend --no-shell-check as first parameters to skip checking the shell type."
      exit
   fi
fi

pgn_file=live.pgn
pgn_file_tmp=live-tmp.pgn

delay=17
if [ -n "$1" ]
then
   if [ "$1" -eq "$1" 2> /dev/null ]
   then
      delay="$1"
   else
      echo "ERROR: $(basename $0) the delay parameter should be an integer (supplied $1)"
      exit
   fi
fi

# dont touch after this line

umask 0000
if [ $? -ne 0 ]
then
   echo "ERROR: $(basename $0) failed setting umask 0000"
   exit
fi

game1_header="[Event \"Tilburg Fontys\"]\n[Site \"Tilburg\"]\n[Date \"1998.10.24\"]\n[Round \"2\"]\n[White \"Anand, Viswanathan\"]\n[Black \"Kramnik, Vladimir\"]\n[WhiteClock \"2:00:00\"]\n[BlackClock \"2:00:00\"]"
game1_header_live="$game1_header\n[Result \"*\"]"
game1_header_end="$game1_header\n[Result \"1-0\"]"

game1_moves[0]="1.e4 {[%clk 1:59:59]} e5 {[%clk 1:58:58]}"
game1_clock[0]="[Clock \"W/1:58:00\"]"

game1_moves[1]=" 2.Nf3 {[%clk 1:57:57]} Nf6 {[%clk 1:56:56]} 3.Nxe5 {[%clk 1:55:55]}"
game1_clock[1]="[Clock \"B/1:55:00\"]"

game1_moves[2]="d6 {[%clk 1:54:54]}"
game1_clock[2]="[Clock \"W/1:54:00\"]"

game1_moves[3]="4.Nf3 {[%clk 1:53:53]} Nxe4 {[%clk 1:52:52]}"
game1_clock[3]="[Clock \"W/1:52:00\"]"

game1_moves[4]="5.d4 {[%clk 1:51:51]} d5 {[%clk 1:50:50]} 6.Bd3 {[%clk 1:49:49]}"
game1_clock[4]="[Clock \"B/1:49:00\"]"

game1_moves[5]="Nc6 {[%clk 1:48:48]} 7.O-O {[%clk 1:47:47]}"
game1_clock[5]="[Clock \"B/1:47:00\"]"

game1_moves[6]="Be7 {[%clk 1:46:46]} 8.Re1 {[%clk 1:45:45]}"
game1_clock[6]="[Clock \"B/1:45:00\"]"

game1_moves[7]="Bg4 {[%clk 1:44:44]} 9.c3 {[%clk 1:43:43]} f5 {[%clk 1:42:42]}"
game1_clock[7]="[Clock \"W/1:43:01\"]"

game1_moves[8]=""
game1_clock[8]="[Clock \"W/1:43:00\"]"

game1_moves[9]="10.Qb3 {[%clk 1:41:41]} O-O {[%clk 1:40:40]} 11.Nbd2 {[%clk 1:39:39]}"
game1_clock[9]="[Clock \"B/1:39:01\"]"

game1_moves[10]=""
game1_clock[10]="[Clock \"B/1:39:00\"]"

game1_moves[11]="Na5 {[%clk 1:38:38]}"
game1_clock[11]="[Clock \"W/1:38:00\"]"

game1_moves[12]="12.Qa4 {[%clk 1:37:37]} Nc6 {[%clk 1:36:36]} 13.Bb5 {[%clk 1:35:35]}"
game1_clock[12]="[Clock \"W/1:35:00\"]"

game1_moves[13]="Nxd2 {[%clk 1:34:34]} 14.Nxd2 {[%clk 1:33:33]} Qd6 {[%clk 1:32:32]}"
game1_clock[13]="[Clock \"W/1:32:00\"]"

game1_moves[14]="15.h3 {[%clk 1:31:31]} Bh5 {[%clk 1:30:30]}"
game1_clock[14]="[Clock \"W/1:30:01\"]"

game1_moves[15]=""
game1_clock[15]="[Clock \"W/1:30:00\"]"

game1_moves[16]="16.Nb3 {[%clk 1:29:29]} Bh4 {[%clk 1:28:28]}"
game1_clock[16]="[Clock \"W/1:28:00\"]"

game1_moves[17]="17.Nc5 {[%clk 1:27:27]}"
game1_clock[17]="[Clock \"B/1:27:00\"]"

game1_moves[18]="Bxf2+ {[%clk 1:26:26]}"
game1_clock[18]="[Clock \"W/1:26:00\"]"

game1_moves[19]="18.Kxf2 {[%clk 1:25:25]} Qh2 {[%clk 1:24:24]} 19.Bxc6 {[%clk 1:23:23]}"
game1_clock[19]="[Clock \"B/1:23:00\"]"

game1_moves[20]="bxc6 {[%clk 1:22:22]} 20.Qxc6 {[%clk 1:21:21]} f4 {[%clk 1:20:20]}"
game1_clock[20]="[Clock \"W/1:20:00\"]"

game1_moves[21]="21.Qxd5+ {[%clk 1:19:19]}"
game1_clock[21]="[Clock \"B/1:19:00\"]"

game1_moves[22]="Kh8 {[%clk 1:18:18]} 22.Qxh5 {[%clk 1:17:17]}"
game1_clock[22]="[Clock \"W/1:17:00\"]"

game1_moves[23]="f3 {[%clk 1:16:16]}"
game1_clock[23]="[Clock \"W/1:16:00\"]"

game1_moves[24]="23.Qxf3 {[%clk 1:15:15]} Rxf3+ {[%clk 1:14:14]}"
game1_clock[24]="[Clock \"W/1:14:00\"]"

game1_moves[25]="24.Kxf3 {[%clk 1:13:13]} Rf8+ {[%clk 1:12:12]} 25.Ke2 {[%clk 1:11:11]}"
game1_clock[25]="[Clock \"B/1:11:00\"]"

game1_moves[26]="Qxg2+ {[%clk 1:10:10]} 26.Kd3 {[%clk 1:09:09]}"
game1_clock[26]="[Clock \"B/1:09:00\"]"

game1_moves[27]="Qxh3+ {[%clk 1:08:08]} 27.Kc2 {[%clk 1:07:07]} Qg2+ {[%clk 1:06:06]}"
game1_clock[27]="[Clock \"W/1:06:00\"]"

game1_moves[28]="28.Bd2 {[%clk 1:05:05]} Qg6+ {[%clk 1:04:04]}"
game1_clock[28]="[Clock \"W/1:04:00\"]"

game1_moves[29]="29.Re4 {[%clk 1:03:03]} h5 {[%clk 1:02:02]} 30.Re1 {[%clk 1:01:01]}"
game1_clock[29]="[Clock \"B/1:01:00\"]"

game1_moves[30]="Re8 {[%clk 1:00:00]} 31.Kc1 {[%clk 59:59]} Rxe4 {[%clk 58:58]}"
game1_clock[30]="[Clock \"W/58:00\"]"

game1_moves[31]="Nxe4 {[%clk 57:57]} h4 {[%clk 56:56]} 33.Ng5 {[%clk 55:55]}"
game1_clock[31]="[Clock \"B/55:00\"]"

game1_moves[32]="Qh5 {[%clk 54:54]} 34.Re3 {[%clk 53:53]} Kg8 {[%clk 52:52]}"
game1_clock[32]="[Clock \"W/52:00\"]"

game1_moves[33]="35.c4 {[%clk 51:51]}"
game1_clock[33]="[Clock \"B/51:00\"]"

game1_moves[34]="1-0"
game1_clock[34]="[Clock \"B/50:00\"]"

game2_header="[Event \"Tilburg Fontys\"]\n[Site \"Tilburg\"]\n[Date \"1998.10.24\"]\n[Round \"2\"]\n[White \"Lautier, Joel\"]\n[Black \"Van Wely, Loek\"]\n[WhiteClock \"2:00:00\"]\n[BlackClock \"2:00:00\"]"
game2_header_live="$game2_header\n[Result \"*\"]"
game2_header_end="$game2_header\n[Result \"1/2-1/2\"]"

game2_moves[0]=""
game2_clock[0]="[Clock \"W/1:59:59\"]"

game2_moves[1]="1.d4 {[%clk 1:59:59]} Nf6 {[%clk 1:59:58]} 2.c4 {[%clk 1:58:57]} c5 {[%clk 1:58:56]} 3.d5 {[%clk 1:57:55]}"
game2_clock[1]="[Clock \"B/1:58:00\"]"

game2_moves[2]="b5 {[%clk 1:57:54]}"
game2_clock[2]="[Clock \"W/1:57:00\"]"

game2_moves[3]="4.Nf3 {[%clk 1:56:53]}"
game2_clock[3]="[Clock \"B/1:57:00\"]"

game2_moves[4]="Bb7 {[%clk 1:56:52]}"
game2_clock[4]="[Clock \"W/1:56:00\"]"

game2_moves[5]="5.a4 {[%clk 1:55:51]}"
game2_clock[5]="[Clock \"B/1:56:00\"]"

game2_moves[6]="Qa5+ {[%clk 1:55:50]}"
game2_clock[6]="[Clock \"W/1:55:00\"]"

game2_moves[7]="6.Bd2 {[%clk 1:54:49]}"
game2_clock[7]="[Clock \"B/1:55:00\"]"

game2_moves[8]="b4 {[%clk 1:54:48]}"
game2_clock[8]="[Clock \"W/1:54:00\"]"

game2_moves[9]="7.Bg5 {[%clk 1:53:47]} d6 {[%clk 1:53:46]}"
game2_clock[9]="[Clock \"W/1:53:01\"]"

game2_moves[10]=""
game2_clock[10]="[Clock \"W/1:53:00\"]"

game2_moves[11]="8.Nbd2 {[%clk 1:52:45]}"
game2_clock[11]="[Clock \"B/1:53:00\"]"

game2_moves[12]="Nbd7 {[%clk 1:52:44]}"
game2_clock[12]="[Clock \"W/1:52:00\"]"

game2_moves[13]="9.h3 {[%clk 1:51:43]} g6 {[%clk 1:51:42]}"
game2_clock[13]="[Clock \"W/1:51:00\"]"

game2_moves[14]="10.e4 {[%clk 1:50:41]} Bg7 {[%clk 1:50:40]} 11.Bd3 {[%clk 1:49:39]}"
game2_clock[14]="[Clock \"B/1:50:00\"]"

game2_moves[15]="O-O {[%clk 1:49:38]} 12.O-O {[%clk 1:48:37]}"
game2_clock[15]="[Clock \"B/1:49:00\"]"

game2_moves[16]="Rae8 {[%clk 1:48:36]}"
game2_clock[16]="[Clock \"W/1:48:01\"]"

game2_moves[17]=""
game2_clock[17]="[Clock \"W/1:48:00\"]"

game2_moves[18]="13.Re1 {[%clk 1:47:35]} e5 {[%clk 1:47:34]}"
game2_clock[18]="[Clock \"W/1:47:00\"]"

game2_moves[19]="14.Nf1 {[%clk 1:46:33]}"
game2_clock[19]="[Clock \"B/1:47:00\"]"

game2_moves[20]="Nh5 {[%clk 1:46:32]} 15.g3 {[%clk 1:45:31]}"
game2_clock[20]="[Clock \"B/1:46:00\"]"

game2_moves[21]="Bc8 {[%clk 1:45:30]}"
game2_clock[21]="[Clock \"W/1:45:01\"]"

game2_moves[22]=""
game2_clock[22]="[Clock \"W/1:45:00\"]"

game2_moves[23]="16.Kh2 {[%clk 1:44:29]} Kh8 {[%clk 1:44:28]}"
game2_clock[23]="[Clock \"W/1:44:00\"]"

game2_moves[24]="17.b3 {[%clk 1:43:27]}"
game2_clock[24]="[Clock \"B/1:44:00\"]"

game2_moves[25]="Qc7 {[%clk 1:43:26]}"
game2_clock[25]="[Clock \"W/1:43:01\"]"

game2_moves[26]=""
game2_clock[26]="[Clock \"W/1:43:00\"]"

game2_moves[27]="18.Ra2 {[%clk 1:42:25]}"
game2_clock[27]="[Clock \"B/1:43:00\"]"

game2_moves[28]="Ndf6 {[%clk 1:42:24]}"
game2_clock[28]="[Clock \"W/1:42:00\"]"

game2_moves[29]="19.Ng1 {[%clk 1:41:23]}"
game2_clock[29]="[Clock \"B/1:42:01\"]"

game2_moves[30]=""
game2_clock[30]="[Clock \"B/1:42:00\"]"

game2_moves[31]="Ng8 {[%clk 1:41:22]}"
game2_clock[31]="[Clock \"W/1:41:01\"]"

game2_moves[32]=""
game2_clock[32]="[Clock \"W/1:41:00\"]"

game2_moves[33]="20.Bc1 {[%clk 1:40:21]}"
game2_clock[33]="[Clock \"B/1:40:00\"]"

game2_moves[34]="1/2-1/2"
game2_clock[34]="[Clock \"B/1:39:00\"]"

steps=34

if [ -e "$pgn_file" ]
then
   echo "ERROR: $(basename $0): $pgn_file exists"
   echo "Delete the file or choose another filename and restart $(basename $0)"
   exit
fi

echo Generating PGN file $pgn_file simulating live game broadcast

echo > $pgn_file_tmp
echo -e $game1_header_live >> $pgn_file_tmp
echo "*" >> $pgn_file_tmp
echo >> $pgn_file_tmp
echo -e $game2_header_live >> $pgn_file_tmp
echo "*" >> $pgn_file_tmp
mv $pgn_file_tmp $pgn_file
sleep $delay

upto=0;
while [ $upto -lt $steps ]
do
   echo " step $upto of $steps"
   echo > $pgn_file_tmp

   echo -e $game1_header_live >> $pgn_file_tmp
   echo -e ${game1_clock[$upto]} >> $pgn_file_tmp
   echo >> $pgn_file_tmp
   move=0
   while [ $move -le $upto ]
   do
      echo ${game1_moves[$move]} >> $pgn_file_tmp
      move=$(($move + 1))
   done
   echo "*" >> $pgn_file_tmp

   echo >> $pgn_file_tmp

   echo -e $game2_header_live >> $pgn_file_tmp
   echo -e ${game2_clock[$upto]} >> $pgn_file_tmp
   echo >> $pgn_file_tmp
   move=0
   while [ $move -le $upto ]
   do
      echo ${game2_moves[$move]} >> $pgn_file_tmp
      move=$(($move + 1))
   done
   echo "*" >> $pgn_file_tmp

   mv $pgn_file_tmp $pgn_file
   sleep $delay

   upto=$(($upto + 1))
done

echo " step $upto of $steps"
echo > $pgn_file_tmp
echo -e $game1_header_end >> $pgn_file_tmp
echo -e ${game1_clock[$upto]} >> $pgn_file_tmp
echo >> $pgn_file_tmp
move=0
while [ $move -le $upto ]
do
   echo ${game1_moves[$move]} >> $pgn_file_tmp
   move=$(($move + 1))
done
echo >> $pgn_file_tmp
echo -e $game2_header_end >> $pgn_file_tmp
echo -e ${game2_clock[$upto]} >> $pgn_file_tmp
echo >> $pgn_file_tmp
move=0
while [ $move -le $upto ]
do
   echo ${game2_moves[$move]} >> $pgn_file_tmp
   move=$(($move + 1))
done
mv $pgn_file_tmp $pgn_file
echo done with games... waiting for a while before deleting $pgn_file

sleep 3600
rm $pgn_file

