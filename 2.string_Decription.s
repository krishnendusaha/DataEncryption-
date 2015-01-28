.data
fin: .asciiz "C:\\Users\\srajan\\Desktop\\boat_watermarked.txt"#boat-matrix
fout: .asciiz "C:\\Users\\srajan\\Desktop\\boat_retrieved_matrix.txt.txt"#boat-matrix
spc : .asciiz " "
nwln: .asciiz "\n"
str: .space 160
buf: .space 3

.text
.globl main

main:

reg_init:
li $t1,0
li $t2,0
li $t3,0
li $t5,0 #counter for no. of digits in number
li $t6,1 #flag = 1 if end of file not reached
li $t8,0
li $s1,1 #no. of digits =1
li $s2,2 #no. of digits = 2
li $s3,32 #blank space
li $s4,10 #newline
li $s5,145#peak point
la $a3,str
li $s8,20#lenght of string
li $s0,256
li $v1,128
addi $t9,$s5,1
#la $t7,arr2D
jal open_watermarked_boat
jal open_retrieval_boat


loop:
li $v0,14 #system call for reading from file
move $a0,$s6
la $a1,buf
li $a2,1
syscall
la $t0,buf
lb $t4,($t0)	#load first byte
beq $t4,$s3,checkDigits 	#if space..check no. of digits
beq $t4,$s4,newlineCounter  #if newline
#beq $t4,$zero,end_loop 		#if end of file..end loop
addi $t4,$t4,-48		#else convert to integer
beq $t5,$zero,first		#if digit counter is 0 go to first
beq $t5,$s1,second		#if digit counter is 1 go to second
b third					#else go t0 third

first:
move $t1,$t4 		#store first digit in $t1
addi $t5,$t5,1 	#increment digit counter
b loop

second:
move $t2,$t4 	#store second digit in $t2
add $t5,$t5,1 #increment digit counter
b loop

third: 
move $t3,$t4  #store third digit in $t3
addi $t5,$t5,1    #re-initiate digit counter
b loop

newlineCounter:
addi $t8,$t8,1
beq $t8,$s0,end_loop

checkDigits:

beq $t5,$zero,loop
beq $t5,$s1,oneDigit 	#
beq $t5,$s2,twoDigit    #

threeDigit:
li $t5,100 
mult $t5,$t1   #100's digit
mflo $t1
li $t5,10
mult $t5,$t2
mflo $t2 		#10's digit
add $t2,$t2,$t1 
add $t1,$t2,$t3 #net digit
jal write_procedure
b reInitiate


oneDigit:
jal write_procedure
b reInitiate

twoDigit:
li $t3,10
mult $t1,$t3
mflo $t1
add $t1,$t1,$t2

jal write_procedure
b reInitiate


reInitiate:
beq $t6,$zero,elp
li $t1,0
li $t3,0
li $t2,0
li $t5,0
#addi $t0,$t0,1
b loop

end_loop:     #after reading the last byte
move $a0,$s6
li $v0,16
syscall
move $t8,$zero
move $t6,$zero
beq $t5,$s1,oneDigit 	#branch to if oneDigit one digit no.
beq $t5,$s2,twoDigit    #branch to twoDigit if two digit no.
b threeDigit			#else branch to threeDigit

elp:
exit:
move $a0,$s7
la $a1,nwln
li $a2,1
li $v0,15
syscall

#la $a0,str
#li $v0,4
#syscall

move $a0,$s7
li $v0,16
syscall
li $v0,10
syscall


write_procedure:
checkDigits2:
beq $t7,$s0,writeNewLine
addi $t7,$t7,1
beq $t5,$s1,write1
beq $t5,$s2,write2
b write3

writeNewLine:
move $a0,$s7
la $a1,nwln
li $a2,1
li $v0,15
syscall
move $t7,$zero
b checkDigits2

