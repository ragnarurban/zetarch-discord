# FmodManager.gd
extends Node
class_name FmodHandler

# Holds all FMOD events loaded from GUIDs.txt
var events : Dictionary = {}  # key: event path, value: type ("event", "bus", etc.)

# Singleton style access
static var instance

func _ready():
	instance = self
	#_load_banks()
	#_load_events_list()

# --- Load all .bank files for the current platform ---
func _load_banks():
	var bank_folder = "res://music/fmod/Mobile/" if OS.get_name() in ["Android", "iOS"] else "res://music/fmod/Desktop/"
	
	var dir = DirAccess.open(bank_folder)
	if not dir:
		push_error("Cannot open FMOD bank folder: %s" % bank_folder)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".bank"):
			var bank_path = bank_folder + file_name
			if not FmodServer.load_bank(bank_path, FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL):
				push_error("Failed to load bank: %s" % bank_path)
		file_name = dir.get_next()
	dir.list_dir_end()

# --- Parse GUIDs.txt and store events ---
func _load_events_list():
	var guid_file_path = "res://music/fmod/GUIDs.txt"
	var file = FileAccess.open(guid_file_path, FileAccess.READ)
	if not file:
		push_error("Cannot open GUIDs.txt: %s" % guid_file_path)
		return

	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "":
			continue
		# Example line: {5e3dc658-32f6-4b1a-a050-8fb1eac60b93} event:/MainSong
		var parts = line.split("}")
		if parts.size() < 2:
			continue
		var type_and_path = parts[1].strip_edges().split(":")
		if type_and_path.size() < 2:
			continue
		var obj_type = type_and_path[0].strip_edges()
		var obj_path = type_and_path[1].strip_edges()
		# Only store events for now
		if obj_type == "event":
			events[obj_path] = obj_type

	file.close()
	print("FMOD events loaded from GUIDs.txt:")
	for e in events.keys():
		print(" - ", e)

# --- Utility function to play an event by path safely ---
func play_event(event_path: String):
	if not events.has(event_path):
		push_error("FMOD event not found: %s" % event_path)
		return null
	var inst = FmodServer.create_event_instance(event_path)
	if inst:
		inst.start()
	else:
		push_error("Failed to create FMOD event instance: %s" % event_path)
	return inst
