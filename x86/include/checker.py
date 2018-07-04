import re
import subprocess
from subprocess import Popen, PIPE, STDOUT
import random
import os

## fix me: (1) this script is not easy to use
##         (2) better support for excluding armfish from testing

## set these to whatever is needed for your system
## the makequick command should make armfish and asmfish executables

#armCmd = ['qemu-aarch64', os.getcwd() + '/armfish']
asmCmd = ['C:\\Winboard\\asmFishW_b2e1185_bmi2.exe']
stockCmd = ['C:\\Winboard\\stockfish-a87a100.exe']

## important! you must recompile stockfish with the following modification:
##  it needs to be able to respond to the "wait" command
##  so that the engine does not quit before the search is finished
#
# original uci.cpp around line 204:
#
#      else if (token == "setoption")  setoption(is);
#
#      // Additional custom non-UCI commands, useful for debugging
#      else if (token == "flip")       pos.flip();
#
# modified uci.cpp around line 204:
#
#      else if (token == "setoption")  setoption(is);
#
#      // Additional custom non-UCI commands, useful for debugging
#      else if (token == "wait")       Threads.main()->wait_for_search_finished();
#      else if (token == "flip")       pos.flip();

# run an engine to depth 14 on a sequence of moves
def GetData(cmd, mseq):
    p = Popen(cmd, stdout = PIPE, stdin = PIPE, stderr = PIPE, encoding = 'utf8')
    data = p.communicate(input = 'position startpos moves ' + ' '.join(str(mseq)) + '\ngo depth 14\nwait\nquit\n')[0]
    nodes = '?'
    bestmove = '?'
    for line in data.split('\n'):
        tokens = line.split();
        for i in range(0, len(tokens) - 1):
            if tokens[i] == 'bestmove':
                bestmove = tokens[i + 1]
            if tokens[i] == 'nodes':
                nodes = tokens[i + 1]
    return [nodes, bestmove]

# generate a list of all legal moves given a sequence of moves from startpos
def GetLegalMoves(mseq):
    p = Popen(asmCmd, stdout = PIPE, stdin = PIPE, stderr = PIPE)
    data = p.communicate(input = b'position startpos moves ' + b' '.join(mseq) + b'\n' + b'perft 1' + b'\n' + b'quit' + b'\n')[0]
    res = []
    for line in data.split(b'\n'):
        mo = re.search('=' , str(line), flags=0)
        if mo != None:
            break
        tokens = line.split(b':');
        if len(tokens) > 1:
            res.append(tokens[0].strip())
    return res
 
# generate a random sequence of moves
def GetRandMoveList():
    mseq = []
    for i in range(random.randint(3, 6)):
        newlist = GetLegalMoves(mseq)
        if len(newlist) < 1:
            mseq.pop() # avoid mate
            break
        mseq.append(random.choice(newlist))
    return mseq

mseq = []

for i in range(1000):
    if len(mseq)<2 or len(mseq)>200:
        mseq = GetRandMoveList()
#        mseq = ['g2g4','a7a5','e2e4','d7d5','e4e5','d5d4','f1g2']
    print('testing '),
    print(' '.join(str(mseq)))
#    armData = GetData(armCmd, mseq)
#    print '  arm',
#    print(armData)
    asmData = GetData(asmCmd, mseq)
    print('  asm'),
    print(asmData)
    stockData = GetData(stockCmd, mseq)
    print('stock'),
    print(stockData)
    if asmData[1] == "NONE" and armData[1]=="NONE" and stockData[1]=="(none)":
        print('PASSED')
    elif asmData != stockData:
        print('FAILED1')
        break
#    elif armData[1] != '?' and asmData != armData:
#        print('FAILED2')
#        break
    else:
        print('PASSED ', i+1, '/ 1000')

    if asmData[1]=="NONE":
        mseq = []
    else:
        mseq.append(asmData[1])

