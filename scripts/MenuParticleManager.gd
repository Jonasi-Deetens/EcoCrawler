extends Node2D

# Menu Particle Manager - Handles all particle effects for the menu
# Single responsibility: Particle system management and effects

@onready var floating_particles: GPUParticles2D = $FloatingParticles
@onready var ambient_particles: GPUParticles2D = $AmbientParticles

func _ready():
	# Start all particle systems
	start_particle_systems()

func start_particle_systems():
	"""Start all particle systems"""
	print("MenuParticleManager: Starting particle systems...")
	print("Floating particles: ", floating_particles)
	print("Ambient particles: ", ambient_particles)
	floating_particles.emitting = true
	ambient_particles.emitting = true
	print("Particle systems started!")

func stop_particle_systems():
	"""Stop all particle systems"""
	floating_particles.emitting = false
	ambient_particles.emitting = false

func create_particle_burst(burst_position: Vector2):
	"""Create a particle burst at the specified position"""
	floating_particles.global_position = burst_position
	# Temporarily reduce amount for burst effect
	var original_amount = floating_particles.amount
	floating_particles.amount = 10
	floating_particles.restart()
	# Restore original amount after a short delay
	await get_tree().create_timer(0.5).timeout
	floating_particles.amount = original_amount

func set_particle_intensity(intensity: float):
	"""Adjust particle intensity (0.0 to 1.0)"""
	var amount = int(50 * intensity)
	floating_particles.amount = amount
	ambient_particles.amount = int(20 * intensity) 
