package game

import pd "../packages/playdate-api"
import "base:runtime"
import "core:c"

pd_api: ^pd.Api
global_ctx: runtime.Context
game: Game

@(export)
eventHandler :: proc "c" (api: ^pd.Api, event: pd.System_Event, arg: u32) -> i32 {
	#partial switch event {
	case .Init:
		pd_api = api
		global_ctx = pd.playdate_context_create(api)
		context = global_ctx

		game_init()
		pd_api.system.set_update_callback(update_callback, api)
	}

	return 0
}

update_callback :: proc "c" (userdata: rawptr) -> pd.Update_Result {
	context = global_ctx
	update_game()
	draw_game()
	return .Update_Display
}

game_init :: proc() {
	pd_api.display.set_refresh_rate(30)
	pd_api.graphics.set_background_color(.White)

	init_lock()
	init_combination()
	init_tutorial_scratchpad()
	game.tutorial_visible = true
	game.scene = .Dialogue
	game.dialogue.sequence = .Player_Briefing
	game.dialogue.page = 0
}
