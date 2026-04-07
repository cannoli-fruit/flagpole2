@stack = global [1024 x i64] zeroinitializer
@sp = global i64 0
@fmt_int = private constant [6 x i8] c"%lld\0A\00"

define i64 @__fp_internal_pop() {
entry:
	%sp_val = load i64, i64* @sp
	%sp_next = sub i64 %sp_val, 1
	store i64 %sp_next, i64* @sp	
	%ptr = getelementptr [1024 x i64],
			 	 							 [1024 x i64]* @stack,
											 i64 0,
											 i64 %sp_next
	%val = load i64, i64* %ptr
	ret i64 %val
}

define void @__fp_internal_push(i64 %x) {
entry:
	%sp_val = load i64, i64* @sp
	%ptr = getelementptr [1024 x i64],
			 	 							 [1024 x i64]* @stack,
											 i64 0,
											 i64 %sp_val
	store i64 %x, i64* %ptr
	%sp_next = add i64 %sp_val, 1
	store i64 %sp_next, i64* @sp	
	ret void
}

define void @__fp_internal_addints() {
entry:
	%y = call i64 @__fp_internal_pop()
	%x = call i64 @__fp_internal_pop()
	%z = add i64 %x, %y
	call void @__fp_internal_push(i64 %z)
	ret void
}

define void @__fp_internal_subints() {
entry:
	%y = call i64 @__fp_internal_pop()
	%x = call i64 @__fp_internal_pop()
	%z = sub i64 %x, %y
	call void @__fp_internal_push(i64 %z)
	ret void
}

define void @__fp_internal_mulints() {
entry:
	%y = call i64 @__fp_internal_pop()
	%x = call i64 @__fp_internal_pop()
	%z = mul i64 %x, %y
	call void @__fp_internal_push(i64 %z)
	ret void
}

define void @__fp_internal_divints() {
entry:
	%y = call i64 @__fp_internal_pop()
	%x = call i64 @__fp_internal_pop()
	%z = sdiv i64 %x, %y
	call void @__fp_internal_push(i64 %z)
	ret void
}

define void @__fp_internal_equals() {
entry:
	%y = call i64 @__fp_internal_pop()
	%x = call i64 @__fp_internal_pop()
	%bool = icmp eq i64 %x, %y
	%ret = select i1 %bool, i64 1, i64 0
	call void @__fp_internal_push(i64 %ret)
	ret void
}

define void @__fp_internal_ilt() {
entry:
	%y = call i64 @__fp_internal_pop()
	%x = call i64 @__fp_internal_pop()
	%bool = icmp slt i64 %x, %y
	%ret = select i1 %bool, i64 1, i64 0
	call void @__fp_internal_push(i64 %ret)
	ret void
}

define void @__fp_internal_igt() {
entry:
	%y = call i64 @__fp_internal_pop()
	%x = call i64 @__fp_internal_pop()
	%bool = icmp sgt i64 %x, %y
	%ret = select i1 %bool, i64 1, i64 0
	call void @__fp_internal_push(i64 %ret)
	ret void
}

define void @__fp_internal_duplicate() {
entry:
	%x = call i64 @__fp_internal_pop()
	call void @__fp_internal_push(i64 %x)
	call void @__fp_internal_push(i64 %x)
	ret void
}

define void @__fp_internal_swap() {
entry:
	%y = call i64 @__fp_internal_pop()
	%x = call i64 @__fp_internal_pop()
	call void @__fp_internal_push(i64 %y)
	call void @__fp_internal_push(i64 %x)
	ret void
}

define void @__fp_internal_pick() {
	%idx = call i64 @__fp_internal_pop()
	%sp_val = load i64, i64* @sp
	%sp_read = sub i64 %sp_val, %idx
	%ptr = getelementptr [1024 x i64],
			 	 							 [1024 x i64]* @stack,
											 i64 0,
											 i64 %sp_read
	%val = load i64, i64* %ptr
	call void @__fp_internal_push(i64 %val)
	ret void
}

define void @__fp_internal_poke() {
	%idx = call i64 @__fp_internal_pop()
	%val = call i64 @__fp_internal_pop()
	%sp_val = load i64, i64* @sp
	%sp_read = sub i64 %sp_val, %idx
	%ptr = getelementptr [1024 x i64],
			 	 							 [1024 x i64]* @stack,
											 i64 0,
											 i64 %sp_read
	store i64 %val, i64* %ptr
	ret void
}

define void @__fp_internal_not() {
	%x = call i64 @__fp_internal_pop()
	%eq0 = icmp eq i64 %x, 0
	br i1 %eq0, label %iszero, label %notzero

iszero:
	call void @__fp_internal_push(i64 1)
	ret void

notzero:
	call void @__fp_internal_push(i64 0)
	ret void
}

define void @__fp_internal_bitnot() {
	%x = call i64 @__fp_internal_pop()
	%y = xor i64 %x, -1
	call void @__fp_internal_push(i64 %y)
	ret void
}
