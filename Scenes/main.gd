extends Node2D

@onready var player_grid = $CanvasLayer/HBoxContainer/PlayerGrid
@onready var ai_flip_card = $CanvasLayer/HBoxContainer/AIFlipCard
@onready var ai_grid_front = $CanvasLayer/HBoxContainer/AIFlipCard/AIGridFront
@onready var submit_button = $CanvasLayer/SubmitButton
@onready var timer_label = $CanvasLayer/TimerLabel
@onready var result_label = $CanvasLayer/ResultLabel

var time_left: int = 10
var drawing_active: bool = false
var timer: Timer
var ai_sequence: Array = []

func _ready():
	submit_button.pressed.connect(_on_submit_pressed)
	submit_button.disabled = true
	result_label.text = ""
	timer_label.text = "Memorise!"
	await get_tree().process_frame
	await get_tree().process_frame
	player_grid.is_player_grid = true
	player_grid.can_interact = false
	player_grid.show_numbers = true
	ai_grid_front.is_player_grid = false
	ai_grid_front.can_interact = false
	ai_grid_front.show_numbers = true
	player_grid.setup_dots()
	ai_grid_front.setup_dots()
	generate_ai_pattern()
	# Show pattern for 2 seconds then flip card back
	await get_tree().create_timer(2.0).timeout
	ai_flip_card.flip_to_back(func():
		# Card is now face down — let player draw
		player_grid.can_interact = true
		submit_button.disabled = false
		drawing_active = true
		start_timer()
	)

func generate_ai_pattern():
	ai_sequence = PatternGenerator.generate_random_path(6, 5)
	ai_grid_front.set_sequence(ai_sequence)
	player_grid.hint_start = ai_sequence[0]
	player_grid.queue_redraw()

func start_timer():
	timer_label.text = "Time: " + str(time_left) + "s"
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_tick)
	add_child(timer)
	timer.start()

func _on_timer_tick():
	if not drawing_active:
		return
	time_left -= 1
	timer_label.text = "Time: " + str(time_left) + "s"
	if time_left <= 0:
		end_drawing([])

func _on_submit_pressed():
	if drawing_active:
		var snapshot = player_grid.connected_sequence.duplicate()
		end_drawing(snapshot)

func end_drawing(snapshot: Array):
	drawing_active = false
	player_grid.dragging = false
	player_grid.can_interact = false
	submit_button.disabled = true
	timer.stop()
	timer_label.text = "Time's up!"
	# Flip card back to front to reveal answer
	ai_flip_card.flip_to_front(func():
		ai_grid_front.show_numbers = true
		ai_grid_front.queue_redraw()
	)
	var player_seq = snapshot if snapshot.size() > 0 else player_grid.connected_sequence.duplicate()
	calculate_score(player_seq)

func calculate_score(player_seq: Array):
	if player_seq.size() < 2:
		result_label.text = "Connect some dots first!"
		return
	var a_moves = get_move_sequence(player_seq)
	var b_moves = get_move_sequence(ai_sequence)
	var similarity = compare_moves(a_moves, b_moves)
	var score = round(similarity)
	if score >= 80:
		result_label.text = "Great! " + str(score) + "%"
	elif score >= 50:
		result_label.text = "OK! " + str(score) + "%"
	else:
		result_label.text = "Try again! " + str(score) + "%"

func index_to_grid(idx: int) -> Vector2:
	return Vector2(idx % 6, floori(idx / 6.0))

func get_move_sequence(seq: Array) -> Array:
	var moves = []
	for i in range(seq.size() - 1):
		var from = index_to_grid(seq[i])
		var to = index_to_grid(seq[i + 1])
		moves.append(to - from)
	return moves

func compare_moves(a: Array, b: Array) -> float:
	if a.size() == 0 or b.size() == 0:
		return 0.0
	var m = a.size()
	var n = b.size()
	var dp = []
	for i in range(m + 1):
		dp.append([])
		for j in range(n + 1):
			dp[i].append(0)
	for i in range(m + 1):
		dp[i][0] = i
	for j in range(n + 1):
		dp[0][j] = j
	for i in range(1, m + 1):
		for j in range(1, n + 1):
			if a[i-1] == b[j-1]:
				dp[i][j] = dp[i-1][j-1]
			else:
				dp[i][j] = 1 + min(dp[i-1][j], min(dp[i][j-1], dp[i-1][j-1]))
	var max_len = max(m, n)
	return clamp((1.0 - float(dp[m][n]) / float(max_len)) * 100.0, 0.0, 100.0)

func setup_ui_styles():
	# Timer label - dark background
	timer_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	timer_label.add_theme_font_size_override("font_size", 20)
	var timer_bg = StyleBoxFlat.new()
	timer_bg.bg_color = Color(0.05, 0.08, 0.25, 0.9)
	timer_bg.border_color = Color(0.3, 0.5, 1.0, 0.9)
	timer_bg.set_border_width_all(2)
	timer_bg.set_corner_radius_all(6)
	timer_bg.content_margin_left = 12
	timer_bg.content_margin_right = 12
	timer_bg.content_margin_top = 6
	timer_bg.content_margin_bottom = 6
	timer_label.add_theme_stylebox_override("normal", timer_bg)

	# Result label - dark background
	result_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	result_label.add_theme_font_size_override("font_size", 20)
	var result_bg = timer_bg.duplicate()
	result_label.add_theme_stylebox_override("normal", result_bg)

	# Submit button
	submit_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	submit_button.add_theme_font_size_override("font_size", 16)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.1, 0.2, 0.6, 0.95)
	btn_style.border_color = Color(0.4, 0.6, 1.0, 1.0)
	btn_style.set_border_width_all(2)
	btn_style.set_corner_radius_all(6)
	btn_style.content_margin_left = 16
	btn_style.content_margin_right = 16
	btn_style.content_margin_top = 8
	btn_style.content_margin_bottom = 8
	submit_button.add_theme_stylebox_override("normal", btn_style)
	var hover_style = btn_style.duplicate()
	hover_style.bg_color = Color(0.2, 0.35, 0.85, 1.0)
	submit_button.add_theme_stylebox_override("hover", hover_style)
