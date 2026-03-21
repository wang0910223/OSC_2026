
kernel.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000000200000 <_start>:
  200000:	00002297          	auipc	t0,0x2
  200004:	b3028293          	addi	t0,t0,-1232 # 201b30 <dtb_addr>
  200008:	00002317          	auipc	t1,0x2
  20000c:	bd030313          	addi	t1,t1,-1072 # 201bd8 <__bss_end>

0000000000200010 <_clear_bss>:
  200010:	0062d663          	bge	t0,t1,20001c <_bss_done>
  200014:	0002b023          	sd	zero,0(t0)
  200018:	02a1                	addi	t0,t0,8
  20001a:	bfdd                	j	200010 <_clear_bss>

000000000020001c <_bss_done>:
  20001c:	00006117          	auipc	sp,0x6
  200020:	bc410113          	addi	sp,sp,-1084 # 205be0 <__stack_top>
  200024:	4a5000ef          	jal	200cc8 <main>

0000000000200028 <hex_to_ul>:
  200028:	7139                	addi	sp,sp,-64
  20002a:	fc22                	sd	s0,56(sp)
  20002c:	0080                	addi	s0,sp,64
  20002e:	fca43423          	sd	a0,-56(s0)
  200032:	87ae                	mv	a5,a1
  200034:	fcf42223          	sw	a5,-60(s0)
  200038:	fe043423          	sd	zero,-24(s0)
  20003c:	fe042223          	sw	zero,-28(s0)
  200040:	a0e1                	j	200108 <hex_to_ul+0xe0>
  200042:	fe442783          	lw	a5,-28(s0)
  200046:	fc843703          	ld	a4,-56(s0)
  20004a:	97ba                	add	a5,a5,a4
  20004c:	0007c783          	lbu	a5,0(a5)
  200050:	fcf40ba3          	sb	a5,-41(s0)
  200054:	fd744783          	lbu	a5,-41(s0)
  200058:	0ff7f713          	zext.b	a4,a5
  20005c:	02f00793          	li	a5,47
  200060:	02e7f363          	bgeu	a5,a4,200086 <hex_to_ul+0x5e>
  200064:	fd744783          	lbu	a5,-41(s0)
  200068:	0ff7f713          	zext.b	a4,a5
  20006c:	03900793          	li	a5,57
  200070:	00e7eb63          	bltu	a5,a4,200086 <hex_to_ul+0x5e>
  200074:	fd744783          	lbu	a5,-41(s0)
  200078:	2781                	sext.w	a5,a5
  20007a:	fd07879b          	addiw	a5,a5,-48
  20007e:	2781                	sext.w	a5,a5
  200080:	fcf43c23          	sd	a5,-40(s0)
  200084:	a0ad                	j	2000ee <hex_to_ul+0xc6>
  200086:	fd744783          	lbu	a5,-41(s0)
  20008a:	0ff7f713          	zext.b	a4,a5
  20008e:	06000793          	li	a5,96
  200092:	02e7f363          	bgeu	a5,a4,2000b8 <hex_to_ul+0x90>
  200096:	fd744783          	lbu	a5,-41(s0)
  20009a:	0ff7f713          	zext.b	a4,a5
  20009e:	06600793          	li	a5,102
  2000a2:	00e7eb63          	bltu	a5,a4,2000b8 <hex_to_ul+0x90>
  2000a6:	fd744783          	lbu	a5,-41(s0)
  2000aa:	2781                	sext.w	a5,a5
  2000ac:	fa97879b          	addiw	a5,a5,-87
  2000b0:	2781                	sext.w	a5,a5
  2000b2:	fcf43c23          	sd	a5,-40(s0)
  2000b6:	a825                	j	2000ee <hex_to_ul+0xc6>
  2000b8:	fd744783          	lbu	a5,-41(s0)
  2000bc:	0ff7f713          	zext.b	a4,a5
  2000c0:	04000793          	li	a5,64
  2000c4:	02e7f363          	bgeu	a5,a4,2000ea <hex_to_ul+0xc2>
  2000c8:	fd744783          	lbu	a5,-41(s0)
  2000cc:	0ff7f713          	zext.b	a4,a5
  2000d0:	04600793          	li	a5,70
  2000d4:	00e7eb63          	bltu	a5,a4,2000ea <hex_to_ul+0xc2>
  2000d8:	fd744783          	lbu	a5,-41(s0)
  2000dc:	2781                	sext.w	a5,a5
  2000de:	fc97879b          	addiw	a5,a5,-55
  2000e2:	2781                	sext.w	a5,a5
  2000e4:	fcf43c23          	sd	a5,-40(s0)
  2000e8:	a019                	j	2000ee <hex_to_ul+0xc6>
  2000ea:	fc043c23          	sd	zero,-40(s0)
  2000ee:	fe843783          	ld	a5,-24(s0)
  2000f2:	0792                	slli	a5,a5,0x4
  2000f4:	fd843703          	ld	a4,-40(s0)
  2000f8:	8fd9                	or	a5,a5,a4
  2000fa:	fef43423          	sd	a5,-24(s0)
  2000fe:	fe442783          	lw	a5,-28(s0)
  200102:	2785                	addiw	a5,a5,1
  200104:	fef42223          	sw	a5,-28(s0)
  200108:	fe442783          	lw	a5,-28(s0)
  20010c:	873e                	mv	a4,a5
  20010e:	fc442783          	lw	a5,-60(s0)
  200112:	2701                	sext.w	a4,a4
  200114:	2781                	sext.w	a5,a5
  200116:	f2f746e3          	blt	a4,a5,200042 <hex_to_ul+0x1a>
  20011a:	fe843783          	ld	a5,-24(s0)
  20011e:	853e                	mv	a0,a5
  200120:	7462                	ld	s0,56(sp)
  200122:	6121                	addi	sp,sp,64
  200124:	8082                	ret

0000000000200126 <align4>:
  200126:	1101                	addi	sp,sp,-32
  200128:	ec22                	sd	s0,24(sp)
  20012a:	1000                	addi	s0,sp,32
  20012c:	fea43423          	sd	a0,-24(s0)
  200130:	fe843783          	ld	a5,-24(s0)
  200134:	078d                	addi	a5,a5,3
  200136:	9bf1                	andi	a5,a5,-4
  200138:	853e                	mv	a0,a5
  20013a:	6462                	ld	s0,24(sp)
  20013c:	6105                	addi	sp,sp,32
  20013e:	8082                	ret

0000000000200140 <cpio_strcmp>:
  200140:	1101                	addi	sp,sp,-32
  200142:	ec22                	sd	s0,24(sp)
  200144:	1000                	addi	s0,sp,32
  200146:	fea43423          	sd	a0,-24(s0)
  20014a:	feb43023          	sd	a1,-32(s0)
  20014e:	a819                	j	200164 <cpio_strcmp+0x24>
  200150:	fe843783          	ld	a5,-24(s0)
  200154:	0785                	addi	a5,a5,1
  200156:	fef43423          	sd	a5,-24(s0)
  20015a:	fe043783          	ld	a5,-32(s0)
  20015e:	0785                	addi	a5,a5,1
  200160:	fef43023          	sd	a5,-32(s0)
  200164:	fe843783          	ld	a5,-24(s0)
  200168:	0007c783          	lbu	a5,0(a5)
  20016c:	c385                	beqz	a5,20018c <cpio_strcmp+0x4c>
  20016e:	fe043783          	ld	a5,-32(s0)
  200172:	0007c783          	lbu	a5,0(a5)
  200176:	cb99                	beqz	a5,20018c <cpio_strcmp+0x4c>
  200178:	fe843783          	ld	a5,-24(s0)
  20017c:	0007c703          	lbu	a4,0(a5)
  200180:	fe043783          	ld	a5,-32(s0)
  200184:	0007c783          	lbu	a5,0(a5)
  200188:	fcf704e3          	beq	a4,a5,200150 <cpio_strcmp+0x10>
  20018c:	fe843783          	ld	a5,-24(s0)
  200190:	0007c783          	lbu	a5,0(a5)
  200194:	0007871b          	sext.w	a4,a5
  200198:	fe043783          	ld	a5,-32(s0)
  20019c:	0007c783          	lbu	a5,0(a5)
  2001a0:	2781                	sext.w	a5,a5
  2001a2:	40f707bb          	subw	a5,a4,a5
  2001a6:	2781                	sext.w	a5,a5
  2001a8:	853e                	mv	a0,a5
  2001aa:	6462                	ld	s0,24(sp)
  2001ac:	6105                	addi	sp,sp,32
  2001ae:	8082                	ret

00000000002001b0 <cpio_ls>:
  2001b0:	7119                	addi	sp,sp,-128
  2001b2:	fc86                	sd	ra,120(sp)
  2001b4:	f8a2                	sd	s0,112(sp)
  2001b6:	f4a6                	sd	s1,104(sp)
  2001b8:	0100                	addi	s0,sp,128
  2001ba:	f8a43423          	sd	a0,-120(s0)
  2001be:	fc043823          	sd	zero,-48(s0)
  2001c2:	f8843783          	ld	a5,-120(s0)
  2001c6:	fcf43c23          	sd	a5,-40(s0)
  2001ca:	fd843783          	ld	a5,-40(s0)
  2001ce:	fcf43423          	sd	a5,-56(s0)
  2001d2:	fc843783          	ld	a5,-56(s0)
  2001d6:	0007c783          	lbu	a5,0(a5)
  2001da:	873e                	mv	a4,a5
  2001dc:	03000793          	li	a5,48
  2001e0:	04f71663          	bne	a4,a5,20022c <cpio_ls+0x7c>
  2001e4:	fc843783          	ld	a5,-56(s0)
  2001e8:	0017c783          	lbu	a5,1(a5)
  2001ec:	873e                	mv	a4,a5
  2001ee:	03700793          	li	a5,55
  2001f2:	02f71d63          	bne	a4,a5,20022c <cpio_ls+0x7c>
  2001f6:	fc843783          	ld	a5,-56(s0)
  2001fa:	0027c783          	lbu	a5,2(a5)
  2001fe:	873e                	mv	a4,a5
  200200:	03000793          	li	a5,48
  200204:	02f71463          	bne	a4,a5,20022c <cpio_ls+0x7c>
  200208:	fc843783          	ld	a5,-56(s0)
  20020c:	0037c783          	lbu	a5,3(a5)
  200210:	873e                	mv	a4,a5
  200212:	03700793          	li	a5,55
  200216:	00f71b63          	bne	a4,a5,20022c <cpio_ls+0x7c>
  20021a:	fc843783          	ld	a5,-56(s0)
  20021e:	0047c783          	lbu	a5,4(a5)
  200222:	873e                	mv	a4,a5
  200224:	03000793          	li	a5,48
  200228:	00f70963          	beq	a4,a5,20023a <cpio_ls+0x8a>
  20022c:	00001517          	auipc	a0,0x1
  200230:	5ac50513          	addi	a0,a0,1452 # 2017d8 <strcmp+0x7a>
  200234:	372010ef          	jal	2015a6 <uart_puts>
  200238:	a24d                	j	2003da <cpio_ls+0x22a>
  20023a:	fc843783          	ld	a5,-56(s0)
  20023e:	05e78793          	addi	a5,a5,94
  200242:	45a1                	li	a1,8
  200244:	853e                	mv	a0,a5
  200246:	de3ff0ef          	jal	200028 <hex_to_ul>
  20024a:	fca43023          	sd	a0,-64(s0)
  20024e:	fc843783          	ld	a5,-56(s0)
  200252:	03678793          	addi	a5,a5,54
  200256:	45a1                	li	a1,8
  200258:	853e                	mv	a0,a5
  20025a:	dcfff0ef          	jal	200028 <hex_to_ul>
  20025e:	faa43c23          	sd	a0,-72(s0)
  200262:	fd843783          	ld	a5,-40(s0)
  200266:	06e78793          	addi	a5,a5,110
  20026a:	faf43823          	sd	a5,-80(s0)
  20026e:	00001597          	auipc	a1,0x1
  200272:	58a58593          	addi	a1,a1,1418 # 2017f8 <strcmp+0x9a>
  200276:	fb043503          	ld	a0,-80(s0)
  20027a:	ec7ff0ef          	jal	200140 <cpio_strcmp>
  20027e:	87aa                	mv	a5,a0
  200280:	cb95                	beqz	a5,2002b4 <cpio_ls+0x104>
  200282:	fd043783          	ld	a5,-48(s0)
  200286:	0785                	addi	a5,a5,1
  200288:	fcf43823          	sd	a5,-48(s0)
  20028c:	fc043783          	ld	a5,-64(s0)
  200290:	06e78793          	addi	a5,a5,110
  200294:	853e                	mv	a0,a5
  200296:	e91ff0ef          	jal	200126 <align4>
  20029a:	84aa                	mv	s1,a0
  20029c:	fb843503          	ld	a0,-72(s0)
  2002a0:	e87ff0ef          	jal	200126 <align4>
  2002a4:	87aa                	mv	a5,a0
  2002a6:	97a6                	add	a5,a5,s1
  2002a8:	fd843703          	ld	a4,-40(s0)
  2002ac:	97ba                	add	a5,a5,a4
  2002ae:	fcf43c23          	sd	a5,-40(s0)
  2002b2:	bf21                	j	2001ca <cpio_ls+0x1a>
  2002b4:	0001                	nop
  2002b6:	00001517          	auipc	a0,0x1
  2002ba:	55250513          	addi	a0,a0,1362 # 201808 <strcmp+0xaa>
  2002be:	2e8010ef          	jal	2015a6 <uart_puts>
  2002c2:	fd043503          	ld	a0,-48(s0)
  2002c6:	39c010ef          	jal	201662 <uart_dec>
  2002ca:	00001517          	auipc	a0,0x1
  2002ce:	54650513          	addi	a0,a0,1350 # 201810 <strcmp+0xb2>
  2002d2:	2d4010ef          	jal	2015a6 <uart_puts>
  2002d6:	f8843783          	ld	a5,-120(s0)
  2002da:	fcf43c23          	sd	a5,-40(s0)
  2002de:	fd843783          	ld	a5,-40(s0)
  2002e2:	faf43423          	sd	a5,-88(s0)
  2002e6:	fa843783          	ld	a5,-88(s0)
  2002ea:	0007c783          	lbu	a5,0(a5)
  2002ee:	873e                	mv	a4,a5
  2002f0:	03000793          	li	a5,48
  2002f4:	0ef71363          	bne	a4,a5,2003da <cpio_ls+0x22a>
  2002f8:	fa843783          	ld	a5,-88(s0)
  2002fc:	0017c783          	lbu	a5,1(a5)
  200300:	873e                	mv	a4,a5
  200302:	03700793          	li	a5,55
  200306:	0cf71a63          	bne	a4,a5,2003da <cpio_ls+0x22a>
  20030a:	fa843783          	ld	a5,-88(s0)
  20030e:	0027c783          	lbu	a5,2(a5)
  200312:	873e                	mv	a4,a5
  200314:	03000793          	li	a5,48
  200318:	0cf71163          	bne	a4,a5,2003da <cpio_ls+0x22a>
  20031c:	fa843783          	ld	a5,-88(s0)
  200320:	0037c783          	lbu	a5,3(a5)
  200324:	873e                	mv	a4,a5
  200326:	03700793          	li	a5,55
  20032a:	0af71863          	bne	a4,a5,2003da <cpio_ls+0x22a>
  20032e:	fa843783          	ld	a5,-88(s0)
  200332:	0047c783          	lbu	a5,4(a5)
  200336:	873e                	mv	a4,a5
  200338:	03000793          	li	a5,48
  20033c:	08f71f63          	bne	a4,a5,2003da <cpio_ls+0x22a>
  200340:	fa843783          	ld	a5,-88(s0)
  200344:	05e78793          	addi	a5,a5,94
  200348:	45a1                	li	a1,8
  20034a:	853e                	mv	a0,a5
  20034c:	cddff0ef          	jal	200028 <hex_to_ul>
  200350:	faa43023          	sd	a0,-96(s0)
  200354:	fa843783          	ld	a5,-88(s0)
  200358:	03678793          	addi	a5,a5,54
  20035c:	45a1                	li	a1,8
  20035e:	853e                	mv	a0,a5
  200360:	cc9ff0ef          	jal	200028 <hex_to_ul>
  200364:	f8a43c23          	sd	a0,-104(s0)
  200368:	fd843783          	ld	a5,-40(s0)
  20036c:	06e78793          	addi	a5,a5,110
  200370:	f8f43823          	sd	a5,-112(s0)
  200374:	00001597          	auipc	a1,0x1
  200378:	48458593          	addi	a1,a1,1156 # 2017f8 <strcmp+0x9a>
  20037c:	f9043503          	ld	a0,-112(s0)
  200380:	dc1ff0ef          	jal	200140 <cpio_strcmp>
  200384:	87aa                	mv	a5,a0
  200386:	cba9                	beqz	a5,2003d8 <cpio_ls+0x228>
  200388:	f9843503          	ld	a0,-104(s0)
  20038c:	2d6010ef          	jal	201662 <uart_dec>
  200390:	00001517          	auipc	a0,0x1
  200394:	49050513          	addi	a0,a0,1168 # 201820 <strcmp+0xc2>
  200398:	20e010ef          	jal	2015a6 <uart_puts>
  20039c:	f9043503          	ld	a0,-112(s0)
  2003a0:	206010ef          	jal	2015a6 <uart_puts>
  2003a4:	00001517          	auipc	a0,0x1
  2003a8:	48450513          	addi	a0,a0,1156 # 201828 <strcmp+0xca>
  2003ac:	1fa010ef          	jal	2015a6 <uart_puts>
  2003b0:	fa043783          	ld	a5,-96(s0)
  2003b4:	06e78793          	addi	a5,a5,110
  2003b8:	853e                	mv	a0,a5
  2003ba:	d6dff0ef          	jal	200126 <align4>
  2003be:	84aa                	mv	s1,a0
  2003c0:	f9843503          	ld	a0,-104(s0)
  2003c4:	d63ff0ef          	jal	200126 <align4>
  2003c8:	87aa                	mv	a5,a0
  2003ca:	97a6                	add	a5,a5,s1
  2003cc:	fd843703          	ld	a4,-40(s0)
  2003d0:	97ba                	add	a5,a5,a4
  2003d2:	fcf43c23          	sd	a5,-40(s0)
  2003d6:	b721                	j	2002de <cpio_ls+0x12e>
  2003d8:	0001                	nop
  2003da:	70e6                	ld	ra,120(sp)
  2003dc:	7446                	ld	s0,112(sp)
  2003de:	74a6                	ld	s1,104(sp)
  2003e0:	6109                	addi	sp,sp,128
  2003e2:	8082                	ret

