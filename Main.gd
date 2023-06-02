extends Node2D

var Enemy = preload("res://Enemy.tscn")

onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer
onready var difficulty_timer = $DifficultyTimer

onready var difficulty_value = $CanvasLayer/VBoxContainer/BottomRow/HBoxContainer/DifficultyLabel2
onready var killed_value = $CanvasLayer/VBoxContainer/TopRow2/TopRow/EnemiesKilledValue
onready var game_over_screen = $CanvasLayer/GameOverScreen 

#SFX
var mistype_sound: AudioStreamPlayer
var success_sound: AudioStreamPlayer

# detecta naves ativas na cena
var active_enemy = null

#index da letra atual que necessita ser digitada
var current_letter_index: int = -1

#variavel da dificuldade
var difficulty: int = 0

#naves matadas
var enemies_killed: int = 0

#spawna um inimogo antes do timeout de 3 segundos
func _ready() -> void:
	# Load the mistype sound effect
	mistype_sound = AudioStreamPlayer.new()
	mistype_sound.stream = preload("res://assets/sfx/wrong_type.wav")
	add_child(mistype_sound)
	mistype_sound.volume_db = -10.0
	
	# Load the success sound effect
	success_sound = AudioStreamPlayer.new()
	success_sound.stream = preload("res://assets/sfx/type_success.wav")
	add_child(success_sound)
	success_sound.volume_db = -20.0
	
	start_game()

##SFX Functions
func play_mistype_sound() -> void:
	# Play the mistype sound effect
	mistype_sound.play()
	
func play_success_sound() -> void:
	# Play the success sound effect
	success_sound.play()
	
func find_new_active_enemy(typed_character: String):
	for enemy in enemy_container.get_children():
		var prompt = enemy.get_prompt()
		var next_character = prompt.substr(0, 1)
		if next_character == typed_character:
			print("Novo inimigo encontrado, comeca com a letra %s " % next_character)
			active_enemy = enemy
			current_letter_index = 1
			active_enemy.set_next_character(current_letter_index)
			return
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		#caso nao haja nenhuma nave ativa, passa para a proxima na cena
		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:
			var prompt = active_enemy.get_prompt()
			var next_character = prompt.substr(current_letter_index, 1)
			if key_typed == next_character:
				play_success_sound()
				print ("successfully typed %s" % key_typed)
				current_letter_index += 1
				active_enemy.set_next_character(current_letter_index)
				if current_letter_index == prompt.length():
					print("correto")
					current_letter_index = -1
					active_enemy.queue_free()
					active_enemy = null
					enemies_killed += 1
					killed_value.text = str(enemies_killed)
			else:
				play_mistype_sound()
				print("Voce digitou errado, letra %s ao invez de %s" % [key_typed, next_character])
					

#spawna as naves a cada 3 segundos em um spawn aleatorio
func _on_SpawnTimer_timeout() -> void:
	spawn_enemy()
	

func spawn_enemy():
	var enemy_instance = Enemy.instance()
	var spawns = spawn_container.get_children()
	var index = randi() % spawns.size()
	enemy_instance.global_position = spawns[index].global_position
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_difficulty(difficulty)
	

# emite as mudancas na dificuldade ao decorrer da pontuacao
func _on_DifficultyTimer_timeout():
	difficulty += 1
	GlobalSignals.emit_signal("difficulty_increased", difficulty)
	print("dificuldade aumentada para %d" % difficulty)
	var new_wait_time = spawn_timer.wait_time - 0.2
	spawn_timer.wait_time = clamp(new_wait_time, 1, spawn_timer.wait_time)
	difficulty_value.text = str(difficulty)


func _on_LoseArea_body_entered(body):
	game_over()
	
func game_over():
	game_over_screen.show()
	spawn_timer.stop()
	difficulty_timer.stop()
	difficulty
	active_enemy = null
	current_letter_index = -1
	for enemy in enemy_container.get_children():
		enemy.queue_free()
		
func start_game():
	game_over_screen.hide()
	difficulty = 0
	enemies_killed = 0
	randomize()
	spawn_timer.start()
	difficulty_timer.start()
	spawn_enemy()

func _on_RestartButton_pressed():
	start_game()
