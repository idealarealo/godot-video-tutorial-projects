class_name Main
extends Node3D

static var map := BasicMap.new()
static var rnd := RandomNumberGenerator.new()

static func _static_init():
	map.from_image_resource(preload("res://resources/terrain/texmap.png"))
	assert(map.is_valid(), "Invalid Map")
	
	rnd.seed = 6  # a good example
