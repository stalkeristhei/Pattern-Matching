extends Node2D

@onready var player_grid = $CanvasLayer/HBoxContainer/PlayerGrid
@onready var ai_flip_card = $CanvasLayer/HBoxContainer/AIFlipCard
@onready var ai_grid_front = $CanvasLayer/HBoxContainer/AIFlipCard/AIGridFront
@onready var submit_button = $CanvasLayer/SubmitButton
@onready var timer_label = $CanvasLayer/TimerLabel
@onready var result_label = $CanvasLayer/ResultLabel
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var restart_button = $CanvasLayer/RestartButton

var time_left: int = 10
var drawing_active: bool = false
var timer: Timer
var ai_sequence: Array = []

var streak: int = 0
var game_over: bool = false

func _ready():
	submit_button.pressed.connect(_on_submit_pressed)
	restart_button.pressed.connect(_on_restart_pressed)

	player_grid.is_player_grid = true
	player_grid.can_interact = false
	player_grid.show_numbers = true

	ai_grid_front.is_player_grid = false
	ai_grid_front.can_interact = false
	ai_grid_front.show_numbers = true

	player_grid.setup_dots()
	ai_grid_front.setup_dots()

	restart_button.visible = false

	start_round()

func start_round():
	time_left = 10

	player_grid.connected_sequence.clear()
	player_grid.dragging = false
	player_grid.queue_redraw()

	submit_button.disabled = true
	result_label.text = ""
	timer_label.text = "Memorise!"

	generate_ai_pattern()

	await get_tree().create_timer(2.0).timeout

	ai_flip_card.flip_to_back(func():
		player_grid.can_interact = true
		submit_button.disabled = false
		drawing_active = true
		start_timer()
	)

	update_score()

func generate_ai_pattern():
	ai_sequence = PatternGenerator.generate_random_path(6, 5)

	ai_grid_front.set_sequence(ai_sequence)

	player_grid.hint_start = ai_sequence[0]
	player_grid.queue_redraw()

func start_timer():
	if timer:
		timer.queue_free()

	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_tick)

	add_child(timer)

	timer_label.text = "Time: " + str(time_left) + "s"

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

	if timer:
		timer.stop()

	ai_flip_card.flip_to_front(func():
		ai_grid_front.show_numbers = true
		ai_grid_front.queue_redraw()
	)

	var player_seq = snapshot

	if player_seq.size() <= 0:
		player_seq = player_grid.connected_sequence.duplicate()

	calculate_score(player_seq)

func calculate_score(player_seq: Array):
	if player_seq.size() < 2:
		game_failed("No pattern!")
		return

	var a_moves = get_move_sequence(player_seq)
	var b_moves = get_move_sequence(ai_sequence)

	var similarity = compare_moves(a_moves, b_moves)
	var score = round(similarity)

	if score >= 80:
		streak += 1

		result_label.text = "Correct! " + str(score) + "%"

		update_score()

		await get_tree().create_timer(1.5).timeout

		start_round()

	else:
		game_failed("Wrong! " + str(score) + "%")

func game_failed(message: String):
	game_over = true

	result_label.text = message + "\nFinal Score: " + str(streak)

	timer_label.text = "Game Over"

	restart_button.visible = true

func _on_restart_pressed():
	streak = 0
	game_over = false

	restart_button.visible = false

	start_round()

func update_score():
	score_label.text = "Score: " + str(streak)

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

			if a[i - 1] == b[j - 1]:
				dp[i][j] = dp[i - 1][j - 1]
			else:
				dp[i][j] = 1 + min(
					dp[i - 1][j],
					min(dp[i][j - 1], dp[i - 1][j - 1])
				)

	var max_len = max(m, n)

	return clamp(
		(1.0 - float(dp[m][n]) / float(max_len)) * 100.0,
		0.0,
		100.0
	)
