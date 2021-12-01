extends Node2D

export(NodePath) onready var target = get_node(target)

func _ready():
    pass

func _physics_process(_delta):
    set_position(target.get_global_position())
    set_rotation(get_angle_from_origin())

func set_target(target_node):
    target = target_node

func get_angle_from_origin():
    var pos = get_global_position()
    var h = pos.length()
    var a = pos.x
    var o = pos.y
    var theta = asin(o/h)
    var theta_degree = rad2deg(theta)
    var game_theta = (theta_degree+90) * (-1 if sign(a) == -1 else 1)
    return deg2rad(game_theta)
