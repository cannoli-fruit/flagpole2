$inc std.fp

proc fib
    if dup 0 == then
			drop 0 return
    endif

    if dup 1 == then
			drop 1 return
    endif

    dup
    1 i- :fib swap
    2 i- :fib
    i+
endproc

proc main
    :getint :fib
    :putint
endproc
