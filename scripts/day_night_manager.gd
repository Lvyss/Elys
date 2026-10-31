extends Node

@export var sun: DirectionalLight3D
@export var world_env: WorldEnvironment
@export var day_length_seconds: float = 120.0 # 120 detik = 1 siklus pagi ke sore

@export var sun_color_gradient: Gradient
@export var fog_density_curve: Curve

var time_of_day: float = 0.0 # 0.0 = Pagi, 0.5 = Siang, 1.0 = Sore

func _process(delta):
	# Waktu berjalan terus
	time_of_day += delta / day_length_seconds
	if time_of_day > 1.0:
		time_of_day = 0.0 # Balik ke pagi lagi
	
	_update_lighting()

func _update_lighting():
	if not sun or not world_env:
		return # Kalau belum dimasukkan di Inspector, script berhenti biar gak error
		
	# 1. MUTER MATAHARI (Dari timur ke barat)
	sun.rotation_degrees.x = lerp(-10.0, -170.0, time_of_day)
	sun.rotation_degrees.y = lerp(-45.0, 45.0, time_of_day) 
	
	# 2. INTENSITAS CAHAYA (Pagi redup -> Siang terik -> Sore redup)
	var sun_energy = sin(time_of_day * PI) * 1.5
	sun.light_energy = max(sun_energy, 0.1) # Minimal 0.1 biar gak gelap total
	
	# 3. UBAH WARNA MATAHARI & KABUT
	if sun_color_gradient:
		sun.light_color = sun_color_gradient.sample(time_of_day)
		world_env.environment.volumetric_fog_albedo = sun_color_gradient.sample(time_of_day)
	
	# 4. UBAH KETEBALAN KABUT
	if fog_density_curve:
		world_env.environment.volumetric_fog_density = fog_density_curve.sample(time_of_day)
