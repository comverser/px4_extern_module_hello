px4_add_module(
	MODULE modules__hello_px4
	MAIN hello_px4
	STACK_MAIN 2000
	SRCS
		hello_px4.cpp
	EXTERNAL
)