00000000002003e4 <cpio_cat>:
  2003e4:	711d                	addi	sp,sp,-96
  2003e6:	ec86                	sd	ra,88(sp)
  2003e8:	e8a2                	sd	s0,80(sp)
  2003ea:	1080                	addi	s0,sp,96
  2003ec:	faa43423          	sd	a0,-88(s0)
  2003f0:	fab43023          	sd	a1,-96(s0)
  2003f4:	fa843783          	ld	a5,-88(s0)
  2003f8:	fef43423          	sd	a5,-24(s0)
  2003fc:	fe843783          	ld	a5,-24(s0)
  200400:	fcf43c23          	sd	a5,-40(s0)
  200404:	fd843783          	ld	a5,-40(s0)
  200408:	0007c783          	lbu	a5,0(a5)
  20040c:	873e                	mv	a4,a5
  20040e:	03000793          	li	a5,48
  200412:	04f71663          	bne	a4,a5,20045e <cpio_cat+0x7a>
  200416:	fd843783          	ld	a5,-40(s0)
  20041a:	0017c783          	lbu	a5,1(a5)
  20041e:	873e                	mv	a4,a5
  200420:	03700793          	li	a5,55
  200424:	02f71d63          	bne	a4,a5,20045e <cpio_cat+0x7a>
  200428:	fd843783          	ld	a5,-40(s0)
  20042c:	0027c783          	lbu	a5,2(a5)
  200430:	873e                	mv	a4,a5
  200432:	03000793          	li	a5,48
  200436:	02f71463          	bne	a4,a5,20045e <cpio_cat+0x7a>
  20043a:	fd843783          	ld	a5,-40(s0)
  20043e:	0037c783          	lbu	a5,3(a5)
  200442:	873e                	mv	a4,a5
  200444:	03700793          	li	a5,55
  200448:	00f71b63          	bne	a4,a5,20045e <cpio_cat+0x7a>
  20044c:	fd843783          	ld	a5,-40(s0)
  200450:	0047c783          	lbu	a5,4(a5)
  200454:	873e                	mv	a4,a5
  200456:	03000793          	li	a5,48
  20045a:	00f70963          	beq	a4,a5,20046c <cpio_cat+0x88>
  20045e:	00001517          	auipc	a0,0x1
  200462:	37a50513          	addi	a0,a0,890 # 2017d8 <strcmp+0x7a>
  200466:	140010ef          	jal	2015a6 <uart_puts>
  20046a:	a8dd                	j	200560 <cpio_cat+0x17c>
  20046c:	fd843783          	ld	a5,-40(s0)
  200470:	05e78793          	addi	a5,a5,94
  200474:	45a1                	li	a1,8
  200476:	853e                	mv	a0,a5
  200478:	bb1ff0ef          	jal	200028 <hex_to_ul>
  20047c:	fca43823          	sd	a0,-48(s0)
  200480:	fd843783          	ld	a5,-40(s0)
  200484:	03678793          	addi	a5,a5,54
  200488:	45a1                	li	a1,8
  20048a:	853e                	mv	a0,a5
  20048c:	b9dff0ef          	jal	200028 <hex_to_ul>
  200490:	fca43423          	sd	a0,-56(s0)
  200494:	fe843783          	ld	a5,-24(s0)
  200498:	06e78793          	addi	a5,a5,110
  20049c:	fcf43023          	sd	a5,-64(s0)
  2004a0:	00001597          	auipc	a1,0x1
  2004a4:	35858593          	addi	a1,a1,856 # 2017f8 <strcmp+0x9a>
  2004a8:	fc043503          	ld	a0,-64(s0)
  2004ac:	c95ff0ef          	jal	200140 <cpio_strcmp>
  2004b0:	87aa                	mv	a5,a0
  2004b2:	c7d5                	beqz	a5,20055e <cpio_cat+0x17a>
  2004b4:	fd043783          	ld	a5,-48(s0)
  2004b8:	06e78793          	addi	a5,a5,110
  2004bc:	853e                	mv	a0,a5
  2004be:	c69ff0ef          	jal	200126 <align4>
  2004c2:	faa43c23          	sd	a0,-72(s0)
  2004c6:	fa043583          	ld	a1,-96(s0)
  2004ca:	fc043503          	ld	a0,-64(s0)
  2004ce:	c73ff0ef          	jal	200140 <cpio_strcmp>
  2004d2:	87aa                	mv	a5,a0
  2004d4:	e7bd                	bnez	a5,200542 <cpio_cat+0x15e>
  2004d6:	fe843703          	ld	a4,-24(s0)
  2004da:	fb843783          	ld	a5,-72(s0)
  2004de:	97ba                	add	a5,a5,a4
  2004e0:	faf43823          	sd	a5,-80(s0)
  2004e4:	fe043023          	sd	zero,-32(s0)
  2004e8:	a00d                	j	20050a <cpio_cat+0x126>
  2004ea:	fb043703          	ld	a4,-80(s0)
  2004ee:	fe043783          	ld	a5,-32(s0)
  2004f2:	97ba                	add	a5,a5,a4
  2004f4:	0007c783          	lbu	a5,0(a5)
  2004f8:	2781                	sext.w	a5,a5
  2004fa:	853e                	mv	a0,a5
  2004fc:	7c9000ef          	jal	2014c4 <uart_putc>
  200500:	fe043783          	ld	a5,-32(s0)
  200504:	0785                	addi	a5,a5,1
  200506:	fef43023          	sd	a5,-32(s0)
  20050a:	fe043703          	ld	a4,-32(s0)
  20050e:	fc843783          	ld	a5,-56(s0)
  200512:	fcf76ce3          	bltu	a4,a5,2004ea <cpio_cat+0x106>
  200516:	fc843783          	ld	a5,-56(s0)
  20051a:	cf89                	beqz	a5,200534 <cpio_cat+0x150>
  20051c:	fc843783          	ld	a5,-56(s0)
  200520:	17fd                	addi	a5,a5,-1
  200522:	fb043703          	ld	a4,-80(s0)
  200526:	97ba                	add	a5,a5,a4
  200528:	0007c783          	lbu	a5,0(a5)
  20052c:	873e                	mv	a4,a5
  20052e:	47a9                	li	a5,10
  200530:	04f70963          	beq	a4,a5,200582 <cpio_cat+0x19e>
  200534:	00001517          	auipc	a0,0x1
  200538:	2f450513          	addi	a0,a0,756 # 201828 <strcmp+0xca>
  20053c:	06a010ef          	jal	2015a6 <uart_puts>
  200540:	a089                	j	200582 <cpio_cat+0x19e>
  200542:	fc843503          	ld	a0,-56(s0)
  200546:	be1ff0ef          	jal	200126 <align4>
  20054a:	872a                	mv	a4,a0
  20054c:	fb843783          	ld	a5,-72(s0)
  200550:	97ba                	add	a5,a5,a4
  200552:	fe843703          	ld	a4,-24(s0)
  200556:	97ba                	add	a5,a5,a4
  200558:	fef43423          	sd	a5,-24(s0)
  20055c:	b545                	j	2003fc <cpio_cat+0x18>
  20055e:	0001                	nop
  200560:	00001517          	auipc	a0,0x1
  200564:	2d050513          	addi	a0,a0,720 # 201830 <strcmp+0xd2>
  200568:	03e010ef          	jal	2015a6 <uart_puts>
  20056c:	fa043503          	ld	a0,-96(s0)
  200570:	036010ef          	jal	2015a6 <uart_puts>
  200574:	00001517          	auipc	a0,0x1
  200578:	2b450513          	addi	a0,a0,692 # 201828 <strcmp+0xca>
  20057c:	02a010ef          	jal	2015a6 <uart_puts>
  200580:	a011                	j	200584 <cpio_cat+0x1a0>
  200582:	0001                	nop
  200584:	60e6                	ld	ra,88(sp)
  200586:	6446                	ld	s0,80(sp)
  200588:	6125                	addi	sp,sp,96
  20058a:	8082                	ret

000000000020058c <bswap_32>:
  20058c:	1101                	addi	sp,sp,-32
  20058e:	ec22                	sd	s0,24(sp)
  200590:	1000                	addi	s0,sp,32
  200592:	87aa                	mv	a5,a0
  200594:	fef42623          	sw	a5,-20(s0)
  200598:	fec42783          	lw	a5,-20(s0)
  20059c:	0187d79b          	srliw	a5,a5,0x18
  2005a0:	0007871b          	sext.w	a4,a5
  2005a4:	fec42783          	lw	a5,-20(s0)
  2005a8:	0087d79b          	srliw	a5,a5,0x8
  2005ac:	2781                	sext.w	a5,a5
  2005ae:	86be                	mv	a3,a5
  2005b0:	67c1                	lui	a5,0x10
  2005b2:	f0078793          	addi	a5,a5,-256 # ff00 <_start-0x1f0100>
  2005b6:	8ff5                	and	a5,a5,a3
  2005b8:	2781                	sext.w	a5,a5
  2005ba:	8fd9                	or	a5,a5,a4
  2005bc:	0007871b          	sext.w	a4,a5
  2005c0:	fec42783          	lw	a5,-20(s0)
  2005c4:	0087979b          	slliw	a5,a5,0x8
  2005c8:	2781                	sext.w	a5,a5
  2005ca:	86be                	mv	a3,a5
  2005cc:	00ff07b7          	lui	a5,0xff0
  2005d0:	8ff5                	and	a5,a5,a3
  2005d2:	2781                	sext.w	a5,a5
  2005d4:	8fd9                	or	a5,a5,a4
  2005d6:	0007871b          	sext.w	a4,a5
  2005da:	fec42783          	lw	a5,-20(s0)
  2005de:	0187979b          	slliw	a5,a5,0x18
  2005e2:	2781                	sext.w	a5,a5
  2005e4:	8fd9                	or	a5,a5,a4
  2005e6:	2781                	sext.w	a5,a5
  2005e8:	853e                	mv	a0,a5
  2005ea:	6462                	ld	s0,24(sp)
  2005ec:	6105                	addi	sp,sp,32
  2005ee:	8082                	ret

00000000002005f0 <align_32>:
  2005f0:	1101                	addi	sp,sp,-32
  2005f2:	ec22                	sd	s0,24(sp)
  2005f4:	1000                	addi	s0,sp,32
  2005f6:	fea43423          	sd	a0,-24(s0)
  2005fa:	fe843783          	ld	a5,-24(s0)
  2005fe:	078d                	addi	a5,a5,3 # ff0003 <__stack_top+0xdea423>
  200600:	9bf1                	andi	a5,a5,-4
  200602:	853e                	mv	a0,a5
  200604:	6462                	ld	s0,24(sp)
  200606:	6105                	addi	sp,sp,32
  200608:	8082                	ret

