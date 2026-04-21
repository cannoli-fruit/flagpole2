$extern scanf i i
$extern printf i i
$extern malloc i
$extern strcmp i i
$extern fputs i i
$extern fgets i i i
$extern fdopen i i
$extern fflush i

proc getint
    8 :malloc dup
    "%lld" :scanf drop
    ld64
endproc

proc putint
		"%lld" :printf drop
endproc

proc getline
		"r" 0 :fdopen 
		4096 
		4096 :malloc 
		:fgets
endproc

proc puts
		"w" 1 :fdopen swap 2 pick swap
		:fputs drop
		:fflush drop
endproc

proc newline
		0 "\0a" :printf drop
endproc
