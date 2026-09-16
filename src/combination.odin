package game

Combination_Progress :: struct {
	code:           [3]int,
	clear_detents:  int,
	revealed_count: int,
	is_cleared:     bool,
	phase:          Lock_Phase,
}

Turn_Direction :: enum {
	Clockwise,
	Counterclockwise,
}

Lock_Phase :: enum {
	Clearing,
	First_Number,
	Reverse_For_Second,
	Second_Number,
	Reverse_For_Third,
	Third_Number,
	Unlocked,
}

init_combination :: proc() {
	game.combination.code = {12, 27, 4}
	game.combination.phase = .Clearing
}

update_combination :: proc(direction: Turn_Direction) {
	#partial switch game.combination.phase {
	case .First_Number:
		if direction != .Clockwise {
			reset_combination()
		} else if game.dial_number == game.combination.code[0] {
			game.combination.revealed_count = 1
			game.combination.phase = .Reverse_For_Second
		}

	case .Reverse_For_Second:
		if direction == .Clockwise {
			reset_combination()
		} else {
			game.combination.phase = .Second_Number
		}

	case .Second_Number:
		if direction != .Counterclockwise {
			reset_combination()
		} else if game.dial_number == game.combination.code[1] {
			game.combination.revealed_count = 2
			game.combination.phase = .Reverse_For_Third
		}

	case .Reverse_For_Third:
		if direction == .Counterclockwise {
			reset_combination()
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
		game.combination.phase = .First_Number
	}
}

reset_combination :: proc() {
	game.combination.clear_detents = 0
	game.combination.revealed_count = 0
	game.combination.is_cleared = false
	game.combination.phase = .Clearing
}
