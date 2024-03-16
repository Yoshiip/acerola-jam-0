class_name Item

extends Resource

@export_enum("Item", "Furniture", "Blueprint") var type: int

@export var id : String
@export var name : String
@export_multiline var description : String
@export var icon : CompressedTexture2D
@export var prop : PackedScene

@export var price := 0

@export_category("Furniture")
@export var decorative_value := 0
@export var paintable := false

var data := {}
