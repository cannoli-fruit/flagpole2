$inc std.fp

$extern InitWindow i i i
$extern WindowShouldClose
$extern BeginDrawing
$extern EndDrawing
$extern ClearBackground i
$extern CloseWindow
$extern SetTargetFPS i
$extern DrawText i i i i i

# 42069

proc main
	"Flagpole Raylib!" 450 800 :InitWindow drop
	60 :SetTargetFPS drop
	while :WindowShouldClose not do
		:BeginDrawing drop

		4279769112 :ClearBackground drop
		4278255360 20 200 190
		"This was written in raylib"
		:DrawText drop

		4278255360 20 230 190
		"I'm sorry for raylib's default font though"
		:DrawText drop

	:EndDrawing drop
	endwhile
	:CloseWindow
endproc