000000000020060a <node_name_match>:
  20060a:	1101                	addi	sp,sp,-32
  20060c:	ec22                	sd	s0,24(sp)
  20060e:	1000                	addi	s0,sp,32
  200610:	fea43423          	sd	a0,-24(s0)
  200614:	feb43023          	sd	a1,-32(s0)
  200618:	a0b9                	j	200666 <node_name_match+0x5c>
  20061a:	fe843783          	ld	a5,-24(s0)
  20061e:	0007c783          	lbu	a5,0(a5)
  200622:	cb91                	beqz	a5,200636 <node_name_match+0x2c>
  200624:	fe843783          	ld	a5,-24(s0)
  200628:	0007c783          	lbu	a5,0(a5)
  20062c:	873e                	mv	a4,a5
  20062e:	04000793          	li	a5,64
  200632:	00f71463          	bne	a4,a5,20063a <node_name_match+0x30>
  200636:	4781                	li	a5,0
  200638:	a8a9                	j	200692 <node_name_match+0x88>
  20063a:	fe843783          	ld	a5,-24(s0)
  20063e:	0007c703          	lbu	a4,0(a5)
  200642:	fe043783          	ld	a5,-32(s0)
  200646:	0007c783          	lbu	a5,0(a5)
  20064a:	00f70463          	beq	a4,a5,200652 <node_name_match+0x48>
  20064e:	4781                	li	a5,0
  200650:	a089                	j	200692 <node_name_match+0x88>
  200652:	fe843783          	ld	a5,-24(s0)
  200656:	0785                	addi	a5,a5,1
  200658:	fef43423          	sd	a5,-24(s0)
  20065c:	fe043783          	ld	a5,-32(s0)
  200660:	0785                	addi	a5,a5,1
  200662:	fef43023          	sd	a5,-32(s0)
  200666:	fe043783          	ld	a5,-32(s0)
  20066a:	0007c783          	lbu	a5,0(a5)
  20066e:	f7d5                	bnez	a5,20061a <node_name_match+0x10>
  200670:	fe843783          	ld	a5,-24(s0)
  200674:	0007c783          	lbu	a5,0(a5)
  200678:	cb91                	beqz	a5,20068c <node_name_match+0x82>
  20067a:	fe843783          	ld	a5,-24(s0)
  20067e:	0007c783          	lbu	a5,0(a5)
  200682:	873e                	mv	a4,a5
  200684:	04000793          	li	a5,64
  200688:	00f71463          	bne	a4,a5,200690 <node_name_match+0x86>
  20068c:	4785                	li	a5,1
  20068e:	a011                	j	200692 <node_name_match+0x88>
  200690:	4781                	li	a5,0
  200692:	853e                	mv	a0,a5
  200694:	6462                	ld	s0,24(sp)
  200696:	6105                	addi	sp,sp,32
  200698:	8082                	ret

000000000020069a <path_segment>:
  20069a:	715d                	addi	sp,sp,-80
  20069c:	e4a2                	sd	s0,72(sp)
  20069e:	0880                	addi	s0,sp,80
  2006a0:	fca43423          	sd	a0,-56(s0)
  2006a4:	87ae                	mv	a5,a1
  2006a6:	fac43c23          	sd	a2,-72(s0)
  2006aa:	fcf42223          	sw	a5,-60(s0)
  2006ae:	fc843783          	ld	a5,-56(s0)
  2006b2:	cb91                	beqz	a5,2006c6 <path_segment+0x2c>
  2006b4:	fc843783          	ld	a5,-56(s0)
  2006b8:	0007c783          	lbu	a5,0(a5)
  2006bc:	873e                	mv	a4,a5
  2006be:	02f00793          	li	a5,47
  2006c2:	00f70463          	beq	a4,a5,2006ca <path_segment+0x30>
  2006c6:	4781                	li	a5,0
  2006c8:	a055                	j	20076c <path_segment+0xd2>
  2006ca:	fc843783          	ld	a5,-56(s0)
  2006ce:	0785                	addi	a5,a5,1
  2006d0:	fef43423          	sd	a5,-24(s0)
  2006d4:	fe042223          	sw	zero,-28(s0)
  2006d8:	fe843783          	ld	a5,-24(s0)
  2006dc:	0007c783          	lbu	a5,0(a5)
  2006e0:	e399                	bnez	a5,2006e6 <path_segment+0x4c>
  2006e2:	4781                	li	a5,0
  2006e4:	a061                	j	20076c <path_segment+0xd2>
  2006e6:	fe843783          	ld	a5,-24(s0)
  2006ea:	fcf43c23          	sd	a5,-40(s0)
  2006ee:	a031                	j	2006fa <path_segment+0x60>
  2006f0:	fe843783          	ld	a5,-24(s0)
  2006f4:	0785                	addi	a5,a5,1
  2006f6:	fef43423          	sd	a5,-24(s0)
  2006fa:	fe843783          	ld	a5,-24(s0)
  2006fe:	0007c783          	lbu	a5,0(a5)
  200702:	cb91                	beqz	a5,200716 <path_segment+0x7c>
  200704:	fe843783          	ld	a5,-24(s0)
  200708:	0007c783          	lbu	a5,0(a5)
  20070c:	873e                	mv	a4,a5
  20070e:	02f00793          	li	a5,47
  200712:	fcf71fe3          	bne	a4,a5,2006f0 <path_segment+0x56>
  200716:	fe442783          	lw	a5,-28(s0)
  20071a:	873e                	mv	a4,a5
  20071c:	fc442783          	lw	a5,-60(s0)
  200720:	2701                	sext.w	a4,a4
  200722:	2781                	sext.w	a5,a5
  200724:	02f71063          	bne	a4,a5,200744 <path_segment+0xaa>
  200728:	fe843703          	ld	a4,-24(s0)
  20072c:	fd843783          	ld	a5,-40(s0)
  200730:	40f707b3          	sub	a5,a4,a5
  200734:	0007871b          	sext.w	a4,a5
  200738:	fb843783          	ld	a5,-72(s0)
  20073c:	c398                	sw	a4,0(a5)
  20073e:	fd843783          	ld	a5,-40(s0)
  200742:	a02d                	j	20076c <path_segment+0xd2>
  200744:	fe442783          	lw	a5,-28(s0)
  200748:	2785                	addiw	a5,a5,1
  20074a:	fef42223          	sw	a5,-28(s0)
  20074e:	fe843783          	ld	a5,-24(s0)
  200752:	0007c783          	lbu	a5,0(a5)
  200756:	873e                	mv	a4,a5
  200758:	02f00793          	li	a5,47
  20075c:	f6f71ee3          	bne	a4,a5,2006d8 <path_segment+0x3e>
  200760:	fe843783          	ld	a5,-24(s0)
  200764:	0785                	addi	a5,a5,1
  200766:	fef43423          	sd	a5,-24(s0)
  20076a:	b7bd                	j	2006d8 <path_segment+0x3e>
  20076c:	853e                	mv	a0,a5
  20076e:	6426                	ld	s0,72(sp)
  200770:	6161                	addi	sp,sp,80
  200772:	8082                	ret

0000000000200774 <path_depth>:
  200774:	7179                	addi	sp,sp,-48
  200776:	f422                	sd	s0,40(sp)
  200778:	1800                	addi	s0,sp,48
  20077a:	fca43c23          	sd	a0,-40(s0)
  20077e:	fd843783          	ld	a5,-40(s0)
  200782:	cb91                	beqz	a5,200796 <path_depth+0x22>
  200784:	fd843783          	ld	a5,-40(s0)
  200788:	0007c783          	lbu	a5,0(a5)
  20078c:	873e                	mv	a4,a5
  20078e:	02f00793          	li	a5,47
  200792:	00f70463          	beq	a4,a5,20079a <path_depth+0x26>
  200796:	57fd                	li	a5,-1
  200798:	a8a9                	j	2007f2 <path_depth+0x7e>
  20079a:	fd843783          	ld	a5,-40(s0)
  20079e:	0785                	addi	a5,a5,1
  2007a0:	0007c783          	lbu	a5,0(a5)
  2007a4:	e399                	bnez	a5,2007aa <path_depth+0x36>
  2007a6:	4781                	li	a5,0
  2007a8:	a0a9                	j	2007f2 <path_depth+0x7e>
  2007aa:	fe042623          	sw	zero,-20(s0)
  2007ae:	fd843783          	ld	a5,-40(s0)
  2007b2:	0785                	addi	a5,a5,1
  2007b4:	fef43023          	sd	a5,-32(s0)
  2007b8:	a025                	j	2007e0 <path_depth+0x6c>
  2007ba:	fe043783          	ld	a5,-32(s0)
  2007be:	0007c783          	lbu	a5,0(a5)
  2007c2:	873e                	mv	a4,a5
  2007c4:	02f00793          	li	a5,47
  2007c8:	00f71763          	bne	a4,a5,2007d6 <path_depth+0x62>
  2007cc:	fec42783          	lw	a5,-20(s0)
  2007d0:	2785                	addiw	a5,a5,1
  2007d2:	fef42623          	sw	a5,-20(s0)
  2007d6:	fe043783          	ld	a5,-32(s0)
  2007da:	0785                	addi	a5,a5,1
  2007dc:	fef43023          	sd	a5,-32(s0)
  2007e0:	fe043783          	ld	a5,-32(s0)
  2007e4:	0007c783          	lbu	a5,0(a5)
  2007e8:	fbe9                	bnez	a5,2007ba <path_depth+0x46>
  2007ea:	fec42783          	lw	a5,-20(s0)
  2007ee:	2785                	addiw	a5,a5,1
  2007f0:	2781                	sext.w	a5,a5
  2007f2:	853e                	mv	a0,a5
  2007f4:	7422                	ld	s0,40(sp)
  2007f6:	6145                	addi	sp,sp,48
  2007f8:	8082                	ret

00000000002007fa <dtb_set_addr>:
  2007fa:	1101                	addi	sp,sp,-32
  2007fc:	ec22                	sd	s0,24(sp)
  2007fe:	1000                	addi	s0,sp,32
  200800:	fea43423          	sd	a0,-24(s0)
  200804:	00001797          	auipc	a5,0x1
  200808:	32c78793          	addi	a5,a5,812 # 201b30 <dtb_addr>
  20080c:	fe843703          	ld	a4,-24(s0)
  200810:	e398                	sd	a4,0(a5)
  200812:	0001                	nop
  200814:	6462                	ld	s0,24(sp)
  200816:	6105                	addi	sp,sp,32
  200818:	8082                	ret

