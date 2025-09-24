px4_add_module(
	MODULE modules__ext_hello
	MAIN ext_hello
	STACK_MAIN 2000
	SRCS
		ext_hello.cpp
	EXTERNAL
)