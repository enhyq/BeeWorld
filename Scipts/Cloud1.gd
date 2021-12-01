extends RigidBody2D


var direction = 1

var rng = RandomNumberGenerator.new()

func _ready():
    rng.randomize()


func _on_MovementTimer_timeout():
    var x = rng.randi_range(0, 1000)
    var x_dir = rng.randi_range(-1,1)
    var y = rng.randi_range(0, 1000)
    apply_central_impulse(Vector2(x*x_dir, y*direction))
    direction = direction * -1
    
    var timer_time = rng.randi_range(1,10)
    $MovementTimer.start(timer_time)
