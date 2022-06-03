# Miko³aj Taudul

.eqv BMP_FILE_SIZE 90122
.eqv BYTES_PER_ROW 1800
.eqv BMP_WIDTH 600
.eqv BMP_HEIGHT 50

	.data
result: .space 100
.align 2
res:		.space 2
image:		.space BMP_FILE_SIZE

fname:		.asciz "source3.bmp"
no_bar:		.asciz "No barcode in bmp"
set_B:		.asciz "Start is from set B or C"
set_C:		.asciz "Start is from set C"
no_char:	.asciz "No char found in codes_array"
bad_ctrl:	.asciz "Control sum doesn't match"

.data
codes_array:
code_0:		.word	0x6CC
code_1:		.word	0x66C
code_2:		.word	0x666
code_3:		.word	0x498
code_4:		.word	0x48C
code_5:		.word	0x44C
code_6:		.word	0x4C8
code_7:		.word	0x4C4
code_8:		.word	0x464
code_9:		.word	0x648
code_10:	.word	0x644
code_11:	.word	0x624
code_12:	.word	0x59C
code_13:	.word	0x4DC
code_14:	.word	0x4CE
code_15:	.word	0x5CC
code_16:	.word	0x4EC
code_17:	.word	0x4E6
code_18:	.word	0x672
code_19:	.word	0x65C
code_20:	.word	0x64E
code_21:	.word	0x6E4
code_22:	.word	0x674
code_23:	.word	0x76E
code_24:	.word	0x74C
code_25:	.word	0x72C
code_26:	.word	0x726
code_27:	.word	0x764
code_28:	.word	0x734
code_29:	.word	0x732
code_30:	.word	0x6D8
code_31:	.word	0x6C6
code_32:	.word	0x636
code_33:	.word	0x518
code_34:	.word	0x458
code_35:	.word	0x446
code_36:	.word	0x588
code_37:	.word	0x468
code_38:	.word	0x462
code_39:	.word	0x688
code_40:	.word	0x628
code_41:	.word	0x622
code_42:	.word	0x5B8
code_43:	.word	0x58E
code_44:	.word	0x46E
code_45:	.word	0x5D8
code_46:	.word	0x5C6
code_47:	.word	0x476
code_48:	.word	0x776
code_49:	.word	0x68E
code_50:	.word	0x62E
code_51:	.word	0x6E8
code_52:	.word	0x6E2
code_53:	.word	0x6EE
code_54:	.word	0x758
code_55:	.word	0x746
code_56:	.word	0x716
code_57:	.word	0x768
code_58:	.word	0x762
code_59:	.word	0x71A
code_60:	.word	0x77A
code_61:	.word	0x642
code_62:	.word	0x78A
code_63:	.word	0x530
code_64:	.word	0x50C
code_65:	.word	0x4B0
code_66:	.word	0x486
code_67:	.word	0x42C
code_68:	.word	0x426
code_69:	.word	0x590
code_70:	.word	0x584
code_71:	.word	0x4D0
code_72:	.word	0x4C2
code_73:	.word	0x434
code_74:	.word	0x432
code_75:	.word	0x612
code_76:	.word	0x650
code_77:	.word	0x7BA
code_78:	.word	0x614
code_79:	.word	0x47A
code_80:	.word	0x53C
code_81:	.word	0x4BC
code_82:	.word	0x49E
code_83:	.word	0x5E4
code_84:	.word	0x4F4
code_85:	.word	0x4F2
code_86:	.word	0x7A4
code_87:	.word	0x794
code_88:	.word	0x792
code_89:	.word	0x6DE
code_90:	.word	0x6F6
code_91:	.word	0x7B6
code_92:	.word	0x578
code_93:	.word	0x51E
code_94:	.word	0x45E
code_95:	.word	0x5E8
code_96:	.word	0x5E2
code_97:	.word	0x7A8
code_98:	.word	0x7A2
code_99:	.word	0x5DE
code_100:	.word	0x5EE
code_101:	.word	0x75E
code_102:	.word	0x7AE
code_103:	.word	0x684
code_104:	.word	0x690
code_105:	.word	0x69C
code_106:	.word	0x18E
	
	.text
read_bmp:
	addi sp, sp, -4	
	sw s1, 0(sp)
#otwiera plik
	li a7, 1024
        la a0, fname		#nazwa pliku
        li a1, 0	
        ecall
	mv s1, a0   

#czyta plik
	li a7, 63
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

#zamyka plik
	li a7, 57
	mv a0, s1
        ecall

	
set_values:

	li s0, 0		# znak binarnie
	li s1, 0		# X
	li s2, 0		# counter	
	li s3, BMP_HEIGHT	# Y
	srli s3, s3, 1		# : 2
	li s4, BMP_WIDTH
	li s5, 0		# szerokoœæ paska
	li s6, 0		# suma kontrolna
	#li s6, 103
	#li s9, 11		# 11 iloœæ pasków na litere
	
