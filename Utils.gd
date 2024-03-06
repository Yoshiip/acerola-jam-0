class_name Utils

extends Node

static func get_level_needed_xp(level : int) -> int:
	return int(floor(20 * pow(1.12, level)))
