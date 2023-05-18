extends Node

var palavras = [
"elefante",
"girafa",
"banana",
"sorvete",
"jardim",
"parque",
"lapis",
"teclado",
"computador",
"chave",
"porta",
"janela",
"cadeira",
"mesa",
"livro",
"cama",
"travesseiro",
"sol",
"lua"
]

var especiais = [
	"!",
	"."
]

#gera as palavras que irao aparecer nas naves
func get_prompt() -> String:
	#var upperCase = [true, false]
	var word_index = randi() % palavras.size()
	var special_index = randi() % especiais.size()
	
	var palavra = palavras[word_index]
	var especial = especiais[special_index]
	
	return palavra + especial
	
