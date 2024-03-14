class_name Utils

extends Node

static func get_level_needed_xp(level : int) -> int:
	return int(floor(25 * pow(1.12, level + 1)))

static func get_total_needed_xp(level : int) -> int:
	var _sum := 0
	for l in range(1, level):
		_sum += get_level_needed_xp(l)
	return _sum
