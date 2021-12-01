tool

extends StaticBody2D

var RADIUS = 1000
# SOI (Sphere of Influence) : 중력 영향권
var SOI = RADIUS*2
var min_SOI = RADIUS+300
var max_SOI = RADIUS+800

var tree1_scene = preload("res://Scenes/Tree1.tscn")
var cloud1_scene = preload("res://Scenes/Cloud1.tscn")

var rng = RandomNumberGenerator.new()

func _ready():
    seed(12345)
#    rng.randomize()
    
    if SOI < min_SOI:
        SOI = min_SOI
    elif SOI > max_SOI:
        SOI = max_SOI
    
    for _i in range(20):
        var pos = (rng.randf_range(deg2rad(10), deg2rad(350)))
        plant_trees(pos)
    
    for _i in range(27):
        var pos = (rng.randf_range(deg2rad(10), deg2rad(350)))
        plant_clouds(pos)
    
    var planet_collision_shape = $Planet_CollisionPolygon2D
    var gravity_area_shape = $Gravity_Area2D/Gravity_CollisionShape2D
    planet_collision_shape.shape.set_radius(RADIUS)
    gravity_area_shape.shape.set_radius(SOI)
    update()

func _draw():
    draw_circle(position, 10000, Color("010026")) # space color
    draw_circle(position, SOI, Color("4ee8fc"))
    draw_circle(position, RADIUS, Color("6fb92b"))


func _physics_process(_delta):
    $StarPivot.set_rotation($BugFollower.rotation)



func plant_trees(angle):
    var surface_origin = Vector2(0, -1000)
    var plant_position = surface_origin.rotated(angle)
    var tree = tree1_scene.instance()
    tree.set_position(plant_position)
    tree.rotate(angle)
    var frame_idx = randi() % 4
    # tree.get_node("AnimatedSprite").get_sprite_frames().frames.size()
    tree.get_node("AnimatedSprite").set_frame(frame_idx)
    add_child(tree)

func plant_clouds(angle):
    var y_variation = rng.randi_range(-200, 200)
    var surface_origin = Vector2(0, -1500+y_variation)
    var plant_position = surface_origin.rotated(angle)
    var cloud = cloud1_scene.instance()
    cloud.set_position(plant_position)
    cloud.rotate(angle)
    var frame_idx = randi() % 8
    cloud.get_node("AnimatedSprite").set_frame(frame_idx)
    add_child(cloud)


func get_rotation_on_earth():
    var pos = get_global_position()
    if pos == Vector2.ZERO:
        return 0
    var h = pos.length()
    var a = pos.x
    var o = pos.y
    var theta = asin(o/h)
    var theta_degree = rad2deg(theta)
    var game_theta = (theta_degree+90) * (-1 if sign(a) == -1 else 1)
    return deg2rad(game_theta)
