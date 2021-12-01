extends Control

signal hide_instruction

var count_down = 2

func _ready():
    pass

func _gui_input(event):
    if event is InputEventMouseButton:
        if event.pressed:
            if event.get_button_index() == BUTTON_LEFT:
                count_down -= 1
            if event.get_button_index() == BUTTON_RIGHT:
                count_down -= 1
        
        if not count_down:
            set_visible(false)
            emit_signal("hide_instruction")
