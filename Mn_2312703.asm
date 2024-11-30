.data
	points_string:    .asciiz "So diem nam trong hinh tron: "
    	pi_string:        .asciiz "\nSo PI tinh duoc: "
    	so_50000:	  .asciiz "/50000"
    	file_name:        .asciiz "PI.TXT"
    	endl:		  .asciiz "\n"
    	dot:		  .asciiz "."
    	buffer1: 	  .space 32  # Luu so m
	buffer2: 	  .space 32  # Luu phan nguyen cua so PI
	buffer3: 	  .space 32  # Luu phan thap phan cua so PI
.text
main:	
	# Thiet lap seed ngau nhien
	li 	$v0, 30  # syscall 30 lay thoi gian hien tai va luu vao $a0 (low order/genID) va $a1 (high order/seed)
	syscall
	move 	$t0, $a0  # Luu du lieu $a0 vao $t0
	
	li 	$v0, 40  # syscall 40 de set seed theo thoi gian
	li	$a0, 0  # Set RNG ID thanh 0
	add 	$a1, $t0, $zero  # Set Random seed thanh gia tri tai $t0
	syscall

	# Thiet lap cac bien duoc su dung trong chuong trinh
	li 	$s0, 0  # Bien dem so diem trong hinh tron (m)
	li 	$s1, 0  # Bien dem vong lap (so diem duoc phat)
	li 	$s2, 50000  # Bien kiem tra vong lap (tong so diem duoc phat)
	
loop:
	beq 	$s1, $s2, calculate_pi  # Kiem tra so lan lap, neu du 50000 lan thi bat dau tinh so pi
	
	# Sinh so ngau nhien cho x luu o $f0 ===========================================================
	li 	$v0, 42  # Tao so int random va luu trong $a0
	li	$a0, 0  # Dat RNG ID thanh 0
	li 	$a1, 10000  # Dat upper bound la 10000 (khong bao gom 10000)
    	syscall
    	
    	# Doi int luu o $a0 thanh float va luu o $f1
    	move	$t1, $a0  # Chuyen du lieu tu $a0 vao $t1
    	mtc1 	$t1, $f1  # Dat so int vao thanh ghi FP $f1
    	cvt.s.w	$f1, $f1  # Doi int thanh floating point
    	
    	# Chuyen so ve ti le 1:10000 (0;1)
    	li 	$t1, 10000  # Dat $t1 thanh 10000 de chia
    	mtc1 	$t1, $f2  # Dat int vao thanh ghi FP $f2
    	cvt.s.w	$f2, $f2  # Doi 10000 o thanh ghi $f2 thanh FP
    	div.s 	$f0, $f1, $f2  # $f0 = $f1 / $f2
    	# Sinh so ngau nhien cho x END =================================================================
    	
    	# Sinh so ngau nhien cho y luu o $f3 ===========================================================
	li 	$v0, 42  # Tao so int random va luu trong $a0
	li	$a0, 0  # Dat RNG ID thanh 0
	li 	$a1, 10000  # Dat upper bound la 10000 (khong bao gom 10000)
    	syscall
    	
    	# Doi int luu o $a0 thanh float va luu o $f4
    	move	$t1, $a0  # Chuyen du lieu tu $a0 vao $t1
    	mtc1 	$t1, $f4  # Dat so int vao thanh ghi FP $f4
    	cvt.s.w	$f4, $f4  # Doi int thanh floating point
    	
    	# Chuyen so ve ti le 1:10000 (0;1)
    	li 	$t1, 10000  # Dat $t1 thanh 10000 de chia
    	mtc1 	$t1, $f5  # Dat 100 vao thanh ghi FP $f5
    	cvt.s.w	$f5, $f5  # Doi int o thanh ghi $f5 thanh FP
    	div.s 	$f3, $f4, $f5  # $f3 = $f4 / $f5
    	# Sinh so ngau nhien cho y END =================================================================
    	
    	# Tinh xem diem (x,y) co nam trong hinh tron khong =============================================
    	# Tinh d_ZI^2 = (x - 0.5)^2 + (y - 0.5)^2 la khoang cach tu diem Z(x,y) toi tam I(0.5,0.5) binh phuong
    	# Z nam tron hinh tron neu 0 <= d_ZI^2 < 0.5^2
    	
    	# Gan gia tri 0.5 vao $f6
    	li 	$t6, 1
    	li 	$t7, 2
    	mtc1 	$t6, $f7  # Dat so int vao thanh ghi FP $f7
    	mtc1 	$t7, $f8  # Dat so int vao thanh ghi FP $f8
    	cvt.s.w	$f7, $f7  # Doi int o thanh ghi $f7 thanh FP
   	cvt.s.w	$f8, $f8  # Doi int o thanh ghi $f8 thanh FP
    	div.s 	$f6, $f7, $f8  # $f6 = $f7 / $f8 = 0.5
    	
    	# Tinh d_ZI va luu o thanh ghi FP $f9
	sub.s	$f0, $f0, $f6  # x - 0.5
	mul.s	$f0, $f0, $f0  # (x - 0.5)*(x - 0.5)
	sub.s	$f3, $f3, $f6  # y - 0.5
	mul.s	$f3, $f3, $f3  # (y - 0.5)*(y - 0.5)
	add.s	$f9, $f0, $f3  # (x - 0.5)*(x - 0.5) + (y - 0.5)*(y - 0.5)
	
	# So sanh d_ZI^2 ($f9) voi 0.25 ($f10)
	# Gan gia tri 0.25 vao $f10
    	div.s 	$f10, $f6, $f8  # $f10 = $f6 / $f8 = 0.25
    	c.lt.s 	$f9, $f10  # Neu $f9 < $f10 thi dat flag la True
    	bc1t 	inside_circle  # Di toi inside_circle neu flag la true de tang bien dem
    	# Tinh xem diem (x,y) co nam trong hinh tron khong END =========================================
    	
	addi 	$s1, $s1, 1        # Tiep tuc kiem tra diem tiep theo
    	j loop