000000000020081a <dtb_getprop>:
  20081a:	7151                	addi	sp,sp,-240
  20081c:	f586                	sd	ra,232(sp)
  20081e:	f1a2                	sd	s0,224(sp)
  200820:	1980                	addi	s0,sp,240
  200822:	f2a43423          	sd	a0,-216(s0)
  200826:	f2b43023          	sd	a1,-224(s0)
  20082a:	f0c43c23          	sd	a2,-232(s0)
  20082e:	00001797          	auipc	a5,0x1
  200832:	30278793          	addi	a5,a5,770 # 201b30 <dtb_addr>
  200836:	639c                	ld	a5,0(a5)
  200838:	c799                	beqz	a5,200846 <dtb_getprop+0x2c>
  20083a:	f2843783          	ld	a5,-216(s0)
  20083e:	c781                	beqz	a5,200846 <dtb_getprop+0x2c>
  200840:	f2043783          	ld	a5,-224(s0)
  200844:	e399                	bnez	a5,20084a <dtb_getprop+0x30>
  200846:	4781                	li	a5,0
  200848:	acdd                	j	200b3e <dtb_getprop+0x324>
  20084a:	00001797          	auipc	a5,0x1
  20084e:	2e678793          	addi	a5,a5,742 # 201b30 <dtb_addr>
  200852:	639c                	ld	a5,0(a5)
  200854:	fcf43823          	sd	a5,-48(s0)
  200858:	fd043783          	ld	a5,-48(s0)
  20085c:	439c                	lw	a5,0(a5)
  20085e:	853e                	mv	a0,a5
  200860:	d2dff0ef          	jal	20058c <bswap_32>
  200864:	87aa                	mv	a5,a0
  200866:	2781                	sext.w	a5,a5
  200868:	873e                	mv	a4,a5
  20086a:	d00e07b7          	lui	a5,0xd00e0
  20086e:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <__stack_top+0xffffffffcfeda30d>
  200872:	00f70463          	beq	a4,a5,20087a <dtb_getprop+0x60>
  200876:	4781                	li	a5,0
  200878:	a4d9                	j	200b3e <dtb_getprop+0x324>
  20087a:	f2843503          	ld	a0,-216(s0)
  20087e:	ef7ff0ef          	jal	200774 <path_depth>
  200882:	87aa                	mv	a5,a0
  200884:	fcf42623          	sw	a5,-52(s0)
  200888:	fd043783          	ld	a5,-48(s0)
  20088c:	53dc                	lw	a5,36(a5)
  20088e:	853e                	mv	a0,a5
  200890:	cfdff0ef          	jal	20058c <bswap_32>
  200894:	87aa                	mv	a5,a0
  200896:	fcf42423          	sw	a5,-56(s0)
  20089a:	fd043783          	ld	a5,-48(s0)
  20089e:	479c                	lw	a5,8(a5)
  2008a0:	853e                	mv	a0,a5
  2008a2:	cebff0ef          	jal	20058c <bswap_32>
  2008a6:	87aa                	mv	a5,a0
  2008a8:	2781                	sext.w	a5,a5
  2008aa:	1782                	slli	a5,a5,0x20
  2008ac:	9381                	srli	a5,a5,0x20
  2008ae:	fd043703          	ld	a4,-48(s0)
  2008b2:	97ba                	add	a5,a5,a4
  2008b4:	fcf43023          	sd	a5,-64(s0)
  2008b8:	fd043783          	ld	a5,-48(s0)
  2008bc:	47dc                	lw	a5,12(a5)
  2008be:	853e                	mv	a0,a5
  2008c0:	ccdff0ef          	jal	20058c <bswap_32>
  2008c4:	87aa                	mv	a5,a0
  2008c6:	2781                	sext.w	a5,a5
  2008c8:	1782                	slli	a5,a5,0x20
  2008ca:	9381                	srli	a5,a5,0x20
  2008cc:	fd043703          	ld	a4,-48(s0)
  2008d0:	97ba                	add	a5,a5,a4
  2008d2:	faf43c23          	sd	a5,-72(s0)
  2008d6:	fc043783          	ld	a5,-64(s0)
  2008da:	fef43423          	sd	a5,-24(s0)
  2008de:	fc846783          	lwu	a5,-56(s0)
  2008e2:	fc043703          	ld	a4,-64(s0)
  2008e6:	97ba                	add	a5,a5,a4
  2008e8:	faf43823          	sd	a5,-80(s0)
  2008ec:	57fd                	li	a5,-1
  2008ee:	fef42223          	sw	a5,-28(s0)
  2008f2:	57fd                	li	a5,-1
  2008f4:	fef42023          	sw	a5,-32(s0)
  2008f8:	a41d                	j	200b1e <dtb_getprop+0x304>
  2008fa:	fe843783          	ld	a5,-24(s0)
  2008fe:	439c                	lw	a5,0(a5)
  200900:	853e                	mv	a0,a5
  200902:	c8bff0ef          	jal	20058c <bswap_32>
  200906:	87aa                	mv	a5,a0
  200908:	faf42623          	sw	a5,-84(s0)
  20090c:	fe843783          	ld	a5,-24(s0)
  200910:	0791                	addi	a5,a5,4
  200912:	fef43423          	sd	a5,-24(s0)
  200916:	fac42783          	lw	a5,-84(s0)
  20091a:	0007871b          	sext.w	a4,a5
  20091e:	4785                	li	a5,1
  200920:	10f71e63          	bne	a4,a5,200a3c <dtb_getprop+0x222>
  200924:	fe843783          	ld	a5,-24(s0)
  200928:	f8f43423          	sd	a5,-120(s0)
  20092c:	a031                	j	200938 <dtb_getprop+0x11e>
  20092e:	fe843783          	ld	a5,-24(s0)
  200932:	0785                	addi	a5,a5,1
  200934:	fef43423          	sd	a5,-24(s0)
  200938:	fe843783          	ld	a5,-24(s0)
  20093c:	0007c783          	lbu	a5,0(a5)
  200940:	f7fd                	bnez	a5,20092e <dtb_getprop+0x114>
  200942:	fe843783          	ld	a5,-24(s0)
  200946:	0785                	addi	a5,a5,1
  200948:	fef43423          	sd	a5,-24(s0)
  20094c:	fe843783          	ld	a5,-24(s0)
  200950:	853e                	mv	a0,a5
  200952:	c9fff0ef          	jal	2005f0 <align_32>
  200956:	87aa                	mv	a5,a0
  200958:	fef43423          	sd	a5,-24(s0)
  20095c:	fe442783          	lw	a5,-28(s0)
  200960:	2785                	addiw	a5,a5,1
  200962:	fef42223          	sw	a5,-28(s0)
  200966:	fe042783          	lw	a5,-32(s0)
  20096a:	2781                	sext.w	a5,a5
  20096c:	1a07d963          	bgez	a5,200b1e <dtb_getprop+0x304>
  200970:	fe442783          	lw	a5,-28(s0)
  200974:	2781                	sext.w	a5,a5
  200976:	eb89                	bnez	a5,200988 <dtb_getprop+0x16e>
  200978:	fcc42783          	lw	a5,-52(s0)
  20097c:	2781                	sext.w	a5,a5
  20097e:	1a079063          	bnez	a5,200b1e <dtb_getprop+0x304>
  200982:	fe042023          	sw	zero,-32(s0)
  200986:	aa61                	j	200b1e <dtb_getprop+0x304>
  200988:	fe442783          	lw	a5,-28(s0)
  20098c:	37fd                	addiw	a5,a5,-1
  20098e:	2781                	sext.w	a5,a5
  200990:	f7840713          	addi	a4,s0,-136
  200994:	863a                	mv	a2,a4
  200996:	85be                	mv	a1,a5
  200998:	f2843503          	ld	a0,-216(s0)
  20099c:	cffff0ef          	jal	20069a <path_segment>
  2009a0:	f8a43023          	sd	a0,-128(s0)
  2009a4:	f8043783          	ld	a5,-128(s0)
  2009a8:	16078b63          	beqz	a5,200b1e <dtb_getprop+0x304>
  2009ac:	f7842783          	lw	a5,-136(s0)
  2009b0:	0007869b          	sext.w	a3,a5
  2009b4:	03f00713          	li	a4,63
  2009b8:	00d75463          	bge	a4,a3,2009c0 <dtb_getprop+0x1a6>
  2009bc:	03f00793          	li	a5,63
  2009c0:	f6f42e23          	sw	a5,-132(s0)
  2009c4:	fc042e23          	sw	zero,-36(s0)
  2009c8:	a01d                	j	2009ee <dtb_getprop+0x1d4>
  2009ca:	fdc42783          	lw	a5,-36(s0)
  2009ce:	f8043703          	ld	a4,-128(s0)
  2009d2:	97ba                	add	a5,a5,a4
  2009d4:	0007c703          	lbu	a4,0(a5)
  2009d8:	fdc42783          	lw	a5,-36(s0)
  2009dc:	17c1                	addi	a5,a5,-16
  2009de:	97a2                	add	a5,a5,s0
  2009e0:	f4e78423          	sb	a4,-184(a5)
  2009e4:	fdc42783          	lw	a5,-36(s0)
  2009e8:	2785                	addiw	a5,a5,1
  2009ea:	fcf42e23          	sw	a5,-36(s0)
  2009ee:	fdc42783          	lw	a5,-36(s0)
  2009f2:	873e                	mv	a4,a5
  2009f4:	f7c42783          	lw	a5,-132(s0)
  2009f8:	2701                	sext.w	a4,a4
  2009fa:	2781                	sext.w	a5,a5
  2009fc:	fcf747e3          	blt	a4,a5,2009ca <dtb_getprop+0x1b0>
  200a00:	fdc42783          	lw	a5,-36(s0)
  200a04:	17c1                	addi	a5,a5,-16
  200a06:	97a2                	add	a5,a5,s0
  200a08:	f4078423          	sb	zero,-184(a5)
  200a0c:	f3840793          	addi	a5,s0,-200
  200a10:	85be                	mv	a1,a5
  200a12:	f8843503          	ld	a0,-120(s0)
  200a16:	bf5ff0ef          	jal	20060a <node_name_match>
  200a1a:	87aa                	mv	a5,a0
  200a1c:	10078163          	beqz	a5,200b1e <dtb_getprop+0x304>
  200a20:	fe442783          	lw	a5,-28(s0)
  200a24:	873e                	mv	a4,a5
  200a26:	fcc42783          	lw	a5,-52(s0)
  200a2a:	2701                	sext.w	a4,a4
  200a2c:	2781                	sext.w	a5,a5
  200a2e:	0ef71863          	bne	a4,a5,200b1e <dtb_getprop+0x304>
  200a32:	fe442783          	lw	a5,-28(s0)
  200a36:	fef42023          	sw	a5,-32(s0)
  200a3a:	a0d5                	j	200b1e <dtb_getprop+0x304>
  200a3c:	fac42783          	lw	a5,-84(s0)
  200a40:	0007871b          	sext.w	a4,a5
  200a44:	4789                	li	a5,2
  200a46:	02f71463          	bne	a4,a5,200a6e <dtb_getprop+0x254>
  200a4a:	fe042783          	lw	a5,-32(s0)
  200a4e:	873e                	mv	a4,a5
  200a50:	fe442783          	lw	a5,-28(s0)
  200a54:	2701                	sext.w	a4,a4
  200a56:	2781                	sext.w	a5,a5
  200a58:	00f71563          	bne	a4,a5,200a62 <dtb_getprop+0x248>
  200a5c:	57fd                	li	a5,-1
  200a5e:	fef42023          	sw	a5,-32(s0)
  200a62:	fe442783          	lw	a5,-28(s0)
  200a66:	37fd                	addiw	a5,a5,-1
  200a68:	fef42223          	sw	a5,-28(s0)
  200a6c:	a84d                	j	200b1e <dtb_getprop+0x304>
  200a6e:	fac42783          	lw	a5,-84(s0)
  200a72:	0007871b          	sext.w	a4,a5
  200a76:	478d                	li	a5,3
  200a78:	08f71b63          	bne	a4,a5,200b0e <dtb_getprop+0x2f4>
  200a7c:	fe843783          	ld	a5,-24(s0)
  200a80:	faf43023          	sd	a5,-96(s0)
  200a84:	fe843783          	ld	a5,-24(s0)
  200a88:	07a1                	addi	a5,a5,8
  200a8a:	fef43423          	sd	a5,-24(s0)
  200a8e:	fa043783          	ld	a5,-96(s0)
  200a92:	439c                	lw	a5,0(a5)
  200a94:	853e                	mv	a0,a5
  200a96:	af7ff0ef          	jal	20058c <bswap_32>
  200a9a:	87aa                	mv	a5,a0
  200a9c:	f8f42e23          	sw	a5,-100(s0)
  200aa0:	fa043783          	ld	a5,-96(s0)
  200aa4:	43dc                	lw	a5,4(a5)
  200aa6:	853e                	mv	a0,a5
  200aa8:	ae5ff0ef          	jal	20058c <bswap_32>
  200aac:	87aa                	mv	a5,a0
  200aae:	2781                	sext.w	a5,a5
  200ab0:	1782                	slli	a5,a5,0x20
  200ab2:	9381                	srli	a5,a5,0x20
  200ab4:	fb843703          	ld	a4,-72(s0)
  200ab8:	97ba                	add	a5,a5,a4
  200aba:	f8f43823          	sd	a5,-112(s0)
  200abe:	fe042783          	lw	a5,-32(s0)
  200ac2:	2781                	sext.w	a5,a5
  200ac4:	0207c563          	bltz	a5,200aee <dtb_getprop+0x2d4>
  200ac8:	f2043583          	ld	a1,-224(s0)
  200acc:	f9043503          	ld	a0,-112(s0)
  200ad0:	48f000ef          	jal	20175e <strcmp>
  200ad4:	87aa                	mv	a5,a0
  200ad6:	ef81                	bnez	a5,200aee <dtb_getprop+0x2d4>
  200ad8:	f1843783          	ld	a5,-232(s0)
  200adc:	c791                	beqz	a5,200ae8 <dtb_getprop+0x2ce>
  200ade:	f9c42703          	lw	a4,-100(s0)
  200ae2:	f1843783          	ld	a5,-232(s0)
  200ae6:	c398                	sw	a4,0(a5)
  200ae8:	fe843783          	ld	a5,-24(s0)
  200aec:	a889                	j	200b3e <dtb_getprop+0x324>
  200aee:	f9c46783          	lwu	a5,-100(s0)
  200af2:	fe843703          	ld	a4,-24(s0)
  200af6:	97ba                	add	a5,a5,a4
  200af8:	fef43423          	sd	a5,-24(s0)
  200afc:	fe843783          	ld	a5,-24(s0)
  200b00:	853e                	mv	a0,a5
  200b02:	aefff0ef          	jal	2005f0 <align_32>
  200b06:	87aa                	mv	a5,a0
  200b08:	fef43423          	sd	a5,-24(s0)
  200b0c:	a809                	j	200b1e <dtb_getprop+0x304>
  200b0e:	fac42783          	lw	a5,-84(s0)
  200b12:	0007871b          	sext.w	a4,a5
  200b16:	4791                	li	a5,4
  200b18:	00f71a63          	bne	a4,a5,200b2c <dtb_getprop+0x312>
  200b1c:	0001                	nop
  200b1e:	fe843703          	ld	a4,-24(s0)
  200b22:	fb043783          	ld	a5,-80(s0)
  200b26:	dcf76ae3          	bltu	a4,a5,2008fa <dtb_getprop+0xe0>
  200b2a:	a011                	j	200b2e <dtb_getprop+0x314>
  200b2c:	0001                	nop
  200b2e:	f1843783          	ld	a5,-232(s0)
  200b32:	c789                	beqz	a5,200b3c <dtb_getprop+0x322>
  200b34:	f1843783          	ld	a5,-232(s0)
  200b38:	0007a023          	sw	zero,0(a5)
  200b3c:	4781                	li	a5,0
  200b3e:	853e                	mv	a0,a5
  200b40:	70ae                	ld	ra,232(sp)
  200b42:	740e                	ld	s0,224(sp)
  200b44:	616d                	addi	sp,sp,240
  200b46:	8082                	ret

0000000000200b48 <dtb_get_reg>:
  200b48:	715d                	addi	sp,sp,-80
  200b4a:	e486                	sd	ra,72(sp)
  200b4c:	e0a2                	sd	s0,64(sp)
  200b4e:	0880                	addi	s0,sp,80
  200b50:	faa43c23          	sd	a0,-72(s0)
  200b54:	fc042623          	sw	zero,-52(s0)
  200b58:	fcc40793          	addi	a5,s0,-52
  200b5c:	863e                	mv	a2,a5
  200b5e:	00001597          	auipc	a1,0x1
  200b62:	cea58593          	addi	a1,a1,-790 # 201848 <strcmp+0xea>
  200b66:	fb843503          	ld	a0,-72(s0)
  200b6a:	cb1ff0ef          	jal	20081a <dtb_getprop>
  200b6e:	fea43423          	sd	a0,-24(s0)
  200b72:	fe843783          	ld	a5,-24(s0)
  200b76:	c799                	beqz	a5,200b84 <dtb_get_reg+0x3c>
  200b78:	fcc42783          	lw	a5,-52(s0)
  200b7c:	873e                	mv	a4,a5
  200b7e:	478d                	li	a5,3
  200b80:	00e7c463          	blt	a5,a4,200b88 <dtb_get_reg+0x40>
  200b84:	4781                	li	a5,0
  200b86:	a0b5                	j	200bf2 <dtb_get_reg+0xaa>
  200b88:	fe843783          	ld	a5,-24(s0)
  200b8c:	fef43023          	sd	a5,-32(s0)
  200b90:	fcc42783          	lw	a5,-52(s0)
  200b94:	873e                	mv	a4,a5
  200b96:	479d                	li	a5,7
  200b98:	04e7d363          	bge	a5,a4,200bde <dtb_get_reg+0x96>
  200b9c:	fe043783          	ld	a5,-32(s0)
  200ba0:	439c                	lw	a5,0(a5)
  200ba2:	853e                	mv	a0,a5
  200ba4:	9e9ff0ef          	jal	20058c <bswap_32>
  200ba8:	87aa                	mv	a5,a0
  200baa:	2781                	sext.w	a5,a5
  200bac:	1782                	slli	a5,a5,0x20
  200bae:	9381                	srli	a5,a5,0x20
  200bb0:	fcf43c23          	sd	a5,-40(s0)
  200bb4:	fe043783          	ld	a5,-32(s0)
  200bb8:	0791                	addi	a5,a5,4
  200bba:	439c                	lw	a5,0(a5)
  200bbc:	853e                	mv	a0,a5
  200bbe:	9cfff0ef          	jal	20058c <bswap_32>
  200bc2:	87aa                	mv	a5,a0
  200bc4:	2781                	sext.w	a5,a5
  200bc6:	1782                	slli	a5,a5,0x20
  200bc8:	9381                	srli	a5,a5,0x20
  200bca:	fcf43823          	sd	a5,-48(s0)
  200bce:	fd843783          	ld	a5,-40(s0)
  200bd2:	02079713          	slli	a4,a5,0x20
  200bd6:	fd043783          	ld	a5,-48(s0)
  200bda:	8fd9                	or	a5,a5,a4
  200bdc:	a819                	j	200bf2 <dtb_get_reg+0xaa>
  200bde:	fe043783          	ld	a5,-32(s0)
  200be2:	439c                	lw	a5,0(a5)
  200be4:	853e                	mv	a0,a5
  200be6:	9a7ff0ef          	jal	20058c <bswap_32>
  200bea:	87aa                	mv	a5,a0
  200bec:	2781                	sext.w	a5,a5
  200bee:	1782                	slli	a5,a5,0x20
  200bf0:	9381                	srli	a5,a5,0x20
  200bf2:	853e                	mv	a0,a5
  200bf4:	60a6                	ld	ra,72(sp)
  200bf6:	6406                	ld	s0,64(sp)
  200bf8:	6161                	addi	sp,sp,80
  200bfa:	8082                	ret

