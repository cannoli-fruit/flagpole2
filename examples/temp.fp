$inc std.fp

proc main
    "Is your source temp F or C? " :puts
    :getline
    
    if dup "C\0a" :strcmp 0 == then
        drop
	"Temp: " :puts
        :getint 9 i* 5 i/ 32 i+
        "Final temp: %d F\0a" :printf
        return
    endif

    if dup "F\0a" :strcmp 0 == then
        drop
	"Temp: " :puts
        :getint 32 i- 5 i* 9 i/
        "Final temp: %d C\0a" :printf
        return
    endif

    0 "Try again\0a" :printf
endproc
