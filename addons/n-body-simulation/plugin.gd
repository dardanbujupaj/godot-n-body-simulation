tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("NBodySimulation3D", "Spatial", preload("NBodySimulation3D.gd"), preload("NBodySimulation3D.svg"))



func _exit_tree():
	remove_custom_type("NBodySimulation3D")
