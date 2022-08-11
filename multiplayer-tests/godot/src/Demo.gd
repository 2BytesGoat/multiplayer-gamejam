extends Node


onready var server_connection := $ServerConnection

func _ready() -> void:
	yield(request_authentication(), "completed")
	yield(connect_to_server(), "completed")
	yield(join_world(), "completed")

func request_authentication() -> void:
	var email := "test@test.com"
	var password := "password"
	
	print_debug("Authenticating user %s."% email)
	var result: int = yield(server_connection.authenticate_async(email, password), "completed")
	
	if result == OK:
		print_debug("SUCCESS - Authenticating user %s."%email)
	else:
		print_debug("FAILED - Authenticating user %s."%email)

func connect_to_server() -> void:
	var result: int = yield(server_connection.connect_to_server_async(), "completed")
	if result == OK:
		print_debug("SUCCESS - Connected to the server")
	else:
		print_debug("FAILED - Could not connect to server")

func join_world() -> void:
	var presences: Dictionary = yield(server_connection.join_world_async(), "completed")
	print_debug("Joined world")
	print_debug(presences)
