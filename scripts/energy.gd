extends Node

var max_energy: int = 100
var current_energy: int = 100
var regen_amount: int = 1
var regen_seconds: int = 6
var last_update_time: float = 0

signal energy_changed(new_amount, max_amount)

func _ready() -> void:
	if DataStore.config.has("energy_max"):
		max_energy = DataStore.config.get("energy_max")
	if DataStore.config.has("energy_regen_amount"):
		regen_amount = DataStore.config.get("energy_regen_amount")
	if DataStore.config.has("energy_regen_seconds"):
		regen_seconds = DataStore.config.get("energy_regen_seconds")
		
	current_energy = max_energy
	last_update_time = Time.get_unix_time_from_system()

func _process(_delta: float) -> void:
	var current_time = Time.get_unix_time_from_system()
	var diff = current_time - last_update_time
	
	if diff >= regen_seconds:
		var ticks = floor(diff / regen_seconds)
		last_update_time += ticks * regen_seconds
		
		if current_energy < max_energy:
			current_energy = min(current_energy + (ticks * regen_amount), max_energy)
			energy_changed.emit(current_energy, max_energy)

func consume(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		energy_changed.emit(current_energy, max_energy)
		return true
	return false

func has_energy(amount: int) -> bool:
	return current_energy >= amount
