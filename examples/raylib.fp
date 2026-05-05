$inc std.fp

$extern InitWindow i i i
$extern WindowShouldClose
$extern BeginDrawing
$extern EndDrawing
$extern ClearBackground i
$extern CloseWindow
$extern SetTargetFPS i
$extern DrawText i i i i i


proc rgba
    16777216 i* swap
    65536 i* i+ swap
    255 i* i+ swap
    i+
endproc

proc main
    "Flagpole Raylib!" 450 800 :InitWindow drop
    60 :SetTargetFPS drop
    25 25 25 255 :rgba @col_gray
    25 255 25 255 :rgba @col_green
    while :WindowShouldClose not do
    	:BeginDrawing drop

	&col_gray :ClearBackground drop
	&col_green 20 200 190
	"This was written in flagpole with raylib!"
	:DrawText drop

	&col_green 20 230 190
	"I'm sorry for raylib's default font though"
	:DrawText drop
	:EndDrawing drop
    endwhile
    :CloseWindow
endproc
