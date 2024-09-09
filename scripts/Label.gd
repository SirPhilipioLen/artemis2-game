extends Label

var saved_text: String = ""
var typing_in_progress: bool = false
var visible_chars: int = 0
@export var typing_speed: float = 30.0  # Characters per second
var time_accumulator: float = 0.0
@onready var typewriter_sound: AudioStreamPlayer = $"../../../../AudioStreamPlayer"

func _ready():
	saved_text = text  # Save the full text
	text = ""  # Start with an empty text
	# Ensure the sound player is paused initially
	typewriter_sound.stop()

func _process(delta):
	# Start typing if the label is visible and typing hasn't started yet
	if visible and not typing_in_progress and text == "":
		start_typing()

	# Continue typing if it's in progress
	if typing_in_progress:
		time_accumulator += delta
		var chars_to_show = int(time_accumulator * typing_speed)
		
		if chars_to_show > visible_chars:
			visible_chars = chars_to_show
			text = saved_text.substr(0, visible_chars)
			
			# Stop typing when the full text is displayed
			if visible_chars >= saved_text.length():
				typing_in_progress = false
				typewriter_sound.stop()  # Stop the typing sound
				

func start_typing():
	# Initialize typing state
	typing_in_progress = true
	visible_chars = 0
	time_accumulator = 0.0
	text = ""  # Reset the text to start typing from scratch
	
	# Play the typing sound
	if not typewriter_sound.playing:
		typewriter_sound.play()

func _input(event):
	if event.is_action_pressed("skip"):
		typing_speed = 500
