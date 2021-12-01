extends RigidBody2D

signal bug_is_dead
signal score_point_reached

export var debug = true

var forward_impulse = Vector2(120,0)
var forward_frequency = 1 #seconds
var jump_impulse = Vector2(0, -80)
var fall_impulse = Vector2(0, 60)
var angular_impulse = 8

# for updating score 
var score_point_step = 180/10
var next_score_point = 0 + score_point_step


enum State {
    IDLE = 0,
    PLAYING = 1,
    DEAD = 2
   }
var bug_state = State.IDLE

var default_gravity_scale = 1


# currently not used
var max_jump_vel = Vector2(-100, 0)
var max_forward_vel = Vector2(123, 0)
var SOI_sources = []

# built in system functions
func _ready():
    # init
    $ForwardMoveTimer.wait_time = forward_frequency
    set_state(State.IDLE)
    
    # debug
    if debug == false:
        var debug_nodes = [$LinearVelocity]
        debug_nodes = debug_nodes + $DebugViewport.get_children()
        for node in debug_nodes:
            node.visible = false

func _physics_process(_delta):
    if bug_state == State.PLAYING:
        var game_theta = get_rotation_on_earth()
        
        if get_rotation() < game_theta:
            # rotate right
            apply_torque_impulse(angular_impulse)
            set_debugLabel_text("adding", "AddingLabel")
        else:
            # rotate left
            apply_torque_impulse(-angular_impulse)
            set_debugLabel_text("subtracting", "AddingLabel")
        
        if $ForwardMoveTimer.time_left == 0:
            apply_central_impulse( forward_impulse.rotated(get_rotation_on_earth()) )
            $DebugViewport/ForwardVector.points[1] = forward_impulse.rotated(get_rotation_on_earth())
            $ForwardMoveTimer.start()
        
        # for score update
#        print(rad2deg(get_rotation_on_earth()))
        if next_score_point == 180.0:
            if sign(get_rotation_on_earth()) == -1:
                next_score_point = -180 + score_point_step
                emit_signal("score_point_reached")
        elif rad2deg(get_rotation_on_earth()) >= next_score_point:
            next_score_point = next_score_point + score_point_step
            emit_signal("score_point_reached")
        
        set_debugLabel_text("rotation:   " + str(rotation_degrees) + "\ngame_angle: " + str(rad2deg(game_theta)), "DebugLabel")

func _unhandled_input(event):
    if bug_state == State.PLAYING:
        if event is InputEventMouseButton:
            if event.get_button_index() == BUTTON_LEFT:
                jump()
            if event.get_button_index() == BUTTON_RIGHT:
                fall()

func _integrate_forces(state):
    if bug_state == State.PLAYING:
        set_debugLabel_text(state.get_angular_velocity(), "PhysicalState/AngularVelocity")
        set_debugLabel_text(state.get_linear_velocity(), "PhysicalState/LinearVelocity")
        $LinearVelocity.points[1] = state.get_linear_velocity().rotated(-get_global_rotation())
        
        # max and min speed contorl ???
#    if state.get_linear_velocity() > max_forward_velocity:
#        pass


# custom functions
func jump():
    var impulse = jump_impulse.rotated(get_rotation())
    $DebugViewport/JumpVector.points[1] = jump_impulse.rotated(get_rotation_on_earth())
    apply_central_impulse(impulse)

func fall():
    var impulse = fall_impulse.rotated(get_rotation())
    $DebugViewport/JumpVector.points[1] = fall_impulse.rotated(get_rotation_on_earth())
    apply_central_impulse(impulse)

func entered_SOI(SOI_origin):
    SOI_sources.append(SOI_origin)

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

func set_state(state):
    bug_state = state
    if state == State.DEAD:
        $AnimatedSprite.set_animation("bee_dead")
        call_deferred("set_contact_monitor", false)
        emit_signal("bug_is_dead")
    if state == State.IDLE:
        gravity_scale = 0
        $AnimatedSprite.set_animation("default")
        call_deferred("set_contact_monitor", false)
    if state == State.PLAYING:
        gravity_scale = default_gravity_scale
        $AnimatedSprite.set_animation("bee_fly")
        set_contact_monitor(true)


# functions for debugging
func set_debugLabel_text(text, label_path):
    if debug:
        label_path = "DebugViewport/Debug/" + label_path
        var node
        if "/" in label_path:
            node = get_node(label_path)
        else:
            node = get_node(label_path.replace(".", "/"))
        if node.get_class() == "Label":
            node.set_text(str(text))
        else:
            print_stack()
            printerr("set text for non-label node")

func show_mouse_angle_on_earth():
    if debug:
        var mouse_pos = get_global_mouse_position()
        var h = mouse_pos.length()
        var a = mouse_pos.x
        var o = mouse_pos.y
    #    var theta = acos(a/h)
        var theta = asin(o/h)
        var theta_degree = rad2deg(theta)
        var _game_theta = (theta_degree+90) * (-1 if sign(a) == -1 else 1)
        # + (360 if sign(a) == -1 else 0)


# signals

func _on_Bug_RigidBody2D_body_entered(_body):
    set_state(State.DEAD)
