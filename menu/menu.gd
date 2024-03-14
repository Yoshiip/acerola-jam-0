extends Node3D

func _ready() -> void:
	PlayerData.day = 0

	PlayerData.unique_customers = 0
	PlayerData.vip_chance = 5
	PlayerData.money = 100

	PlayerData.reputation = 0
	PlayerData.reputation_level = 0
	PlayerData.reputation_objective = Utils.get_level_needed_xp(PlayerData.reputation_level)

	PlayerData.warned = false
	PlayerData.game_over = false

	PlayerData.rewards_to_apply = []

func _on_start_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://hotel/hotel.tscn")
