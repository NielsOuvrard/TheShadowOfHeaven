## Script of animations
##
## Author: Sol Rojo[br]Date: 16-10-2024
##

extends Node

@export var animated_sprite: AnimatedSprite2D

var animations_queue = {
	Data.Animations.IDLE: 0
}

var current_animation := Data.Animations.IDLE

## Add animation to the queue
## used by child nodes, like player or enemy
## @param anim: Data.Animations
func add_animation(anim: Data.Animations):
	var current_time = Time.get_ticks_msec()
	if not animations_queue.has(anim):
		animations_queue[anim] = current_time + Data.animations_data[anim].seconds_active * 1000

func actualize_animation():
	var all_animations = Data.animations_data.keys()
	all_animations.reverse()

	# * if exist animation that can override the current one, play it
	for anim in all_animations:
		if animations_queue.has(anim) and current_animation < anim:
			# print("override by animation: " + str(Data.animations_data[anim].name))
			current_animation = anim
			animated_sprite.play(Data.animations_data[current_animation].name)
			break

	# * if no animation is playing, play the first one that is active
	if not animated_sprite.is_playing() or Data.animations_data[current_animation].can_be_override:
		for anim in all_animations:
			if animations_queue.has(anim):
				if current_animation != anim:
					current_animation = anim
					# print("time out by animation: " + str(Data.animations_data[current_animation].name))
					animated_sprite.play(Data.animations_data[current_animation].name)
				break

	# * remove animations_queue that are done
	var current_time = Time.get_ticks_msec()
	for anim in animations_queue.keys():
		if animations_queue[anim] < current_time and anim != Data.Animations.IDLE:
			animations_queue.erase(anim)
			# print("remove animation: " + str(Data.animations_data[anim].name))
