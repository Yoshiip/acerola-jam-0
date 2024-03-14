extends CanvasLayer


var xp_animation_progress := 0.0

@onready var start_level := PlayerData.reputation_level

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var _level_data := GameManager.hotel
	xp_animation_progress = PlayerData.reputation
	var _customers_today := 0
	var _happiness_today := 0
	var _money_today := 0
	if is_instance_valid(_level_data):
		_customers_today = _level_data.get_node("customers").get_child_count()
		for customer in _level_data.get_node("customers").get_children():
			if customer.vip:
				_happiness_today += customer.happiness * 2
			else:
				_happiness_today += customer.happiness
			_money_today += customer.money_per_night
	PlayerData.reputation += _happiness_today
	while PlayerData.reputation >= PlayerData.reputation_objective:
		PlayerData.rewards_to_apply.append(PlayerData.REWARDS_CYCLE[PlayerData.reputation_level % PlayerData.REWARDS_CYCLE.size()])
		PlayerData.reputation_level += 1
		PlayerData.reputation_objective += Utils.get_level_needed_xp(PlayerData.reputation_level)
	PlayerData.money += _money_today
	
	var _sum := 0

	$container/vbox/title.text = str("[center][wave]Day ", PlayerData.day, "[/wave][/center]")

	$container/vbox/grid/customers_value.text = str(_customers_today)
	$container/vbox/grid/customers_total.text = str("(total: ", PlayerData.unique_customers, ")")

	$container/vbox/grid/happiness_value.text = str("+", _happiness_today)
	$container/vbox/grid/happiness_total.text = str("(total: ", PlayerData.reputation, ")")

	$container/vbox/grid/money_value.text = str("+", _happiness_today, "c")
	$container/vbox/grid/money_total.text = str("(total: ", PlayerData.money, "c)")
	
	$container/vbox/level/vbox/progress.text = str("next level in ", PlayerData.reputation_objective - PlayerData.reputation)
	$container/vbox/level/vbox/hbox.update()

var rewards_labels := {
	"bag": "To reward you, we've given you a better bag!",
	"customers": "We set up an advertising campaign for the hotel. Expect more customers!",
	"vip": "With the reputation you've built up, more VIPs will set foot in your hotel.",
	"money": "We've sent you money as a reward.",
	"gift": "A parcel full of gifts for your customers will arrive later today.",
}

var tips := [
	"Rodents can't reach high objects.",
	"The rodents you scare will be terrified and won't come out until the day after tomorrow!",
	"To assign a room to a customer, you can either use the whistle on the door or bring the customer inside.",
	"A rodent nest is destroyed if there are no rodents in it, or if all the rodents inside are terrorized."
]

var i = 0.0

func show_next() -> void:
	$container/vbox/continue.visible = true

var ended := true

func _process(delta: float) -> void:
	$container/background.position.y = -784 + (sin(i) * 8.0)
	$container/background.rotation += abs(cos(i)) * delta * 0.2
	i += delta
	#if ended:
		#return
	#if xp_animation_progress <= PlayerData.reputation:
		#xp_animation_progress += delta * 25.0
		#$container/vbox/level/vbox/progress.text = str("xp today: ", floor(PlayerData.reputation - xp_animation_progress))
	#else:
		#$container/vbox/level/vbox/progress.text = str("stars: ", PlayerData.reputation_level)
		#ended = true
		#show_next()
	#for bar in $container/vbox/level/vbox/hbox.get_children():
		#bar.value = xp_animation_progress


var messages : Array[String]

func _on_continue_pressed() -> void:
	$container/vbox.visible = false
	$container/messages.visible = true
	if GameManager.hotel.cleanliness <= 0.20:
		if PlayerData.warned:
			PlayerData.game_over = true
			messages.append("[color='550f0a']Hello.\n\n" +
				"Unfortunately yesterday's mail was not enough.\n" +
				"The city is urgently asking us to close the hotel.\n" +
				"It's been a great adventure, but everything has an end.\n" +
				"We congratulate you on the efforts you've made for Bizarre Hotels.[/color]"
			)
		else:
			PlayerData.warned = true
			messages.append("[color='550f0a']Hello.\n\n" +
				"The cleanliness of your hotel is really not good enough. If you don't redouble your efforts, we will be forced to close the establishment [shake]TOMORROW EVENING[/shake].\n" +
				"This will be our one and only warning.\n" +
				"Good luck in getting things back on track.[/color]\n"
			)
	if PlayerData.day == 1:
		messages.append("[wave]Hello![/wave]\n" +
			"Congratulations on your promotion to manager of one of the Bizarre hotels, i hope your first day wasn't too difficult.\n" +
			"We've received word from the neighboring buildings that a rodent infection is spreading throughout the city.\n" +
			"Until it settles down, we're asking you to please be vigilant. Rodents can quickly become a threat if you don't take the necessary precautions.\n\n" +
			"[color='482e27']If the infection becomes too serious, we'll be legally obliged to destroy the hotel immediately, leaving you jobless.[/color]"
		)
	if PlayerData.day == 3:
		messages.append("By the way... If you see furniture stuck upside down to the ceiling, don't be surprised... It must still be a strange phenomenon to explain!")
	if !PlayerData.game_over:
		for label in PlayerData.rewards_to_apply:
			messages.append(str("Congratulations on your performance!\n", rewards_labels[label]))
		messages.append("Tip:\n" + tips.pick_random())
	show_next_message()

func show_next_message() -> void:
	if PlayerData.game_over:
		get_tree().change_scene_to_file("res://ui/game_over.tscn")
		return
	if messages.is_empty():
		$container/transition/animation_player.play("fade_in")
		var _tween := get_tree().create_tween()
		_tween.tween_property($music, "volume_db", -80, 0.3)
		GameManager.to_hotel()
		return
	var _message := messages[0]
	messages.remove_at(0)
	$paper.play()
	$container/messages/label.text = str("Messages (", messages.size(), " remaining)")
	$container/messages/message.text = str(
		_message + "\n" +
		"[right][color=red]Signed: Hotel management[/color][/right]")

func _on_message_continue_pressed() -> void:
	show_next_message()
