tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("NBodySimulation", "Spatial", preload("NBodySimulation.gd"), preload("NBodySimulation.svg"))



func _exit_tree():
	remove_custom_type("NBodySimulation")
