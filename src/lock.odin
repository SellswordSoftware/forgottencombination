package game

init_lock :: proc() {
	game.lock.background = pd_api.graphics.load_bitmap("assets/lockback", nil)
	game.lock.face = pd_api.graphics.load_bitmap("assets/lockface", nil)
	game.lock.knobs = {
		pd_api.graphics.load_bitmap("assets/lockknob1", nil),
		pd_api.graphics.load_bitmap("assets/lockknob2", nil),
		pd_api.graphics.load_bitmap("assets/lockknob3", nil),
	}

	game.sound.click = pd_api.sound.sample.load("assets/sound/clickextra")
	game.sound.player = pd_api.sound.sample_player.new_player()
	pd_api.sound.sample_player.set_sample(game.sound.player, game.sound.click)

	game.dial_angle = pd_api.system.get_crank_angle()
	game.dial_number = dial_number_from_angle(game.dial_angle)
}

advance_dial :: proc(direction: Turn_Direction) {
	#partial switch direction {
	case .Clockwise:
		game.dial_number = (game.dial_number + Dial_Number_Count - 1) % Dial_Number_Count
		game.knob_frame = (game.knob_frame + 1) % len(game.lock.knobs)

	case .Counterclockwise:
		game.dial_number = (game.dial_number + 1) % Dial_Number_Count
		game.knob_frame = (game.knob_frame + len(game.lock.knobs) - 1) % len(game.lock.knobs)
	}

	was_cleared := game.combination.is_cleared
	update_clear_progress(direction)
	if was_cleared {
		update_combination(direction)
	}
	play_detent_click()
}

update_lock_input :: proc() {
	game.dial_angle = pd_api.system.get_crank_angle()
	game.crank_remainder += pd_api.system.get_crank_change()

	for game.crank_remainder >= Knob_Step_Degrees {
		game.crank_remainder -= Knob_Step_Degrees
		advance_dial(.Clockwise)
	}

	for game.crank_remainder <= -Knob_Step_Degrees {
		game.crank_remainder += Knob_Step_Degrees
		advance_dial(.Counterclockwise)
	}
}

dial_number_from_angle :: proc(angle: f32) -> int {
	// Round to the nearest 9° detent, then map clockwise motion to
	// descending numbers: 0° is 0, 9° is 39, 18° is 38, and so on.
	detent := int((angle + Knob_Step_Degrees / 2) / Knob_Step_Degrees) % Dial_Number_Count
	return (Dial_Number_Count - detent) % Dial_Number_Count
}

play_detent_click :: proc() {
	pd_api.sound.sample_player.play(game.sound.player, 1, 1)
}
