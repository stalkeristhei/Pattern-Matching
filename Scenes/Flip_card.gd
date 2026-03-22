extends Control

const GRID_WIDTH = 350.0
const GRID_HEIGHT = 450.0
const FLIP_DURATION = 0.4

var is_front_showing: bool = true
var is_flipping: bool = false
var flip_progress: float = 0.0
var flip_phase: int = 0
var tween: Tween

@onready var front = $AIGridFront
@onready var back = $CardBack

func _ready():
	custom_minimum_size = Vector2(GRID_WIDTH, GRID_HEIGHT)
	back.hide()

func show_front():
	is_front_showing = true
	front.show()
	back.hide()
	scale.x = 1.0

func flip_to_back(callback: Callable):
	if is_flipping:
		return
	is_flipping = true
	# Phase 1: rotate from front to edge
	tween = create_tween()
	tween.tween_property(self, "scale:x", 0.0, FLIP_DURATION).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		front.hide()
		back.show()
		# Phase 2: rotate from edge to back
		tween = create_tween()
		tween.tween_property(self, "scale:x", 1.0, FLIP_DURATION).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func():
			is_flipping = false
			is_front_showing = false
			callback.call()
		)
	)

func flip_to_front(callback: Callable):
	if is_flipping:
		return
	is_flipping = true
	tween = create_tween()
	tween.tween_property(self, "scale:x", 0.0, FLIP_DURATION).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		back.hide()
		front.show()
		tween = create_tween()
		tween.tween_property(self, "scale:x", 1.0, FLIP_DURATION).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func():
			is_flipping = false
			is_front_showing = true
			callback.call()
		)
	)
