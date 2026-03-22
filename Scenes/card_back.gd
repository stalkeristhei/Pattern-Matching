extends Control

const GRID_WIDTH = 350.0
const GRID_HEIGHT = 450.0

func _ready():
	custom_minimum_size = Vector2(GRID_WIDTH, GRID_HEIGHT)

func _draw():
	var card_color = Color(0.05, 0.1, 0.35, 0.92)
	var border_color = Color(0.25, 0.4, 0.75, 0.9)
	var bevel_light = Color(1.0, 1.0, 1.0, 0.3)
	var bevel_dark = Color(0.0, 0.0, 0.0, 0.45)

	# Drop shadow
	draw_rect(Rect2(6, 6, GRID_WIDTH, GRID_HEIGHT), Color(0, 0, 0, 0.35), true)

	# Main card body
	draw_rect(Rect2(0, 0, GRID_WIDTH, GRID_HEIGHT), card_color, true)

	# Bevel dark bottom/right
	draw_line(Vector2(14, GRID_HEIGHT), Vector2(GRID_WIDTH - 14, GRID_HEIGHT), bevel_dark, 3.0)
	draw_line(Vector2(GRID_WIDTH, 14), Vector2(GRID_WIDTH, GRID_HEIGHT - 14), bevel_dark, 3.0)

	# Bevel light top/left
	draw_line(Vector2(14, 0), Vector2(GRID_WIDTH - 14, 0), bevel_light, 3.0)
	draw_line(Vector2(0, 14), Vector2(0, GRID_HEIGHT - 14), bevel_light, 3.0)

	# Outer border
	draw_rect(Rect2(0, 0, GRID_WIDTH, GRID_HEIGHT), border_color, false, 2.0)

	# Inner borders (card inset look)
	draw_rect(Rect2(8, 8, GRID_WIDTH - 16, GRID_HEIGHT - 16), Color(1, 1, 1, 0.07), false, 1.0)
	draw_rect(Rect2(16, 16, GRID_WIDTH - 32, GRID_HEIGHT - 32), Color(1, 1, 1, 0.05), false, 1.0)

	# Label
	draw_string(
		ThemeDB.fallback_font,
		Vector2(GRID_WIDTH / 2 - 28, 22),
		"PATTERN",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1, 11,
		Color(1, 1, 1, 0.4)
	)
	draw_line(Vector2(20, 28), Vector2(GRID_WIDTH - 20, 28), Color(1, 1, 1, 0.08), 1.0)

	# Diamond dot pattern
	var spacing = 38.0
	for x in range(-1, int(GRID_WIDTH / spacing) + 2):
		for y in range(-1, int(GRID_HEIGHT / spacing) + 2):
			var offset = spacing * 0.5 if y % 2 == 0 else 0.0
			var cx = x * spacing + offset
			var cy = y * spacing
			if cx > 20 and cx < GRID_WIDTH - 20 and cy > 32 and cy < GRID_HEIGHT - 20:
				draw_circle(Vector2(cx, cy), 3.5, Color(0.35, 0.35, 0.95, 0.3))
				draw_arc(Vector2(cx, cy), 3.5, 0, TAU, 8, Color(0.5, 0.5, 1.0, 0.2), 1.0)

	# Center emblem background
	var center = Vector2(GRID_WIDTH / 2, GRID_HEIGHT / 2)
	draw_circle(center, 52.0, Color(0.08, 0.08, 0.3, 0.7))
	draw_circle(center, 48.0, Color(0.1, 0.1, 0.4, 0.6))

	# Emblem rings
	draw_arc(center, 52.0, 0, TAU, 64, Color(0.4, 0.4, 0.9, 0.7), 2.0)
	draw_arc(center, 40.0, 0, TAU, 64, Color(0.4, 0.4, 0.9, 0.4), 1.5)
	draw_arc(center, 28.0, 0, TAU, 64, Color(0.5, 0.5, 1.0, 0.3), 1.0)

	# Emblem spokes
	for i in range(8):
		var angle = i * TAU / 8.0
		var inner = center + Vector2(cos(angle), sin(angle)) * 28.0
		var outer = center + Vector2(cos(angle), sin(angle)) * 48.0
		draw_line(inner, outer, Color(0.5, 0.5, 1.0, 0.25), 1.0)

	# Center dot
	draw_circle(center, 10.0, Color(0.3, 0.3, 0.8, 0.8))
	draw_circle(center, 6.0, Color(0.6, 0.6, 1.0, 0.9))
	draw_circle(center + Vector2(-2, -2), 2.5, Color(1, 1, 1, 0.5))

	# Question mark
	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-6, 70),
		"memorise & draw",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1, 11,
		Color(0.6, 0.6, 1.0, 0.5)
	)
