class_name PatternGenerator

static func generate_random_path(grid_size: int, min_length: int = 5) -> Array:
	var path: Array = []
	var visited: Array = []
	var start = randi() % (grid_size * grid_size)
	path.append(start)
	visited.append(start)
	var attempts = 0
	while attempts < 100:
		attempts += 1
		var neighbors = get_neighbors(path.back(), grid_size)
		var unvisited = []
		for n in neighbors:
			if not visited.has(n):
				unvisited.append(n)
		if unvisited.is_empty():
			break
		var next = unvisited[randi() % unvisited.size()]
		path.append(next)
		visited.append(next)
		if path.size() >= min_length and randf() < 0.3:
			break
	return path

static func get_neighbors(dot_index: int, grid_size: int) -> Array:
	var neighbors = []
	var row = floori(dot_index / float(grid_size))
	var col = dot_index % grid_size
	for dr in [-1, 0, 1]:
		for dc in [-1, 0, 1]:
			if dr == 0 and dc == 0:
				continue
			var nr = row + dr
			var nc = col + dc
			if nr >= 0 and nr < grid_size and nc >= 0 and nc < grid_size:
				neighbors.append(nr * grid_size + nc)
	return neighbors