inside_circle:
	addi 	$s0, $s0, 1        # Tang so diem nam trong hinh tron
    	addi 	$s1, $s1, 1        # Tiep tuc kiem tra diem tiep theo
    	j loop
	
calculate_pi:
	# TODO
	mtc1 	$s0, $f0  # Dat so int m vao thanh ghi FP $f0
    	cvt.s.w	$f0, $f0  # Doi int m thanh floating point
    	
    	mtc1 	$s2, $f1  # Dat so int 50000 vao thanh ghi FP $f1
    	cvt.s.w	$f1, $f1  # Doi int m thanh floating point
	
	div.s	$f2, $f0, $f1  # $f2 = $f0 / $f1 = m / 50000
	
	li 	$t0, 4  # Dat $f0 = 4
	mtc1 	$t0, $f3  # Dat so int 4 vao thanh ghi FP $f3
    	cvt.s.w	$f3, $f3  # Doi int 4 thanh floating point
    	
    	mul.s	$f4, $f3, $f2  # PI = 4 * (m / n)

# Viet dap an vao file PI.TXT =====================================================================
# Chia so PI thanh 2 phan: phan nguyen va phan so le sau dau cham. Lay phan nguyen bang cach chuyen so PI ve dang immediate,
# chuyen phan le sau sau cham sang immediate bang cach lay so PI tru di 3 va nhan 1000000
# B1: copy so PI dang o thanh ghi $f4 vao thanh ghi $f2
mov.s 	$f2, $f4
# B2: chuyen so PI o thanh ghi $f4 thanh immediate và luu o thanh ghi $s3
cvt.w.s	$f5, $f4  # Chuyen so FP thanh so nguyen
mfc1 	$s3, $f5  # Luu phan nguyen tai thanh ghi $s3
# B3: tru so PI cho 3, nhan voi 1000000
li      $t1, 3  # Luu so 3 tai thanh ghi $t1    
mtc1    $t1, $f0  # Chuyen so 3 vao thanh ghi $f0
cvt.s.w $f0, $f0  # Chuyen so 3 thanh so so thuc dau cham dong
sub.s   $f2, $f2, $f0  # PI - 3

li      $t1, 1000000  # Luu so 1000000 tai thanh ghi $t1    
mtc1    $t1, $f0  # Chuyen so 1000000 vao thanh ghi $f0
cvt.s.w $f0, $f0  # Chuyen so 1000000 thanh so so thuc dau cham dong
mul.s 	$f2, $f2, $f0  # PI = PI*1000000
# B4: chuyen phan thap phan o thanh ghi $f2 thanh immediate và luu o thanh ghi $s4
cvt.w.s	$f18, $f2  # Chuyen so FP thanh so nguyen
mfc1 	$s4, $f18  # Luu phan nguyen tai thanh ghi $s4
# B5: mo file
li 	$v0,13           
la 	$a0,file_name
li 	$a1,1  # File flag = write
syscall
move 	$s6,$v0  # Luu file descriptor

# B6: Ghi vao file
li $v0, 15  # write_file syscall 15
move $a0, $s6  # File descriptor (file_name)
la $a1, points_string  # In "So diem nam trong hinh tron: "
li $a2, 29
syscall

move $a0, $s0
la   $a1, buffer1 
jal to_string
li   $v0, 15            # syscall 15: write to file
move $a0, $s6           # file descriptor
la   $a1, buffer1        # ??a ch? c?a chu?i c?n ghi vào file
li   $a2, 5            # S? l??ng byte c?n ghi (kích th??c b? ??m)
syscall

