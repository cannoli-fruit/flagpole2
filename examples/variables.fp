$inc std.fp

proc main
		"Hello " @txt1
		"!\0a" @txt2
		"World" @txt3
		&txt1 :puts
		&txt3 :puts
		&txt2 :puts
endproc