0000000000200bfc <dtb_load_initrd_addr>:
  200bfc:	7139                	addi	sp,sp,-64
  200bfe:	fc06                	sd	ra,56(sp)
  200c00:	f822                	sd	s0,48(sp)
  200c02:	0080                	addi	s0,sp,64
  200c04:	fc042223          	sw	zero,-60(s0)
  200c08:	fc440793          	addi	a5,s0,-60
  200c0c:	863e                	mv	a2,a5
  200c0e:	00001597          	auipc	a1,0x1
  200c12:	c4258593          	addi	a1,a1,-958 # 201850 <strcmp+0xf2>
  200c16:	00001517          	auipc	a0,0x1
  200c1a:	c5250513          	addi	a0,a0,-942 # 201868 <strcmp+0x10a>
  200c1e:	bfdff0ef          	jal	20081a <dtb_getprop>
  200c22:	fea43423          	sd	a0,-24(s0)
  200c26:	fe843783          	ld	a5,-24(s0)
  200c2a:	cbd1                	beqz	a5,200cbe <dtb_load_initrd_addr+0xc2>
  200c2c:	fc442783          	lw	a5,-60(s0)
  200c30:	c7d9                	beqz	a5,200cbe <dtb_load_initrd_addr+0xc2>
  200c32:	fc442783          	lw	a5,-60(s0)
  200c36:	873e                	mv	a4,a5
  200c38:	479d                	li	a5,7
  200c3a:	04e7dd63          	bge	a5,a4,200c94 <dtb_load_initrd_addr+0x98>
  200c3e:	fe843783          	ld	a5,-24(s0)
  200c42:	fcf43c23          	sd	a5,-40(s0)
  200c46:	fd843783          	ld	a5,-40(s0)
  200c4a:	439c                	lw	a5,0(a5)
  200c4c:	853e                	mv	a0,a5
  200c4e:	93fff0ef          	jal	20058c <bswap_32>
  200c52:	87aa                	mv	a5,a0
  200c54:	2781                	sext.w	a5,a5
  200c56:	1782                	slli	a5,a5,0x20
  200c58:	9381                	srli	a5,a5,0x20
  200c5a:	fcf43823          	sd	a5,-48(s0)
  200c5e:	fd843783          	ld	a5,-40(s0)
  200c62:	0791                	addi	a5,a5,4
  200c64:	439c                	lw	a5,0(a5)
  200c66:	853e                	mv	a0,a5
  200c68:	925ff0ef          	jal	20058c <bswap_32>
  200c6c:	87aa                	mv	a5,a0
  200c6e:	2781                	sext.w	a5,a5
  200c70:	1782                	slli	a5,a5,0x20
  200c72:	9381                	srli	a5,a5,0x20
  200c74:	fcf43423          	sd	a5,-56(s0)
  200c78:	fd043783          	ld	a5,-48(s0)
  200c7c:	02079713          	slli	a4,a5,0x20
  200c80:	fc843783          	ld	a5,-56(s0)
  200c84:	8fd9                	or	a5,a5,a4
  200c86:	873e                	mv	a4,a5
  200c88:	00001797          	auipc	a5,0x1
  200c8c:	eb078793          	addi	a5,a5,-336 # 201b38 <cpio_addr>
  200c90:	e398                	sd	a4,0(a5)
  200c92:	a03d                	j	200cc0 <dtb_load_initrd_addr+0xc4>
  200c94:	fe843783          	ld	a5,-24(s0)
  200c98:	fef43023          	sd	a5,-32(s0)
  200c9c:	fe043783          	ld	a5,-32(s0)
  200ca0:	439c                	lw	a5,0(a5)
  200ca2:	853e                	mv	a0,a5
  200ca4:	8e9ff0ef          	jal	20058c <bswap_32>
  200ca8:	87aa                	mv	a5,a0
  200caa:	2781                	sext.w	a5,a5
  200cac:	1782                	slli	a5,a5,0x20
  200cae:	9381                	srli	a5,a5,0x20
  200cb0:	873e                	mv	a4,a5
  200cb2:	00001797          	auipc	a5,0x1
  200cb6:	e8678793          	addi	a5,a5,-378 # 201b38 <cpio_addr>
  200cba:	e398                	sd	a4,0(a5)
  200cbc:	a011                	j	200cc0 <dtb_load_initrd_addr+0xc4>
  200cbe:	0001                	nop
  200cc0:	70e2                	ld	ra,56(sp)
  200cc2:	7442                	ld	s0,48(sp)
  200cc4:	6121                	addi	sp,sp,64
  200cc6:	8082                	ret

0000000000200cc8 <main>:
  200cc8:	7179                	addi	sp,sp,-48
  200cca:	f406                	sd	ra,40(sp)
  200ccc:	f022                	sd	s0,32(sp)
  200cce:	1800                	addi	s0,sp,48
  200cd0:	87aa                	mv	a5,a0
  200cd2:	fcb43823          	sd	a1,-48(s0)
  200cd6:	fcf42e23          	sw	a5,-36(s0)
  200cda:	00001797          	auipc	a5,0x1
  200cde:	e6678793          	addi	a5,a5,-410 # 201b40 <boot_hart_id>
  200ce2:	fdc42703          	lw	a4,-36(s0)
  200ce6:	c398                	sw	a4,0(a5)
  200ce8:	fd043503          	ld	a0,-48(s0)
  200cec:	b0fff0ef          	jal	2007fa <dtb_set_addr>
  200cf0:	00001517          	auipc	a0,0x1
  200cf4:	b8050513          	addi	a0,a0,-1152 # 201870 <strcmp+0x112>
  200cf8:	e51ff0ef          	jal	200b48 <dtb_get_reg>
  200cfc:	fea43423          	sd	a0,-24(s0)
  200d00:	fe843783          	ld	a5,-24(s0)
  200d04:	eb89                	bnez	a5,200d16 <main+0x4e>
  200d06:	00001517          	auipc	a0,0x1
  200d0a:	b7a50513          	addi	a0,a0,-1158 # 201880 <strcmp+0x122>
  200d0e:	e3bff0ef          	jal	200b48 <dtb_get_reg>
  200d12:	fea43423          	sd	a0,-24(s0)
  200d16:	fe843503          	ld	a0,-24(s0)
  200d1a:	784000ef          	jal	20149e <uart_set_base>
  200d1e:	edfff0ef          	jal	200bfc <dtb_load_initrd_addr>
  200d22:	00001517          	auipc	a0,0x1
  200d26:	b6e50513          	addi	a0,a0,-1170 # 201890 <strcmp+0x132>
  200d2a:	07d000ef          	jal	2015a6 <uart_puts>
  200d2e:	72e000ef          	jal	20145c <shell>
  200d32:	0001                	nop
  200d34:	70a2                	ld	ra,40(sp)
  200d36:	7402                	ld	s0,32(sp)
  200d38:	6145                	addi	sp,sp,48
  200d3a:	8082                	ret

0000000000200d3c <sbi_ecall>:
  200d3c:	7159                	addi	sp,sp,-112
  200d3e:	f4a2                	sd	s0,104(sp)
  200d40:	1880                	addi	s0,sp,112
  200d42:	fcc43023          	sd	a2,-64(s0)
  200d46:	fad43c23          	sd	a3,-72(s0)
  200d4a:	fae43823          	sd	a4,-80(s0)
  200d4e:	faf43423          	sd	a5,-88(s0)
  200d52:	fb043023          	sd	a6,-96(s0)
  200d56:	f9143c23          	sd	a7,-104(s0)
  200d5a:	87aa                	mv	a5,a0
  200d5c:	fcf42623          	sw	a5,-52(s0)
  200d60:	87ae                	mv	a5,a1
  200d62:	fcf42423          	sw	a5,-56(s0)
  200d66:	fc043503          	ld	a0,-64(s0)
  200d6a:	fb843583          	ld	a1,-72(s0)
  200d6e:	fb043603          	ld	a2,-80(s0)
  200d72:	fa843683          	ld	a3,-88(s0)
  200d76:	fa043703          	ld	a4,-96(s0)
  200d7a:	f9843783          	ld	a5,-104(s0)
  200d7e:	fc842803          	lw	a6,-56(s0)
  200d82:	fcc42883          	lw	a7,-52(s0)
  200d86:	00000073          	ecall
  200d8a:	87aa                	mv	a5,a0
  200d8c:	fcf43823          	sd	a5,-48(s0)
  200d90:	87ae                	mv	a5,a1
  200d92:	fcf43c23          	sd	a5,-40(s0)
  200d96:	fd043783          	ld	a5,-48(s0)
  200d9a:	fef43023          	sd	a5,-32(s0)
  200d9e:	fd843783          	ld	a5,-40(s0)
  200da2:	fef43423          	sd	a5,-24(s0)
  200da6:	fe043703          	ld	a4,-32(s0)
  200daa:	fe843783          	ld	a5,-24(s0)
  200dae:	833a                	mv	t1,a4
  200db0:	83be                	mv	t2,a5
  200db2:	871a                	mv	a4,t1
  200db4:	879e                	mv	a5,t2
  200db6:	853a                	mv	a0,a4
  200db8:	85be                	mv	a1,a5
  200dba:	7426                	ld	s0,104(sp)
  200dbc:	6165                	addi	sp,sp,112
  200dbe:	8082                	ret

0000000000200dc0 <parse>:
  200dc0:	1101                	addi	sp,sp,-32
  200dc2:	ec22                	sd	s0,24(sp)
  200dc4:	1000                	addi	s0,sp,32
  200dc6:	87aa                	mv	a5,a0
  200dc8:	fef407a3          	sb	a5,-17(s0)
  200dcc:	fef40783          	lb	a5,-17(s0)
  200dd0:	0007d563          	bgez	a5,200dda <parse+0x1a>
  200dd4:	20000793          	li	a5,512
  200dd8:	a0a9                	j	200e22 <parse+0x62>
  200dda:	fef44783          	lbu	a5,-17(s0)
  200dde:	0ff7f713          	zext.b	a4,a5
  200de2:	07f00793          	li	a5,127
  200de6:	00f70963          	beq	a4,a5,200df8 <parse+0x38>
  200dea:	fef44783          	lbu	a5,-17(s0)
  200dee:	0ff7f713          	zext.b	a4,a5
  200df2:	47a1                	li	a5,8
  200df4:	00f71563          	bne	a4,a5,200dfe <parse+0x3e>
  200df8:	07f00793          	li	a5,127
  200dfc:	a01d                	j	200e22 <parse+0x62>
  200dfe:	fef44783          	lbu	a5,-17(s0)
  200e02:	0ff7f713          	zext.b	a4,a5
  200e06:	47b5                	li	a5,13
  200e08:	00f70963          	beq	a4,a5,200e1a <parse+0x5a>
  200e0c:	fef44783          	lbu	a5,-17(s0)
  200e10:	0ff7f713          	zext.b	a4,a5
  200e14:	47a9                	li	a5,10
  200e16:	00f71463          	bne	a4,a5,200e1e <parse+0x5e>
  200e1a:	47a9                	li	a5,10
  200e1c:	a019                	j	200e22 <parse+0x62>
  200e1e:	20100793          	li	a5,513
  200e22:	853e                	mv	a0,a5
  200e24:	6462                	ld	s0,24(sp)
  200e26:	6105                	addi	sp,sp,32
  200e28:	8082                	ret

0000000000200e2a <command_help>:
  200e2a:	1141                	addi	sp,sp,-16
  200e2c:	e406                	sd	ra,8(sp)
  200e2e:	e022                	sd	s0,0(sp)
  200e30:	0800                	addi	s0,sp,16
  200e32:	00001517          	auipc	a0,0x1
  200e36:	a7650513          	addi	a0,a0,-1418 # 2018a8 <strcmp+0x14a>
  200e3a:	76c000ef          	jal	2015a6 <uart_puts>
  200e3e:	00001517          	auipc	a0,0x1
  200e42:	a8a50513          	addi	a0,a0,-1398 # 2018c8 <strcmp+0x16a>
  200e46:	760000ef          	jal	2015a6 <uart_puts>
  200e4a:	00001517          	auipc	a0,0x1
  200e4e:	a9e50513          	addi	a0,a0,-1378 # 2018e8 <strcmp+0x18a>
  200e52:	754000ef          	jal	2015a6 <uart_puts>
  200e56:	00001517          	auipc	a0,0x1
  200e5a:	ab250513          	addi	a0,a0,-1358 # 201908 <strcmp+0x1aa>
  200e5e:	748000ef          	jal	2015a6 <uart_puts>
  200e62:	00001517          	auipc	a0,0x1
  200e66:	ace50513          	addi	a0,a0,-1330 # 201930 <strcmp+0x1d2>
  200e6a:	73c000ef          	jal	2015a6 <uart_puts>
  200e6e:	0001                	nop
  200e70:	60a2                	ld	ra,8(sp)
  200e72:	6402                	ld	s0,0(sp)
  200e74:	0141                	addi	sp,sp,16
  200e76:	8082                	ret

0000000000200e78 <command_hello>:
  200e78:	1141                	addi	sp,sp,-16
  200e7a:	e406                	sd	ra,8(sp)
  200e7c:	e022                	sd	s0,0(sp)
  200e7e:	0800                	addi	s0,sp,16
  200e80:	00001517          	auipc	a0,0x1
  200e84:	ae850513          	addi	a0,a0,-1304 # 201968 <strcmp+0x20a>
  200e88:	71e000ef          	jal	2015a6 <uart_puts>
  200e8c:	0001                	nop
  200e8e:	60a2                	ld	ra,8(sp)
  200e90:	6402                	ld	s0,0(sp)
  200e92:	0141                	addi	sp,sp,16
  200e94:	8082                	ret

0000000000200e96 <command_info>:
  200e96:	1101                	addi	sp,sp,-32
  200e98:	ec06                	sd	ra,24(sp)
  200e9a:	e822                	sd	s0,16(sp)
  200e9c:	1000                	addi	s0,sp,32
  200e9e:	4881                	li	a7,0
  200ea0:	4801                	li	a6,0
  200ea2:	4781                	li	a5,0
  200ea4:	4701                	li	a4,0
  200ea6:	4681                	li	a3,0
  200ea8:	4601                	li	a2,0
  200eaa:	4581                	li	a1,0
  200eac:	4541                	li	a0,16
  200eae:	e8fff0ef          	jal	200d3c <sbi_ecall>
  200eb2:	872a                	mv	a4,a0
  200eb4:	87ae                	mv	a5,a1
  200eb6:	fee43023          	sd	a4,-32(s0)
  200eba:	fef43423          	sd	a5,-24(s0)
  200ebe:	00001517          	auipc	a0,0x1
  200ec2:	aba50513          	addi	a0,a0,-1350 # 201978 <strcmp+0x21a>
  200ec6:	6e0000ef          	jal	2015a6 <uart_puts>
  200eca:	fe843783          	ld	a5,-24(s0)
  200ece:	853e                	mv	a0,a5
  200ed0:	712000ef          	jal	2015e2 <uart_hex>
  200ed4:	4881                	li	a7,0
  200ed6:	4801                	li	a6,0
  200ed8:	4781                	li	a5,0
  200eda:	4701                	li	a4,0
  200edc:	4681                	li	a3,0
  200ede:	4601                	li	a2,0
  200ee0:	4585                	li	a1,1
  200ee2:	4541                	li	a0,16
  200ee4:	e59ff0ef          	jal	200d3c <sbi_ecall>
  200ee8:	872a                	mv	a4,a0
  200eea:	87ae                	mv	a5,a1
  200eec:	fee43023          	sd	a4,-32(s0)
  200ef0:	fef43423          	sd	a5,-24(s0)
  200ef4:	00001517          	auipc	a0,0x1
  200ef8:	aa450513          	addi	a0,a0,-1372 # 201998 <strcmp+0x23a>
  200efc:	6aa000ef          	jal	2015a6 <uart_puts>
  200f00:	fe843783          	ld	a5,-24(s0)
  200f04:	853e                	mv	a0,a5
  200f06:	6dc000ef          	jal	2015e2 <uart_hex>
  200f0a:	4881                	li	a7,0
  200f0c:	4801                	li	a6,0
  200f0e:	4781                	li	a5,0
  200f10:	4701                	li	a4,0
  200f12:	4681                	li	a3,0
  200f14:	4601                	li	a2,0
  200f16:	4589                	li	a1,2
  200f18:	4541                	li	a0,16
  200f1a:	e23ff0ef          	jal	200d3c <sbi_ecall>
  200f1e:	872a                	mv	a4,a0
  200f20:	87ae                	mv	a5,a1
  200f22:	fee43023          	sd	a4,-32(s0)
  200f26:	fef43423          	sd	a5,-24(s0)
  200f2a:	00001517          	auipc	a0,0x1
  200f2e:	a8650513          	addi	a0,a0,-1402 # 2019b0 <strcmp+0x252>
  200f32:	674000ef          	jal	2015a6 <uart_puts>
  200f36:	fe843783          	ld	a5,-24(s0)
  200f3a:	853e                	mv	a0,a5
  200f3c:	6a6000ef          	jal	2015e2 <uart_hex>
  200f40:	4529                	li	a0,10
  200f42:	582000ef          	jal	2014c4 <uart_putc>
  200f46:	0001                	nop
  200f48:	60e2                	ld	ra,24(sp)
  200f4a:	6442                	ld	s0,16(sp)
  200f4c:	6105                	addi	sp,sp,32
  200f4e:	8082                	ret