li $v0, 15  # write_file syscall 15
move $a0, $s6  # File descriptor (file_name)
la $a1, so_50000  # In "/50000"
li $a2, 7
syscall

li $v0, 15  # write_file syscall 15
move $a0, $s6  # File descriptor (file_name)
la $a1, pi_string  # In "\nSo PI tinh duoc: "
li $a2, 19
syscall

move $a0, $s3
la   $a1, buffer2 
jal to_string
li   $v0, 15            # syscall 15: write to file
move $a0, $s6           # file descriptor
la   $a1, buffer2        # ??a ch? c?a chu?i c?n ghi vào file
li   $a2, 1            # S? l??ng byte c?n ghi (kích th??c b? ??m)
syscall

li $v0, 15  # write_file syscall 15
move $a0, $s6  # File descriptor (file_name)
la $a1, dot  # In "."
li $a2, 1
syscall

move $a0, $s4
la   $a1, buffer3 
jal to_string
li   $v0, 15            # syscall 15: write to file
move $a0, $s6           # file descriptor
la   $a1, buffer3        # ??a ch? c?a chu?i c?n ghi vào file
li   $a2, 5            # S? l??ng byte c?n ghi (kích th??c b? ??m)
syscall

# B7: Dong file
li $v0, 16
syscall
# Viet dap an vao file PI.TXT =====================================================================

# Ket thuc chuong trinh
li 	$v0, 10
syscall

# Ham to_string ========================================================================================
to_string:
    bnez $a0, to_string.non_zero  # Neu gia tri $a0 khong phai 0, chuyen sang xuly tiep
    nop
    li   $t3, '0'                 # Dat ky tu '0' vao thanh ghi $t3
    sb   $t3, 0($a1)              # Ghi '0' vao bo dem tai vi tri $a1
    sb   $zero, 1($a1)            # Them ky tu NULL de ket thuc chuoi
    li   $v1, 1                   # Tra ve 1, so ky tu da ghi vao chuoi
    jr   $ra

to_string.non_zero:
    addi $t4, $zero, 10           # Xac dinh gia tri chia cho 10
    li   $v1, 0                    # Khoi tao bien dem so ky tu da ghi la 0
    
    bgtz $a0, to_string.recurr    # Neu gia tri $a0 lon hon 0, goi de quy
    nop
    li   $t5, '-'                  # Dat ky tu '-' vao $t5
    sb   $t5, 0($a1)               # Ghi dau '-' vao bo dem
    addi $v1, $v1, 1               # Tang bien dem so ky tu da ghi
    neg  $a0, $a0                  # Thay doi dau cua so

to_string.recurr:
    addi $sp, $sp, -24             # Cap phat bo nho cho stack
    sw   $fp, 8($sp)               # Luu gia tri thanh ghi $fp vao stack
    addi $fp, $sp, 8               # Cap nhat con tro stack frame
    sw   $a0, 4($fp)               # Luu tham so $a0 vao stack
    sw   $a1, 8($fp)               # Luu tham so $a1 vao stack
    sw   $ra, -4($fp)              # Luu return address vao stack
    sw   $s2, -8($fp)              # Luu thanh ghi $s2 vao stack
    sw   $s3, -12($fp)             # Luu thanh ghi $s3 vao stack

    div  $a0, $t4                  # Thuc hien phep chia o thanh ghi $a0 cho 10
    mflo $s2                       # Luu thuong vao thanh ghi $s2
    mfhi $s3                       # Luu so du vao thanh ghi $s3
    beqz $s2, to_string.write 

    move $a0, $s2         
    jal to_string.recurr
    nop

to_string.write:
    add  $t6, $a1, $v1             # Tinh toan vi tri trong bo dem
    addi $v1, $v1, 1               # Tang bien dem so ky tu da ghi
    addi $t7, $s3, 0x30            # Chuyen du thanh ky tu ASCII
    sb   $t7, 0($t6)               # Ghi so du vao bo dem
    sb   $zero, 1($t6)             # Ket thuc chuoi bang ky tu '\0'

to_string.exit:
    lw   $a1, 8($fp)               # Phuc hoi gia tri o thanh ghi $a1
    lw   $a0, 4($fp)               # Phuc hoi gia tri o thanh ghi $a0
    lw   $ra, -4($fp)              # Phuc hoi return address
    lw   $s2, -8($fp)              # Phuc hoi gia tri o thanh ghi $s2
    lw   $s3, -12($fp)             # Phuc hoi gia tri o thanh ghi $s3
    lw   $fp, 8($sp)               # Phuc hoi gia tri o thanh ghi $fp
    addi $sp, $sp, 24              # Hoan tra bo nho da cap phat
    jr   $ra                       # Quay lai
# Ham to_string END ====================================================================================