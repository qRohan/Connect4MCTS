import sugar
import sequtils

from MCTSNode import MCTSNode, newMCTSNode, expand, backpropogate, rollout, select
from Connect4 import GameBoard, PlayerID, MoveType, terminal_state, get_valid_moves
type
    MCTS = object
        initial_state: GameBoard
        root_node : MCTSNode
        num_of_playouts: int
        player_id: PlayerID

proc newMCTS*(initial_state: GameBoard, player_id: PlayerID, num_of_playouts: int): MCTS = 
    var root_node = newMCTSNode(initial_state, player_id, @[])
    return MCTS(initial_state: initial_state, root_node: root_node, num_of_playouts: num_of_playouts, player_id: player_id)


proc best_move(self: MCTS): MoveType = 
    var children = self.root_node.children
    var best_node_index = maxIndex(children.map(child => child.v/float(child.n)))
    result = self.initial_state.get_valid_moves()[best_node_index]
    return result

proc run_playout(self: MCTS) = 
    var current = self.root_node
    while not current.state.terminal_state():
        if not bool(current.children.len()): #TODO
            current.expand()
            current = current.children[0]
            break
        else:
            # echo "select"
            current = current.select()
    var value = current.rollout()
    # echo value
    current.backpropogate(value, self.player_id)

proc run_mcts*(self: MCTS): MoveType = 
    for _ in 0..<self.num_of_playouts:
        self.run_playout()
    return self.best_move()