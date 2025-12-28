extends Node

func create_noise_image(
	seed: int,
	frequency: float = 0.01,
	fractal_octaves: int = 5,
	fractal_gain: float = 0.02,
	fractal_lacunarity: float = 2.0,
	offset: Vector2i = Vector2i.ZERO,
	size: Vector2i = Vector2i.ZERO,
	path: String = "res://noise.png",
) -> void:
	var noise = create_noise(
		seed,
		frequency,
		fractal_octaves,
		fractal_gain,
		fractal_lacunarity,
	)
	var image = generate_noise_image(noise, offset, size)
	save_image_png(image, path)

func create_noise(
	seed: int,
	frequency: float,
	fractal_octaves: int,
	fractal_gain: float,
	fractal_lacunarity: float,
) -> FastNoiseLite:
	var noise := FastNoiseLite.new()
	noise.seed = seed

	# NOISE TYPE ĐÚNG CHO GODOT 4
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	noise.frequency = frequency
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = fractal_octaves
	noise.fractal_gain = fractal_gain
	noise.fractal_lacunarity = fractal_lacunarity

	return noise

func generate_noise_image(
	noise: FastNoiseLite,
	offset: Vector2i,
	size: Vector2i,
) -> Image:

	var img: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)

	for x in range(size.x):
		for y in range(size.y):
			var n: float = noise.get_noise_2d(x - offset.x, y - offset.y)
			# Noise [-1, 1] → [0, 1]
			var v: float = (n + 1.0) * 0.5
			img.set_pixel(x, y, Color(v, v, v, 1.0))

	return img

func save_image_png(img: Image, path: String) -> void:
	img.save_png(path)
