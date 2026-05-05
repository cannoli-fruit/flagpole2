$inc std.fp

proc fib
    if dup 0 == then
	drop 0 return
    endif

    if dup 1 == then
	drop 1 return
    endif

    dup
    1 i- :fib @fibnm1
    2 i- :fib @fibnm2

    &fibnm1 &fibnm2 i+
endproc

proc main
    :getint :fib
    :putint :newline
endproc