write3:
beq $t1,$s5,decode0
beq $t1,$t9,decode1
bgt $s5,$t1,shift3
addi $t1,$t1,-1
shift3:
move $a0,$t1
la $a1,buf
jal lItoA

li $v0,15 #system call for reading from file
move $a0,$s7
li $a2,3
syscall
beq $t7,$s0,reInitiate
la $a1,spc
move $a2,$s1
li $v0,15
syscall
b reInitiate

write2:
shift2:
move $a0,$t1
la $a1,buf
jal lItoA

li $v0,15 #system call for reading from file
move $a0,$s7
li $a2,2
syscall
beq $t7,$s0,reInitiate
la $a1,spc
move $a2,$s1
li $v0,15
syscall

b reInitiate

write1:
shift1:
move $a0,$t1
la $a1,buf

jal lItoA

move $a0,$s7
move $a2,$s1
li $v0,15 #system call for reading from file
syscall
beq $t7,$s0,reInitiate
la $a1,spc
move $a2,$s1
li $v0,15
syscall

b reInitiate



decode0:
beq $s8,$zero,shift3
beq $v1,$zero,reini2
srl $v1,$v1,1
b do2
reini2:
li $v1,32
sb $t3,($a3)
addi $a3,$a3,1
move $t3,$zero

do2:
#beq $s8,$zero,shift3
addi $s8,$s8,-1
b shift3

decode1:
beq $v1,$zero,reini1
add $t3,$t3,$v1
srl $v1,$v1,1
b do1

reini1:
beq $s8,$zero,shift3
sb $t3,($a3)
addi $a3,$a3,1
li $v1,32
move $t3,$zero

do1:

addi $s8,$s8,-1
addi $t3,$t3,-1
b shift3







open_watermarked_boat:
li $v0,13 #sysrem call for opening the file
la $a0,fin #board file name
li $a1,0 #open for reading(flag 0:read 1:write)
li $a2,0 #ignored
syscall
move $s6,$v0 #save file dexcriptor
jr $ra
 
 open_retrieval_boat:
li $v0,13 #sysrem call for opening the file
la $a0,fout #board file name
li $a1,1 #open for reading(flag 0:read 1:write)
li $a2,0 #ignored
syscall
move $s7,$v0 #save file dexcriptor
jr $ra


lItoA:

  bnez $a0, ItoA.non_zero  # first, handle the special case of a value of zero
  nop
  li   $t0, '0'
  sb   $t0, 0($a1)
  sb   $zero, 1($a1)
  li   $v0, 1
  jr   $ra
ItoA.non_zero:
  addi $t0, $zero, 10     # now check for a negative value
  li $v0, 0
    
  bgtz $a0, ItoA.recurse
  nop
  li   $t1, '-'
  sb   $t1, 0($a1)
  addi $v0, $v0, 1
  neg  $a0, $a0
ItoA.recurse:
  addi $sp, $sp, -24
  sw   $fp, 8($sp)
  addi $fp, $sp, 8
  sw   $a0, 4($fp)
  sw   $a1, 8($fp)
  sw   $ra, -4($fp)
  sw   $s0, -8($fp)
  sw   $s1, -12($fp)
   
  div  $a0, $t0       # $a0/10
  mflo $s0            # $s0 = quotient
  mfhi $s1            # s1 = remainder  
  beqz $s0, ItoA.write
ItoA.continue:
  move $a0, $s0  
  jal ItoA.recurse
  nop
ItoA.write:
  add  $t1, $a1, $v0
  addi $v0, $v0, 1    
  addi $t2, $s1, 0x30 # convert to ASCII
  sb   $t2, 0($t1)    # store in the buffer
  sb   $zero, 1($t1)
  
ItoA.exit:
  lw   $a1, 8($fp)
  lw   $a0, 4($fp)
  lw   $ra, -4($fp)
  lw   $s0, -8($fp)
  lw   $s1, -12($fp)
  lw   $fp, 8($sp)    
  addi $sp, $sp, 24
  jr $ra
  nop