#
# 64bit_mult.asm
# Chait Sayani and Andy Younkins, 1 April 2014

.data
f1:.word -0
f2: .word -0
one: .word 1

.text
# The main program
main:
      # Load factors into registers a0 and a1				#WE SHOULD LOAD THINGS INTO BETTER REGISTERS...WE CAN DO THIS AT THE END ONCE WE ARE FINISHED AND IT RUNS CORRECTLY
      la	$a0, f1
      lw	$a0, 0($a0) #multiplier
      la	$a1, f2
      lw	$a1, 0($a1) #multiplicand
      li	$a2, 0      #multiplicand, larger half
      la	$t7, one
      lw	$t7, 0($t7) #one

      jal	checkNegs
      jal	mult
      jal	properNegation
      jal	printPretty

      # Exit
      li	$v0, 10
      syscall

checkNegs:
	addu	$s2, $zero, $zero
      xor	$s2, $a1, $a0
      srl	$s2, $s2, 31
      andi	$s2, $s2, 1
      abs	$a0, $a0
      abs	$a1, $a1
      b	end


# The multiplication subroutine
mult: li	$s4, 0  #nothing

loop: beqz	$a0, end
      andi	$s0, $a0, 1
      add	$s5, $a0, $zero
      srl	$a0, $a0, 1
      add	$s6, $a1, $zero
      add	$s7, $a2, $zero
      b	shiftBigNums		#shift to higher register too

shiftBigNums:
	srl	$s3, $s6, 31
	sll	$a2, $a2, 1
	addu	$a2, $s3, $a2
      sll	$a1, $a1, 1
      beqz	$s0, loop  #if multipicand is odd, add mutiplier
      b	addBigNums

# Adds the 2 register numbers		#$a1 and $a2 are where the multiplicand are stored
addBigNums: 				#$t0 and $t1 are where the sum are store
	addu	$t2, $zero, $t0		#stores temp copy of smaller half of sum
	addu	$t0, $t0, $s6		#adds the small half of digits to the sum
	addu	$t1, $t1, $s7		#adds the larger half of digits to the sum
	bgt	$s6, $t0, addBigNumsHelp
	b	loop

#helper called in addBigNums in case of overflow
addBigNumsHelp:
	addu	$t1, $t1, 1
	b	loop

properNegation:
	bgtz 	$s2,  properNegationHelper
	b	end

properNegationHelper:
	not	$t0, $t0
      not	$t1, $t1
      addu	$t0, $t0, $t7
      addu	$t1, $t1, $t7
	addi  $t9,$t9,1
      b	end


#called in main, prints everything nicely			#WE STILL NEED TO PRINT THE CORRECT THING...SWITCH TO NEGATIVE HERE AND PRINT PROPERLY
printPretty:
	add	$a0, $zero, $zero
	add	$a0, $zero $t1
	li	$v0, 34
      syscall
      								#CASE 1: IF A NUMBER IS LESS THAN 32 BITS, PRINT ONLY SMALLL REGISTRER AND ADD NEGATIVE TO SMALL REGISTER
	addu	$a0, $zero, $zero
	add	$a0, $zero $t0
	li	$v0, 34
      syscall

	jr	$ra

end:
      jr	$ra
