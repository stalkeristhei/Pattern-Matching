extends Control

const GRID_SIZE = 6
const DOT_RADIUS = 10.0
const GRID_WIDTH = 350.0
const GRID_HEIGHT = 450.0
const PADDING = 50.0

var dots: Array = []
var connected_sequence: Array = []
var is_player_grid: bool = true
var dragging: bool = false
var can_interact: bool = true
var show_numbers: bool = true
var hint_start: int = -1

func _ready():
	custom_minimum_size = Vector2(GRID_WIDTH, GRID_HEIGHT)
	setup_dots()

func setup_dots():
	dots.clear()
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			dots.append(Vector2(
				PADDING + col * ((GRID_WIDTH - PADDING * 2) / (GRID_SIZE - 1)),
				PADDING + row * ((GRID_HEIGHT - PADDING * 2) / (GRID_SIZE - 1))
			))
	queue_redraw()

func _input(event):
	if not is_player_grid:
		return
	var local_pos = get_local_mouse_position()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and can_interact:
			var dot = get_dot_at(local_pos)
			if dot != -1:
				dragging = true
				connected_sequence.clear()
				connected_sequence.append(dot)
				queue_redraw()
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging and can_interact:
		var dot = get_dot_at(local_pos)
		if dot != -1 and (connected_sequence.is_empty() or connected_sequence.back() != dot):
			if not connected_sequence.has(dot):
				connected_sequence.append(dot)
				queue_redraw()

func get_dot_at(pos: Vector2) -> int:
	for i in range(dots.size()):
		if pos.distance_to(dots[i]) <= DOT_RADIUS * 2.0:
			return i
	return -1

func set_sequence(seq: Array):
	connected_sequence = seq.duplicate()
	queue_redraw()

func clear():
	connected_sequence.clear()
	queue_redraw()

