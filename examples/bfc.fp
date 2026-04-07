$inc std.fp
$extern getchar

# bf compiler aura
# gotta use stdin and stdout
# also using fasm because that's just the best asm
proc main
		0 "format ELF64 executable 3\0a" :printf drop
		0 "section '.text' executable\0a" :printf drop
		0 "use64\0a" :printf drop
		0 "public main\0a" :printf drop
		0 "extrn putchar\0a" :printf drop
		0 "extrn getchar\0a" :printf drop
		0 "main:\0a" :printf drop
		# stack size: 4096 16 bit values
		# stack sp + in one
		16 4096 i* :malloc
		# current max label
		0
		:getchar
		while dup 0 1 i- == not do
				# +
				if dup 43 == then
					  0 "\09inc [ptr + tape]\0a" :printf drop
				endif
				# -
				if dup 45 == then
					  0 "\09dec [ptr + tape]\0a" :printf drop
				endif
				# >
				if dup 62 == then
					  0 "\09inc [ptr]\0a" :printf drop
				endif
				# <
				if dup 60 == then
					  0 "\09dec [ptr]\0a" :printf drop
				endif
				# ,
				if dup 44 == then
					  0 "\09call getchar\0a" :printf drop
						0 "\09mov [ptr+tape], rax\0a" :printf drop
				endif
				# .
				if dup 46 == then
					  0 "\09xor edi, edi\0a" :printf drop
						0 "\09mov dil, [ptr+tape]\0a" :printf drop
					  0 "\09call putchar\0a" :printf drop
				endif
				# [
				if dup 91 == then
					 	# max
					  pick 2
						# stack
						dup pick 3
						# sto
						st16
						# print
						0 "\09mov dil, [ptr+tape]\0a" :printf drop
						0 "\09test dil, dil\0a" :printf drop
						dup "\09jz tail%d\0a" :printf drop
						dup "head%d:\0a" :printf drop
				endif
				# ]
				if dup 93 == then
				endif
				drop
				:getchar
		endwhile
		0 "section '.data' readable writeable" :printf drop
		0 "tape db 4096 dup(0)" :printf drop
		0 "ptr dd 0" :printf drop
endproc
