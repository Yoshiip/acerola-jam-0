extends VBoxContainer

const LABEL = preload("res://ui/customer_status/label.tscn")
const VALUE = preload("res://ui/customer_status/value.tscn")

func display(summary : Array[Array]) -> void:
	for child in $container.get_children():
		child.queue_free()
	var _total := 0
	for line in summary:
		var _label := LABEL.instantiate()
		_label.text = line[0]
		$container.add_child(_label)
		var _value := VALUE.instantiate()
		_value.text = str("+" if line[1] > 0 else "", line[1])
		$container.add_child(_value)
		_total += line[1]
	$total.text = str(_total, "/20")
