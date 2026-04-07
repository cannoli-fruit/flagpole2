declare i64 @printf(i8*, i64)
@stack = global [1024 x i64] zeroinitializer
@sp = global i64 0
@fmt_int = private constant [7 x i8] c"%lld\n\00"

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

define void @__fp_internal_putint() {
entry:
	%val = call i64 @__fp_internal_pop()
	%fmt_ptr = getelementptr [7 x i8],
					 	 							 [7 x i8]* @fmt_int,
													 i64 0,
													 i64 0
	call i64 @printf (
			 i8* %fmt_ptr,
			 i64 %val
	)
	ret void
}

define void @__fp_user_main() {
	call void @__fp_internal_push(i64 1)
	call void @__fp_internal_push(i64 2)
	call void @__fp_internal_push(i64 3)
	call void @__fp_internal_push(i64 4)
	call void @__fp_internal_push(i64 5)
	call void @__fp_internal_putint()
	call void @__fp_internal_putint()
	call void @__fp_internal_putint()
	call void @__fp_internal_putint()
	call void @__fp_internal_putint()
ret void
	}