first_black:			# szuka 1 czarnego
	jal get_pixel	
	mv t1, a0
	beqz t1, black_found

iterate:
	addi s1, s1, 1
	addi s2, s2, 1
	beq s2, s4, no_barcode_in_bmp
	j first_black
	
black_found:
	mv t5, s2 # 0x00b6
	xor s2, s2, s2
	
get_one_bar_width:		# znajduje szerokoœæ 1 paska
	jal get_pixel
	mv t1, a0
	bnez t1, calc_bar_width
	addi s1, s1, 1
	addi s2, s2, 1
	j get_one_bar_width
	
calc_bar_width:			# liczy szerokoœæ paska
	li t2, 2
	div s5, s2, t2 		# s5 szerokoœæ standardowa paska
	li s7, -1		# licznik liter
	la s8, result
	mv s1, t5 	#jestem na pocz¹tku startu
	
new_char:
	xor s0, s0, s0		# znak binarnie 
	xor t1, t1, t1		# kolor 
	xor s2, s2, s2 		# iloœæ pasków 

	addi s7, s7, 1		# licznik
	
new_bar:
	jal get_pixel
	mv t1, a0
	add s1, s1, s5
	
	
check_color:
	bnez t1, give_white
	
give_black:			# wsstawi 1
	li t0, 1
	or s0, s0, t0
	addi s2, s2, 1
	li t0, 11
	beq s2, t0, decode_char # jeœli t2 == 11
	slli s0, s0, 1
	j new_bar

give_white:			# wstawi 0
	li t0, 0
	or s0, s0, t0
	addi s2, s2, 1
	li t0, 11
	beq s2, t0, decode_char
	slli s0, s0, 1
	j new_bar
	
decode_char:			# sprawdza czy znaleziony znak to jakiœ kod startu lub stopu
	li t0, 0x684
	beq s0, t0, new_char
	li t0, 0x690
	beq s0, t0, set_error
	li t0, 0x69C
	beq s0, t0, set_error
	li t0, 0x63A
	beq s0, t0, stop
	
	
	la s10, codes_array 	# s10 tablica
	xor t1, t1, t1 		# licznik iteracji
	xor s4, s4, s4
	
find_char:			# znajduje znak z tablicy
	lw s4, (s10)
	beq s0, s4, correct_char
	li t0, 106
	beq t1, t0, no_char_error
	
	addi s10, s10, 4
	addi t1, t1, 1
	j find_char
	
correct_char:
	mv s11, t1		# s11 to wartoœæ znaku np 33 dla "a"
	mv t2, t1		# to samo potrzebne do sumy kontrolnej
	addi t1, t1, 32
	li t5, 96
	blt t1, t5, next
	
	
sub_96:				#odejmuje 96 dla znaków od 64
	addi t1, t1 -96
	
next:				# wrzuca znak do result
	sb t1, (s8) 		# s8 wynik
	addi s8, s8, 1
	mul t2, t2, s7
	add s6, s6, t2 		# suma kontrolna
	j new_char
	
stop:				
	mv t0, s7		#usuwam z sumy kontrolnej wartoœæ sumy kontrolnej
	addi t0, t0, -1
	mul t0, t0, s11
	sub s6, s6, t0
	li t0, 103
	remu s6, s6, t0
	bne s6, s11, bad_control_sum
	
exit_succ:			
	addi s8, s8, -1
	sb zero, (s8)
	la a0, result
	li a7, 4
	ecall
	
	
exit:
	li a7, 10
	ecall
	
	
no_barcode_in_bmp:
	la a0, no_bar
	li a7, 4
	ecall
	j exit
	
set_error:
	la a0,	set_B
	li a7, 4
	ecall
	j exit
	
no_char_error:
	la a0,	no_char
	li a7, 4
	ecall
	j exit
	
bad_control_sum:
	la a0,	bad_ctrl
	li a7, 4
	ecall
	j exit
	

	
	
	
	
#=========================================================

get_pixel:
#parameters:
#	a0 - x coordinate
#	a1 - y coordinate - (0,0) - bottom left corner
#return value:
#	a0 - 0RGB - pixel color
	## dodane przeze mnie
	mv a0, s1
	mv a1, s3
	##
	la t1, image		#adress of file offset to pixel array
	addi t1,t1,10
	lhu t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2		#adress of pixel array in $t2
	
	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 		#t1= y*BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0		#$t3= 3*x
	add t1, t1, t3		#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1	#pixel address
	
	#get color
	lbu a0,(t2)		#load B
	lbu t1,1(t2)		#load G
	slli t1,t1,8
	or a0, a0, t1
	lbu t1,2(t2)		#load R
	slli t1,t1,16
	or a0, a0, t1
	
	jr ra
	
