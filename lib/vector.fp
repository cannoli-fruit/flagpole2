# Vector implementation on i64 or really whatever you want
# as long as it's 64 bit

proc vectorNew
		# label contains count, cap, *items
		24 :malloc
		dup 0 st8
		8 i+
		dup 256 st8
		8 i+
		dup 2048 :malloc st8

		16 i-
endproc
