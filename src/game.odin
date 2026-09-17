package game

import pd "../packages/playdate-api"

Screen_Width :: 400.0
Screen_Height :: 240.0
Screen_Center_X :: 200
Screen_Center_Y :: 120
Knob_Step_Degrees :: 9.0
Dial_Number_Count :: 40
Clear_Detents_Required :: 3 * Dial_Number_Count

Lock_Art :: struct {
	background: ^pd.Bitmap,
	face:       ^pd.Bitmap,
	knobs:      [3]^pd.Bitmap,
}

Lock_Sound :: struct {
	click:  ^pd.Audio_Sample,
	player: ^pd.Sample_Player,
}

Game_Scene :: enum {
	Dialogue,
	Lock,
	Unlock_Flash,
	Open_Result,
}

Dialogue_Sequence :: enum {
	Player_Briefing,
	Bully_Introduction,
}

Dialogue_State :: struct {
	sequence: Dialogue_Sequence,
	page:     int,
}

Scratchpad_Slot :: struct {
	value:       int,
	has_value:   bool,
	is_supplied: bool,
}

Scratchpad :: struct {
	slots:         [3]Scratchpad_Slot,
	selected_slot: int,
}

Game :: struct {
	lock:                   Lock_Art,
	dial_angle:             f32,
	knob_frame:             int,
	crank_remainder:        f32,
	sound:                  Lock_Sound,
	dial_number:            int,
	combination:            Combination_Progress,
	scene:                  Game_Scene,
	dialogue:               Dialogue_State,
	scratchpad:             Scratchpad,
	tutorial_visible:       bool,
	crank_moved_this_frame: bool,
	flash_frames:           int,
	b_used_for_tension:     bool,
}

update_game :: proc() {
	#partial switch game.scene {
	case .Dialogue:
		update_dialogue()
	case .Lock:
		if game.tutorial_visible {
			update_tutorial_overlay()
		} else {
			update_lock_input()
			update_lock_controls()
		}
	case .Unlock_Flash:
		update_unlock_flash()
	case .Open_Result:
		update_open_result()
	}
}

update_dialogue :: proc() {
	pushed: pd.Buttons
	pd_api.system.get_button_state(nil, &pushed, nil)

	if .A in pushed {
		advance_dialogue()
	}
}

advance_dialogue :: proc() {
	#partial switch game.dialogue.sequence {
	case .Player_Briefing:
		if game.dialogue.page == 0 {
			game.dialogue.page = 1
		} else {
			game.scene = .Lock
		}
	case .Bully_Introduction:

	}
}

update_lock_controls :: proc() {
	current, pushed, released: pd.Buttons
	pd_api.system.get_button_state(&current, &pushed, &released)

	if .B in pushed {
		game.b_used_for_tension = false
	}

	if .B in current && game.crank_moved_this_frame {
		game.b_used_for_tension = true
	}

	if .Left in pushed {
		move_scratchpad_selection(-1)
	}

	if .Right in pushed {
		move_scratchpad_selection(1)
	}

	if .A in pushed {
		selected := game.scratchpad.selected_slot

		if !game.scratchpad.slots[selected].is_supplied {
			game.scratchpad.slots[selected].value = game.dial_number
			game.scratchpad.slots[selected].has_value = true
		}
	}

	if .B in released && !game.b_used_for_tension {
		attempt_open_lock()
	}
}

move_scratchpad_selection :: proc(step: int) {
	index := game.scratchpad.selected_slot + step

	for index >= 0 && index < len(game.scratchpad.slots) {
		if !game.scratchpad.slots[index].is_supplied {
			game.scratchpad.selected_slot = index
			return
		}
		index += step
	}
}

update_tutorial_overlay :: proc() {
	pushed: pd.Buttons
	pd_api.system.get_button_state(nil, &pushed, nil)

	if .A in pushed {
		game.tutorial_visible = false
	}
}

attempt_open_lock :: proc() {
	if game.combination.phase == .Unlocked {
		game.flash_frames = 12
		game.scene = .Unlock_Flash
	} else {
		reset_combination()
	}
}

update_unlock_flash :: proc() {
	game.flash_frames -= 1

	if game.flash_frames <= 0 {
		game.scene = .Open_Result
	}
}

update_open_result :: proc() {
	pushed: pd.Buttons
	pd_api.system.get_button_state(nil, &pushed, nil)

	if .A in pushed {
		game.dialogue.sequence = .Bully_Introduction
		game.dialogue.page = 0
		game.scene = .Dialogue
	}
}
