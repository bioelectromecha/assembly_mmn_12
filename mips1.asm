.data
	buf: .space 20
	buf1: .space 20
.text
	
main:	
	
	jal read_buf
	
	# set counter to 0
	li $t0, 0
	li $t3, 0
	li $t4, 0
	la $t1, buf
	la $a0, buf1
loopa_loop:
	# exit when counter reaches index 19
	beq $t0, 19, exit_loop
	
	# get letters at positions i and i+1
	lb $t2, 0($t1)
	lb $t3, 1($t1)
	
	# case where letter at position i+1 is terminal
	beq $t3, '\0', exit_loop
	
	# compare letters at positions i and i+1
	sub $t4, $t3, $t2
	blt $t4, 0, else1
	bgt $t4, 0, else2
	move $s0, $t0
	jal put_equal
	move $t0, $s0
	j end
else1:
	move $s0, $t0
	jal put_minus
	move $t0, $s0
	j end
else2: 
	move $s0, $t0
	jal put_plus
	move $t0, $s0
	j end

end: 
	
	# increment counter
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $a0, $a0, 1
	# dup da loop
	j loopa_loop
	
exit_loop:
	
	jal put_terminator
	
	# print out buf1
	jal print_buf1
	
	# exit
	li $v0, 10
	syscall




# read string into buf
read_buf:
	li $v0, 8
	li $a1, 20
	la $a0, buf
	syscall
	jr $ra
	
# print string from buf
print_buf1:
	li $v0, 4
	la $a0, buf1
	syscall
	jr $ra
	
# put a + sign at location $a0 in buf1
put_plus:
	li $t0, '+'
	sb $t0, 0($a0)
	jr $ra
# put a - sign at location $a0 in buf1
put_minus:
	li $t0, '-'
	sb $t0, 0($a0)
	jr $ra
# put an = sign at location $a0 in buf1
put_equal:
	li $t0, '='
	sb $t0, 0($a0)
	jr $ra

# put a terminal char
put_terminator:
	li $t0, '\0'
	sb $t0, -1($a0)
	jr $ra

	
