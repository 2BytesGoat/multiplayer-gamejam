extends Control

var user_name setget set_user_name
var user_status = "Not Connected" setget set_user_status

func set_user_name(name):
	$UserName.text = name

func set_user_status(status):
	$UserStatus.text = status
