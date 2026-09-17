package game

Combination_Progress :: struct {
	code:                    [3]int,
	clear_detents:           int,
	revealed_count:          int,
	is_cleared:              bool,
	phase:                   Lock_Phase,
	has_passed_first_number: bool,
}

Turn_Direction :: enum {
	Clockwise,
	Counterclockwise,
}

Lock_Phase :: enum {
	Clearing,
	Awaiting_First_Reverse,
	Second_Number,
	Reverse_For_Third,
	Third_Number,
	Unlocked,
}

init_combination :: proc() {
	game.combination.code = {12, 27, 4}
	game.combination.phase = .Clearing
}

update_combination :: proc(direction: Turn_Direction, dial_number_before_turn: int) {
	#partial switch game.combination.phase {
	case .Awaiting_First_Reverse:
		// Clockwise turns continue clearing. Reversing counterclockwise
		// latches the number that was under the dial before this detent.
		if direction == .Counterclockwise {
			if dial_number_before_turn == game.combination.code[0] {
				game.combination.revealed_count = 1
				game.combination.phase = .Second_Number
			} else {
				reset_combination()
			}
		}

	case .Second_Number:
		if direction != .Counterclockwise {
			reset_combination()
		} else if !game.combination.has_passed_first_number {
			if game.dial_number == game.combination.code[0] {
				game.combination.has_passed_first_number = true
			}
		} else if game.dial_number == game.combination.code[1] {
			game.combination.revealed_count = 2
			game.combination.phase = .Reverse_For_Third
		}

	case .Reverse_For_Third:
		if direction == .Counterclockwise {
			reset_combination()
		} else if game.dial_number == game.combination.code[2] {
			game.combination.revealed_count = 3
			game.combination.phase = .Unlocked
		} else {
			game.combination.phase = .Third_Number
		}

	case .Third_Number:
		if direction != .Clockwise {
			reset_combination()
		} else if game.dial_number == game.combination.code[2] {
			game.combination.revealed_count = 3
			game.combination.phase = .Unlocked
		}

	case .Clearing, .Unlocked:
	}
}

update_clear_progress :: proc(direction: Turn_Direction) {
	if game.combination.is_cleared {
		return
	}

	if direction == .Counterclockwise {
		// Clearing requires three continuous clockwise revolutions
		game.combination.clear_detents = 0
		return
	}

	game.combination.clear_detents += 1

	if game.combination.clear_detents >= Clear_Detents_Required {
		game.combination.clear_detents = Clear_Detents_Required
		game.combination.is_cleared = true
		game.combination.phase = .Awaiting_First_Reverse
	}
}

reset_combination :: proc() {
	game.combination.clear_detents = 0
	game.combination.revealed_count = 0
	game.combination.is_cleared = false
	game.combination.phase = .Clearing
	game.combination.has_passed_first_number = false
}

init_tutorial_scratchpad :: proc() {
	game.scratchpad.slots[0].value = 12
	game.scratchpad.slots[0].has_value = true
	game.scratchpad.slots[0].is_supplied = true

	game.scratchpad.slots[1].value = 27
	game.scratchpad.slots[1].has_value = true
	game.scratchpad.slots[1].is_supplied = true

	game.scratchpad.selected_slot = 2
}
