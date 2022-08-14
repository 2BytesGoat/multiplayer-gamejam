extends Node2D


export (PackedScene) var Player
var ready_players = {}

func _ready():
	setup_game()

func setup_game():
	for id in GameManager.players:
		var player_idx = GameManager.players[id].peer_id
		var player_obj = Player.instance()
		player_obj.name = str(id)
		$Players.add_child(player_obj)
		player_obj.set_network_master(GameManager.players[id].peer_id)
		player_obj.position = $SpawnPositions.get_node(str(player_idx)).position
	var my_id = OnlineMatch.get_my_session_id()
	var player = $Players.get_node(str(my_id))
	player.player_controlled = true
	rpc_id(1, "finishedSetup", my_id)

mastersync func finishedSetup(id):
	ready_players[id] = GameManager.players[id]
	if ready_players.size() == GameManager.players.size():
		print("start game all players are ready")
