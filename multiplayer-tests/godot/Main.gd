extends Control

const key = "defaultkey"
const server_ip = "127.0.0.1"
const server_port = 7350

const MIN_PLAYERS = 2
const MAX_PLAYERS = 4

var _client: NakamaClient
var _session: NakamaSession
var _socket: NakamaSocket

var username = "example"
var ready_players = []

export var ReadyUser:PackedScene = ResourceLoader.load("res://UserReady.tscn")

func connect_to_nakama():
	_client = Nakama.create_client(key, server_ip, server_port, 'http', 3, 
	NakamaLogger.LOG_LEVEL.ERROR)
	
	var id = OS.get_unique_id()
	_session = yield(_client.authenticate_device_async(id, username), 'completed')
	if _session.is_exception():
		print_debug("FAILED connecting: %s"% _session.exception)
		return
		
	_socket = Nakama.create_socket_from(_client)
	yield(_socket.connect_async(_session), "completed")
	$MatchMakingScreen.hide()
	
	start_matchmaking()

func start_matchmaking():
	OnlineMatch.min_players = MIN_PLAYERS
	OnlineMatch.max_players = MAX_PLAYERS
	OnlineMatch.client_version = 'dev'
	OnlineMatch.ice_servers = [{"urls":["stun:stun.1.google.com:19302"]}]
	OnlineMatch.use_network_relay = OnlineMatch.NetworkRelay.AUTO
	
	OnlineMatch.connect("disconnected", self, "_on_OnlineMatch_disconnected")
	OnlineMatch.connect("error", self, "_on_OnlineMatch_error")
	OnlineMatch.connect("match_created", self, "_on_OnlineMatch_created")
	OnlineMatch.connect("match_joined", self, "_on_OnlineMatch_joined")
	OnlineMatch.connect("matchmaker_matched", self, "_on_OnlineMatch_matched")
	OnlineMatch.connect("player_joined", self, "_on_OnlineMatch_player_joined")
	OnlineMatch.connect("player_left", self, "_on_OnlineMatch_player_left")
	OnlineMatch.connect("player_status_changed", self, "_on_OnlineMatch_player_status_changed")
	OnlineMatch.connect("match_ready", self, "_on_OnlineMatch_ready")
	OnlineMatch.connect("match_not_ready", self, "_on_OnlineMatch_not_ready")
	
	OnlineMatch.start_matchmaking(_socket)
	print_debug("Started Matchmaking")

func _on_OnlineMatch_matched(players):
	pass

func _on_OnlineMatch_player_status_changed(player, status):
	pass

func _on_OnlineMatch_player_joined(player):
	print(player)

func _on_OnlineMatch_ready(players):
	$ConnectingScreen.hide()
	GameManager.players = players
	for player in GameManager.players.values():
		var ready_user = ReadyUser.instance()
		ready_user.name = player.session_id
		ready_user.user_name = player.username
		$ReadyScreen/VBoxContainer.add_child(ready_user)

func _on_Button_pressed():
	username = $MatchMakingScreen/Username.text
	connect_to_nakama()

remotesync func ready(id):
	$ReadyScreen/VBoxContainer.get_node_or_null(id).user_status = "Ready"
	ready_players.append(id)
	# TODO: rather check if all player ids are the same, rather than len
	if ready_players.size() == GameManager.players.size():
		print("Start Game!")
		get_tree().change_scene("res://GamePlayScene.tscn")

func _on_ReadyButton_pressed():
	rpc("ready", OnlineMatch.get_my_session_id())
