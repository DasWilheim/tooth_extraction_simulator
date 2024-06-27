extends Node

# This signal should be emitted by _handle_client_data function
signal new_data(force: Vector3, torque: Vector3)

var force_values: Array = []
var torque_values: Array = []
const NUM_STANDARD_VALUES: int = 100

var itterations: int = 0

var standard_avg_force: Vector3 = Vector3()
var standard_avg_torque: Vector3 = Vector3()
var standard_set: bool = false
var checking: bool = true
var start: bool = true


# Reference to the AudioStreamPlayer node
@onready var error_player: AudioStreamPlayer = $AudioStreamPlayer

# Reference to the AudioStreamPlayer node
@onready var start_player: AudioStreamPlayer = $AudioStreamPlayer2

func _ready():
	print("Listen Node ready")
	# Connect the new_data signal to the _on_new_data_received function
	var parent = get_parent()
	if parent:
		parent.connect("new_data", Callable(self, "_on_new_data_received"))

func _on_new_data_received(force: Vector3, torque: Vector3) -> void:
	if start:
		start_player.play()
		start = false
	# Collect the first 10 values to set the standard
	if not standard_set:
		force_values.append(force)
		torque_values.append(torque)
		
		if force_values.size() >= NUM_STANDARD_VALUES:
			standard_avg_force = compute_average(force_values)
			standard_avg_torque = compute_average(torque_values)
			standard_set = true
			print("Standard values set: avg_force =", standard_avg_force, " avg_torque =", standard_avg_torque)
	else:
		# Check if the new values exceed the standard values
		if (exceeds_threshold(force, standard_avg_force, Vector3(2, 2, 3)) or exceeds_threshold(torque, standard_avg_torque, Vector3(1, 1, 2))) and checking and itterations < 1300:
			print("exceed")
			start_player.stop()
			error_player.play() 
			checking = false
			
	itterations += 1

func compute_average(values: Array) -> Vector3:
	var sum: Vector3 = Vector3()
	for value in values:
		sum += value
	return sum / values.size()

func exceeds_threshold(current: Vector3, standard: Vector3, thresholds: Vector3) -> bool:
	return abs(current.x - standard.x) > thresholds.x or abs(current.y - standard.y) > thresholds.y or abs(current.z - standard.z) > thresholds.z
