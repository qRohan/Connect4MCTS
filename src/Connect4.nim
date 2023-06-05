import sugar
from strformat import fmt
from strutils import replace
from sequtils import zip, toSeq

const
    BoardHeight = 6
    BoardWidth = 7

type
    PlayerID* = enum
        Default
        Player1
        Player2

    GameResults* = enum
        NO_RESULT = "NO_RESULT"
        WIN = "WIN"
        LOSS = "LOSS"
        DRAW = "DRAW"


    MoveType* = tuple
        column: int

    GameBoardGridType = array[BoardHeight, array[BoardWidth, PlayerID]]
    
    ResultType* = tuple
        result: GameResults
        player: PlayerID

    GameBoard* = object
        grid : GameBoardGridType
        result* : ResultType

    InvalidMoveError = object of ValueError


proc reverse_result*(game_result: GameResults): GameResults = 
    case game_result:
    of WIN : result = LOSS
    of LOSS: result = WIN
    else: result = game_result

    return result

proc newGameBoard*(): GameBoard=
    var grid: GameBoardGridType
    return GameBoard(grid: grid)

proc newGameBoard*(grid: GameBoardGridType): GameBoard=
    return GameBoard(grid: grid)

proc pretty_print_grid*(board: GameBoard): string =
    result = $(board.grid)
    result = result.replace("[[", "[")
    result = result.replace("]]", "]")
    result = result.replace("], ", "]\n")
    result = result.replace($(Default), "  ")
    result = result.replace($(Player1), "X ")
    result = result.replace($(Player2), "O ")
    return result

proc can_play(self: GameBoard, move: MoveType): bool = 
    if not(move.column in 0..<BoardWidth):
        return false
    return self.grid[0][move.column] == PlayerID.Default

proc get_valid_moves*(self: GameBoard): seq[MoveType] =
    result = collect(newSeq):
        for y in 0..<BoardWidth:
            if self.can_play((column: y)): (column: y)

proc has_valid_moves(self: GameBoard): bool =
    return self.get_valid_moves().len() > 0

proc get_player(self: GameBoard): PlayerID = 
    var player1_move_count, player2_move_count = 0
    for y in 0..<BoardHeight:
        for x in 0..<BoardWidth:
            case self.grid[y][x]:
            of Player1: inc(player1_move_count)
            of Player2: inc(player2_move_count)
            of Default: discard
    
    if player1_move_count > player2_move_count:
        result = Player2
    else:
        result = Player1
    return result


proc next_player*(player: PlayerID): PlayerID = 
    case player:
    of Player1: result = Player2
    of Player2: result = Player1
    else: discard

proc set_draw(self: var GameBoard) = 
    self.result = (GameResults.DRAW, PlayerID.Default)

proc set_win(self: var GameBoard, player: PlayerID) = 
    self.result = (GameResults.WIN, player)

proc has_won(self: GameBoard, player: PlayerID, last_move: tuple[y: int, x:int]): bool = 
    result = false
    let 
        y = last_move.y
        x = last_move.x

    # Check vertical
    if BoardHeight - y > 3:
        result = true
        for i in y..(y+3):
            if self.grid[i][x] != player:
                result = false
                break
        if result: return
    
    # Check Horizontal
    if result == false:
        var count = 0
        for i in 0..<BoardWidth:
            if self.grid[y][i] == player:
                inc(count)
            else:
                count = 0
            
            if count == 4:
                result = true
                return

    # Check diagonal
    if result == false:
        var
            count = 0

            top_left = last_move
            bottom_right = last_move
            bottom_left = last_move
            top_right = last_move
        
        while top_left.y>0 and top_left.x>0:
            dec(top_left.y)
            dec(top_left.x)

        while bottom_right.y<(BoardHeight-1) and bottom_right.x<(BoardWidth-1):
            inc(bottom_right.y)
            inc(bottom_right.x)

        # echo fmt"top_left: {top_left}"
        # echo fmt"bottom_right: {bottom_right}"
        for (j,i) in zip(countup(top_left.y, bottom_right.y).toSeq, countup(top_left.x, bottom_right.x).toSeq):
            if self.grid[j][i] == player:
                inc(count)
            else:
                count = 0
            
            if count == 4:
                result = true
                return
        
        while bottom_left.y<(BoardHeight-1) and bottom_left.x>0:
            inc(bottom_left.y)
            dec(bottom_left.x)

        while top_right.y>0 and top_right.x<(BoardWidth-1):
            dec(top_right.y)
            inc(top_right.x)

        # echo fmt"bottom_left: {bottom_left}"
        # echo fmt"top_right: {top_right}"
        count = 0
        for (j,i) in zip(countdown(bottom_left.y, top_right.y).toSeq(), countup(bottom_left.x, top_right.x).toSeq()) :
            if self.grid[j][i] == player:
                inc(count)
            else:
                count = 0
            # echo count
            if count == 4:
                result = true
                return
    return result

proc terminal_state*(self: GameBoard): bool = 
    return (self.result[0] != GameResults.NO_RESULT) or not self.has_valid_moves()

proc check_if_draw(self: var GameBoard, last_move: tuple[y: int, x:int]) =
    let is_draw = self.terminal_state() and not(self.has_won(Player1, last_move) or self.has_won(Player2, last_move))
    if is_draw:
        self.set_draw()

proc check_if_win(self: var GameBoard, player: PlayerID, last_move: tuple[y: int, x:int]) = 
    let victory = self.has_won(player, last_move)
    if victory:
        self.set_win(player)


proc get_move_row(self: GameBoard, column: int): int =
    for i in countdown(BoardHeight-1, 0):
        if self.grid[i][column] == Default:
            return i

proc play*(self: GameBoard, move: MoveType, player: PlayerID = PlayerID.Default): GameBoard = 
    if self.terminal_state():
        result = newGameBoard(self.grid)
        result.set_draw()
    
    var player = player
    if player == PlayerID.Default:
        player = self.get_player()
    var grid = self.grid
    if not self.can_play(move):
        raise newException(InvalidMoveError, fmt"{move.column} is invalid move")
    
    let
        x = move.column
        y = self.get_move_row(x)
    grid[y][x] = player
    
    result = newGameBoard(grid)
    result.check_if_win(player, (y: y, x: x))
    result.check_if_draw((y: y, x: x))
    return result

# var board = newGameBoard()
# board = board.play((column: 1))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'
# board = board.play((column: 2))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'
# board = board.play((column: 1))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'
# board = board.play((column: 3))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'
# board = board.play((column: 2))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'
# board = board.play((column: 4))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'
# board = board.play((column: 0))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'
# board = board.play((column: 3))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'
# board = board.play((column: 2))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'
# board = board.play((column: 3))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'
# board = board.play((column: 3))
# echo pretty_print_grid(board)
# echo board.result
# echo '\n'



