extends Node3D

#const HOST: String = "127.0.0.1"
const HOST: String = "192.168.1.100"
const PORT: int = 2001
const RECONNECT_TIMEOUT: float = 3.0

const Client = preload("res://scripts/Extraction/Sensor/client.gd")
var _client: Client = Client.new()

signal connected
signal disconnected
signal data
signal directions
signal new_data

@export var molar_3d : MeshInstance3D
@export var incisor_3d : MeshInstance3D
@export var canine_3d : MeshInstance3D
@export var premolar_3d : MeshInstance3D

# this function is called when scene tree is entered
func _ready() -> void:
	_client.connect("connected",Callable(self,"_handle_client_connected"))
	_client.connect("disconnected",Callable(self,"_handle_client_disconnected"))
	_client.connect("error",Callable(self,"_handle_client_error"))
	_client.connect("data",Callable(self,"_handle_client_data"))
	add_child(_client)
	_client.connect_to_host(HOST, PORT)
	Global.startTimestamp = Time.get_unix_time_from_system()

	var t = Global.selectedTooth
	molar_3d.visible = false
	incisor_3d.visible = false
	if t == 1 or t == 2:
		incisor_3d.visible = true
	elif t == 3:
		incisor_3d.visible = true # Canine model is doing weird
	elif t == 4 or t == 5:
		molar_3d.visible = true # premolar model is doing weird
	elif t > 5:
		molar_3d.visible = true
		
		

func _connect_after_timeout(timeout: float) -> void:
	await get_tree().create_timer(timeout).timeout # Delay for timeout
	_client.connect_to_host(HOST, PORT)

func _handle_client_connected() -> void:
	emit_signal("connected")
	print("Client connected to server.")
	


# Rotation matrices for rotations around z, x, and y axes
func rotation_matrix_z(angle):
	var c = cos(angle)
	var s = sin(angle)
	return Basis(Vector3(c, -s, 0), Vector3(s, c, 0), Vector3(0, 0, 1))

func rotation_matrix_x(angle):
	var c = cos(angle)
	var s = sin(angle)
	return Basis(Vector3(1, 0, 0), Vector3(0, c, -s), Vector3(0, s, c))

# Rotation form base frame to frame 2 (frame for quadrant 1 and 2)
func rotation_1_to_2():
	return Basis(Vector3(0, 0, 1), Vector3(0, -1, 0), Vector3(1, 0, 0))
	
# Example usage of the rotation matrix functions
func calculate_rotation_matrix(selectedQuadrant, selectedTooth):
	var rad = deg_to_rad(angles[selectedQuadrant - 1][selectedTooth - 1])
	var rotation_matrix = Basis()
	
	if selectedQuadrant in [1, 2]:
		rotation_matrix = rotation_1_to_2() * rotation_matrix_x(rad)
	else:
		rotation_matrix = rotation_matrix_z(rad)
	
	return rotation_matrix

# this function returns the torque at the tooth location, by taking the cross product
func convert_torque(torque, force, location):
	var result = torque - location.cross(force)
	return result
	
# this function returns a location vector for a given kwadrant and element number. The array tandvectors has 5 list entries, the first is a list of two vectors containinng a base vector
# for both the upper and lower jaw. The other four lists contain locations for each tooth in each kwadfrant to be added to the base vector. Change these vectors based on the measured tooth locations.
# a small correction vector is added as well
# format for tandvectors = [[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8]]
func tand_locatie(kwadrant, tand):
	var tandvectors = [
		[Vector3(0.06311, -0.00415, 0.23629), Vector3(0.06311, -0.01142, 0.2349), Vector3(0.06311, -0.01734, 0.23075), Vector3(0.06311, -0.02029, 0.22367), Vector3(0.06311, -0.0229, 0.21683), Vector3(0.06311, -0.02448, 0.2079), Vector3(0.06311, -0.02575, 0.19759), Vector3(0.06311, -0.02553, 0.18799)],
		[Vector3(0.06311, 0.00483, 0.23623), Vector3(0.06311, 0.01231, 0.23484), Vector3(0.06311, 0.01753, 0.23132), Vector3(0.06311, 0.01997, 0.22477), Vector3(0.06311, 0.02315, 0.21791), Vector3(0.06311, 0.02462, 0.20863), Vector3(0.06311, 0.02653, 0.19819), Vector3(0.06311, 0.02632, 0.18836)],
		[Vector3(0.20887, 0.00299, 0.08229), Vector3(0.20785, 0.00868, 0.08229), Vector3(0.20505, 0.01414, 0.08229), Vector3(0.19977, 0.01773, 0.08229), Vector3(0.19292, 0.02031, 0.08229), Vector3(0.18383, 0.02286, 0.08229), Vector3(0.17332, 0.02488, 0.08379), Vector3(0.16328, 0.02458, 0.08449)],
		[Vector3(0.20886, -0.00246, 0.08229), Vector3(0.20785, -0.00788, 0.08229), Vector3(0.20555, -0.01341, 0.08229), Vector3(0.20023, -0.01769, 0.08229), Vector3(0.19307, -0.02056, 0.08229), Vector3(0.18412, -0.02329, 0.08229), Vector3(0.17332, -0.02471, 0.08379), Vector3(0.16318, -0.02434, 0.08449)]
	]
	return tandvectors[kwadrant - 1][tand - 1]

