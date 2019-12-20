	  .data
l_prompt: 	.asciiz "Input the start of the range: "
h_prompt: 	.asciiz "Input the end of the range: "
e_prompt: 	.asciiz "Unable to check non-positive values\nExiting......"
swap_prompt:	.asciiz "End of range < start of range -- swapping values\n"
amc_prompt: 	.asciiz " are amicable numbers\n"
pair_prompt: 	.asciiz "\nPairs of amicable numbers = "
range_prompt: 	.asciiz "Range of amicable numbers: "
_and: 		.asciiz " and "
_sdash:		.asciiz " - "
_mdash:		.asciiz "\n-----\n"
range:	  	.word 	0, 0
	  .text
	  
########################################################################
### main: driver of program...
########################################################################
main:
		li $v0, 4		# signal string output.
		la $a0, l_prompt	# load output string.
		syscall			# execute string output.
	
		li $v0, 5		# signal input of integer.
		syscall			# execute input of integer.
		blez $v0, exit		# branch if user inputs <= 0.
		la $s0, range
		sw  $v0, 0($s0)		# store input of integer into l_range.
	
		li $v0, 4		# signal string output.
		la $a0, h_prompt	# load output string.
		syscall			# execute string output.
	
		li $v0, 5		# signal input of integer.
		syscall			# execute input of integer.
		blez $v0, exit		# branch if user inputs <= 0.
		sw  $v0, 4($s0)		# store input of integer into h_range.
		
		lw $a1, 0($s0)		
		lw $a2, 4($s0)
		jal swap		# call swap to check input

########################################################################
### isAmic: will loop through a given range of numbers, finding the pairs that are amicable
########################################################################
isAmic:
		la $t0, range
		lw $s0, 0($t0) 		# i = counter, set at low range
		lw $s1, 4($t0)		# set at high range
		li $s2, 0		# hold sum of counter
		li $s3, 0		# counter for pairs
isAmicLoop:	
		move $a0, $s0		
		jal findFac		# find i's sum
		move $s2, $v0		# store the sum
		beq $s2, $s0, isAmicInc	# dont want perfect numbers
		bgt $s0, $s2, isAmicInc	# if the sum of i is less than i, break
		bgt $s2, $s1, isAmicInc # if the sum is greater than the range, break
		move $a0, $s2		
		jal findFac		# find the sum of i's divisors - sum
		bne $s0, $v0, isAmicInc	# if the sum of i's divisors - sum does not equal i, break
		move $a0, $s0
		move $a1, $s2
		jal amc_print
		addi $s3, $s3, 1	# add to pair counter
isAmicInc:	
		addi $s0, $s0, 1	# increase counter by 1
		bgt  $s0, $s1, isAmicEnd# if i >= high range, we done
		j isAmicLoop		# keep looping
isAmicEnd:
		jal end_print
		j main			# jump back to main.
	
########################################################################
### Print exit prompt to ui
########################################################################
exit:
		li $v0, 4		# signal string output.
		la $a0, e_prompt	# load output string.
		syscall			# execute string output.
	
		li $v0, 10		# signal exit code.
		syscall			# execute exit.
		
########################################################################
### Swap values that are input incorrectly and print to ui
### Example: Input the start of the range: 1250
###	     Input the end of the range: 1
###	     End of range < start of range -- swapping values
########################################################################
swap:		blt $a1, $a2, swapExit
		sw $a2, 0($s0)
		sw $a1, 4($s0)
		
		li $v0, 4
		la $a0, swap_prompt
		syscall
swapExit:
		jr $ra
########################################################################
### Print the pairs of amicable numbers
########################################################################
amc_print: 
		li $v0, 1
		syscall
	
		li $v0, 4
		la $a0, _and
		syscall
	
		move $a0, $a1
		li $v0, 1
		syscall
	
		li $v0, 4
		la $a0, amc_prompt
		syscall
	
		jr $ra
		
########################################################################
### Print the ending bit of ui:
### Example: Range of amicable numbers: 1 - 1250
###	     Pairs of amicable numbers = 2
###	     -----
########################################################################
end_print:
		li $v0, 4
		la $a0, range_prompt
		syscall
	
		la $t0, range
		li $v0, 1
		lw $a0, 0($t0)
		syscall
	
		li $v0, 4
		la $a0, _sdash
		syscall
	
		li $v0, 1
		lw $a0, 4($t0)
		syscall
	
		li $v0, 4
		la $a0, pair_prompt
		syscall
	
		li $v0, 1
		move $a0, $s3
		syscall
	
		li $v0, 4
		la $a0, _mdash
		syscall
	
		jr $ra
		
########################################################################
### findFac: will return the sum of all the divisors of a number - excluding the number itself
########################################################################
findFac:	
		move $t7, $a0		# preserve number (n)
		move $t0, $t7		# entered number (n)
		li $t1, 2		# factor to check (i)
		li $v0, 1		# resulting prime factorization
facLoop:	
		div $t6, $t0, $t1	# n / i = $t6
		bgt $t1, $t6, facCondEnd# i > n/i ??? then we're done
		li $t2, 1		# summation (current_sum)
		li $t3, 1		# looping term (current_term)
facPrimeLoop:	
		div $t0, $t1		
		mfhi $t5		# n % 1
		bnez $t5, facInc	# if n % i =/= 0, break
		div $t0, $t0, $t1	# n = n / i
		mul $t3, $t3, $t1	# current_term *= i
		add $t2, $t2, $t3	# current_sum += i
		j facPrimeLoop 
facInc:
		mul $v0, $v0, $t2	# result *= current_sum
		addi $t1, $t1, 1	# i++
		j facLoop		# keep looping
facCondEnd:	
		blt $t0, 2, facEnd	# check if n is less than 2, break
		add $t4, $t0, 1		# n + 1
		mul $v0, $v0, $t4	# result *= (n + 1)
facEnd:		
		sub $v0, $v0, $t7	# subtract original n value from total
		jr $ra			
