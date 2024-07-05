extends GridContainer

@onready var Needle_1: Sprite2D = $"Axis 1/VBoxContainer/PanelContainer/Needle_1"
@onready var Needle_2: Sprite2D = $"Axis 2/VBoxContainer/PanelContainer/Needle_2"
@onready var Needle_3: Sprite2D = $"Axis 3/VBoxContainer/PanelContainer/Needle_3"

@onready var Bar1: Sprite2D = $"Axis 1/VBoxContainer/Bar/Bar1_slider"
@onready var Bar2: Sprite2D = $"Axis 2/VBoxContainer/Bar2/Bar2_slider"
@onready var Bar3: Sprite2D = $"Axis 3/VBoxContainer/Bar3/Bar3_slider"

@onready var barX: Sprite2D = $"Axis 1/VBoxContainer/Bar2/forceBar"  # New slider
@onready var barY: Sprite2D = $"Axis 2/VBoxContainer/Bar3/forceBar"
@onready var barZ: Sprite2D = $"Axis 3/VBoxContainer/Bar4/forceBar"

signal data 

func _ready():
	Needle_1.rotation = 0.0
	Needle_2.rotation = 0.0
	Needle_3.rotation = 0.0

	Bar1.position.x = 176
	Bar1.position.y = 16.5
	Bar2.position.x = 176
	Bar2.position.y = 16.5
	Bar3.position.x = 176
	Bar3.position.y = 16.5
	barX.position.x = 176  # Initial position for the new slider
	barX.position.y = 16.5
	
func _process(_delta):
	var n = 120
	
	# Set parameters for the clustermeters:
	var min_rotation_degrees = -90
	var max_rotation_degrees = 90
	
	var min_position_x = 0
	var max_position_x = 352
	
	# Parameter input based on Data Analysis:
	
	var min_torque_m_d = -1.2
	var max_torque_m_d = 1.2
	var min_torque_b_l = -3
	var max_torque_b_l = 3
	var min_torque_m_l = -1
	var max_torque_m_l = 1
	
	var min_force_b_l = -20
	var max_force_b_l = 20
	var min_force_m_d = -20
	var max_force_m_d = 20
	var min_force_e_i = -30
	var max_force_e_i = 30

	var min_force_x = -20  # Adjust these limits based on your data
	var max_force_x = 20
	
	var min_force_y = -20  # Adjust these limits based on your data
	var max_force_y = 20
	
	
	var min_force_z = -20  # Adjust these limits based on your data
	var max_force_z = 20

	if Global.selectedQuadrant != null and Global.selectedTooth != null:
		if Global.selectedQuadrant == 1 or Global.selectedQuadrant == 3:
	
			var torque_b_l =  Global.get_avg_torque(n).y 
			var weight_rot_b_l = (torque_b_l - min_torque_b_l) / (max_torque_b_l - min_torque_b_l)
			var D_rotation_b_l = lerp(min_rotation_degrees, max_rotation_degrees, weight_rot_b_l)
			Needle_1.rotation_degrees = clamp(D_rotation_b_l, min_rotation_degrees, max_rotation_degrees)

			var torque_m_d = - Global.get_avg_torque(n).x   
			var weight_rot_m_d = (torque_m_d - min_torque_m_d) / (max_torque_m_d - min_torque_m_d)
			var D_rotation_m_d = lerp(min_rotation_degrees, max_rotation_degrees, weight_rot_m_d)
			Needle_2.rotation_degrees = clamp(D_rotation_m_d, min_rotation_degrees, max_rotation_degrees)
			
			var torque_m_l = - Global.get_avg_torque(n).z  
			var weight_rot_m_l = (torque_m_l - min_torque_m_l) / (max_torque_m_l - min_torque_m_l)
			var D_rotation_m_l = lerp(min_rotation_degrees, max_rotation_degrees, weight_rot_m_l)
			Needle_3.rotation_degrees = clamp(D_rotation_m_l, min_rotation_degrees, max_rotation_degrees)	
			
			var force_x = Global.get_avg_force(n).x
			var weight_pos_x = (force_x - min_force_x) / (max_force_x - min_force_x)
			var D_position_x = lerp(min_position_x, max_position_x, weight_pos_x)
			barX.position.x = clamp(D_position_x, min_position_x, max_position_x)

			var force_y = - Global.get_avg_force(n).y
			var weight_pos_y = (force_y - min_force_y) / (max_force_y - min_force_y)
			var D_position_y = lerp(min_position_x, max_position_x, weight_pos_y)
			barY.position.x = clamp(D_position_y, min_position_x, max_position_x)
			
			# Update the new bar slider based on force in z direction
			var force_z = Global.get_avg_force(n).z
			var weight_pos_z = (force_z - min_force_z) / (max_force_z - min_force_z)
			var D_position_z = lerp(min_position_x, max_position_x, weight_pos_z)
			barZ.position.x = clamp(D_position_z, min_position_x, max_position_x)
		
	

		
		if Global.selectedQuadrant == 2 or Global.selectedQuadrant == 4:
	
			var torque_b_l =   Global.get_avg_torque(n).y  
			var weight_rot_b_l = (torque_b_l - min_torque_b_l) / (max_torque_b_l - min_torque_b_l)
			var D_rotation_b_l = lerp(min_rotation_degrees, max_rotation_degrees, weight_rot_b_l)
			Needle_1.rotation_degrees = clamp(D_rotation_b_l, min_rotation_degrees, max_rotation_degrees)

			var torque_m_d =  Global.get_avg_torque(n).x    
			var weight_rot_m_d = (torque_m_d - min_torque_m_d) / (max_torque_m_d - min_torque_m_d)
			var D_rotation_m_d = lerp(min_rotation_degrees, max_rotation_degrees, weight_rot_m_d)
			Needle_2.rotation_degrees = clamp(D_rotation_m_d, min_rotation_degrees, max_rotation_degrees)
			
			var torque_m_l = Global.get_avg_torque(n).z   
			var weight_rot_m_l = (torque_m_l - min_torque_m_l) / (max_torque_m_l - min_torque_m_l)
			var D_rotation_m_l = lerp(min_rotation_degrees, max_rotation_degrees, weight_rot_m_l)
			Needle_3.rotation_degrees = clamp(D_rotation_m_l, min_rotation_degrees, max_rotation_degrees)	
			
			var force_x = Global.get_avg_force(n).x
			var weight_pos_x = (force_x - min_force_x) / (max_force_x - min_force_x)
			var D_position_x = lerp(min_position_x, max_position_x, weight_pos_x)
			barX.position.x = clamp(D_position_x, min_position_x, max_position_x)

			var force_y =  Global.get_avg_force(n).y
			var weight_pos_y = (force_y - min_force_y) / (max_force_y - min_force_y)
			var D_position_y = lerp(min_position_x, max_position_x, weight_pos_y)
			barY.position.x = clamp(D_position_y, min_position_x, max_position_x)
			
			# Update the new bar slider based on force in z direction
			var force_z = Global.get_avg_force(n).z
			var weight_pos_z = (force_z - min_force_z) / (max_force_z - min_force_z)
			var D_position_z = lerp(min_position_x, max_position_x, weight_pos_z)
			barZ.position.x = clamp(D_position_z, min_position_x, max_position_x)
		
	
