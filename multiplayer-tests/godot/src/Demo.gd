extends Node


onready var server_connection := $ServerConnection

func _ready() -> void:
	yield(request_authentication(), "completed")

func request_authentication() -> void:
	var email := "test@test.com"
	var password := "password"
	
	print_debug("Authenticating user %s."% email)
	var result: int = yield(server_connection.authenticate_async(email, password), "completed")
	
	if result == OK:
		print_debug("SUCCESS - Authenticating user %s."%email)
	else:
		print_debug("FAILED - Authenticating user %s."%email)
