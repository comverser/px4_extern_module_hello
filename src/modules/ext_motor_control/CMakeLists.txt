px4_add_module(
	MODULE modules__ext_motor_control
	MAIN ext_motor_control
	STACK_MAIN 2000
	SRCS
		ext_motor_control.cpp
	EXTERNAL
	)