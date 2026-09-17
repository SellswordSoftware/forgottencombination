package game

import pd "../packages/playdate-api"
import "base:runtime"
import "core:c"

Digit_Text: [10]cstring = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}

draw_game :: proc() {
	pd_api.graphics.clear(pd.color_solid(.White))

	#partial switch game.scene {
	case .Dialogue:
		draw_dialogue_scene()
	case .Lock:
		draw_lock_scene()
	case .Unlock_Flash:
		draw_unlock_flash()
	case .Open_Result:
		draw_open_result_scene()
	}
}

draw_dialogue_scene :: proc() {
	pd_api.graphics.draw_rect(12, 12, 244, 216, pd.color_solid(.Black))
	pd_api.graphics.draw_rect(272, 12, 116, 216, pd.color_solid(.Black))


	#partial switch game.dialogue.sequence {
	case .Player_Briefing:
		pd_api.graphics.draw_text("PLAYER", 6, .ASCII, 296, 28)
		pd_api.graphics.draw_text("[ portrait ]", 11, .ASCII, 286, 112)
		if game.dialogue.page == 0 {
			pd_api.graphics.draw_text("My locker is stuck.", 19, .ASCII, 24, 32)
			pd_api.graphics.draw_text("I remember most of", 20, .ASCII, 24, 56)
			pd_api.graphics.draw_text("the combination...", 18, .ASCII, 24, 80)
		} else {
			pd_api.graphics.draw_text("It starts with 12,", 18, .ASCII, 24, 32)
			pd_api.graphics.draw_text("then 27. I lost", 16, .ASCII, 24, 56)
			pd_api.graphics.draw_text("the last number.", 16, .ASCII, 24, 80)
		}
	case .Bully_Introduction:
		pd_api.graphics.draw_text("BULLY", 5, .ASCII, 296, 28)
		pd_api.graphics.draw_text("[ portrait ]", 11, .ASCII, 286, 112)
		pd_api.graphics.draw_text("Hey, nerd. Open", 15, .ASCII, 24, 32)
		pd_api.graphics.draw_text("my lock next.", 13, .ASCII, 24, 56)
		pd_api.graphics.draw_text("End of tutorial slice.", 22, .ASCII, 24, 104)
	}

	pd_api.graphics.draw_text("A: continue", 11, .ASCII, 24, 204)
}

draw_lock_scene :: proc() {
	pd_api.graphics.clear(pd.color_solid(.White))

	pd_api.graphics.draw_bitmap(game.lock.background, 0, 0, .Unflipped)

	// The black disk hides the background inside the lock's circular body.
	pd_api.graphics.fill_ellipse(
		Screen_Center_X - 107,
		Screen_Center_Y - 107,
		214,
		214,
		0,
		0,
		pd.color_solid(.Black),
	)
	pd_api.graphics.fill_triangle(210, 0, 190, 0, 200, 10, pd.color_solid(.White))

	pd_api.graphics.draw_rotated_bitmap(
		game.lock.face,
		Screen_Center_X,
		Screen_Center_Y,
		game.dial_angle,
		0.5,
		0.5,
		1,
		1,
	)
	pd_api.graphics.draw_bitmap(
		game.lock.knobs[game.knob_frame],
		Screen_Center_X - 50,
		Screen_Center_Y - 47,
		.Unflipped,
	)

	draw_dial_number()
	draw_scratchpad()
	draw_clear_progress()
	if game.tutorial_visible {
		draw_tutorial_overlay()
	}
}

draw_tutorial_overlay :: proc() {
	pd_api.graphics.fill_rect(12, 126, 376, 102, pd.color_solid(.White))
	pd_api.graphics.draw_rect(12, 126, 376, 102, pd.color_solid(.Black))

	pd_api.graphics.draw_text("Aw man, I lost the last digit to my", 35, .ASCII, 20, 136)
	pd_api.graphics.draw_text("locker combination. I've gotta figure", 37, .ASCII, 20, 148)
	pd_api.graphics.draw_text("this out. Maybe if I look closely with", 39, .ASCII, 20, 160)
	pd_api.graphics.draw_text("Up and listen closely with Down, I'll", 37, .ASCII, 20, 172)
	pd_api.graphics.draw_text("be able to figure out what the last", 36, .ASCII, 20, 184)
	pd_api.graphics.draw_text("number is. When I think I have it,", 35, .ASCII, 20, 196)
	pd_api.graphics.draw_text("I'll open the locker with B.", 29, .ASCII, 20, 208)

	pd_api.graphics.draw_text("A: start", 8, .ASCII, 320, 214)
}

draw_number :: proc(number: int, x, y: i32) {
	draw_x := x
	tens := number / 10
	ones := number % 10

	if number >= 10 {
		pd_api.graphics.draw_text(Digit_Text[tens], 1, .ASCII, draw_x, y)
		draw_x += 14
	}

	pd_api.graphics.draw_text(Digit_Text[ones], 1, .ASCII, draw_x, y)
}

draw_dial_number :: proc() {
	draw_number(game.dial_number, 16, 16)
}

draw_clear_progress :: proc() {
	Bar_Width :: 92

	filled_width := i32(Bar_Width * game.combination.clear_detents / Clear_Detents_Required)

	pd_api.graphics.draw_rect(16, 40, Bar_Width + 4, 8, pd.color_solid(.Black))
	pd_api.graphics.fill_rect(18, 42, filled_width, 4, pd.color_solid(.Black))
}

draw_scratchpad :: proc() {
	Slot_Width :: 26
	Slot_Spacing :: 30
	First_Slot_X :: 290
	Slot_Y :: 14

	pd_api.graphics.draw_text("NOTES", 5, .ASCII, 290, 2)

	for index in 0 ..< len(game.scratchpad.slots) {
		x := i32(First_Slot_X + index * Slot_Spacing)
		slot := game.scratchpad.slots[index]

		pd_api.graphics.draw_rect(x, Slot_Y, Slot_Width, 20, pd.color_solid(.Black))

		if slot.is_supplied {
			pd_api.graphics.fill_rect(
				x + 1,
				Slot_Y + 1,
				Slot_Width - 2,
				18,
				pd.color_solid(.White),
			)
		}

		if index == game.scratchpad.selected_slot && !slot.is_supplied {
			pd_api.graphics.draw_rect(
				x - 2,
				Slot_Y - 2,
				Slot_Width + 4,
				24,
				pd.color_solid(.Black),
			)
		}

		if slot.has_value {
			draw_number(slot.value, x + 4, Slot_Y + 2)
		} else {
			pd_api.graphics.draw_text("--", 2, .ASCII, x + 5, Slot_Y + 2)
		}
	}

	if game.combination.phase == .Unlocked {
		pd_api.graphics.draw_text("OPEN", 4, .ASCII, 320, 40)
	}
}

draw_unlock_flash :: proc() {
	// intentionally empty
}

draw_open_result_scene :: proc() {
	pd_api.graphics.draw_rect(60, 24, 280, 164, pd.color_solid(.Black))
	pd_api.graphics.draw_text("LOCKER OPEN", 11, .ASCII, 144, 52)
	pd_api.graphics.draw_text("[ open locker ]", 15, .ASCII, 130, 96)
	pd_api.graphics.draw_text("Your books are safe.", 20, .ASCII, 124, 140)
	pd_api.graphics.draw_text("A: continue", 11, .ASCII, 144, 210)
}
