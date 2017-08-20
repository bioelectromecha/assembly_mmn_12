.data
	number: .space 10
	# this is what I used for testing
	#number: .byte 1, 2, 3, 8, 5, 16, 255, 254, 248, 0
	#number: .byte 1, 1,0, 1, 1, 0, 1, 1, 1, 0
	#number: .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
	
	# messages to print
	div_by_x_message: .asciiz "\nthe numbers divisible by x are:\n"
	sum_message: .asciiz"\nthe sum of the array is:\n"
	diff_message: .asciiz"\nthe diffs are:\n"
	is_series_message: .asciiz "\nthe array is a series\nplease select which array element to print (integer from 50-100)\n"
	is_not_series_message: .asciiz "\nthe array is a not series"
	bad_input_message: .asciiz "input is not in right range - rerun" 
	series_element_message: .asciiz "\nthe requested series element is:\n"
	
.text
	main:
		# this is what I used for tests
		#la $a0, number #array address
		#li $a1, 10 # array size
		#li $a2, 10 # base
		#jal print_numbers_div_by_8_base_x_signed
		#jal print_numbers_div_by_4_base_x_unsigned	
		#jal print_sum_of_numbers_signed
		#jal print_sum_of_numbers_unsigned
		#jal print_numbers_diff_signed
	
		# exit
		li $v0, 10
		syscall 
	
	
	# print the numbers divisible by 8 in base x signed
	# $a0 array address, $a1 array size, $a2 base
	print_numbers_div_by_8_base_x_signed:
		#set print parameters
		li $a3, 1 #signed
		li $v1, 8 #divisible by
		#save return address to memory
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#print the numbers
		jal print_numbers_div_by_x
		#restore return address
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

	

	# print the numbers divisible by 4 in base x unsigned
	# $a0 array address, $a1 array size, $a2 base
	print_numbers_div_by_4_base_x_unsigned:

		li $a3, 0 #unsigned
		li $v1, 4 #divisible by
		#save return address to memory
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#print the numbers
		jal print_numbers_div_by_x
		#restore return address
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
	# print sum of numbers signed in base x
	# $a0 array address, $a1 array size, $a2 base
	print_sum_of_numbers_signed:
		li $a3, 1 #signed
		#save return address to memory
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#print the numbers
		jal print_sum_numbers
		#restore return address
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
	# print sum of numbers unsigned in base x
	# $a0 array address, $a1 array size, $a2 base
	print_sum_of_numbers_unsigned:
		li $a3, 0 #signed
		#save return address to memory
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#print the numbers
		jal print_sum_numbers
		#restore return address
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	
	print_sum_numbers:
		# print presentation message
		li $v0, 4 
		move $s0, $a0 #save
		la $a0, sum_message
		syscall 
		move $a0, $s0 #restore 
		
		#save the return address to the stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#init counter
		li $t0, 0
		li $s0, 0
		loop2: 
			beq $t0, $a1, exit_loop2
			#increment the address
			la $t1, number
			add $t1, $t1, $t0
			#increment the counter
			addi $t0, $t0, 1
			# check if signed or unsigned
			beq $a3, 1, signed2 
			lbu $a0, 0($t1) #get the 8 bit unsigned integer
			addu $s0, $s0, $a0 
			j after_sign_check2
			signed2: 
			lb $a0, 0($t1)  #get the 8 bit signed integer
			add $s0, $s0, $a0
			after_sign_check2:
			j loop2
		exit_loop2:
		# convert to the specified base
		jal save_my_regs
		move $a0, $s0
		jal convert_to_base
		jal restore_my_regs
		move $a0, $v0
		# print out the number, a0 already loaded
		li $v0, 1
		syscall
		#restore return address
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	
	
	# print the numbers divisible by x, signed or unsigned
	# a0 array address, a1 array size, a2 base, a3 signed(1)/unsigned(0), $v1 div by x 
	print_numbers_div_by_x:
		# print presentation message
		li $v0, 4 
		move $s0, $a0 #save
		la $a0, div_by_x_message
		syscall 
		move $a0, $s0 #restore 
		
		#save the return address to the stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		li $t0, 0
		loop1: 
			beq $t0, $a1, exit_loop1
			#increment the address
			la $t1, number
			add $t1, $t1, $t0
			#increment the counter
			addi $t0, $t0, 1
			# check if signed or unsigned
			beq $a3, 1, signed1
			lbu $a0, 0($t1) #get the 8 bit unsigned integer
			j after_sign_check1
			signed1: 
			lb $a0, 0($t1)  #get the 8 bit signed integer
			after_sign_check1:
			
			# check if divisible by 4 - continue to next number if not
			rem $t2, $a0, $v1
			bne $t2, 0, loop1
			
			# convert to the specified base
			jal save_my_regs
			jal convert_to_base
			jal restore_my_regs
			move $a0, $v0
			# print out the number, a0 already loaded
			li $v0, 1
			syscall
			
			#print space
			li $v0, 11
			li $a0, ' '
			syscall
			#loop
			j loop1
			
		exit_loop1:
		#restore return address
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	
	# print the difference between two consecutive numers
	# a0 array address, a1 array size, a2 base, a3 signed(1)/unsigned(0), $v1 div by x 
	# at end of run $v1 =1 if series, $v1 = 0 o/w
	print_numbers_diff_signed:
		# print presentation message
		li $v0, 4 
		move $s0, $a0 #save
		la $a0, diff_message
		syscall 
		move $a0, $s0 #restore 
		
		#save the return address to the stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		li $t0, 0
		subi $a1, $a1, 1 # there are l-1 diffs in an array of length l
		li $v1, 1
		li $t3, 0
		loop4: 
			beq $t0, $a1, exit_loop4
			#increment the counter
			addi $t0, $t0, 1
			#increment the address
			la $t1, number
			add $t1, $t1, $t0
			#get the 8 bit signed integers
			lb $a0, 0($t1)  
			lb $t2, -1($t1) # get the second integer
			sub $a0, $a0, $t2 # calc the diff between them
			
			#check if series or first run
			beq $t3, $a0, still_series # check if previous diff equal to current dif
			beq $t0, 1, still_series # if first iteration, it's ok if not equal
			li $v1, 0 # it's not a series
			still_series:
			move $t3, $a0 # update the series diff
			# convert to the specified base
			jal save_my_regs
			jal convert_to_base
			jal restore_my_regs
			move $a0, $v0
			# print out the number, a0 already loaded
			li $v0, 1
			syscall
			#print space
			li $v0, 11
			li $a0, ' '
			syscall
			#loop
			j loop4
		exit_loop4:
		# check if series or not
		beq $v1, 1, is_series
		#print is not series 
		li $v0, 4
		la $a0, is_not_series_message
		syscall	
		j after_series_check
		# print is series
		is_series:
		li $v0, 4
		la $a0, is_series_message
		syscall
		li $v0, 5
		syscall
				
		# check input is in right range
		bgt $v0, 100, bad_input
		blt $v0, 50, bad_input
		move $s0, $v0 # save $v0 between prints
		
		# print the presentation message
		li $v0, 4
		la $a0, series_element_message
		syscall
		
		# load the requested element
		addi $s0, $s0, -1 # the request is 1 based, we need to make it 0 based
		la $t0, number 
		add $t0, $t0, $s0 # offset the address to correct spot
		lb $a0, 0($t0)
		# print the requested number
		li $v0, 1
		syscall
		j after_series_check
		
		
		bad_input:
		li $v0, 4
		la $a0, bad_input_message
		syscall
		j after_series_check
		
		after_series_check: 	

		#restore return address
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	

	#save a0,a1,a2,t0,t1,t2 to memory
	save_my_regs:
		addi $sp, $sp, -24 # allocate stack segment
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $t0, 12($sp)
		sw $t1, 16($sp)
		sw $t2, 20($sp)
		jr $ra
		
	# restore a0,a1,a2,t0,t1,t2 from memory
	restore_my_regs:
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $t0, 12($sp)
		lw $t1, 16($sp)
		lw $t2, 20($sp)
		addi $sp, $sp, 24 # deallocate stack segment
		jr $ra
		
	#convert an integer to required base <=10
	# $a0 is the input integer, $a2 required base, $v0 return number
	convert_to_base:
		move $t0, $a0
		bgez $t0, after_negate1 #don't negate if non-negative
		xori $t0, $t0, -1 #flip bits
		add $t0, $t0, 1 # add 1 to to convert 1's complement to 2's complement
		after_negate1:
		li $t1, 1
		li $v0, 0
		loop3: 
			div $t0, $a2
			mflo $t0 # division quotient
			mfhi $t2 # division remainder
			mul $t2,$t2, $t1 #move the remainder to the right place
			mul $t1, $t1, 10 #increment the place mover
			add $v0, $v0, $t2 #add to the output number
			#quit when quotient equals zero
			beq $t0, 0, exit_loop3
			j loop3
		exit_loop3:
		bgez $a0, after_negate2 # don't negate if non-negative
		xori $v0, $v0, -1
		add $v0, $v0, 1
		after_negate2:
		jr $ra
