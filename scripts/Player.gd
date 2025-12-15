#extends CharacterBody2D
#class_name Player
#
#@export var jump_force := -400
#@export var gravity := 1000
#@export var run_speed := 220
#@export var slam_force := 900
#@export var input_buffer_len := 0.18
#
#var buffered_jump_time := -1.0
#var buffered_attack_time := -1.0
#var buffered_parry_time := -1.0
#var buffered_dodge_time := -1.0
#
#var current_anim := ""
#var is_parrying := false
#var is_invulnerable := false
#var is_floating := false
#
#var resonance_system   # assigned in Game.gd but NOT used for scoring
#var last_song_time := 0.0
#
#
################################################################################
## READY
################################################################################
#
#func _ready():
	#play_anim("idle")
#
#
################################################################################
## INPUT BUFFERING
################################################################################
#
#func _input(event):
	#var t = AudioManager.get_current_song_time()
	#
#
	#if event.is_action_pressed("jump"):
		#buffered_jump_time = t
#
	#if event.is_action_pressed("attack"):
		#buffered_attack_time = t
#
	#if event.is_action_pressed("parry"):
		#buffered_parry_time = t
#
	#if event.is_action_pressed("dodge"):
		#buffered_dodge_time = t
#
#
#func _process(delta):
	#_clear_expired_buffers()
#
#
#func _clear_expired_buffers():
	#var now = AudioManager.get_current_song_time()
#
	#if buffered_jump_time >= 0 and now - buffered_jump_time > input_buffer_len:
		#buffered_jump_time = -1
#
	#if buffered_attack_time >= 0 and now - buffered_attack_time > input_buffer_len:
		#buffered_attack_time = -1
#
	#if buffered_parry_time >= 0 and now - buffered_parry_time > input_buffer_len:
		#buffered_parry_time = -1
#
	#if buffered_dodge_time >= 0 and now - buffered_dodge_time > input_buffer_len:
		#buffered_dodge_time = -1
#
#
################################################################################
## PHYSICS
################################################################################
#
#func _physics_process(delta):
	#velocity.x = run_speed   # constant movement
#
	## gravity unless floating
	#if not is_floating:
		#velocity.y += gravity * delta
#
	## animations
	#if not is_on_floor():
		#play_anim("fall")
	#else:
		#play_anim("run")
#
	#move_and_slide()
#
#
################################################################################
## ACTIONS TRIGGERED BY RHYTHM SYSTEM
################################################################################
#
## Tiles or Enemy projectiles call these when RhythmHitJudge says "perfect / ok"
#
#func do_jump():
	#velocity.y = jump_force
	#is_floating = false
	#play_anim("jump")
#
#func do_slam():
	#velocity.y = slam_force
	#is_floating = false
	#play_anim("slam")
#
#func do_float():
	#is_floating = true
	#play_anim("float")
#
#func do_attack():
	#play_anim("attack")
#
#func do_parry():
	#is_parrying = true
	#play_anim("parry")
#
#func end_parry():
	#is_parrying = false
#
#func do_dodge():
	#is_invulnerable = true
	#play_anim("dodge")
#
#
################################################################################
## BUFFER ACCESS FOR TILES
################################################################################
#
#func get_buffer_time(action: String) -> float:
	#match action:
		#"jump": return buffered_jump_time
		#"attack": return buffered_attack_time
		#"parry": return buffered_parry_time
		#"dodge": return buffered_dodge_time
	#return -1.0
#
#
################################################################################
## ANIMATION WRAPPER
################################################################################
#
#func play_anim(name: String):
	#if current_anim == name:
		#return
	#current_anim = name
	#$AnimatedSprite2D.play(name)
