package game

import pd "../packages/playdate-api"
import "base:runtime"
import "core:c"

Digit_Text: [10]cstring = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}

draw_game :: proc() {
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
	draw_combination_status()
	draw_clear_progress()
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

draw_combination_status :: proc() {
	Slot_Width :: 26
	Slot_Spacing :: 30
	First_Slot_X :: 290
	Slot_Y :: 14

	for index in 0 ..< len(game.combination.code) {
		x := i32(First_Slot_X + index * Slot_Spacing)

		pd_api.graphics.draw_rect(x, Slot_Y, Slot_Width, 20, pd.color_solid(.Black))

		if index < game.combination.revealed_count {
			draw_number(game.combination.code[index], x + 4, Slot_Y + 2)
		}
	}

	if game.combination.phase == .Unlocked {
		pd_api.graphics.draw_text("OPEN", 4, .ASCII, 170, 16)
	}
}
