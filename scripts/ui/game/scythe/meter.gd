extends Node2D

var point_arr

onready var points = get_node("points")

func _ready():
	point_arr = []
	for point in points.get_children():
		point_arr.append(point)
	update_points(0)

func update_points(point_count):
	var temp_count = 0
	for i in range(len(point_arr)):
		temp_count += 1
		point_arr[i].visible = point_count >= temp_count