func _draw():
	if dots.is_empty():
		return
	
	var card_color = Color(0.25, 0.45, 0.85, 0.55) if is_player_grid else Color(0.05, 0.12, 0.38, 0.75)
	var border_color = Color(0.55, 0.75, 1.0, 0.9) if is_player_grid else Color(0.25, 0.4, 0.75, 0.9)
	var bevel_light = Color(1.0, 1.0, 1.0, 0.35)
	var bevel_dark = Color(0.0, 0.0, 0.0, 0.4)
	var r = 16.0 # corner radius

	# Drop shadow
	draw_rect(Rect2(6, 6, GRID_WIDTH, GRID_HEIGHT), Color(0, 0, 0, 0.3), true)

	# Main card body
	draw_rect(Rect2(0, 0, GRID_WIDTH, GRID_HEIGHT), card_color, true)

	# Bevel - dark bottom/right edges
	draw_line(Vector2(r, GRID_HEIGHT), Vector2(GRID_WIDTH - r, GRID_HEIGHT), bevel_dark, 3.0)
	draw_line(Vector2(GRID_WIDTH, r), Vector2(GRID_WIDTH, GRID_HEIGHT - r), bevel_dark, 3.0)

	# Bevel - light top/left edges
	draw_line(Vector2(r, 0), Vector2(GRID_WIDTH - r, 0), bevel_light, 3.0)
	draw_line(Vector2(0, r), Vector2(0, GRID_HEIGHT - r), bevel_light, 3.0)

	# Outer border
	draw_rect(Rect2(0, 0, GRID_WIDTH, GRID_HEIGHT), border_color, false, 2.0)

	# Inner inset border
	draw_rect(Rect2(8, 8, GRID_WIDTH - 16, GRID_HEIGHT - 16), Color(1, 1, 1, 0.08), false, 1.0)

	# Subtle inner glow line
	draw_rect(Rect2(4, 4, GRID_WIDTH - 8, GRID_HEIGHT - 8), Color(1, 1, 1, 0.05), false, 1.0)

	# Label at top
	var label = "PLAYER" if is_player_grid else "PATTERN"
	draw_string(
		ThemeDB.fallback_font,
		Vector2(GRID_WIDTH / 2 - 28, 22),
		label,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1, 11,
		Color(1, 1, 1, 0.5)
	)

	# Divider line under label
	draw_line(Vector2(20, 28), Vector2(GRID_WIDTH - 20, 28), Color(1, 1, 1, 0.1), 1.0)

	# Connecting lines
	if connected_sequence.size() >= 2:
		for i in range(connected_sequence.size() - 1):
			var color = Color(0.3, 0.9, 1.0) if is_player_grid else Color(1.0, 0.85, 0.2)
			draw_line(
				dots[connected_sequence[i]],
				dots[connected_sequence[i + 1]],
				color, 3.5
			)

	# Dots
	for i in range(dots.size()):
		var is_selected = connected_sequence.has(i)
		var dot_color: Color
		if is_selected:
			dot_color = Color(0.3, 0.9, 1.0) if is_player_grid else Color(1.0, 0.85, 0.2)
		else:
			dot_color = Color(1.0, 1.0, 1.0, 0.85)
		# Dot shadow
		draw_circle(dots[i] + Vector2(1, 2), DOT_RADIUS, Color(0, 0, 0, 0.2))
		# Dot fill
		draw_circle(dots[i], DOT_RADIUS, dot_color)
		# Dot highlight
		draw_circle(dots[i] + Vector2(-2, -2), DOT_RADIUS * 0.35, Color(1, 1, 1, 0.4))
		# Dot ring
		draw_arc(dots[i], DOT_RADIUS + 2, 0, TAU, 32, Color(0, 0, 0, 0.15), 1.5)

	# Start hint
	if is_player_grid and hint_start != -1 and connected_sequence.is_empty():
		draw_circle(dots[hint_start], DOT_RADIUS + 6, Color(0.0, 1.0, 0.4, 0.25))
		draw_arc(dots[hint_start], DOT_RADIUS + 6, 0, TAU, 32, Color(0.0, 1.0, 0.4, 0.9), 2.0)
		draw_string(
			ThemeDB.fallback_font,
			dots[hint_start] + Vector2(-12, -16),
			"START",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1, 11,
			Color(0.0, 1.0, 0.4)
		)

	# Numbers
	if show_numbers:
		for i in range(connected_sequence.size()):
			var idx = connected_sequence[i]
			draw_string(
				ThemeDB.fallback_font,
				dots[idx] + Vector2(-5, 5),
				str(i + 1),
				HORIZONTAL_ALIGNMENT_LEFT,
				-1, 13,
				Color(0.05, 0.05, 0.05)
			)
	if show_numbers:
		for i in range(connected_sequence.size()):
			var idx = connected_sequence[i]
			draw_string(
				ThemeDB.fallback_font,
				dots[idx] + Vector2(-5, 5),
				str(i + 1),
				HORIZONTAL_ALIGNMENT_LEFT,
				-1, 14,
				Color.BLACK
			)
	# Draw all dots
	for i in range(dots.size()):
		var is_selected = connected_sequence.has(i)
		var dot_color = Color.WHITE if not is_selected else (Color.CYAN if is_player_grid else Color.YELLOW)
		draw_circle(dots[i], DOT_RADIUS, dot_color)
		draw_arc(dots[i], DOT_RADIUS + 2, 0, TAU, 32, Color.DIM_GRAY, 1.5)
	# Draw start hint on player grid
	if is_player_grid and hint_start != -1 and connected_sequence.is_empty():
		draw_circle(dots[hint_start], DOT_RADIUS + 5, Color(0.0, 1.0, 0.0, 0.4))
		draw_arc(dots[hint_start], DOT_RADIUS + 5, 0, TAU, 32, Color.GREEN, 2.0)
		draw_string(
			ThemeDB.fallback_font,
			dots[hint_start] + Vector2(-12, -15),
			"START",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1, 12,
			Color.GREEN
		)
	# Draw order numbers
	if show_numbers:
		for i in range(connected_sequence.size()):
			var idx = connected_sequence[i]
			draw_string(
				ThemeDB.fallback_font,
				dots[idx] + Vector2(-5, 5),
				str(i + 1),
				HORIZONTAL_ALIGNMENT_LEFT,
				-1, 14,
				Color.BLACK
			)