0000000000200f50 <command_load>:
  200f50:	7139                	addi	sp,sp,-64
  200f52:	fc06                	sd	ra,56(sp)
  200f54:	f822                	sd	s0,48(sp)
  200f56:	f426                	sd	s1,40(sp)
  200f58:	0080                	addi	s0,sp,64
  200f5a:	00001517          	auipc	a0,0x1
  200f5e:	a7650513          	addi	a0,a0,-1418 # 2019d0 <strcmp+0x272>
  200f62:	644000ef          	jal	2015a6 <uart_puts>
  200f66:	5b6000ef          	jal	20151c <uart_getc>
  200f6a:	87aa                	mv	a5,a0
  200f6c:	0007849b          	sext.w	s1,a5
  200f70:	5ac000ef          	jal	20151c <uart_getc>
  200f74:	87aa                	mv	a5,a0
  200f76:	2781                	sext.w	a5,a5
  200f78:	0087979b          	slliw	a5,a5,0x8
  200f7c:	2781                	sext.w	a5,a5
  200f7e:	8726                	mv	a4,s1
  200f80:	8fd9                	or	a5,a5,a4
  200f82:	0007849b          	sext.w	s1,a5
  200f86:	596000ef          	jal	20151c <uart_getc>
  200f8a:	87aa                	mv	a5,a0
  200f8c:	2781                	sext.w	a5,a5
  200f8e:	0107979b          	slliw	a5,a5,0x10
  200f92:	2781                	sext.w	a5,a5
  200f94:	8726                	mv	a4,s1
  200f96:	8fd9                	or	a5,a5,a4
  200f98:	0007849b          	sext.w	s1,a5
  200f9c:	580000ef          	jal	20151c <uart_getc>
  200fa0:	87aa                	mv	a5,a0
  200fa2:	2781                	sext.w	a5,a5
  200fa4:	0187979b          	slliw	a5,a5,0x18
  200fa8:	2781                	sext.w	a5,a5
  200faa:	8726                	mv	a4,s1
  200fac:	8fd9                	or	a5,a5,a4
  200fae:	fcf42c23          	sw	a5,-40(s0)
  200fb2:	56a000ef          	jal	20151c <uart_getc>
  200fb6:	87aa                	mv	a5,a0
  200fb8:	0007849b          	sext.w	s1,a5
  200fbc:	560000ef          	jal	20151c <uart_getc>
  200fc0:	87aa                	mv	a5,a0
  200fc2:	2781                	sext.w	a5,a5
  200fc4:	0087979b          	slliw	a5,a5,0x8
  200fc8:	2781                	sext.w	a5,a5
  200fca:	8726                	mv	a4,s1
  200fcc:	8fd9                	or	a5,a5,a4
  200fce:	0007849b          	sext.w	s1,a5
  200fd2:	54a000ef          	jal	20151c <uart_getc>
  200fd6:	87aa                	mv	a5,a0
  200fd8:	2781                	sext.w	a5,a5
  200fda:	0107979b          	slliw	a5,a5,0x10
  200fde:	2781                	sext.w	a5,a5
  200fe0:	8726                	mv	a4,s1
  200fe2:	8fd9                	or	a5,a5,a4
  200fe4:	0007849b          	sext.w	s1,a5
  200fe8:	534000ef          	jal	20151c <uart_getc>
  200fec:	87aa                	mv	a5,a0
  200fee:	2781                	sext.w	a5,a5
  200ff0:	0187979b          	slliw	a5,a5,0x18
  200ff4:	2781                	sext.w	a5,a5
  200ff6:	8726                	mv	a4,s1
  200ff8:	8fd9                	or	a5,a5,a4
  200ffa:	fcf42a23          	sw	a5,-44(s0)
  200ffe:	fd842783          	lw	a5,-40(s0)
  201002:	0007871b          	sext.w	a4,a5
  201006:	544f57b7          	lui	a5,0x544f5
  20100a:	f4278793          	addi	a5,a5,-190 # 544f4f42 <__stack_top+0x542ef362>
  20100e:	00f70963          	beq	a4,a5,201020 <command_load+0xd0>
  201012:	00001517          	auipc	a0,0x1
  201016:	9e650513          	addi	a0,a0,-1562 # 2019f8 <strcmp+0x29a>
  20101a:	58c000ef          	jal	2015a6 <uart_puts>
  20101e:	a861                	j	2010b6 <command_load+0x166>
  201020:	200007b7          	lui	a5,0x20000
  201024:	fcf43423          	sd	a5,-56(s0)
  201028:	fc042e23          	sw	zero,-36(s0)
  20102c:	a00d                	j	20104e <command_load+0xfe>
  20102e:	fdc46783          	lwu	a5,-36(s0)
  201032:	fc843703          	ld	a4,-56(s0)
  201036:	00f704b3          	add	s1,a4,a5
  20103a:	530000ef          	jal	20156a <uart_getc_raw>
  20103e:	87aa                	mv	a5,a0
  201040:	00f48023          	sb	a5,0(s1)
  201044:	fdc42783          	lw	a5,-36(s0)
  201048:	2785                	addiw	a5,a5,1 # 20000001 <__stack_top+0x1fdfa421>
  20104a:	fcf42e23          	sw	a5,-36(s0)
  20104e:	fdc42783          	lw	a5,-36(s0)
  201052:	873e                	mv	a4,a5
  201054:	fd442783          	lw	a5,-44(s0)
  201058:	2701                	sext.w	a4,a4
  20105a:	2781                	sext.w	a5,a5
  20105c:	fcf769e3          	bltu	a4,a5,20102e <command_load+0xde>
  201060:	00001517          	auipc	a0,0x1
  201064:	9b850513          	addi	a0,a0,-1608 # 201a18 <strcmp+0x2ba>
  201068:	53e000ef          	jal	2015a6 <uart_puts>
  20106c:	fd446783          	lwu	a5,-44(s0)
  201070:	853e                	mv	a0,a5
  201072:	5f0000ef          	jal	201662 <uart_dec>
  201076:	00001517          	auipc	a0,0x1
  20107a:	9aa50513          	addi	a0,a0,-1622 # 201a20 <strcmp+0x2c2>
  20107e:	528000ef          	jal	2015a6 <uart_puts>
  201082:	fc843783          	ld	a5,-56(s0)
  201086:	853e                	mv	a0,a5
  201088:	55a000ef          	jal	2015e2 <uart_hex>
  20108c:	00001517          	auipc	a0,0x1
  201090:	9ac50513          	addi	a0,a0,-1620 # 201a38 <strcmp+0x2da>
  201094:	512000ef          	jal	2015a6 <uart_puts>
  201098:	fc843783          	ld	a5,-56(s0)
  20109c:	00001717          	auipc	a4,0x1
  2010a0:	aa470713          	addi	a4,a4,-1372 # 201b40 <boot_hart_id>
  2010a4:	4314                	lw	a3,0(a4)
  2010a6:	00001717          	auipc	a4,0x1
  2010aa:	a8a70713          	addi	a4,a4,-1398 # 201b30 <dtb_addr>
  2010ae:	6318                	ld	a4,0(a4)
  2010b0:	85ba                	mv	a1,a4
  2010b2:	8536                	mv	a0,a3
  2010b4:	9782                	jalr	a5
  2010b6:	70e2                	ld	ra,56(sp)
  2010b8:	7442                	ld	s0,48(sp)
  2010ba:	74a2                	ld	s1,40(sp)
  2010bc:	6121                	addi	sp,sp,64
  2010be:	8082                	ret

00000000002010c0 <command_unknown>:
  2010c0:	1141                	addi	sp,sp,-16
  2010c2:	e406                	sd	ra,8(sp)
  2010c4:	e022                	sd	s0,0(sp)
  2010c6:	0800                	addi	s0,sp,16
  2010c8:	00001517          	auipc	a0,0x1
  2010cc:	97850513          	addi	a0,a0,-1672 # 201a40 <strcmp+0x2e2>
  2010d0:	4d6000ef          	jal	2015a6 <uart_puts>
  2010d4:	00001517          	auipc	a0,0x1
  2010d8:	a7450513          	addi	a0,a0,-1420 # 201b48 <buffer>
  2010dc:	4ca000ef          	jal	2015a6 <uart_puts>
  2010e0:	00001517          	auipc	a0,0x1
  2010e4:	97850513          	addi	a0,a0,-1672 # 201a58 <strcmp+0x2fa>
  2010e8:	4be000ef          	jal	2015a6 <uart_puts>
  2010ec:	0001                	nop
  2010ee:	60a2                	ld	ra,8(sp)
  2010f0:	6402                	ld	s0,0(sp)
  2010f2:	0141                	addi	sp,sp,16
  2010f4:	8082                	ret

00000000002010f6 <command_ls>:
  2010f6:	1141                	addi	sp,sp,-16
  2010f8:	e406                	sd	ra,8(sp)
  2010fa:	e022                	sd	s0,0(sp)
  2010fc:	0800                	addi	s0,sp,16
  2010fe:	00001797          	auipc	a5,0x1
  201102:	a3a78793          	addi	a5,a5,-1478 # 201b38 <cpio_addr>
  201106:	639c                	ld	a5,0(a5)
  201108:	eb81                	bnez	a5,201118 <command_ls+0x22>
  20110a:	00001517          	auipc	a0,0x1
  20110e:	96e50513          	addi	a0,a0,-1682 # 201a78 <strcmp+0x31a>
  201112:	494000ef          	jal	2015a6 <uart_puts>
  201116:	a809                	j	201128 <command_ls+0x32>
  201118:	00001797          	auipc	a5,0x1
  20111c:	a2078793          	addi	a5,a5,-1504 # 201b38 <cpio_addr>
  201120:	639c                	ld	a5,0(a5)
  201122:	853e                	mv	a0,a5
  201124:	88cff0ef          	jal	2001b0 <cpio_ls>
  201128:	60a2                	ld	ra,8(sp)
  20112a:	6402                	ld	s0,0(sp)
  20112c:	0141                	addi	sp,sp,16
  20112e:	8082                	ret

0000000000201130 <command_cat>:
  201130:	1101                	addi	sp,sp,-32
  201132:	ec06                	sd	ra,24(sp)
  201134:	e822                	sd	s0,16(sp)
  201136:	1000                	addi	s0,sp,32
  201138:	00001797          	auipc	a5,0x1
  20113c:	a1078793          	addi	a5,a5,-1520 # 201b48 <buffer>
  201140:	fef43423          	sd	a5,-24(s0)
  201144:	a031                	j	201150 <command_cat+0x20>
  201146:	fe843783          	ld	a5,-24(s0)
  20114a:	0785                	addi	a5,a5,1
  20114c:	fef43423          	sd	a5,-24(s0)
  201150:	fe843783          	ld	a5,-24(s0)
  201154:	0007c783          	lbu	a5,0(a5)
  201158:	cb91                	beqz	a5,20116c <command_cat+0x3c>
  20115a:	fe843783          	ld	a5,-24(s0)
  20115e:	0007c783          	lbu	a5,0(a5)
  201162:	873e                	mv	a4,a5
  201164:	02000793          	li	a5,32
  201168:	fcf71fe3          	bne	a4,a5,201146 <command_cat+0x16>
  20116c:	fe843783          	ld	a5,-24(s0)
  201170:	0007c783          	lbu	a5,0(a5)
  201174:	eb81                	bnez	a5,201184 <command_cat+0x54>
  201176:	00001517          	auipc	a0,0x1
  20117a:	92250513          	addi	a0,a0,-1758 # 201a98 <strcmp+0x33a>
  20117e:	428000ef          	jal	2015a6 <uart_puts>
  201182:	a095                	j	2011e6 <command_cat+0xb6>
  201184:	fe843783          	ld	a5,-24(s0)
  201188:	0007c783          	lbu	a5,0(a5)
  20118c:	873e                	mv	a4,a5
  20118e:	02000793          	li	a5,32
  201192:	00f71763          	bne	a4,a5,2011a0 <command_cat+0x70>
  201196:	fe843783          	ld	a5,-24(s0)
  20119a:	0785                	addi	a5,a5,1
  20119c:	fef43423          	sd	a5,-24(s0)
  2011a0:	fe843783          	ld	a5,-24(s0)
  2011a4:	0007c783          	lbu	a5,0(a5)
  2011a8:	eb81                	bnez	a5,2011b8 <command_cat+0x88>
  2011aa:	00001517          	auipc	a0,0x1
  2011ae:	8ee50513          	addi	a0,a0,-1810 # 201a98 <strcmp+0x33a>
  2011b2:	3f4000ef          	jal	2015a6 <uart_puts>
  2011b6:	a805                	j	2011e6 <command_cat+0xb6>
  2011b8:	00001797          	auipc	a5,0x1
  2011bc:	98078793          	addi	a5,a5,-1664 # 201b38 <cpio_addr>
  2011c0:	639c                	ld	a5,0(a5)
  2011c2:	eb81                	bnez	a5,2011d2 <command_cat+0xa2>
  2011c4:	00001517          	auipc	a0,0x1
  2011c8:	8b450513          	addi	a0,a0,-1868 # 201a78 <strcmp+0x31a>
  2011cc:	3da000ef          	jal	2015a6 <uart_puts>
  2011d0:	a819                	j	2011e6 <command_cat+0xb6>
  2011d2:	00001797          	auipc	a5,0x1
  2011d6:	96678793          	addi	a5,a5,-1690 # 201b38 <cpio_addr>
  2011da:	639c                	ld	a5,0(a5)
  2011dc:	fe843583          	ld	a1,-24(s0)
  2011e0:	853e                	mv	a0,a5
  2011e2:	a02ff0ef          	jal	2003e4 <cpio_cat>
  2011e6:	60e2                	ld	ra,24(sp)
  2011e8:	6442                	ld	s0,16(sp)
  2011ea:	6105                	addi	sp,sp,32
  2011ec:	8082                	ret

