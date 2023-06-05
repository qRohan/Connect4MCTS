import sugar
import sequtils
import std/tables
from std/math import ln, sqrt
from std/random import randomize, sample
from Connect4 import GameBoard, PlayerID, GameResults, ResultType, MoveType, play, get_valid_moves, next_player, terminal_state, reverse_result


type 
    MCTSNode* = ref object
        v* : float
        n* : int
        state*: GameBoard
        player: PlayerID
        parent: MCTSNode
        children*: seq[MCTSNode]

var
    rewards = { GameResults.WIN:1.0, 
                GameResults.DRAW:0.0,
                GameResults.LOSS: -1.0
                }.toTable()
    
randomize()

proc newMCTSNode*(state: GameBoard, player: PlayerID, children: seq[MCTSNode]): MCTSNode =
    return MCTSNode(state: state, player: player, children: children)

proc newMCTSNode*(state: GameBoard, player: PlayerID, parent: MCTSNode, children: seq[MCTSNode]): MCTSNode =
    return MCTSNode(state: state, player: player, parent: parent, children: children)
  
proc get_uct(self: MCTSNode): float = 
    result = Inf
    if self.n == 0:
        return result
    var c: float = 2
    if self.parent != nil :
        result = (self.v / float(self.n)) + c * sqrt(ln(float(self.parent.n)) / self.n.float)
    return result

proc rollout*(self: MCTSNode): ResultType = 
    var state = self.state
    while true:
        if state.terminal_state():
            # echo state
            return state.result
        state = state.play(sample(state.get_valid_moves()))

proc select*(self: MCTSNode): MCTSNode =
    result = self.children[maxIndex(self.children.map(x => x.get_uct()))]

proc create_child(self: MCTSNode, move : MoveType, player: PlayerID): MCTSNode = 
    return newMCTSNode(self.state.play(move), player, self, @[])

proc expand*(self: MCTSNode)=
    self.children = collect(newSeq):
        for move in self.state.get_valid_moves():
            self.create_child(move, next_player(self.player))

proc backpropogate*(self: MCTSNode, value: ResultType, root_player: PlayerID) =
    self.n += 1
    # echo self.state
    # echo value
    self.v += rewards[if value[1] == self.player: reverse_result(value[0]) else: value[0] ]

    if self.parent != nil:
        self.parent.backpropogate(value, root_player)


# var parentNode = MCTSNode(v:1, n:2)
# echo "parent"
# echo parentNode.parent == nil
# var node = MCTSNode(v:1, n:1, parent: parentNode)
# echo "node"
# echo node.parent == nil
# echo get_uct(node)

