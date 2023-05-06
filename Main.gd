extends Node2D


# detecta naves ativas na cena
var active_enemy = null

#index da letra atual que necessita ser digitada
var current_letter_index: int = -1

func find_new_active_enemy(typed_character: String):
	print(typed_character)
	print($Enemy.get_prompt())
	var prompt = $Enemy.get_prompt()
	if prompt.substr(0, 1) == typed_character:
		active_enemy = $Enemy
		print("Novo Inimigo!")
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and not event.is_pressed():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		#caso nao haja nenhuma nave ativa, passa para a proxima na cena
		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:
			var prompt = active_enemy.get_prompt()
			var next_character = prompt.substr(current_letter_index, 1)
			if key_typed == next_character:
				print ("success")
