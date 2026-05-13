define i32 @main(i32 %argc, i8** %argv) {
entry:
	%addr = ptrtoint i8* %argv to i64
	call void @__fp_internal_push(i64 %addr)
	%ci64 = sext i32 %argc to i64
	call void @__fp_internal_push(i64 %ci64)
	call void @__fp_user_main()
	ret i32 0
}