00000000002011ee <cmp_command>:
  2011ee:	1141                	addi	sp,sp,-16
  2011f0:	e406                	sd	ra,8(sp)
  2011f2:	e022                	sd	s0,0(sp)
  2011f4:	0800                	addi	s0,sp,16
  2011f6:	00001597          	auipc	a1,0x1
  2011fa:	8ba58593          	addi	a1,a1,-1862 # 201ab0 <strcmp+0x352>
  2011fe:	00001517          	auipc	a0,0x1
  201202:	94a50513          	addi	a0,a0,-1718 # 201b48 <buffer>
  201206:	558000ef          	jal	20175e <strcmp>
  20120a:	87aa                	mv	a5,a0
  20120c:	e781                	bnez	a5,201214 <cmp_command+0x26>
  20120e:	c1dff0ef          	jal	200e2a <command_help>
  201212:	a0ed                	j	2012fc <cmp_command+0x10e>
  201214:	00001597          	auipc	a1,0x1
  201218:	8a458593          	addi	a1,a1,-1884 # 201ab8 <strcmp+0x35a>
  20121c:	00001517          	auipc	a0,0x1
  201220:	92c50513          	addi	a0,a0,-1748 # 201b48 <buffer>
  201224:	53a000ef          	jal	20175e <strcmp>
  201228:	87aa                	mv	a5,a0
  20122a:	e781                	bnez	a5,201232 <cmp_command+0x44>
  20122c:	c4dff0ef          	jal	200e78 <command_hello>
  201230:	a0f1                	j	2012fc <cmp_command+0x10e>
  201232:	00001597          	auipc	a1,0x1
  201236:	88e58593          	addi	a1,a1,-1906 # 201ac0 <strcmp+0x362>
  20123a:	00001517          	auipc	a0,0x1
  20123e:	90e50513          	addi	a0,a0,-1778 # 201b48 <buffer>
  201242:	51c000ef          	jal	20175e <strcmp>
  201246:	87aa                	mv	a5,a0
  201248:	e781                	bnez	a5,201250 <cmp_command+0x62>
  20124a:	c4dff0ef          	jal	200e96 <command_info>
  20124e:	a07d                	j	2012fc <cmp_command+0x10e>
  201250:	00001597          	auipc	a1,0x1
  201254:	87858593          	addi	a1,a1,-1928 # 201ac8 <strcmp+0x36a>
  201258:	00001517          	auipc	a0,0x1
  20125c:	8f050513          	addi	a0,a0,-1808 # 201b48 <buffer>
  201260:	4fe000ef          	jal	20175e <strcmp>
  201264:	87aa                	mv	a5,a0
  201266:	e781                	bnez	a5,20126e <cmp_command+0x80>
  201268:	ce9ff0ef          	jal	200f50 <command_load>
  20126c:	a841                	j	2012fc <cmp_command+0x10e>
  20126e:	00001597          	auipc	a1,0x1
  201272:	86258593          	addi	a1,a1,-1950 # 201ad0 <strcmp+0x372>
  201276:	00001517          	auipc	a0,0x1
  20127a:	8d250513          	addi	a0,a0,-1838 # 201b48 <buffer>
  20127e:	4e0000ef          	jal	20175e <strcmp>
  201282:	87aa                	mv	a5,a0
  201284:	e781                	bnez	a5,20128c <cmp_command+0x9e>
  201286:	e71ff0ef          	jal	2010f6 <command_ls>
  20128a:	a88d                	j	2012fc <cmp_command+0x10e>
  20128c:	00001797          	auipc	a5,0x1
  201290:	8bc78793          	addi	a5,a5,-1860 # 201b48 <buffer>
  201294:	0007c783          	lbu	a5,0(a5)
  201298:	873e                	mv	a4,a5
  20129a:	06300793          	li	a5,99
  20129e:	04f71d63          	bne	a4,a5,2012f8 <cmp_command+0x10a>
  2012a2:	00001797          	auipc	a5,0x1
  2012a6:	8a678793          	addi	a5,a5,-1882 # 201b48 <buffer>
  2012aa:	0017c783          	lbu	a5,1(a5)
  2012ae:	873e                	mv	a4,a5
  2012b0:	06100793          	li	a5,97
  2012b4:	04f71263          	bne	a4,a5,2012f8 <cmp_command+0x10a>
  2012b8:	00001797          	auipc	a5,0x1
  2012bc:	89078793          	addi	a5,a5,-1904 # 201b48 <buffer>
  2012c0:	0027c783          	lbu	a5,2(a5)
  2012c4:	873e                	mv	a4,a5
  2012c6:	07400793          	li	a5,116
  2012ca:	02f71763          	bne	a4,a5,2012f8 <cmp_command+0x10a>
  2012ce:	00001797          	auipc	a5,0x1
  2012d2:	87a78793          	addi	a5,a5,-1926 # 201b48 <buffer>
  2012d6:	0037c783          	lbu	a5,3(a5)
  2012da:	873e                	mv	a4,a5
  2012dc:	02000793          	li	a5,32
  2012e0:	00f70963          	beq	a4,a5,2012f2 <cmp_command+0x104>
  2012e4:	00001797          	auipc	a5,0x1
  2012e8:	86478793          	addi	a5,a5,-1948 # 201b48 <buffer>
  2012ec:	0037c783          	lbu	a5,3(a5)
  2012f0:	e781                	bnez	a5,2012f8 <cmp_command+0x10a>
  2012f2:	e3fff0ef          	jal	201130 <command_cat>
  2012f6:	a019                	j	2012fc <cmp_command+0x10e>
  2012f8:	dc9ff0ef          	jal	2010c0 <command_unknown>
  2012fc:	0001                	nop
  2012fe:	60a2                	ld	ra,8(sp)
  201300:	6402                	ld	s0,0(sp)
  201302:	0141                	addi	sp,sp,16
  201304:	8082                	ret

0000000000201306 <put_char>:
  201306:	1101                	addi	sp,sp,-32
  201308:	ec06                	sd	ra,24(sp)
  20130a:	e822                	sd	s0,16(sp)
  20130c:	1000                	addi	s0,sp,32
  20130e:	87aa                	mv	a5,a0
  201310:	872e                	mv	a4,a1
  201312:	fef42623          	sw	a5,-20(s0)
  201316:	87ba                	mv	a5,a4
  201318:	fef405a3          	sb	a5,-21(s0)
  20131c:	fec42783          	lw	a5,-20(s0)
  201320:	0007871b          	sext.w	a4,a5
  201324:	20100793          	li	a5,513
  201328:	0cf70c63          	beq	a4,a5,201400 <put_char+0xfa>
  20132c:	fec42783          	lw	a5,-20(s0)
  201330:	0007871b          	sext.w	a4,a5
  201334:	20100793          	li	a5,513
  201338:	10e7ec63          	bltu	a5,a4,201450 <put_char+0x14a>
  20133c:	fec42783          	lw	a5,-20(s0)
  201340:	0007871b          	sext.w	a4,a5
  201344:	47a9                	li	a5,10
  201346:	04f70563          	beq	a4,a5,201390 <put_char+0x8a>
  20134a:	fec42783          	lw	a5,-20(s0)
  20134e:	0007871b          	sext.w	a4,a5
  201352:	07f00793          	li	a5,127
  201356:	0ef71d63          	bne	a4,a5,201450 <put_char+0x14a>
  20135a:	00001797          	auipc	a5,0x1
  20135e:	86e78793          	addi	a5,a5,-1938 # 201bc8 <buf_len>
  201362:	439c                	lw	a5,0(a5)
  201364:	00f05f63          	blez	a5,201382 <put_char+0x7c>
  201368:	00001797          	auipc	a5,0x1
  20136c:	86078793          	addi	a5,a5,-1952 # 201bc8 <buf_len>
  201370:	439c                	lw	a5,0(a5)
  201372:	37fd                	addiw	a5,a5,-1
  201374:	0007871b          	sext.w	a4,a5
  201378:	00001797          	auipc	a5,0x1
  20137c:	85078793          	addi	a5,a5,-1968 # 201bc8 <buf_len>
  201380:	c398                	sw	a4,0(a5)
  201382:	00000517          	auipc	a0,0x0
  201386:	75650513          	addi	a0,a0,1878 # 201ad8 <strcmp+0x37a>
  20138a:	21c000ef          	jal	2015a6 <uart_puts>
  20138e:	a0d1                	j	201452 <put_char+0x14c>
  201390:	4529                	li	a0,10
  201392:	132000ef          	jal	2014c4 <uart_putc>
  201396:	00001797          	auipc	a5,0x1
  20139a:	83278793          	addi	a5,a5,-1998 # 201bc8 <buf_len>
  20139e:	439c                	lw	a5,0(a5)
  2013a0:	873e                	mv	a4,a5
  2013a2:	08000793          	li	a5,128
  2013a6:	00f71963          	bne	a4,a5,2013b8 <put_char+0xb2>
  2013aa:	00000517          	auipc	a0,0x0
  2013ae:	73650513          	addi	a0,a0,1846 # 201ae0 <strcmp+0x382>
  2013b2:	1f4000ef          	jal	2015a6 <uart_puts>
  2013b6:	a839                	j	2013d4 <put_char+0xce>
  2013b8:	00001797          	auipc	a5,0x1
  2013bc:	81078793          	addi	a5,a5,-2032 # 201bc8 <buf_len>
  2013c0:	439c                	lw	a5,0(a5)
  2013c2:	00000717          	auipc	a4,0x0
  2013c6:	78670713          	addi	a4,a4,1926 # 201b48 <buffer>
  2013ca:	97ba                	add	a5,a5,a4
  2013cc:	00078023          	sb	zero,0(a5)
  2013d0:	e1fff0ef          	jal	2011ee <cmp_command>
  2013d4:	00000797          	auipc	a5,0x0
  2013d8:	7f478793          	addi	a5,a5,2036 # 201bc8 <buf_len>
  2013dc:	0007a023          	sw	zero,0(a5)
  2013e0:	08000613          	li	a2,128
  2013e4:	4581                	li	a1,0
  2013e6:	00000517          	auipc	a0,0x0
  2013ea:	76250513          	addi	a0,a0,1890 # 201b48 <buffer>
  2013ee:	312000ef          	jal	201700 <memset>
  2013f2:	00000517          	auipc	a0,0x0
  2013f6:	72650513          	addi	a0,a0,1830 # 201b18 <strcmp+0x3ba>
  2013fa:	1ac000ef          	jal	2015a6 <uart_puts>
  2013fe:	a891                	j	201452 <put_char+0x14c>
  201400:	00000797          	auipc	a5,0x0
  201404:	7c878793          	addi	a5,a5,1992 # 201bc8 <buf_len>
  201408:	439c                	lw	a5,0(a5)
  20140a:	873e                	mv	a4,a5
  20140c:	07f00793          	li	a5,127
  201410:	02e7c963          	blt	a5,a4,201442 <put_char+0x13c>
  201414:	00000797          	auipc	a5,0x0
  201418:	7b478793          	addi	a5,a5,1972 # 201bc8 <buf_len>
  20141c:	439c                	lw	a5,0(a5)
  20141e:	0017871b          	addiw	a4,a5,1
  201422:	0007069b          	sext.w	a3,a4
  201426:	00000717          	auipc	a4,0x0
  20142a:	7a270713          	addi	a4,a4,1954 # 201bc8 <buf_len>
  20142e:	c314                	sw	a3,0(a4)
  201430:	00000717          	auipc	a4,0x0
  201434:	71870713          	addi	a4,a4,1816 # 201b48 <buffer>
  201438:	97ba                	add	a5,a5,a4
  20143a:	feb44703          	lbu	a4,-21(s0)
  20143e:	00e78023          	sb	a4,0(a5)
  201442:	feb44783          	lbu	a5,-21(s0)
  201446:	2781                	sext.w	a5,a5
  201448:	853e                	mv	a0,a5
  20144a:	07a000ef          	jal	2014c4 <uart_putc>
  20144e:	a011                	j	201452 <put_char+0x14c>
  201450:	0001                	nop
  201452:	0001                	nop
  201454:	60e2                	ld	ra,24(sp)
  201456:	6442                	ld	s0,16(sp)
  201458:	6105                	addi	sp,sp,32
  20145a:	8082                	ret

000000000020145c <shell>:
  20145c:	1101                	addi	sp,sp,-32
  20145e:	ec06                	sd	ra,24(sp)
  201460:	e822                	sd	s0,16(sp)
  201462:	1000                	addi	s0,sp,32
  201464:	00000517          	auipc	a0,0x0
  201468:	6b450513          	addi	a0,a0,1716 # 201b18 <strcmp+0x3ba>
  20146c:	13a000ef          	jal	2015a6 <uart_puts>
  201470:	0ac000ef          	jal	20151c <uart_getc>
  201474:	87aa                	mv	a5,a0
  201476:	fef407a3          	sb	a5,-17(s0)
  20147a:	fef44783          	lbu	a5,-17(s0)
  20147e:	853e                	mv	a0,a5
  201480:	941ff0ef          	jal	200dc0 <parse>
  201484:	87aa                	mv	a5,a0
  201486:	fef42423          	sw	a5,-24(s0)
  20148a:	fef44703          	lbu	a4,-17(s0)
  20148e:	fe842783          	lw	a5,-24(s0)
  201492:	85ba                	mv	a1,a4
  201494:	853e                	mv	a0,a5
  201496:	e71ff0ef          	jal	201306 <put_char>
  20149a:	0001                	nop
  20149c:	bfd1                	j	201470 <shell+0x14>

000000000020149e <uart_set_base>:
  20149e:	1101                	addi	sp,sp,-32
  2014a0:	ec22                	sd	s0,24(sp)
  2014a2:	1000                	addi	s0,sp,32
  2014a4:	fea43423          	sd	a0,-24(s0)
  2014a8:	fe843783          	ld	a5,-24(s0)
  2014ac:	cb81                	beqz	a5,2014bc <uart_set_base+0x1e>
  2014ae:	00000797          	auipc	a5,0x0
  2014b2:	72278793          	addi	a5,a5,1826 # 201bd0 <g_uart_base>
  2014b6:	fe843703          	ld	a4,-24(s0)
  2014ba:	e398                	sd	a4,0(a5)
  2014bc:	0001                	nop
  2014be:	6462                	ld	s0,24(sp)
  2014c0:	6105                	addi	sp,sp,32
  2014c2:	8082                	ret

