extends Node

var master_volume_db: float = -20.0

func _ready():
	AudioServer.set_bus_volume_db(0, master_volume_db)
