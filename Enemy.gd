extends Sprite


onready var prompt = $RichTextLabel
onready var prompt_text = prompt.text


func get_prompt() -> String:
	return prompt_text
