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

Game :: struct {
	lock:            Lock_Art,
	dial_angle:      f32,
	knob_frame:      int,
	crank_remainder: f32,
	sound:           Lock_Sound,
	dial_number:     int,
	combination:     Combination_Progress,
}
