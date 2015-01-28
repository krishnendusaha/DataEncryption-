.data
prompt1: .asciiz "Enter a Bit String (<20 characters)"
prompt2: .asciiz "OK \n"
prompt3: .asciiz "OKKKKKKKKKKKKKKKKKKKKKKKKKKKKK \n"
nwln: .asciiz "\n" 
spc : .asciiz " "
str: .space 20
bit_str: .space 160
fin: .asciiz "C:\\Users\\srajan\\Desktop\\boat.txt"#boat-matrix
fout: .asciiz "C:\\Users\\srajan\\Desktop\\out.txt"#boat-matrix
buf: .space 3
arr: .word 0:256
#arr2D: .word 0:65536
.text
.globl main
main:

la $a0,prompt1
li $v0,4
syscall

la $a0,str
li $a1,20
li $v0,8
syscall
move $v1,$zero
len:
lb $t0,($a0)
beq $t0,$zero,outofhere
addi $a0,$a0,1
addi $v1,$v1,1
j len

outofhere:
sll $v1,$v1,3
jal conv_bit_str

la $a3,bit_str

la $a0,nwln
li $v0,4
syscall

 

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
li $s0,256
li $t9,0
move $s8,$t9
move $t7,$zero
#la $t7,arr2D
jal open_boat



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
beq $t9,$s1,reInitiate
#sw $t1,($t7)
#addi $t7,$t7,4
la $a1,arr  #base address
#addi $t1,$t1,-1 #
sll $t1,$t1,2  #offset
add $t1,$a1,$t1 #index value(same as pixel value)
lw $t2,($t1) #
addi $t2,$t2,1 #updates no. of pixels
sw $t2,($t1)
b reInitiate


oneDigit:
jal write_procedure
beq $t9,$s1,reInitiate
la $a1,arr
#sw $t1,($t7)
#addi $t7,$t7,4
sll $t1,$t1,2
add $t1,$a1,$t1
lw $t2,($t1)
addi $t2,$t2,1
sw $t2,($t1)
b reInitiate

twoDigit:
li $t3,10
mult $t1,$t3
mflo $t1
add $t1,$t1,$t2

jal write_procedure
beq $t9,$s1,reInitiate
#sw $t1,($t7)
#addi $t7,$t7,4



la $a1,arr
#addi $t1,$t1,-1
sll $t1,$t1,2
add $t1,$a1,$t1
lw $t3,($t1)
addi $t3,$t3,1
sw $t3,($t1)
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
move $t5,$zero
beq $t9,$s1,exit
la $t0,arr #read head for histogram
move $t1,$t0 #reserves base address of arr
li $t2,1024  #size of array
li $t5,0  #peak point
do:
sub $t3,$t0,$t1 	#position of read head
beq $t3,$t2,end 	#if read head has covered entire length of array then end
#lw $a0,($t0)		#else read array (current value)
#li $v0,1
#syscall
bgt $a0,$t5,max		#if current value>peak point...change peak point
addi $t0,$t0,4 		#else move read head to next value
b do

max:
move $t5,$a0 		#change peak point
srl $t3,$t3,2 		#divide by 4 to get index
move $a1,$t3 		#max pixel value
addi $t0,$t0,4 		#move read head
b do

end:
move $t6,$s1
la $a0,nwln
li $v0,4
syscall

move $a0,$a1
li $v0,1
syscall
move $s5,$a1   #stores maximum
jal open_boat
jal open_out
move $t5,$zero
move $t9,$s1
b loop

exit:
move $a0,$s7
la $a1,nwln
li $a2,1
li $v0,15
syscall
move $a0,$s6
li $v0,16
syscall
move $a0,$s7
li $v0,16
syscall
li $v0,10
syscall




write_procedure:
beq $t9,$s1,checkDigits2
jr $ra
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
beq $t1,$s5,shift0
bgt $s5,$t1,shift3
addi $t1,$t1,1
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
bgt $s5,$t1,shift2
addi $t1,$t1,1
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
bgt $s5,$t1,shift1
addi $t1,$t1,1
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


shift0:

lb $t0,0($a3)
beq $s8,$v1,shift3
addi $a3,$a3,1
addi $s8,$s8,1
beq $t0,$s1,addone
b shift3
addone:
addi $t1,$t1,1
b shift3


open_boat:
li $v0,13 #sysrem call for opening the file
la $a0,fin #board file name
li $a1,0 #open for reading(flag 0:read 1:write)
li $a2,0 #ignored
syscall
move $s6,$v0 #save file dexcriptor
jr $ra

open_out:
li $v0,13 #sysrem call for opening the file
la $a0,fout #board file name
li $a1,1 #open for reading(flag 0:read 1:write)
li $a2,0 #ignored
syscall
move $s7,$v0 #save file dexcriptor
jr $ra


conv_bit_str:

la  $t0,str
la  $t1,bit_str
li  $t6,10
loop4:
lb  $t2,($t0)    
beq  $t2,$t6,end_loop4
addi $t4,$t1,-1
addi $t5,$t1,7
addi $t0,$t0,1
li  $t3,0
nested_loop1:
beq  $t5,$t4,end_nested_loop1
andi $t3,$t2,1
sb   $t3,($t5)
srl  $t2,$t2,1
addi  $t5,$t5,-1
b nested_loop1

end_nested_loop1:
addi $t1,$t1,8
b loop4

end_loop4:
sb $s2,($t1)
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