# this array contains 4 lists of angles. Each angle gives the relative rotation for the particular tooth-frame to the initial reference Frame as used by Godot. to be used in vector_tand_frame()
var angles = [
	[-3.89, -21.56, -50.7, -66.14, -73.35, -79.61, -90, -96.38],
	[3.64, 21.33, 47.38, 68.18, 73, 79.32, 86.18, 94.57],
	[3.72, -14.56, -41.67, -68.11, -72.38, -81.05, -87.66, -91.3],
	[2.22, 7.11, 33.61, 62.67, 69.07, 77.39, 81.31, 92.55]
]


# Transform a vector using a Basis matrix manually
# Transform a vector using a Basis matrix manually
func transform_vector(matrix: Basis, vector: Vector3) -> Vector3:
	return Vector3(
		matrix.x.dot(vector),
		matrix.y.dot(vector),
		matrix.z.dot(vector)
	)


# This function returns a given vector expressed in the tooth frame for a given kwadrand and tooth number.
func vector_tand_frame(kwadrant, tand, vector):
	var angle = deg_to_rad(angles[kwadrant - 1][tand - 1])
	if kwadrant == 1 or kwadrant == 2:
		vector = Vector3(vector.x, cos(angle)*vector.y - sin(angle)*vector.z, sin(angle)*vector.y + cos(angle)*vector.z)
	if kwadrant == 3 or kwadrant == 4:
		vector = Vector3(cos(angle)*vector.x + sin(angle)*vector.z,vector.y, -sin(angle)*vector.x + cos(angle)*vector.z)
	return vector

# this function is the opposite to the previous function. it returns a vector expressed in the initial frame of refence. Translating it back from the tooth frame for a given tooth and kwadrant.
func vector_godot_frame(kwadrant, tand, vector):
	var angle = deg_to_rad(-1*angles[kwadrant - 1][tand - 1])
	if kwadrant == 1 or kwadrant == 2:
		vector = Vector3(vector.x, cos(angle)*vector.y - sin(angle)*vector.z, sin(angle)*vector.y + cos(angle)*vector.z)
	if kwadrant == 3 or kwadrant == 4:
		vector = Vector3(cos(angle)*vector.x + sin(angle)*vector.z,vector.y, -sin(angle)*vector.x + cos(angle)*vector.z)
	return vector
	
