import sugar
from sequtils import map
from strutils import split, parseInt

from Connect4 import PlayerID, MoveType, GameResults, newGameBoard, play, pretty_print_grid
from MCTS import newMCTS, run_mcts

var board = newGameBoard()
echo board.pretty_print_grid()
# echo "╔"

while true:
    var input = stdin.readLine().split(',').map(x => parseInt(x))
    assert input.len() == 1 
    var move = (column: input[0])
    board = board.play(move)
    echo "\n"
    echo board.pretty_print_grid()
    if board.result.result != NO_RESULT:
        if board.result.result == DRAW:
            echo("DRAW")
        else:
            echo("Player Wins")
        break

    var mcts = newMCTS(board, PlayerID(2), 5000)
    var cpu_move = mcts.run_mcts()
    board = board.play(cpu_move)
    echo "\n"
    echo board.pretty_print_grid()
    if board.result.result != NO_RESULT:
        if board.result.result == DRAW:
            echo("DRAW")
        else:
            echo("Computer Wins")
        break