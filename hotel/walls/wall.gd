extends StaticBody3D

const WALLPAPERS := {
	"red": preload("res://resources/materials/red_wallpaper.tres"),
	"green": preload("res://resources/materials/green_wallpaper.tres"),
	"blue": preload("res://resources/materials/blue_wallpaper.tres"),
	"purple": preload("res://resources/materials/purple_wallpaper.tres"),
}

var color := "red"

func _ready() -> void:
	$mesh/wall.set("surface_material_override/0", WALLPAPERS[color])