# This function orders force and torque vectors by the directions as found in dentistry. 
# The first named directions is defined to be a positve value and the second negative, so for a buccal/lingual force a positive value lies in the buccal direction
func type_force_torque(kwadrant, _tand, force, torque):
	var result = [{'buccal/lingual': 0, 'mesial/distal': 0, 'extrusion/intrusion': 0},\
	{'mesial/distal angulation': 0, 'bucco/linguoversion': 0, 'mesiobuccal/lingual': 0}] # directions = [{forces}, {torques}]
	if kwadrant == 1 or kwadrant == 2:
		result[0]['buccal/lingual'] = force.y
		result[0]['extrusion/intrusion'] = force.x
		result[1]['bucco/linguoversion'] = torque.z
		if kwadrant == 1:
			result[0]['mesial/distal'] = -force.z
			result[1]['mesial/distal angulation'] = torque.y
			result[1]['mesiobuccal/lingual'] = torque.x
		if kwadrant == 2:
			result[0]['mesial/distal'] = force.z
			result[1]['mesial/distal angulation'] = -torque.y
			result[1]['mesiobuccal/lingual'] = -torque.x
	if kwadrant == 3 or kwadrant == 4:
		result[0]['buccal/lingual'] = force.x
		result[0]['extrusion/intrusion'] = force.y
		result[1]['bucco/linguoversion'] = -torque.z
		if kwadrant == 3:
			result[0]['mesial/distal'] = force.z
			result[1]['mesial/distal angulation'] = torque.x
			result[1]['mesiobuccal/lingual'] = torque.y
		if kwadrant == 4:
			result[0]['mesial/distal'] = -force.z
			result[1]['mesial/distal angulation'] = -torque.x
			result[1]['mesiobuccal/lingual'] = -torque.y
	return result

# this function combines all the previous functions to process the raw sensor data into usable data
func _handle_client_data(force, torque):
	# Compute the location of the tooth
	Global.raw_forces.append(force)
	Global.raw_torques.append(torque)
	
	# Emit signal to process new data
	emit_signal("new_data", force, torque)
	
	
	var locatie = tand_locatie(Global.selectedQuadrant, Global.selectedTooth)
	
	# Calculate the rotation matrix
	var rotation_matrix = calculate_rotation_matrix(Global.selectedQuadrant, Global.selectedTooth)
	
	# Rotate force and torque vectors manually
	torque = convert_torque(torque, force, locatie)
	torque = transform_vector(rotation_matrix, torque)
	

	force = transform_vector(rotation_matrix, force)
	
	# Store the corrected forces and torques
	Global.corrected_forces.append(force)
	Global.corrected_torques.append(torque)
	
	# Emits signal to debuginfo, this can be displayed during extractions
	emit_signal("data", force, torque)


	# Order forces and torques in various directions
	var dir = type_force_torque(Global.selectedQuadrant, Global.selectedTooth, force, torque)
	
	# store clinically orderd forces and torques in Global
	for key in dir[0].keys():
		Global.clinical_directions[0][key].append(dir[0][key])
	
	for key in dir[1].keys():
		Global.clinical_directions[1][key].append(dir[1][key])
		
	# Remove noise by using average
	var n = 100
	var avg_force = Global.get_avg_force(n)
	var avg_torque = Global.get_avg_torque(n)
	
	# Convert to numbers around 1
	avg_force = avg_force / 100
	avg_torque = avg_torque / 3
	
	# the following if statements relate to the translation of the forces and torques into movement of the 3d tooth model.
	if Global.selectedQuadrant == 1 or Global.selectedQuadrant == 2:
		transform.origin.x = avg_force.x * 2
		transform.origin.y = avg_force.z * 2
		transform.origin.z = - avg_force.y * 2

		var rot: Transform3D = Transform3D.IDENTITY
		rot = rot.rotated(Vector3( 1, 0, 0 ), avg_torque.x * 3)
		rot = rot.rotated(Vector3( 0, 1, 0 ), avg_torque.z * 3)
		rot = rot.rotated(Vector3( 0, 0, 1 ), - avg_torque.y * 3) 
		transform.basis = rot.basis
	
	if Global.selectedQuadrant == 3 or Global.selectedQuadrant == 4:
		transform.origin.x = avg_force.x   * 2 # these translations are done purely because of the axis of the 3D file. 
		transform.origin.y = avg_force.z   * 2
		transform.origin.z = - avg_force.y   * 2

		var rot: Transform3D = Transform3D.IDENTITY
		rot = rot.rotated(Vector3( 1, 0, 0 ), avg_torque.x * 3) 
		rot = rot.rotated(Vector3( 0, 1, 0 ), avg_torque.z * 3) 
		rot = rot.rotated(Vector3( 0, 0, 1 ), - avg_torque.y * 3) 
		transform.basis = rot.basis

func _handle_client_disconnected() -> void:
	emit_signal("disconnected")
	print("Client disconnected from server.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	print("Client error.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds
