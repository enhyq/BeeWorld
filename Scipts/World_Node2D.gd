extends Node2D

enum GameState {
    FIRST = -1,
    READY = 0,
    PLAYING = 1,
    GAMEOVER = 2
   }
var game_state

onready var current_bug = $Planet_StaticBody2D/Bug_KinematicBody2D

onready var title_page = $GUI/TitlePage
onready var in_game_gui = $GUI/InGameGUI
onready var instruction = $GUI/InstructionPage
onready var game_camera = $Planet_StaticBody2D/BugFollower/GameCamera

var bug_scene = preload("res://Scenes/Bug_RigidBody2D.tscn")


var score = 0

func _ready():
    set_game_state(GameState.FIRST)


func set_game_state(state):
    game_state = state
    if state == GameState.FIRST:
        title_page.visible = false
        in_game_gui.visible = false
        instruction.visible = true
        
    elif state == GameState.READY:
        title_page.visible = true
        in_game_gui.visible = false
        instruction.visible = false
        
    elif state == GameState.PLAYING:
        reset_score()
        game_camera.smoothing_speed = 10
        title_page.visible = false
        in_game_gui.visible = true
        instruction.visible = false
        current_bug.set_state(current_bug.State.PLAYING)
        
    elif state == GameState.GAMEOVER:
        game_camera.smoothing_speed = 2
        title_page.visible = false # visible after timer
        in_game_gui.visible = true
        instruction.visible = false
        $GameOverWaitTimer.start()

func reset_score():
    in_game_gui.get_node("ScoreLabel").set_text(str(0.0)+" PI")
    score = 0
func respawn_bug_and_give_control():
    var new_bug = bug_scene.instance()
    new_bug.set_position($Planet_StaticBody2D/PlayerSpawnPoint.get_position())
    add_child(new_bug)
    $Planet_StaticBody2D/BugFollower.set_target(new_bug)
    new_bug.connect("bug_is_dead", self, "_on_Bug_KinematicBody2D_bug_is_dead")
    new_bug.connect("score_point_reached", self, "_on_Bug_KinematicBody2D_score_point_reached")
    current_bug = new_bug


func _on_PlayButton_pressed():
    set_game_state(GameState.PLAYING)


func _on_Bug_KinematicBody2D_bug_is_dead():
    set_game_state(GameState.GAMEOVER)

# GameOver --> Start
func _on_GameOverWaitTimer_timeout():
#    reset_score()
    respawn_bug_and_give_control()
    title_page.visible = true


func _on_Bug_KinematicBody2D_score_point_reached():
    score += 1
    var display_score = score/10.0
    in_game_gui.get_node("ScoreLabel").set_text(str(display_score)+"í µí½… PI")


# if bug leaves earth, it dies
func _on_Gravity_Area2D_body_exited(body):
    if body.has_method("set_state"):
        body.set_state(body.State.DEAD)


func _on_InstructionPage_hide_instruction():
    set_game_state(GameState.READY)
