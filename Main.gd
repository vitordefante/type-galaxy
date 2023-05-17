extends Node2D

var Enemy = preload("res://Enemy.tscn")

onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer


# detecta naves ativas na cena
var active_enemy = null

#index da letra atual que necessita ser digitada
var current_letter_index: int = -1

#spawna um inimogo antes do timeout de 3 segundos
func _ready() -> void:
	randomize()
	spawn_timer.start()
	spawn_enemy()

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
				print ("successfully typed %s" % key_typed)
				current_letter_index += 1
				active_enemy.set_next_character(current_letter_index)
				if current_letter_index == prompt.length():
					print("correto")
					current_letter_index = -1
					active_enemy.queue_free()
					active_enemy = null
			else:
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
	