00000000002014c4 <uart_putc>:
  2014c4:	1101                	addi	sp,sp,-32
  2014c6:	ec06                	sd	ra,24(sp)
  2014c8:	e822                	sd	s0,16(sp)
  2014ca:	1000                	addi	s0,sp,32
  2014cc:	87aa                	mv	a5,a0
  2014ce:	fef42623          	sw	a5,-20(s0)
  2014d2:	fec42783          	lw	a5,-20(s0)
  2014d6:	0007871b          	sext.w	a4,a5
  2014da:	47a9                	li	a5,10
  2014dc:	00f71563          	bne	a4,a5,2014e6 <uart_putc+0x22>
  2014e0:	4535                	li	a0,13
  2014e2:	fe3ff0ef          	jal	2014c4 <uart_putc>
  2014e6:	0001                	nop
  2014e8:	00000797          	auipc	a5,0x0
  2014ec:	6e878793          	addi	a5,a5,1768 # 201bd0 <g_uart_base>
  2014f0:	639c                	ld	a5,0(a5)
  2014f2:	07d1                	addi	a5,a5,20
  2014f4:	439c                	lw	a5,0(a5)
  2014f6:	2781                	sext.w	a5,a5
  2014f8:	0207f793          	andi	a5,a5,32
  2014fc:	2781                	sext.w	a5,a5
  2014fe:	d7ed                	beqz	a5,2014e8 <uart_putc+0x24>
  201500:	00000797          	auipc	a5,0x0
  201504:	6d078793          	addi	a5,a5,1744 # 201bd0 <g_uart_base>
  201508:	639c                	ld	a5,0(a5)
  20150a:	873e                	mv	a4,a5
  20150c:	fec42783          	lw	a5,-20(s0)
  201510:	c31c                	sw	a5,0(a4)
  201512:	0001                	nop
  201514:	60e2                	ld	ra,24(sp)
  201516:	6442                	ld	s0,16(sp)
  201518:	6105                	addi	sp,sp,32
  20151a:	8082                	ret

000000000020151c <uart_getc>:
  20151c:	1101                	addi	sp,sp,-32
  20151e:	ec22                	sd	s0,24(sp)
  201520:	1000                	addi	s0,sp,32
  201522:	0001                	nop
  201524:	00000797          	auipc	a5,0x0
  201528:	6ac78793          	addi	a5,a5,1708 # 201bd0 <g_uart_base>
  20152c:	639c                	ld	a5,0(a5)
  20152e:	07d1                	addi	a5,a5,20
  201530:	439c                	lw	a5,0(a5)
  201532:	2781                	sext.w	a5,a5
  201534:	8b85                	andi	a5,a5,1
  201536:	2781                	sext.w	a5,a5
  201538:	d7f5                	beqz	a5,201524 <uart_getc+0x8>
  20153a:	00000797          	auipc	a5,0x0
  20153e:	69678793          	addi	a5,a5,1686 # 201bd0 <g_uart_base>
  201542:	639c                	ld	a5,0(a5)
  201544:	439c                	lw	a5,0(a5)
  201546:	2781                	sext.w	a5,a5
  201548:	fef407a3          	sb	a5,-17(s0)
  20154c:	fef44783          	lbu	a5,-17(s0)
  201550:	0ff7f713          	zext.b	a4,a5
  201554:	47b5                	li	a5,13
  201556:	00f70563          	beq	a4,a5,201560 <uart_getc+0x44>
  20155a:	fef44783          	lbu	a5,-17(s0)
  20155e:	a011                	j	201562 <uart_getc+0x46>
  201560:	47a9                	li	a5,10
  201562:	853e                	mv	a0,a5
  201564:	6462                	ld	s0,24(sp)
  201566:	6105                	addi	sp,sp,32
  201568:	8082                	ret

000000000020156a <uart_getc_raw>:
  20156a:	1101                	addi	sp,sp,-32
  20156c:	ec22                	sd	s0,24(sp)
  20156e:	1000                	addi	s0,sp,32
  201570:	0001                	nop
  201572:	00000797          	auipc	a5,0x0
  201576:	65e78793          	addi	a5,a5,1630 # 201bd0 <g_uart_base>
  20157a:	639c                	ld	a5,0(a5)
  20157c:	07d1                	addi	a5,a5,20
  20157e:	439c                	lw	a5,0(a5)
  201580:	2781                	sext.w	a5,a5
  201582:	8b85                	andi	a5,a5,1
  201584:	2781                	sext.w	a5,a5
  201586:	d7f5                	beqz	a5,201572 <uart_getc_raw+0x8>
  201588:	00000797          	auipc	a5,0x0
  20158c:	64878793          	addi	a5,a5,1608 # 201bd0 <g_uart_base>
  201590:	639c                	ld	a5,0(a5)
  201592:	439c                	lw	a5,0(a5)
  201594:	2781                	sext.w	a5,a5
  201596:	fef407a3          	sb	a5,-17(s0)
  20159a:	fef44783          	lbu	a5,-17(s0)
  20159e:	853e                	mv	a0,a5
  2015a0:	6462                	ld	s0,24(sp)
  2015a2:	6105                	addi	sp,sp,32
  2015a4:	8082                	ret

00000000002015a6 <uart_puts>:
  2015a6:	1101                	addi	sp,sp,-32
  2015a8:	ec06                	sd	ra,24(sp)
  2015aa:	e822                	sd	s0,16(sp)
  2015ac:	1000                	addi	s0,sp,32
  2015ae:	fea43423          	sd	a0,-24(s0)
  2015b2:	a829                	j	2015cc <uart_puts+0x26>
  2015b4:	fe843783          	ld	a5,-24(s0)
  2015b8:	00178713          	addi	a4,a5,1
  2015bc:	fee43423          	sd	a4,-24(s0)
  2015c0:	0007c783          	lbu	a5,0(a5)
  2015c4:	2781                	sext.w	a5,a5
  2015c6:	853e                	mv	a0,a5
  2015c8:	efdff0ef          	jal	2014c4 <uart_putc>
  2015cc:	fe843783          	ld	a5,-24(s0)
  2015d0:	0007c783          	lbu	a5,0(a5)
  2015d4:	f3e5                	bnez	a5,2015b4 <uart_puts+0xe>
  2015d6:	0001                	nop
  2015d8:	0001                	nop
  2015da:	60e2                	ld	ra,24(sp)
  2015dc:	6442                	ld	s0,16(sp)
  2015de:	6105                	addi	sp,sp,32
  2015e0:	8082                	ret

00000000002015e2 <uart_hex>:
  2015e2:	7179                	addi	sp,sp,-48
  2015e4:	f406                	sd	ra,40(sp)
  2015e6:	f022                	sd	s0,32(sp)
  2015e8:	1800                	addi	s0,sp,48
  2015ea:	fca43c23          	sd	a0,-40(s0)
  2015ee:	00000517          	auipc	a0,0x0
  2015f2:	53a50513          	addi	a0,a0,1338 # 201b28 <strcmp+0x3ca>
  2015f6:	fb1ff0ef          	jal	2015a6 <uart_puts>
  2015fa:	03c00793          	li	a5,60
  2015fe:	fef42623          	sw	a5,-20(s0)
  201602:	a0a9                	j	20164c <uart_hex+0x6a>
  201604:	fec42783          	lw	a5,-20(s0)
  201608:	873e                	mv	a4,a5
  20160a:	fd843783          	ld	a5,-40(s0)
  20160e:	00e7d7b3          	srl	a5,a5,a4
  201612:	8bbd                	andi	a5,a5,15
  201614:	fef43023          	sd	a5,-32(s0)
  201618:	fe043703          	ld	a4,-32(s0)
  20161c:	47a5                	li	a5,9
  20161e:	00e7f563          	bgeu	a5,a4,201628 <uart_hex+0x46>
  201622:	05700793          	li	a5,87
  201626:	a019                	j	20162c <uart_hex+0x4a>
  201628:	03000793          	li	a5,48
  20162c:	fe043703          	ld	a4,-32(s0)
  201630:	97ba                	add	a5,a5,a4
  201632:	fef43023          	sd	a5,-32(s0)
  201636:	fe043783          	ld	a5,-32(s0)
  20163a:	2781                	sext.w	a5,a5
  20163c:	853e                	mv	a0,a5
  20163e:	e87ff0ef          	jal	2014c4 <uart_putc>
  201642:	fec42783          	lw	a5,-20(s0)
  201646:	37f1                	addiw	a5,a5,-4
  201648:	fef42623          	sw	a5,-20(s0)
  20164c:	fec42783          	lw	a5,-20(s0)
  201650:	2781                	sext.w	a5,a5
  201652:	fa07d9e3          	bgez	a5,201604 <uart_hex+0x22>
  201656:	0001                	nop
  201658:	0001                	nop
  20165a:	70a2                	ld	ra,40(sp)
  20165c:	7402                	ld	s0,32(sp)
  20165e:	6145                	addi	sp,sp,48
  201660:	8082                	ret

0000000000201662 <uart_dec>:
  201662:	715d                	addi	sp,sp,-80
  201664:	e486                	sd	ra,72(sp)
  201666:	e0a2                	sd	s0,64(sp)
  201668:	0880                	addi	s0,sp,80
  20166a:	faa43c23          	sd	a0,-72(s0)
  20166e:	fe042623          	sw	zero,-20(s0)
  201672:	fb843783          	ld	a5,-72(s0)
  201676:	e3b1                	bnez	a5,2016ba <uart_dec+0x58>
  201678:	03000513          	li	a0,48
  20167c:	e49ff0ef          	jal	2014c4 <uart_putc>
  201680:	a8a5                	j	2016f8 <uart_dec+0x96>
  201682:	fb843703          	ld	a4,-72(s0)
  201686:	47a9                	li	a5,10
  201688:	02f777b3          	remu	a5,a4,a5
  20168c:	0ff7f713          	zext.b	a4,a5
  201690:	fec42783          	lw	a5,-20(s0)
  201694:	0017869b          	addiw	a3,a5,1
  201698:	fed42623          	sw	a3,-20(s0)
  20169c:	0307071b          	addiw	a4,a4,48
  2016a0:	0ff77713          	zext.b	a4,a4
  2016a4:	17c1                	addi	a5,a5,-16
  2016a6:	97a2                	add	a5,a5,s0
  2016a8:	fce78c23          	sb	a4,-40(a5)
  2016ac:	fb843703          	ld	a4,-72(s0)
  2016b0:	47a9                	li	a5,10
  2016b2:	02f757b3          	divu	a5,a4,a5
  2016b6:	faf43c23          	sd	a5,-72(s0)
  2016ba:	fb843783          	ld	a5,-72(s0)
  2016be:	cb85                	beqz	a5,2016ee <uart_dec+0x8c>
  2016c0:	fec42783          	lw	a5,-20(s0)
  2016c4:	0007871b          	sext.w	a4,a5
  2016c8:	47fd                	li	a5,31
  2016ca:	fae7dce3          	bge	a5,a4,201682 <uart_dec+0x20>
  2016ce:	a005                	j	2016ee <uart_dec+0x8c>
  2016d0:	fec42783          	lw	a5,-20(s0)
  2016d4:	37fd                	addiw	a5,a5,-1
  2016d6:	fef42623          	sw	a5,-20(s0)
  2016da:	fec42783          	lw	a5,-20(s0)
  2016de:	17c1                	addi	a5,a5,-16
  2016e0:	97a2                	add	a5,a5,s0
  2016e2:	fd87c783          	lbu	a5,-40(a5)
  2016e6:	2781                	sext.w	a5,a5
  2016e8:	853e                	mv	a0,a5
  2016ea:	ddbff0ef          	jal	2014c4 <uart_putc>
  2016ee:	fec42783          	lw	a5,-20(s0)
  2016f2:	2781                	sext.w	a5,a5
  2016f4:	fcf04ee3          	bgtz	a5,2016d0 <uart_dec+0x6e>
  2016f8:	60a6                	ld	ra,72(sp)
  2016fa:	6406                	ld	s0,64(sp)
  2016fc:	6161                	addi	sp,sp,80
  2016fe:	8082                	ret

0000000000201700 <memset>:
  201700:	1101                	addi	sp,sp,-32
  201702:	ec22                	sd	s0,24(sp)
  201704:	1000                	addi	s0,sp,32
  201706:	fea43423          	sd	a0,-24(s0)
  20170a:	87ae                	mv	a5,a1
  20170c:	8732                	mv	a4,a2
  20170e:	fef42223          	sw	a5,-28(s0)
  201712:	87ba                	mv	a5,a4
  201714:	fef42023          	sw	a5,-32(s0)
  201718:	fe042783          	lw	a5,-32(s0)
  20171c:	2781                	sext.w	a5,a5
  20171e:	cf85                	beqz	a5,201756 <memset+0x56>
  201720:	fe442783          	lw	a5,-28(s0)
  201724:	0ff7f793          	zext.b	a5,a5
  201728:	fef42223          	sw	a5,-28(s0)
  20172c:	a829                	j	201746 <memset+0x46>
  20172e:	fe843783          	ld	a5,-24(s0)
  201732:	00178713          	addi	a4,a5,1
  201736:	fee43423          	sd	a4,-24(s0)
  20173a:	fe442703          	lw	a4,-28(s0)
  20173e:	0ff77713          	zext.b	a4,a4
  201742:	00e78023          	sb	a4,0(a5)
  201746:	fe042783          	lw	a5,-32(s0)
  20174a:	fff7871b          	addiw	a4,a5,-1
  20174e:	fee42023          	sw	a4,-32(s0)
  201752:	fff1                	bnez	a5,20172e <memset+0x2e>
  201754:	a011                	j	201758 <memset+0x58>
  201756:	0001                	nop
  201758:	6462                	ld	s0,24(sp)
  20175a:	6105                	addi	sp,sp,32
  20175c:	8082                	ret

000000000020175e <strcmp>:
  20175e:	7179                	addi	sp,sp,-48
  201760:	f422                	sd	s0,40(sp)
  201762:	1800                	addi	s0,sp,48
  201764:	fca43c23          	sd	a0,-40(s0)
  201768:	fcb43823          	sd	a1,-48(s0)
  20176c:	fd843783          	ld	a5,-40(s0)
  201770:	00178713          	addi	a4,a5,1
  201774:	fce43c23          	sd	a4,-40(s0)
  201778:	0007c783          	lbu	a5,0(a5)
  20177c:	fef407a3          	sb	a5,-17(s0)
  201780:	fd043783          	ld	a5,-48(s0)
  201784:	00178713          	addi	a4,a5,1
  201788:	fce43823          	sd	a4,-48(s0)
  20178c:	0007c783          	lbu	a5,0(a5)
  201790:	fef40723          	sb	a5,-18(s0)
  201794:	fef44783          	lbu	a5,-17(s0)
  201798:	873e                	mv	a4,a5
  20179a:	fee44783          	lbu	a5,-18(s0)
  20179e:	0ff77713          	zext.b	a4,a4
  2017a2:	0ff7f793          	zext.b	a5,a5
  2017a6:	00f70d63          	beq	a4,a5,2017c0 <strcmp+0x62>
  2017aa:	fef44783          	lbu	a5,-17(s0)
  2017ae:	0007871b          	sext.w	a4,a5
  2017b2:	fee44783          	lbu	a5,-18(s0)
  2017b6:	2781                	sext.w	a5,a5
  2017b8:	40f707bb          	subw	a5,a4,a5
  2017bc:	2781                	sext.w	a5,a5
  2017be:	a809                	j	2017d0 <strcmp+0x72>
  2017c0:	fef44783          	lbu	a5,-17(s0)
  2017c4:	0ff7f793          	zext.b	a5,a5
  2017c8:	c391                	beqz	a5,2017cc <strcmp+0x6e>
  2017ca:	b74d                	j	20176c <strcmp+0xe>
  2017cc:	0001                	nop
  2017ce:	4781                	li	a5,0
  2017d0:	853e                	mv	a0,a5
  2017d2:	7422                	ld	s0,40(sp)
  2017d4:	6145                	addi	sp,sp,48
  2017d6:	8082                	ret
