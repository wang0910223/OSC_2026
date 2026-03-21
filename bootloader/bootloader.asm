
kernel.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_code_start>:
    80200000:	00002297          	auipc	t0,0x2
    80200004:	d2028293          	addi	t0,t0,-736 # 80201d20 <dtb_addr>
    80200008:	00002317          	auipc	t1,0x2
    8020000c:	dc030313          	addi	t1,t1,-576 # 80201dc8 <__bss_end>

0000000080200010 <_clear_bss>:
    80200010:	0062d663          	bge	t0,t1,8020001c <_bss_done>
    80200014:	0002b023          	sd	zero,0(t0)
    80200018:	02a1                	addi	t0,t0,8
    8020001a:	bfdd                	j	80200010 <_clear_bss>

000000008020001c <_bss_done>:
    8020001c:	00006117          	auipc	sp,0x6
    80200020:	db410113          	addi	sp,sp,-588 # 80205dd0 <__stack_top>
    80200024:	4bf000ef          	jal	80200ce2 <main>

0000000080200028 <hex_to_ul>:
    80200028:	7139                	addi	sp,sp,-64
    8020002a:	fc22                	sd	s0,56(sp)
    8020002c:	0080                	addi	s0,sp,64
    8020002e:	fca43423          	sd	a0,-56(s0)
    80200032:	87ae                	mv	a5,a1
    80200034:	fcf42223          	sw	a5,-60(s0)
    80200038:	fe043423          	sd	zero,-24(s0)
    8020003c:	fe042223          	sw	zero,-28(s0)
    80200040:	a0e1                	j	80200108 <hex_to_ul+0xe0>
    80200042:	fe442783          	lw	a5,-28(s0)
    80200046:	fc843703          	ld	a4,-56(s0)
    8020004a:	97ba                	add	a5,a5,a4
    8020004c:	0007c783          	lbu	a5,0(a5)
    80200050:	fcf40ba3          	sb	a5,-41(s0)
    80200054:	fd744783          	lbu	a5,-41(s0)
    80200058:	0ff7f713          	zext.b	a4,a5
    8020005c:	02f00793          	li	a5,47
    80200060:	02e7f363          	bgeu	a5,a4,80200086 <hex_to_ul+0x5e>
    80200064:	fd744783          	lbu	a5,-41(s0)
    80200068:	0ff7f713          	zext.b	a4,a5
    8020006c:	03900793          	li	a5,57
    80200070:	00e7eb63          	bltu	a5,a4,80200086 <hex_to_ul+0x5e>
    80200074:	fd744783          	lbu	a5,-41(s0)
    80200078:	2781                	sext.w	a5,a5
    8020007a:	fd07879b          	addiw	a5,a5,-48
    8020007e:	2781                	sext.w	a5,a5
    80200080:	fcf43c23          	sd	a5,-40(s0)
    80200084:	a0ad                	j	802000ee <hex_to_ul+0xc6>
    80200086:	fd744783          	lbu	a5,-41(s0)
    8020008a:	0ff7f713          	zext.b	a4,a5
    8020008e:	06000793          	li	a5,96
    80200092:	02e7f363          	bgeu	a5,a4,802000b8 <hex_to_ul+0x90>
    80200096:	fd744783          	lbu	a5,-41(s0)
    8020009a:	0ff7f713          	zext.b	a4,a5
    8020009e:	06600793          	li	a5,102
    802000a2:	00e7eb63          	bltu	a5,a4,802000b8 <hex_to_ul+0x90>
    802000a6:	fd744783          	lbu	a5,-41(s0)
    802000aa:	2781                	sext.w	a5,a5
    802000ac:	fa97879b          	addiw	a5,a5,-87
    802000b0:	2781                	sext.w	a5,a5
    802000b2:	fcf43c23          	sd	a5,-40(s0)
    802000b6:	a825                	j	802000ee <hex_to_ul+0xc6>
    802000b8:	fd744783          	lbu	a5,-41(s0)
    802000bc:	0ff7f713          	zext.b	a4,a5
    802000c0:	04000793          	li	a5,64
    802000c4:	02e7f363          	bgeu	a5,a4,802000ea <hex_to_ul+0xc2>
    802000c8:	fd744783          	lbu	a5,-41(s0)
    802000cc:	0ff7f713          	zext.b	a4,a5
    802000d0:	04600793          	li	a5,70
    802000d4:	00e7eb63          	bltu	a5,a4,802000ea <hex_to_ul+0xc2>
    802000d8:	fd744783          	lbu	a5,-41(s0)
    802000dc:	2781                	sext.w	a5,a5
    802000de:	fc97879b          	addiw	a5,a5,-55
    802000e2:	2781                	sext.w	a5,a5
    802000e4:	fcf43c23          	sd	a5,-40(s0)
    802000e8:	a019                	j	802000ee <hex_to_ul+0xc6>
    802000ea:	fc043c23          	sd	zero,-40(s0)
    802000ee:	fe843783          	ld	a5,-24(s0)
    802000f2:	0792                	slli	a5,a5,0x4
    802000f4:	fd843703          	ld	a4,-40(s0)
    802000f8:	8fd9                	or	a5,a5,a4
    802000fa:	fef43423          	sd	a5,-24(s0)
    802000fe:	fe442783          	lw	a5,-28(s0)
    80200102:	2785                	addiw	a5,a5,1
    80200104:	fef42223          	sw	a5,-28(s0)
    80200108:	fe442783          	lw	a5,-28(s0)
    8020010c:	873e                	mv	a4,a5
    8020010e:	fc442783          	lw	a5,-60(s0)
    80200112:	2701                	sext.w	a4,a4
    80200114:	2781                	sext.w	a5,a5
    80200116:	f2f746e3          	blt	a4,a5,80200042 <hex_to_ul+0x1a>
    8020011a:	fe843783          	ld	a5,-24(s0)
    8020011e:	853e                	mv	a0,a5
    80200120:	7462                	ld	s0,56(sp)
    80200122:	6121                	addi	sp,sp,64
    80200124:	8082                	ret

0000000080200126 <align4>:
    80200126:	1101                	addi	sp,sp,-32
    80200128:	ec22                	sd	s0,24(sp)
    8020012a:	1000                	addi	s0,sp,32
    8020012c:	fea43423          	sd	a0,-24(s0)
    80200130:	fe843783          	ld	a5,-24(s0)
    80200134:	078d                	addi	a5,a5,3
    80200136:	9bf1                	andi	a5,a5,-4
    80200138:	853e                	mv	a0,a5
    8020013a:	6462                	ld	s0,24(sp)
    8020013c:	6105                	addi	sp,sp,32
    8020013e:	8082                	ret

0000000080200140 <cpio_strcmp>:
    80200140:	1101                	addi	sp,sp,-32
    80200142:	ec22                	sd	s0,24(sp)
    80200144:	1000                	addi	s0,sp,32
    80200146:	fea43423          	sd	a0,-24(s0)
    8020014a:	feb43023          	sd	a1,-32(s0)
    8020014e:	a819                	j	80200164 <cpio_strcmp+0x24>
    80200150:	fe843783          	ld	a5,-24(s0)
    80200154:	0785                	addi	a5,a5,1
    80200156:	fef43423          	sd	a5,-24(s0)
    8020015a:	fe043783          	ld	a5,-32(s0)
    8020015e:	0785                	addi	a5,a5,1
    80200160:	fef43023          	sd	a5,-32(s0)
    80200164:	fe843783          	ld	a5,-24(s0)
    80200168:	0007c783          	lbu	a5,0(a5)
    8020016c:	c385                	beqz	a5,8020018c <cpio_strcmp+0x4c>
    8020016e:	fe043783          	ld	a5,-32(s0)
    80200172:	0007c783          	lbu	a5,0(a5)
    80200176:	cb99                	beqz	a5,8020018c <cpio_strcmp+0x4c>
    80200178:	fe843783          	ld	a5,-24(s0)
    8020017c:	0007c703          	lbu	a4,0(a5)
    80200180:	fe043783          	ld	a5,-32(s0)
    80200184:	0007c783          	lbu	a5,0(a5)
    80200188:	fcf704e3          	beq	a4,a5,80200150 <cpio_strcmp+0x10>
    8020018c:	fe843783          	ld	a5,-24(s0)
    80200190:	0007c783          	lbu	a5,0(a5)
    80200194:	0007871b          	sext.w	a4,a5
    80200198:	fe043783          	ld	a5,-32(s0)
    8020019c:	0007c783          	lbu	a5,0(a5)
    802001a0:	2781                	sext.w	a5,a5
    802001a2:	40f707bb          	subw	a5,a4,a5
    802001a6:	2781                	sext.w	a5,a5
    802001a8:	853e                	mv	a0,a5
    802001aa:	6462                	ld	s0,24(sp)
    802001ac:	6105                	addi	sp,sp,32
    802001ae:	8082                	ret

00000000802001b0 <cpio_ls>:
    802001b0:	7119                	addi	sp,sp,-128
    802001b2:	fc86                	sd	ra,120(sp)
    802001b4:	f8a2                	sd	s0,112(sp)
    802001b6:	f4a6                	sd	s1,104(sp)
    802001b8:	0100                	addi	s0,sp,128
    802001ba:	f8a43423          	sd	a0,-120(s0)
    802001be:	fc043823          	sd	zero,-48(s0)
    802001c2:	f8843783          	ld	a5,-120(s0)
    802001c6:	fcf43c23          	sd	a5,-40(s0)
    802001ca:	fd843783          	ld	a5,-40(s0)
    802001ce:	fcf43423          	sd	a5,-56(s0)
    802001d2:	fc843783          	ld	a5,-56(s0)
    802001d6:	0007c783          	lbu	a5,0(a5)
    802001da:	873e                	mv	a4,a5
    802001dc:	03000793          	li	a5,48
    802001e0:	04f71663          	bne	a4,a5,8020022c <cpio_ls+0x7c>
    802001e4:	fc843783          	ld	a5,-56(s0)
    802001e8:	0017c783          	lbu	a5,1(a5)
    802001ec:	873e                	mv	a4,a5
    802001ee:	03700793          	li	a5,55
    802001f2:	02f71d63          	bne	a4,a5,8020022c <cpio_ls+0x7c>
    802001f6:	fc843783          	ld	a5,-56(s0)
    802001fa:	0027c783          	lbu	a5,2(a5)
    802001fe:	873e                	mv	a4,a5
    80200200:	03000793          	li	a5,48
    80200204:	02f71463          	bne	a4,a5,8020022c <cpio_ls+0x7c>
    80200208:	fc843783          	ld	a5,-56(s0)
    8020020c:	0037c783          	lbu	a5,3(a5)
    80200210:	873e                	mv	a4,a5
    80200212:	03700793          	li	a5,55
    80200216:	00f71b63          	bne	a4,a5,8020022c <cpio_ls+0x7c>
    8020021a:	fc843783          	ld	a5,-56(s0)
    8020021e:	0047c783          	lbu	a5,4(a5)
    80200222:	873e                	mv	a4,a5
    80200224:	03000793          	li	a5,48
    80200228:	00f70963          	beq	a4,a5,8020023a <cpio_ls+0x8a>
    8020022c:	00001517          	auipc	a0,0x1
    80200230:	6fc50513          	addi	a0,a0,1788 # 80201928 <strcmp+0x7c>
    80200234:	4c0010ef          	jal	802016f4 <uart_puts>
    80200238:	a24d                	j	802003da <cpio_ls+0x22a>
    8020023a:	fc843783          	ld	a5,-56(s0)
    8020023e:	05e78793          	addi	a5,a5,94
    80200242:	45a1                	li	a1,8
    80200244:	853e                	mv	a0,a5
    80200246:	de3ff0ef          	jal	80200028 <hex_to_ul>
    8020024a:	fca43023          	sd	a0,-64(s0)
    8020024e:	fc843783          	ld	a5,-56(s0)
    80200252:	03678793          	addi	a5,a5,54
    80200256:	45a1                	li	a1,8
    80200258:	853e                	mv	a0,a5
    8020025a:	dcfff0ef          	jal	80200028 <hex_to_ul>
    8020025e:	faa43c23          	sd	a0,-72(s0)
    80200262:	fd843783          	ld	a5,-40(s0)
    80200266:	06e78793          	addi	a5,a5,110
    8020026a:	faf43823          	sd	a5,-80(s0)
    8020026e:	00001597          	auipc	a1,0x1
    80200272:	6da58593          	addi	a1,a1,1754 # 80201948 <strcmp+0x9c>
    80200276:	fb043503          	ld	a0,-80(s0)
    8020027a:	ec7ff0ef          	jal	80200140 <cpio_strcmp>
    8020027e:	87aa                	mv	a5,a0
    80200280:	cb95                	beqz	a5,802002b4 <cpio_ls+0x104>
    80200282:	fd043783          	ld	a5,-48(s0)
    80200286:	0785                	addi	a5,a5,1
    80200288:	fcf43823          	sd	a5,-48(s0)
    8020028c:	fc043783          	ld	a5,-64(s0)
    80200290:	06e78793          	addi	a5,a5,110
    80200294:	853e                	mv	a0,a5
    80200296:	e91ff0ef          	jal	80200126 <align4>
    8020029a:	84aa                	mv	s1,a0
    8020029c:	fb843503          	ld	a0,-72(s0)
    802002a0:	e87ff0ef          	jal	80200126 <align4>
    802002a4:	87aa                	mv	a5,a0
    802002a6:	97a6                	add	a5,a5,s1
    802002a8:	fd843703          	ld	a4,-40(s0)
    802002ac:	97ba                	add	a5,a5,a4
    802002ae:	fcf43c23          	sd	a5,-40(s0)
    802002b2:	bf21                	j	802001ca <cpio_ls+0x1a>
    802002b4:	0001                	nop
    802002b6:	00001517          	auipc	a0,0x1
    802002ba:	6a250513          	addi	a0,a0,1698 # 80201958 <strcmp+0xac>
    802002be:	436010ef          	jal	802016f4 <uart_puts>
    802002c2:	fd043503          	ld	a0,-48(s0)
    802002c6:	4ea010ef          	jal	802017b0 <uart_dec>
    802002ca:	00001517          	auipc	a0,0x1
    802002ce:	69650513          	addi	a0,a0,1686 # 80201960 <strcmp+0xb4>
    802002d2:	422010ef          	jal	802016f4 <uart_puts>
    802002d6:	f8843783          	ld	a5,-120(s0)
    802002da:	fcf43c23          	sd	a5,-40(s0)
    802002de:	fd843783          	ld	a5,-40(s0)
    802002e2:	faf43423          	sd	a5,-88(s0)
    802002e6:	fa843783          	ld	a5,-88(s0)
    802002ea:	0007c783          	lbu	a5,0(a5)
    802002ee:	873e                	mv	a4,a5
    802002f0:	03000793          	li	a5,48
    802002f4:	0ef71363          	bne	a4,a5,802003da <cpio_ls+0x22a>
    802002f8:	fa843783          	ld	a5,-88(s0)
    802002fc:	0017c783          	lbu	a5,1(a5)
    80200300:	873e                	mv	a4,a5
    80200302:	03700793          	li	a5,55
    80200306:	0cf71a63          	bne	a4,a5,802003da <cpio_ls+0x22a>
    8020030a:	fa843783          	ld	a5,-88(s0)
    8020030e:	0027c783          	lbu	a5,2(a5)
    80200312:	873e                	mv	a4,a5
    80200314:	03000793          	li	a5,48
    80200318:	0cf71163          	bne	a4,a5,802003da <cpio_ls+0x22a>
    8020031c:	fa843783          	ld	a5,-88(s0)
    80200320:	0037c783          	lbu	a5,3(a5)
    80200324:	873e                	mv	a4,a5
    80200326:	03700793          	li	a5,55
    8020032a:	0af71863          	bne	a4,a5,802003da <cpio_ls+0x22a>
    8020032e:	fa843783          	ld	a5,-88(s0)
    80200332:	0047c783          	lbu	a5,4(a5)
    80200336:	873e                	mv	a4,a5
    80200338:	03000793          	li	a5,48
    8020033c:	08f71f63          	bne	a4,a5,802003da <cpio_ls+0x22a>
    80200340:	fa843783          	ld	a5,-88(s0)
    80200344:	05e78793          	addi	a5,a5,94
    80200348:	45a1                	li	a1,8
    8020034a:	853e                	mv	a0,a5
    8020034c:	cddff0ef          	jal	80200028 <hex_to_ul>
    80200350:	faa43023          	sd	a0,-96(s0)
    80200354:	fa843783          	ld	a5,-88(s0)
    80200358:	03678793          	addi	a5,a5,54
    8020035c:	45a1                	li	a1,8
    8020035e:	853e                	mv	a0,a5
    80200360:	cc9ff0ef          	jal	80200028 <hex_to_ul>
    80200364:	f8a43c23          	sd	a0,-104(s0)
    80200368:	fd843783          	ld	a5,-40(s0)
    8020036c:	06e78793          	addi	a5,a5,110
    80200370:	f8f43823          	sd	a5,-112(s0)
    80200374:	00001597          	auipc	a1,0x1
    80200378:	5d458593          	addi	a1,a1,1492 # 80201948 <strcmp+0x9c>
    8020037c:	f9043503          	ld	a0,-112(s0)
    80200380:	dc1ff0ef          	jal	80200140 <cpio_strcmp>
    80200384:	87aa                	mv	a5,a0
    80200386:	cba9                	beqz	a5,802003d8 <cpio_ls+0x228>
    80200388:	f9843503          	ld	a0,-104(s0)
    8020038c:	424010ef          	jal	802017b0 <uart_dec>
    80200390:	00001517          	auipc	a0,0x1
    80200394:	5e050513          	addi	a0,a0,1504 # 80201970 <strcmp+0xc4>
    80200398:	35c010ef          	jal	802016f4 <uart_puts>
    8020039c:	f9043503          	ld	a0,-112(s0)
    802003a0:	354010ef          	jal	802016f4 <uart_puts>
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	5d450513          	addi	a0,a0,1492 # 80201978 <strcmp+0xcc>
    802003ac:	348010ef          	jal	802016f4 <uart_puts>
    802003b0:	fa043783          	ld	a5,-96(s0)
    802003b4:	06e78793          	addi	a5,a5,110
    802003b8:	853e                	mv	a0,a5
    802003ba:	d6dff0ef          	jal	80200126 <align4>
    802003be:	84aa                	mv	s1,a0
    802003c0:	f9843503          	ld	a0,-104(s0)
    802003c4:	d63ff0ef          	jal	80200126 <align4>
    802003c8:	87aa                	mv	a5,a0
    802003ca:	97a6                	add	a5,a5,s1
    802003cc:	fd843703          	ld	a4,-40(s0)
    802003d0:	97ba                	add	a5,a5,a4
    802003d2:	fcf43c23          	sd	a5,-40(s0)
    802003d6:	b721                	j	802002de <cpio_ls+0x12e>
    802003d8:	0001                	nop
    802003da:	70e6                	ld	ra,120(sp)
    802003dc:	7446                	ld	s0,112(sp)
    802003de:	74a6                	ld	s1,104(sp)
    802003e0:	6109                	addi	sp,sp,128
    802003e2:	8082                	ret

00000000802003e4 <cpio_cat>:
    802003e4:	711d                	addi	sp,sp,-96
    802003e6:	ec86                	sd	ra,88(sp)
    802003e8:	e8a2                	sd	s0,80(sp)
    802003ea:	1080                	addi	s0,sp,96
    802003ec:	faa43423          	sd	a0,-88(s0)
    802003f0:	fab43023          	sd	a1,-96(s0)
    802003f4:	fa843783          	ld	a5,-88(s0)
    802003f8:	fef43423          	sd	a5,-24(s0)
    802003fc:	fe843783          	ld	a5,-24(s0)
    80200400:	fcf43c23          	sd	a5,-40(s0)
    80200404:	fd843783          	ld	a5,-40(s0)
    80200408:	0007c783          	lbu	a5,0(a5)
    8020040c:	873e                	mv	a4,a5
    8020040e:	03000793          	li	a5,48
    80200412:	04f71663          	bne	a4,a5,8020045e <cpio_cat+0x7a>
    80200416:	fd843783          	ld	a5,-40(s0)
    8020041a:	0017c783          	lbu	a5,1(a5)
    8020041e:	873e                	mv	a4,a5
    80200420:	03700793          	li	a5,55
    80200424:	02f71d63          	bne	a4,a5,8020045e <cpio_cat+0x7a>
    80200428:	fd843783          	ld	a5,-40(s0)
    8020042c:	0027c783          	lbu	a5,2(a5)
    80200430:	873e                	mv	a4,a5
    80200432:	03000793          	li	a5,48
    80200436:	02f71463          	bne	a4,a5,8020045e <cpio_cat+0x7a>
    8020043a:	fd843783          	ld	a5,-40(s0)
    8020043e:	0037c783          	lbu	a5,3(a5)
    80200442:	873e                	mv	a4,a5
    80200444:	03700793          	li	a5,55
    80200448:	00f71b63          	bne	a4,a5,8020045e <cpio_cat+0x7a>
    8020044c:	fd843783          	ld	a5,-40(s0)
    80200450:	0047c783          	lbu	a5,4(a5)
    80200454:	873e                	mv	a4,a5
    80200456:	03000793          	li	a5,48
    8020045a:	00f70963          	beq	a4,a5,8020046c <cpio_cat+0x88>
    8020045e:	00001517          	auipc	a0,0x1
    80200462:	4ca50513          	addi	a0,a0,1226 # 80201928 <strcmp+0x7c>
    80200466:	28e010ef          	jal	802016f4 <uart_puts>
    8020046a:	a8dd                	j	80200560 <cpio_cat+0x17c>
    8020046c:	fd843783          	ld	a5,-40(s0)
    80200470:	05e78793          	addi	a5,a5,94
    80200474:	45a1                	li	a1,8
    80200476:	853e                	mv	a0,a5
    80200478:	bb1ff0ef          	jal	80200028 <hex_to_ul>
    8020047c:	fca43823          	sd	a0,-48(s0)
    80200480:	fd843783          	ld	a5,-40(s0)
    80200484:	03678793          	addi	a5,a5,54
    80200488:	45a1                	li	a1,8
    8020048a:	853e                	mv	a0,a5
    8020048c:	b9dff0ef          	jal	80200028 <hex_to_ul>
    80200490:	fca43423          	sd	a0,-56(s0)
    80200494:	fe843783          	ld	a5,-24(s0)
    80200498:	06e78793          	addi	a5,a5,110
    8020049c:	fcf43023          	sd	a5,-64(s0)
    802004a0:	00001597          	auipc	a1,0x1
    802004a4:	4a858593          	addi	a1,a1,1192 # 80201948 <strcmp+0x9c>
    802004a8:	fc043503          	ld	a0,-64(s0)
    802004ac:	c95ff0ef          	jal	80200140 <cpio_strcmp>
    802004b0:	87aa                	mv	a5,a0
    802004b2:	c7d5                	beqz	a5,8020055e <cpio_cat+0x17a>
    802004b4:	fd043783          	ld	a5,-48(s0)
    802004b8:	06e78793          	addi	a5,a5,110
    802004bc:	853e                	mv	a0,a5
    802004be:	c69ff0ef          	jal	80200126 <align4>
    802004c2:	faa43c23          	sd	a0,-72(s0)
    802004c6:	fa043583          	ld	a1,-96(s0)
    802004ca:	fc043503          	ld	a0,-64(s0)
    802004ce:	c73ff0ef          	jal	80200140 <cpio_strcmp>
    802004d2:	87aa                	mv	a5,a0
    802004d4:	e7bd                	bnez	a5,80200542 <cpio_cat+0x15e>
    802004d6:	fe843703          	ld	a4,-24(s0)
    802004da:	fb843783          	ld	a5,-72(s0)
    802004de:	97ba                	add	a5,a5,a4
    802004e0:	faf43823          	sd	a5,-80(s0)
    802004e4:	fe043023          	sd	zero,-32(s0)
    802004e8:	a00d                	j	8020050a <cpio_cat+0x126>
    802004ea:	fb043703          	ld	a4,-80(s0)
    802004ee:	fe043783          	ld	a5,-32(s0)
    802004f2:	97ba                	add	a5,a5,a4
    802004f4:	0007c783          	lbu	a5,0(a5)
    802004f8:	2781                	sext.w	a5,a5
    802004fa:	853e                	mv	a0,a5
    802004fc:	10a010ef          	jal	80201606 <uart_putc>
    80200500:	fe043783          	ld	a5,-32(s0)
    80200504:	0785                	addi	a5,a5,1
    80200506:	fef43023          	sd	a5,-32(s0)
    8020050a:	fe043703          	ld	a4,-32(s0)
    8020050e:	fc843783          	ld	a5,-56(s0)
    80200512:	fcf76ce3          	bltu	a4,a5,802004ea <cpio_cat+0x106>
    80200516:	fc843783          	ld	a5,-56(s0)
    8020051a:	cf89                	beqz	a5,80200534 <cpio_cat+0x150>
    8020051c:	fc843783          	ld	a5,-56(s0)
    80200520:	17fd                	addi	a5,a5,-1
    80200522:	fb043703          	ld	a4,-80(s0)
    80200526:	97ba                	add	a5,a5,a4
    80200528:	0007c783          	lbu	a5,0(a5)
    8020052c:	873e                	mv	a4,a5
    8020052e:	47a9                	li	a5,10
    80200530:	04f70963          	beq	a4,a5,80200582 <cpio_cat+0x19e>
    80200534:	00001517          	auipc	a0,0x1
    80200538:	44450513          	addi	a0,a0,1092 # 80201978 <strcmp+0xcc>
    8020053c:	1b8010ef          	jal	802016f4 <uart_puts>
    80200540:	a089                	j	80200582 <cpio_cat+0x19e>
    80200542:	fc843503          	ld	a0,-56(s0)
    80200546:	be1ff0ef          	jal	80200126 <align4>
    8020054a:	872a                	mv	a4,a0
    8020054c:	fb843783          	ld	a5,-72(s0)
    80200550:	97ba                	add	a5,a5,a4
    80200552:	fe843703          	ld	a4,-24(s0)
    80200556:	97ba                	add	a5,a5,a4
    80200558:	fef43423          	sd	a5,-24(s0)
    8020055c:	b545                	j	802003fc <cpio_cat+0x18>
    8020055e:	0001                	nop
    80200560:	00001517          	auipc	a0,0x1
    80200564:	42050513          	addi	a0,a0,1056 # 80201980 <strcmp+0xd4>
    80200568:	18c010ef          	jal	802016f4 <uart_puts>
    8020056c:	fa043503          	ld	a0,-96(s0)
    80200570:	184010ef          	jal	802016f4 <uart_puts>
    80200574:	00001517          	auipc	a0,0x1
    80200578:	40450513          	addi	a0,a0,1028 # 80201978 <strcmp+0xcc>
    8020057c:	178010ef          	jal	802016f4 <uart_puts>
    80200580:	a011                	j	80200584 <cpio_cat+0x1a0>
    80200582:	0001                	nop
    80200584:	60e6                	ld	ra,88(sp)
    80200586:	6446                	ld	s0,80(sp)
    80200588:	6125                	addi	sp,sp,96
    8020058a:	8082                	ret

000000008020058c <bswap_32>:
    8020058c:	1101                	addi	sp,sp,-32
    8020058e:	ec22                	sd	s0,24(sp)
    80200590:	1000                	addi	s0,sp,32
    80200592:	87aa                	mv	a5,a0
    80200594:	fef42623          	sw	a5,-20(s0)
    80200598:	fec42783          	lw	a5,-20(s0)
    8020059c:	0187d79b          	srliw	a5,a5,0x18
    802005a0:	0007871b          	sext.w	a4,a5
    802005a4:	fec42783          	lw	a5,-20(s0)
    802005a8:	0087d79b          	srliw	a5,a5,0x8
    802005ac:	2781                	sext.w	a5,a5
    802005ae:	86be                	mv	a3,a5
    802005b0:	67c1                	lui	a5,0x10
    802005b2:	f0078793          	addi	a5,a5,-256 # ff00 <_code_size+0xa130>
    802005b6:	8ff5                	and	a5,a5,a3
    802005b8:	2781                	sext.w	a5,a5
    802005ba:	8fd9                	or	a5,a5,a4
    802005bc:	0007871b          	sext.w	a4,a5
    802005c0:	fec42783          	lw	a5,-20(s0)
    802005c4:	0087979b          	slliw	a5,a5,0x8
    802005c8:	2781                	sext.w	a5,a5
    802005ca:	86be                	mv	a3,a5
    802005cc:	00ff07b7          	lui	a5,0xff0
    802005d0:	8ff5                	and	a5,a5,a3
    802005d2:	2781                	sext.w	a5,a5
    802005d4:	8fd9                	or	a5,a5,a4
    802005d6:	0007871b          	sext.w	a4,a5
    802005da:	fec42783          	lw	a5,-20(s0)
    802005de:	0187979b          	slliw	a5,a5,0x18
    802005e2:	2781                	sext.w	a5,a5
    802005e4:	8fd9                	or	a5,a5,a4
    802005e6:	2781                	sext.w	a5,a5
    802005e8:	853e                	mv	a0,a5
    802005ea:	6462                	ld	s0,24(sp)
    802005ec:	6105                	addi	sp,sp,32
    802005ee:	8082                	ret

00000000802005f0 <align_32>:
    802005f0:	1101                	addi	sp,sp,-32
    802005f2:	ec22                	sd	s0,24(sp)
    802005f4:	1000                	addi	s0,sp,32
    802005f6:	fea43423          	sd	a0,-24(s0)
    802005fa:	fe843783          	ld	a5,-24(s0)
    802005fe:	078d                	addi	a5,a5,3 # ff0003 <_code_size+0xfea233>
    80200600:	9bf1                	andi	a5,a5,-4
    80200602:	853e                	mv	a0,a5
    80200604:	6462                	ld	s0,24(sp)
    80200606:	6105                	addi	sp,sp,32
    80200608:	8082                	ret

000000008020060a <node_name_match>:
    8020060a:	1101                	addi	sp,sp,-32
    8020060c:	ec22                	sd	s0,24(sp)
    8020060e:	1000                	addi	s0,sp,32
    80200610:	fea43423          	sd	a0,-24(s0)
    80200614:	feb43023          	sd	a1,-32(s0)
    80200618:	a0b9                	j	80200666 <node_name_match+0x5c>
    8020061a:	fe843783          	ld	a5,-24(s0)
    8020061e:	0007c783          	lbu	a5,0(a5)
    80200622:	cb91                	beqz	a5,80200636 <node_name_match+0x2c>
    80200624:	fe843783          	ld	a5,-24(s0)
    80200628:	0007c783          	lbu	a5,0(a5)
    8020062c:	873e                	mv	a4,a5
    8020062e:	04000793          	li	a5,64
    80200632:	00f71463          	bne	a4,a5,8020063a <node_name_match+0x30>
    80200636:	4781                	li	a5,0
    80200638:	a8a9                	j	80200692 <node_name_match+0x88>
    8020063a:	fe843783          	ld	a5,-24(s0)
    8020063e:	0007c703          	lbu	a4,0(a5)
    80200642:	fe043783          	ld	a5,-32(s0)
    80200646:	0007c783          	lbu	a5,0(a5)
    8020064a:	00f70463          	beq	a4,a5,80200652 <node_name_match+0x48>
    8020064e:	4781                	li	a5,0
    80200650:	a089                	j	80200692 <node_name_match+0x88>
    80200652:	fe843783          	ld	a5,-24(s0)
    80200656:	0785                	addi	a5,a5,1
    80200658:	fef43423          	sd	a5,-24(s0)
    8020065c:	fe043783          	ld	a5,-32(s0)
    80200660:	0785                	addi	a5,a5,1
    80200662:	fef43023          	sd	a5,-32(s0)
    80200666:	fe043783          	ld	a5,-32(s0)
    8020066a:	0007c783          	lbu	a5,0(a5)
    8020066e:	f7d5                	bnez	a5,8020061a <node_name_match+0x10>
    80200670:	fe843783          	ld	a5,-24(s0)
    80200674:	0007c783          	lbu	a5,0(a5)
    80200678:	cb91                	beqz	a5,8020068c <node_name_match+0x82>
    8020067a:	fe843783          	ld	a5,-24(s0)
    8020067e:	0007c783          	lbu	a5,0(a5)
    80200682:	873e                	mv	a4,a5
    80200684:	04000793          	li	a5,64
    80200688:	00f71463          	bne	a4,a5,80200690 <node_name_match+0x86>
    8020068c:	4785                	li	a5,1
    8020068e:	a011                	j	80200692 <node_name_match+0x88>
    80200690:	4781                	li	a5,0
    80200692:	853e                	mv	a0,a5
    80200694:	6462                	ld	s0,24(sp)
    80200696:	6105                	addi	sp,sp,32
    80200698:	8082                	ret

000000008020069a <path_segment>:
    8020069a:	715d                	addi	sp,sp,-80
    8020069c:	e4a2                	sd	s0,72(sp)
    8020069e:	0880                	addi	s0,sp,80
    802006a0:	fca43423          	sd	a0,-56(s0)
    802006a4:	87ae                	mv	a5,a1
    802006a6:	fac43c23          	sd	a2,-72(s0)
    802006aa:	fcf42223          	sw	a5,-60(s0)
    802006ae:	fc843783          	ld	a5,-56(s0)
    802006b2:	cb91                	beqz	a5,802006c6 <path_segment+0x2c>
    802006b4:	fc843783          	ld	a5,-56(s0)
    802006b8:	0007c783          	lbu	a5,0(a5)
    802006bc:	873e                	mv	a4,a5
    802006be:	02f00793          	li	a5,47
    802006c2:	00f70463          	beq	a4,a5,802006ca <path_segment+0x30>
    802006c6:	4781                	li	a5,0
    802006c8:	a055                	j	8020076c <path_segment+0xd2>
    802006ca:	fc843783          	ld	a5,-56(s0)
    802006ce:	0785                	addi	a5,a5,1
    802006d0:	fef43423          	sd	a5,-24(s0)
    802006d4:	fe042223          	sw	zero,-28(s0)
    802006d8:	fe843783          	ld	a5,-24(s0)
    802006dc:	0007c783          	lbu	a5,0(a5)
    802006e0:	e399                	bnez	a5,802006e6 <path_segment+0x4c>
    802006e2:	4781                	li	a5,0
    802006e4:	a061                	j	8020076c <path_segment+0xd2>
    802006e6:	fe843783          	ld	a5,-24(s0)
    802006ea:	fcf43c23          	sd	a5,-40(s0)
    802006ee:	a031                	j	802006fa <path_segment+0x60>
    802006f0:	fe843783          	ld	a5,-24(s0)
    802006f4:	0785                	addi	a5,a5,1
    802006f6:	fef43423          	sd	a5,-24(s0)
    802006fa:	fe843783          	ld	a5,-24(s0)
    802006fe:	0007c783          	lbu	a5,0(a5)
    80200702:	cb91                	beqz	a5,80200716 <path_segment+0x7c>
    80200704:	fe843783          	ld	a5,-24(s0)
    80200708:	0007c783          	lbu	a5,0(a5)
    8020070c:	873e                	mv	a4,a5
    8020070e:	02f00793          	li	a5,47
    80200712:	fcf71fe3          	bne	a4,a5,802006f0 <path_segment+0x56>
    80200716:	fe442783          	lw	a5,-28(s0)
    8020071a:	873e                	mv	a4,a5
    8020071c:	fc442783          	lw	a5,-60(s0)
    80200720:	2701                	sext.w	a4,a4
    80200722:	2781                	sext.w	a5,a5
    80200724:	02f71063          	bne	a4,a5,80200744 <path_segment+0xaa>
    80200728:	fe843703          	ld	a4,-24(s0)
    8020072c:	fd843783          	ld	a5,-40(s0)
    80200730:	40f707b3          	sub	a5,a4,a5
    80200734:	0007871b          	sext.w	a4,a5
    80200738:	fb843783          	ld	a5,-72(s0)
    8020073c:	c398                	sw	a4,0(a5)
    8020073e:	fd843783          	ld	a5,-40(s0)
    80200742:	a02d                	j	8020076c <path_segment+0xd2>
    80200744:	fe442783          	lw	a5,-28(s0)
    80200748:	2785                	addiw	a5,a5,1
    8020074a:	fef42223          	sw	a5,-28(s0)
    8020074e:	fe843783          	ld	a5,-24(s0)
    80200752:	0007c783          	lbu	a5,0(a5)
    80200756:	873e                	mv	a4,a5
    80200758:	02f00793          	li	a5,47
    8020075c:	f6f71ee3          	bne	a4,a5,802006d8 <path_segment+0x3e>
    80200760:	fe843783          	ld	a5,-24(s0)
    80200764:	0785                	addi	a5,a5,1
    80200766:	fef43423          	sd	a5,-24(s0)
    8020076a:	b7bd                	j	802006d8 <path_segment+0x3e>
    8020076c:	853e                	mv	a0,a5
    8020076e:	6426                	ld	s0,72(sp)
    80200770:	6161                	addi	sp,sp,80
    80200772:	8082                	ret

0000000080200774 <path_depth>:
    80200774:	7179                	addi	sp,sp,-48
    80200776:	f422                	sd	s0,40(sp)
    80200778:	1800                	addi	s0,sp,48
    8020077a:	fca43c23          	sd	a0,-40(s0)
    8020077e:	fd843783          	ld	a5,-40(s0)
    80200782:	cb91                	beqz	a5,80200796 <path_depth+0x22>
    80200784:	fd843783          	ld	a5,-40(s0)
    80200788:	0007c783          	lbu	a5,0(a5)
    8020078c:	873e                	mv	a4,a5
    8020078e:	02f00793          	li	a5,47
    80200792:	00f70463          	beq	a4,a5,8020079a <path_depth+0x26>
    80200796:	57fd                	li	a5,-1
    80200798:	a8a9                	j	802007f2 <path_depth+0x7e>
    8020079a:	fd843783          	ld	a5,-40(s0)
    8020079e:	0785                	addi	a5,a5,1
    802007a0:	0007c783          	lbu	a5,0(a5)
    802007a4:	e399                	bnez	a5,802007aa <path_depth+0x36>
    802007a6:	4781                	li	a5,0
    802007a8:	a0a9                	j	802007f2 <path_depth+0x7e>
    802007aa:	fe042623          	sw	zero,-20(s0)
    802007ae:	fd843783          	ld	a5,-40(s0)
    802007b2:	0785                	addi	a5,a5,1
    802007b4:	fef43023          	sd	a5,-32(s0)
    802007b8:	a025                	j	802007e0 <path_depth+0x6c>
    802007ba:	fe043783          	ld	a5,-32(s0)
    802007be:	0007c783          	lbu	a5,0(a5)
    802007c2:	873e                	mv	a4,a5
    802007c4:	02f00793          	li	a5,47
    802007c8:	00f71763          	bne	a4,a5,802007d6 <path_depth+0x62>
    802007cc:	fec42783          	lw	a5,-20(s0)
    802007d0:	2785                	addiw	a5,a5,1
    802007d2:	fef42623          	sw	a5,-20(s0)
    802007d6:	fe043783          	ld	a5,-32(s0)
    802007da:	0785                	addi	a5,a5,1
    802007dc:	fef43023          	sd	a5,-32(s0)
    802007e0:	fe043783          	ld	a5,-32(s0)
    802007e4:	0007c783          	lbu	a5,0(a5)
    802007e8:	fbe9                	bnez	a5,802007ba <path_depth+0x46>
    802007ea:	fec42783          	lw	a5,-20(s0)
    802007ee:	2785                	addiw	a5,a5,1
    802007f0:	2781                	sext.w	a5,a5
    802007f2:	853e                	mv	a0,a5
    802007f4:	7422                	ld	s0,40(sp)
    802007f6:	6145                	addi	sp,sp,48
    802007f8:	8082                	ret

00000000802007fa <dtb_set_addr>:
    802007fa:	1101                	addi	sp,sp,-32
    802007fc:	ec22                	sd	s0,24(sp)
    802007fe:	1000                	addi	s0,sp,32
    80200800:	fea43423          	sd	a0,-24(s0)
    80200804:	00001797          	auipc	a5,0x1
    80200808:	51c78793          	addi	a5,a5,1308 # 80201d20 <dtb_addr>
    8020080c:	fe843703          	ld	a4,-24(s0)
    80200810:	e398                	sd	a4,0(a5)
    80200812:	0001                	nop
    80200814:	6462                	ld	s0,24(sp)
    80200816:	6105                	addi	sp,sp,32
    80200818:	8082                	ret

000000008020081a <dtb_getprop>:
    8020081a:	7151                	addi	sp,sp,-240
    8020081c:	f586                	sd	ra,232(sp)
    8020081e:	f1a2                	sd	s0,224(sp)
    80200820:	1980                	addi	s0,sp,240
    80200822:	f2a43423          	sd	a0,-216(s0)
    80200826:	f2b43023          	sd	a1,-224(s0)
    8020082a:	f0c43c23          	sd	a2,-232(s0)
    8020082e:	00001797          	auipc	a5,0x1
    80200832:	4f278793          	addi	a5,a5,1266 # 80201d20 <dtb_addr>
    80200836:	639c                	ld	a5,0(a5)
    80200838:	c799                	beqz	a5,80200846 <dtb_getprop+0x2c>
    8020083a:	f2843783          	ld	a5,-216(s0)
    8020083e:	c781                	beqz	a5,80200846 <dtb_getprop+0x2c>
    80200840:	f2043783          	ld	a5,-224(s0)
    80200844:	e399                	bnez	a5,8020084a <dtb_getprop+0x30>
    80200846:	4781                	li	a5,0
    80200848:	acdd                	j	80200b3e <dtb_getprop+0x324>
    8020084a:	00001797          	auipc	a5,0x1
    8020084e:	4d678793          	addi	a5,a5,1238 # 80201d20 <dtb_addr>
    80200852:	639c                	ld	a5,0(a5)
    80200854:	fcf43823          	sd	a5,-48(s0)
    80200858:	fd043783          	ld	a5,-48(s0)
    8020085c:	439c                	lw	a5,0(a5)
    8020085e:	853e                	mv	a0,a5
    80200860:	d2dff0ef          	jal	8020058c <bswap_32>
    80200864:	87aa                	mv	a5,a0
    80200866:	2781                	sext.w	a5,a5
    80200868:	873e                	mv	a4,a5
    8020086a:	d00e07b7          	lui	a5,0xd00e0
    8020086e:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <__stack_top+0xffffffff4feda11d>
    80200872:	00f70463          	beq	a4,a5,8020087a <dtb_getprop+0x60>
    80200876:	4781                	li	a5,0
    80200878:	a4d9                	j	80200b3e <dtb_getprop+0x324>
    8020087a:	f2843503          	ld	a0,-216(s0)
    8020087e:	ef7ff0ef          	jal	80200774 <path_depth>
    80200882:	87aa                	mv	a5,a0
    80200884:	fcf42623          	sw	a5,-52(s0)
    80200888:	fd043783          	ld	a5,-48(s0)
    8020088c:	53dc                	lw	a5,36(a5)
    8020088e:	853e                	mv	a0,a5
    80200890:	cfdff0ef          	jal	8020058c <bswap_32>
    80200894:	87aa                	mv	a5,a0
    80200896:	fcf42423          	sw	a5,-56(s0)
    8020089a:	fd043783          	ld	a5,-48(s0)
    8020089e:	479c                	lw	a5,8(a5)
    802008a0:	853e                	mv	a0,a5
    802008a2:	cebff0ef          	jal	8020058c <bswap_32>
    802008a6:	87aa                	mv	a5,a0
    802008a8:	2781                	sext.w	a5,a5
    802008aa:	1782                	slli	a5,a5,0x20
    802008ac:	9381                	srli	a5,a5,0x20
    802008ae:	fd043703          	ld	a4,-48(s0)
    802008b2:	97ba                	add	a5,a5,a4
    802008b4:	fcf43023          	sd	a5,-64(s0)
    802008b8:	fd043783          	ld	a5,-48(s0)
    802008bc:	47dc                	lw	a5,12(a5)
    802008be:	853e                	mv	a0,a5
    802008c0:	ccdff0ef          	jal	8020058c <bswap_32>
    802008c4:	87aa                	mv	a5,a0
    802008c6:	2781                	sext.w	a5,a5
    802008c8:	1782                	slli	a5,a5,0x20
    802008ca:	9381                	srli	a5,a5,0x20
    802008cc:	fd043703          	ld	a4,-48(s0)
    802008d0:	97ba                	add	a5,a5,a4
    802008d2:	faf43c23          	sd	a5,-72(s0)
    802008d6:	fc043783          	ld	a5,-64(s0)
    802008da:	fef43423          	sd	a5,-24(s0)
    802008de:	fc846783          	lwu	a5,-56(s0)
    802008e2:	fc043703          	ld	a4,-64(s0)
    802008e6:	97ba                	add	a5,a5,a4
    802008e8:	faf43823          	sd	a5,-80(s0)
    802008ec:	57fd                	li	a5,-1
    802008ee:	fef42223          	sw	a5,-28(s0)
    802008f2:	57fd                	li	a5,-1
    802008f4:	fef42023          	sw	a5,-32(s0)
    802008f8:	a41d                	j	80200b1e <dtb_getprop+0x304>
    802008fa:	fe843783          	ld	a5,-24(s0)
    802008fe:	439c                	lw	a5,0(a5)
    80200900:	853e                	mv	a0,a5
    80200902:	c8bff0ef          	jal	8020058c <bswap_32>
    80200906:	87aa                	mv	a5,a0
    80200908:	faf42623          	sw	a5,-84(s0)
    8020090c:	fe843783          	ld	a5,-24(s0)
    80200910:	0791                	addi	a5,a5,4
    80200912:	fef43423          	sd	a5,-24(s0)
    80200916:	fac42783          	lw	a5,-84(s0)
    8020091a:	0007871b          	sext.w	a4,a5
    8020091e:	4785                	li	a5,1
    80200920:	10f71e63          	bne	a4,a5,80200a3c <dtb_getprop+0x222>
    80200924:	fe843783          	ld	a5,-24(s0)
    80200928:	f8f43423          	sd	a5,-120(s0)
    8020092c:	a031                	j	80200938 <dtb_getprop+0x11e>
    8020092e:	fe843783          	ld	a5,-24(s0)
    80200932:	0785                	addi	a5,a5,1
    80200934:	fef43423          	sd	a5,-24(s0)
    80200938:	fe843783          	ld	a5,-24(s0)
    8020093c:	0007c783          	lbu	a5,0(a5)
    80200940:	f7fd                	bnez	a5,8020092e <dtb_getprop+0x114>
    80200942:	fe843783          	ld	a5,-24(s0)
    80200946:	0785                	addi	a5,a5,1
    80200948:	fef43423          	sd	a5,-24(s0)
    8020094c:	fe843783          	ld	a5,-24(s0)
    80200950:	853e                	mv	a0,a5
    80200952:	c9fff0ef          	jal	802005f0 <align_32>
    80200956:	87aa                	mv	a5,a0
    80200958:	fef43423          	sd	a5,-24(s0)
    8020095c:	fe442783          	lw	a5,-28(s0)
    80200960:	2785                	addiw	a5,a5,1
    80200962:	fef42223          	sw	a5,-28(s0)
    80200966:	fe042783          	lw	a5,-32(s0)
    8020096a:	2781                	sext.w	a5,a5
    8020096c:	1a07d963          	bgez	a5,80200b1e <dtb_getprop+0x304>
    80200970:	fe442783          	lw	a5,-28(s0)
    80200974:	2781                	sext.w	a5,a5
    80200976:	eb89                	bnez	a5,80200988 <dtb_getprop+0x16e>
    80200978:	fcc42783          	lw	a5,-52(s0)
    8020097c:	2781                	sext.w	a5,a5
    8020097e:	1a079063          	bnez	a5,80200b1e <dtb_getprop+0x304>
    80200982:	fe042023          	sw	zero,-32(s0)
    80200986:	aa61                	j	80200b1e <dtb_getprop+0x304>
    80200988:	fe442783          	lw	a5,-28(s0)
    8020098c:	37fd                	addiw	a5,a5,-1
    8020098e:	2781                	sext.w	a5,a5
    80200990:	f7840713          	addi	a4,s0,-136
    80200994:	863a                	mv	a2,a4
    80200996:	85be                	mv	a1,a5
    80200998:	f2843503          	ld	a0,-216(s0)
    8020099c:	cffff0ef          	jal	8020069a <path_segment>
    802009a0:	f8a43023          	sd	a0,-128(s0)
    802009a4:	f8043783          	ld	a5,-128(s0)
    802009a8:	16078b63          	beqz	a5,80200b1e <dtb_getprop+0x304>
    802009ac:	f7842783          	lw	a5,-136(s0)
    802009b0:	0007869b          	sext.w	a3,a5
    802009b4:	03f00713          	li	a4,63
    802009b8:	00d75463          	bge	a4,a3,802009c0 <dtb_getprop+0x1a6>
    802009bc:	03f00793          	li	a5,63
    802009c0:	f6f42e23          	sw	a5,-132(s0)
    802009c4:	fc042e23          	sw	zero,-36(s0)
    802009c8:	a01d                	j	802009ee <dtb_getprop+0x1d4>
    802009ca:	fdc42783          	lw	a5,-36(s0)
    802009ce:	f8043703          	ld	a4,-128(s0)
    802009d2:	97ba                	add	a5,a5,a4
    802009d4:	0007c703          	lbu	a4,0(a5)
    802009d8:	fdc42783          	lw	a5,-36(s0)
    802009dc:	17c1                	addi	a5,a5,-16
    802009de:	97a2                	add	a5,a5,s0
    802009e0:	f4e78423          	sb	a4,-184(a5)
    802009e4:	fdc42783          	lw	a5,-36(s0)
    802009e8:	2785                	addiw	a5,a5,1
    802009ea:	fcf42e23          	sw	a5,-36(s0)
    802009ee:	fdc42783          	lw	a5,-36(s0)
    802009f2:	873e                	mv	a4,a5
    802009f4:	f7c42783          	lw	a5,-132(s0)
    802009f8:	2701                	sext.w	a4,a4
    802009fa:	2781                	sext.w	a5,a5
    802009fc:	fcf747e3          	blt	a4,a5,802009ca <dtb_getprop+0x1b0>
    80200a00:	fdc42783          	lw	a5,-36(s0)
    80200a04:	17c1                	addi	a5,a5,-16
    80200a06:	97a2                	add	a5,a5,s0
    80200a08:	f4078423          	sb	zero,-184(a5)
    80200a0c:	f3840793          	addi	a5,s0,-200
    80200a10:	85be                	mv	a1,a5
    80200a12:	f8843503          	ld	a0,-120(s0)
    80200a16:	bf5ff0ef          	jal	8020060a <node_name_match>
    80200a1a:	87aa                	mv	a5,a0
    80200a1c:	10078163          	beqz	a5,80200b1e <dtb_getprop+0x304>
    80200a20:	fe442783          	lw	a5,-28(s0)
    80200a24:	873e                	mv	a4,a5
    80200a26:	fcc42783          	lw	a5,-52(s0)
    80200a2a:	2701                	sext.w	a4,a4
    80200a2c:	2781                	sext.w	a5,a5
    80200a2e:	0ef71863          	bne	a4,a5,80200b1e <dtb_getprop+0x304>
    80200a32:	fe442783          	lw	a5,-28(s0)
    80200a36:	fef42023          	sw	a5,-32(s0)
    80200a3a:	a0d5                	j	80200b1e <dtb_getprop+0x304>
    80200a3c:	fac42783          	lw	a5,-84(s0)
    80200a40:	0007871b          	sext.w	a4,a5
    80200a44:	4789                	li	a5,2
    80200a46:	02f71463          	bne	a4,a5,80200a6e <dtb_getprop+0x254>
    80200a4a:	fe042783          	lw	a5,-32(s0)
    80200a4e:	873e                	mv	a4,a5
    80200a50:	fe442783          	lw	a5,-28(s0)
    80200a54:	2701                	sext.w	a4,a4
    80200a56:	2781                	sext.w	a5,a5
    80200a58:	00f71563          	bne	a4,a5,80200a62 <dtb_getprop+0x248>
    80200a5c:	57fd                	li	a5,-1
    80200a5e:	fef42023          	sw	a5,-32(s0)
    80200a62:	fe442783          	lw	a5,-28(s0)
    80200a66:	37fd                	addiw	a5,a5,-1
    80200a68:	fef42223          	sw	a5,-28(s0)
    80200a6c:	a84d                	j	80200b1e <dtb_getprop+0x304>
    80200a6e:	fac42783          	lw	a5,-84(s0)
    80200a72:	0007871b          	sext.w	a4,a5
    80200a76:	478d                	li	a5,3
    80200a78:	08f71b63          	bne	a4,a5,80200b0e <dtb_getprop+0x2f4>
    80200a7c:	fe843783          	ld	a5,-24(s0)
    80200a80:	faf43023          	sd	a5,-96(s0)
    80200a84:	fe843783          	ld	a5,-24(s0)
    80200a88:	07a1                	addi	a5,a5,8
    80200a8a:	fef43423          	sd	a5,-24(s0)
    80200a8e:	fa043783          	ld	a5,-96(s0)
    80200a92:	439c                	lw	a5,0(a5)
    80200a94:	853e                	mv	a0,a5
    80200a96:	af7ff0ef          	jal	8020058c <bswap_32>
    80200a9a:	87aa                	mv	a5,a0
    80200a9c:	f8f42e23          	sw	a5,-100(s0)
    80200aa0:	fa043783          	ld	a5,-96(s0)
    80200aa4:	43dc                	lw	a5,4(a5)
    80200aa6:	853e                	mv	a0,a5
    80200aa8:	ae5ff0ef          	jal	8020058c <bswap_32>
    80200aac:	87aa                	mv	a5,a0
    80200aae:	2781                	sext.w	a5,a5
    80200ab0:	1782                	slli	a5,a5,0x20
    80200ab2:	9381                	srli	a5,a5,0x20
    80200ab4:	fb843703          	ld	a4,-72(s0)
    80200ab8:	97ba                	add	a5,a5,a4
    80200aba:	f8f43823          	sd	a5,-112(s0)
    80200abe:	fe042783          	lw	a5,-32(s0)
    80200ac2:	2781                	sext.w	a5,a5
    80200ac4:	0207c563          	bltz	a5,80200aee <dtb_getprop+0x2d4>
    80200ac8:	f2043583          	ld	a1,-224(s0)
    80200acc:	f9043503          	ld	a0,-112(s0)
    80200ad0:	5dd000ef          	jal	802018ac <strcmp>
    80200ad4:	87aa                	mv	a5,a0
    80200ad6:	ef81                	bnez	a5,80200aee <dtb_getprop+0x2d4>
    80200ad8:	f1843783          	ld	a5,-232(s0)
    80200adc:	c791                	beqz	a5,80200ae8 <dtb_getprop+0x2ce>
    80200ade:	f9c42703          	lw	a4,-100(s0)
    80200ae2:	f1843783          	ld	a5,-232(s0)
    80200ae6:	c398                	sw	a4,0(a5)
    80200ae8:	fe843783          	ld	a5,-24(s0)
    80200aec:	a889                	j	80200b3e <dtb_getprop+0x324>
    80200aee:	f9c46783          	lwu	a5,-100(s0)
    80200af2:	fe843703          	ld	a4,-24(s0)
    80200af6:	97ba                	add	a5,a5,a4
    80200af8:	fef43423          	sd	a5,-24(s0)
    80200afc:	fe843783          	ld	a5,-24(s0)
    80200b00:	853e                	mv	a0,a5
    80200b02:	aefff0ef          	jal	802005f0 <align_32>
    80200b06:	87aa                	mv	a5,a0
    80200b08:	fef43423          	sd	a5,-24(s0)
    80200b0c:	a809                	j	80200b1e <dtb_getprop+0x304>
    80200b0e:	fac42783          	lw	a5,-84(s0)
    80200b12:	0007871b          	sext.w	a4,a5
    80200b16:	4791                	li	a5,4
    80200b18:	00f71a63          	bne	a4,a5,80200b2c <dtb_getprop+0x312>
    80200b1c:	0001                	nop
    80200b1e:	fe843703          	ld	a4,-24(s0)
    80200b22:	fb043783          	ld	a5,-80(s0)
    80200b26:	dcf76ae3          	bltu	a4,a5,802008fa <dtb_getprop+0xe0>
    80200b2a:	a011                	j	80200b2e <dtb_getprop+0x314>
    80200b2c:	0001                	nop
    80200b2e:	f1843783          	ld	a5,-232(s0)
    80200b32:	c789                	beqz	a5,80200b3c <dtb_getprop+0x322>
    80200b34:	f1843783          	ld	a5,-232(s0)
    80200b38:	0007a023          	sw	zero,0(a5)
    80200b3c:	4781                	li	a5,0
    80200b3e:	853e                	mv	a0,a5
    80200b40:	70ae                	ld	ra,232(sp)
    80200b42:	740e                	ld	s0,224(sp)
    80200b44:	616d                	addi	sp,sp,240
    80200b46:	8082                	ret

0000000080200b48 <dtb_get_reg>:
    80200b48:	715d                	addi	sp,sp,-80
    80200b4a:	e486                	sd	ra,72(sp)
    80200b4c:	e0a2                	sd	s0,64(sp)
    80200b4e:	0880                	addi	s0,sp,80
    80200b50:	faa43c23          	sd	a0,-72(s0)
    80200b54:	fc042623          	sw	zero,-52(s0)
    80200b58:	fcc40793          	addi	a5,s0,-52
    80200b5c:	863e                	mv	a2,a5
    80200b5e:	00001597          	auipc	a1,0x1
    80200b62:	e3a58593          	addi	a1,a1,-454 # 80201998 <strcmp+0xec>
    80200b66:	fb843503          	ld	a0,-72(s0)
    80200b6a:	cb1ff0ef          	jal	8020081a <dtb_getprop>
    80200b6e:	fea43423          	sd	a0,-24(s0)
    80200b72:	fe843783          	ld	a5,-24(s0)
    80200b76:	c799                	beqz	a5,80200b84 <dtb_get_reg+0x3c>
    80200b78:	fcc42783          	lw	a5,-52(s0)
    80200b7c:	873e                	mv	a4,a5
    80200b7e:	478d                	li	a5,3
    80200b80:	00e7c463          	blt	a5,a4,80200b88 <dtb_get_reg+0x40>
    80200b84:	4781                	li	a5,0
    80200b86:	a0b5                	j	80200bf2 <dtb_get_reg+0xaa>
    80200b88:	fe843783          	ld	a5,-24(s0)
    80200b8c:	fef43023          	sd	a5,-32(s0)
    80200b90:	fcc42783          	lw	a5,-52(s0)
    80200b94:	873e                	mv	a4,a5
    80200b96:	479d                	li	a5,7
    80200b98:	04e7d363          	bge	a5,a4,80200bde <dtb_get_reg+0x96>
    80200b9c:	fe043783          	ld	a5,-32(s0)
    80200ba0:	439c                	lw	a5,0(a5)
    80200ba2:	853e                	mv	a0,a5
    80200ba4:	9e9ff0ef          	jal	8020058c <bswap_32>
    80200ba8:	87aa                	mv	a5,a0
    80200baa:	2781                	sext.w	a5,a5
    80200bac:	1782                	slli	a5,a5,0x20
    80200bae:	9381                	srli	a5,a5,0x20
    80200bb0:	fcf43c23          	sd	a5,-40(s0)
    80200bb4:	fe043783          	ld	a5,-32(s0)
    80200bb8:	0791                	addi	a5,a5,4
    80200bba:	439c                	lw	a5,0(a5)
    80200bbc:	853e                	mv	a0,a5
    80200bbe:	9cfff0ef          	jal	8020058c <bswap_32>
    80200bc2:	87aa                	mv	a5,a0
    80200bc4:	2781                	sext.w	a5,a5
    80200bc6:	1782                	slli	a5,a5,0x20
    80200bc8:	9381                	srli	a5,a5,0x20
    80200bca:	fcf43823          	sd	a5,-48(s0)
    80200bce:	fd843783          	ld	a5,-40(s0)
    80200bd2:	02079713          	slli	a4,a5,0x20
    80200bd6:	fd043783          	ld	a5,-48(s0)
    80200bda:	8fd9                	or	a5,a5,a4
    80200bdc:	a819                	j	80200bf2 <dtb_get_reg+0xaa>
    80200bde:	fe043783          	ld	a5,-32(s0)
    80200be2:	439c                	lw	a5,0(a5)
    80200be4:	853e                	mv	a0,a5
    80200be6:	9a7ff0ef          	jal	8020058c <bswap_32>
    80200bea:	87aa                	mv	a5,a0
    80200bec:	2781                	sext.w	a5,a5
    80200bee:	1782                	slli	a5,a5,0x20
    80200bf0:	9381                	srli	a5,a5,0x20
    80200bf2:	853e                	mv	a0,a5
    80200bf4:	60a6                	ld	ra,72(sp)
    80200bf6:	6406                	ld	s0,64(sp)
    80200bf8:	6161                	addi	sp,sp,80
    80200bfa:	8082                	ret

0000000080200bfc <dtb_load_initrd_addr>:
    80200bfc:	7139                	addi	sp,sp,-64
    80200bfe:	fc06                	sd	ra,56(sp)
    80200c00:	f822                	sd	s0,48(sp)
    80200c02:	0080                	addi	s0,sp,64
    80200c04:	fc042223          	sw	zero,-60(s0)
    80200c08:	fc440793          	addi	a5,s0,-60
    80200c0c:	863e                	mv	a2,a5
    80200c0e:	00001597          	auipc	a1,0x1
    80200c12:	d9258593          	addi	a1,a1,-622 # 802019a0 <strcmp+0xf4>
    80200c16:	00001517          	auipc	a0,0x1
    80200c1a:	da250513          	addi	a0,a0,-606 # 802019b8 <strcmp+0x10c>
    80200c1e:	bfdff0ef          	jal	8020081a <dtb_getprop>
    80200c22:	fea43423          	sd	a0,-24(s0)
    80200c26:	fe843783          	ld	a5,-24(s0)
    80200c2a:	cbd1                	beqz	a5,80200cbe <dtb_load_initrd_addr+0xc2>
    80200c2c:	fc442783          	lw	a5,-60(s0)
    80200c30:	c7d9                	beqz	a5,80200cbe <dtb_load_initrd_addr+0xc2>
    80200c32:	fc442783          	lw	a5,-60(s0)
    80200c36:	873e                	mv	a4,a5
    80200c38:	479d                	li	a5,7
    80200c3a:	04e7dd63          	bge	a5,a4,80200c94 <dtb_load_initrd_addr+0x98>
    80200c3e:	fe843783          	ld	a5,-24(s0)
    80200c42:	fcf43c23          	sd	a5,-40(s0)
    80200c46:	fd843783          	ld	a5,-40(s0)
    80200c4a:	439c                	lw	a5,0(a5)
    80200c4c:	853e                	mv	a0,a5
    80200c4e:	93fff0ef          	jal	8020058c <bswap_32>
    80200c52:	87aa                	mv	a5,a0
    80200c54:	2781                	sext.w	a5,a5
    80200c56:	1782                	slli	a5,a5,0x20
    80200c58:	9381                	srli	a5,a5,0x20
    80200c5a:	fcf43823          	sd	a5,-48(s0)
    80200c5e:	fd843783          	ld	a5,-40(s0)
    80200c62:	0791                	addi	a5,a5,4
    80200c64:	439c                	lw	a5,0(a5)
    80200c66:	853e                	mv	a0,a5
    80200c68:	925ff0ef          	jal	8020058c <bswap_32>
    80200c6c:	87aa                	mv	a5,a0
    80200c6e:	2781                	sext.w	a5,a5
    80200c70:	1782                	slli	a5,a5,0x20
    80200c72:	9381                	srli	a5,a5,0x20
    80200c74:	fcf43423          	sd	a5,-56(s0)
    80200c78:	fd043783          	ld	a5,-48(s0)
    80200c7c:	02079713          	slli	a4,a5,0x20
    80200c80:	fc843783          	ld	a5,-56(s0)
    80200c84:	8fd9                	or	a5,a5,a4
    80200c86:	873e                	mv	a4,a5
    80200c88:	00001797          	auipc	a5,0x1
    80200c8c:	0a078793          	addi	a5,a5,160 # 80201d28 <cpio_addr>
    80200c90:	e398                	sd	a4,0(a5)
    80200c92:	a03d                	j	80200cc0 <dtb_load_initrd_addr+0xc4>
    80200c94:	fe843783          	ld	a5,-24(s0)
    80200c98:	fef43023          	sd	a5,-32(s0)
    80200c9c:	fe043783          	ld	a5,-32(s0)
    80200ca0:	439c                	lw	a5,0(a5)
    80200ca2:	853e                	mv	a0,a5
    80200ca4:	8e9ff0ef          	jal	8020058c <bswap_32>
    80200ca8:	87aa                	mv	a5,a0
    80200caa:	2781                	sext.w	a5,a5
    80200cac:	1782                	slli	a5,a5,0x20
    80200cae:	9381                	srli	a5,a5,0x20
    80200cb0:	873e                	mv	a4,a5
    80200cb2:	00001797          	auipc	a5,0x1
    80200cb6:	07678793          	addi	a5,a5,118 # 80201d28 <cpio_addr>
    80200cba:	e398                	sd	a4,0(a5)
    80200cbc:	a011                	j	80200cc0 <dtb_load_initrd_addr+0xc4>
    80200cbe:	0001                	nop
    80200cc0:	70e2                	ld	ra,56(sp)
    80200cc2:	7442                	ld	s0,48(sp)
    80200cc4:	6121                	addi	sp,sp,64
    80200cc6:	8082                	ret

0000000080200cc8 <get_current_pc>:
    80200cc8:	1101                	addi	sp,sp,-32
    80200cca:	ec22                	sd	s0,24(sp)
    80200ccc:	1000                	addi	s0,sp,32
    80200cce:	00000797          	auipc	a5,0x0
    80200cd2:	fef43423          	sd	a5,-24(s0)
    80200cd6:	fe843783          	ld	a5,-24(s0)
    80200cda:	853e                	mv	a0,a5
    80200cdc:	6462                	ld	s0,24(sp)
    80200cde:	6105                	addi	sp,sp,32
    80200ce0:	8082                	ret

0000000080200ce2 <main>:
    80200ce2:	7179                	addi	sp,sp,-48
    80200ce4:	f406                	sd	ra,40(sp)
    80200ce6:	f022                	sd	s0,32(sp)
    80200ce8:	1800                	addi	s0,sp,48
    80200cea:	87aa                	mv	a5,a0
    80200cec:	fcb43823          	sd	a1,-48(s0)
    80200cf0:	fcf42e23          	sw	a5,-36(s0)
    80200cf4:	fd043503          	ld	a0,-48(s0)
    80200cf8:	b03ff0ef          	jal	802007fa <dtb_set_addr>
    80200cfc:	00001517          	auipc	a0,0x1
    80200d00:	cc450513          	addi	a0,a0,-828 # 802019c0 <strcmp+0x114>
    80200d04:	e45ff0ef          	jal	80200b48 <dtb_get_reg>
    80200d08:	fea43423          	sd	a0,-24(s0)
    80200d0c:	fe843783          	ld	a5,-24(s0)
    80200d10:	eb89                	bnez	a5,80200d22 <main+0x40>
    80200d12:	00001517          	auipc	a0,0x1
    80200d16:	cbe50513          	addi	a0,a0,-834 # 802019d0 <strcmp+0x124>
    80200d1a:	e2fff0ef          	jal	80200b48 <dtb_get_reg>
    80200d1e:	fea43423          	sd	a0,-24(s0)
    80200d22:	fe843503          	ld	a0,-24(s0)
    80200d26:	0bb000ef          	jal	802015e0 <uart_set_base>
    80200d2a:	ed3ff0ef          	jal	80200bfc <dtb_load_initrd_addr>
    80200d2e:	00001797          	auipc	a5,0x1
    80200d32:	fea78793          	addi	a5,a5,-22 # 80201d18 <had_relocated>
    80200d36:	439c                	lw	a5,0(a5)
    80200d38:	873e                	mv	a4,a5
    80200d3a:	57fd                	li	a5,-1
    80200d3c:	04f71263          	bne	a4,a5,80200d80 <main+0x9e>
    80200d40:	00001517          	auipc	a0,0x1
    80200d44:	ca050513          	addi	a0,a0,-864 # 802019e0 <strcmp+0x134>
    80200d48:	1ad000ef          	jal	802016f4 <uart_puts>
    80200d4c:	f7dff0ef          	jal	80200cc8 <get_current_pc>
    80200d50:	87aa                	mv	a5,a0
    80200d52:	853e                	mv	a0,a5
    80200d54:	1dd000ef          	jal	80201730 <uart_hex>
    80200d58:	00001517          	auipc	a0,0x1
    80200d5c:	ca850513          	addi	a0,a0,-856 # 80201a00 <strcmp+0x154>
    80200d60:	195000ef          	jal	802016f4 <uart_puts>
    80200d64:	00001797          	auipc	a5,0x1
    80200d68:	fb478793          	addi	a5,a5,-76 # 80201d18 <had_relocated>
    80200d6c:	4705                	li	a4,1
    80200d6e:	c398                	sw	a4,0(a5)
    80200d70:	fdc42783          	lw	a5,-36(s0)
    80200d74:	fd043583          	ld	a1,-48(s0)
    80200d78:	853e                	mv	a0,a5
    80200d7a:	05e000ef          	jal	80200dd8 <code_relocate>
    80200d7e:	a80d                	j	80200db0 <main+0xce>
    80200d80:	00001517          	auipc	a0,0x1
    80200d84:	c8850513          	addi	a0,a0,-888 # 80201a08 <strcmp+0x15c>
    80200d88:	16d000ef          	jal	802016f4 <uart_puts>
    80200d8c:	00001517          	auipc	a0,0x1
    80200d90:	c9450513          	addi	a0,a0,-876 # 80201a20 <strcmp+0x174>
    80200d94:	161000ef          	jal	802016f4 <uart_puts>
    80200d98:	f31ff0ef          	jal	80200cc8 <get_current_pc>
    80200d9c:	87aa                	mv	a5,a0
    80200d9e:	853e                	mv	a0,a5
    80200da0:	191000ef          	jal	80201730 <uart_hex>
    80200da4:	00001517          	auipc	a0,0x1
    80200da8:	c5c50513          	addi	a0,a0,-932 # 80201a00 <strcmp+0x154>
    80200dac:	149000ef          	jal	802016f4 <uart_puts>
    80200db0:	00001517          	auipc	a0,0x1
    80200db4:	c8850513          	addi	a0,a0,-888 # 80201a38 <strcmp+0x18c>
    80200db8:	13d000ef          	jal	802016f4 <uart_puts>
    80200dbc:	00001797          	auipc	a5,0x1
    80200dc0:	f7478793          	addi	a5,a5,-140 # 80201d30 <boot_hart_id>
    80200dc4:	fdc42703          	lw	a4,-36(s0)
    80200dc8:	c398                	sw	a4,0(a5)
    80200dca:	7d4000ef          	jal	8020159e <shell>
    80200dce:	0001                	nop
    80200dd0:	70a2                	ld	ra,40(sp)
    80200dd2:	7402                	ld	s0,32(sp)
    80200dd4:	6145                	addi	sp,sp,48
    80200dd6:	8082                	ret

0000000080200dd8 <code_relocate>:
    80200dd8:	7139                	addi	sp,sp,-64
    80200dda:	fc06                	sd	ra,56(sp)
    80200ddc:	f822                	sd	s0,48(sp)
    80200dde:	0080                	addi	s0,sp,64
    80200de0:	87aa                	mv	a5,a0
    80200de2:	fcb43023          	sd	a1,-64(s0)
    80200de6:	fcf42623          	sw	a5,-52(s0)
    80200dea:	00001517          	auipc	a0,0x1
    80200dee:	c6e50513          	addi	a0,a0,-914 # 80201a58 <strcmp+0x1ac>
    80200df2:	103000ef          	jal	802016f4 <uart_puts>
    80200df6:	00001797          	auipc	a5,0x1
    80200dfa:	f1a78793          	addi	a5,a5,-230 # 80201d10 <_relocate_addr>
    80200dfe:	639c                	ld	a5,0(a5)
    80200e00:	fef43023          	sd	a5,-32(s0)
    80200e04:	fffff797          	auipc	a5,0xfffff
    80200e08:	1fc78793          	addi	a5,a5,508 # 80200000 <_code_start>
    80200e0c:	fcf43c23          	sd	a5,-40(s0)
    80200e10:	000067b7          	lui	a5,0x6
    80200e14:	dd078793          	addi	a5,a5,-560 # 5dd0 <_code_size>
    80200e18:	fcf43823          	sd	a5,-48(s0)
    80200e1c:	fe043423          	sd	zero,-24(s0)
    80200e20:	a025                	j	80200e48 <code_relocate+0x70>
    80200e22:	fd843703          	ld	a4,-40(s0)
    80200e26:	fe843783          	ld	a5,-24(s0)
    80200e2a:	973e                	add	a4,a4,a5
    80200e2c:	fe043683          	ld	a3,-32(s0)
    80200e30:	fe843783          	ld	a5,-24(s0)
    80200e34:	97b6                	add	a5,a5,a3
    80200e36:	00074703          	lbu	a4,0(a4)
    80200e3a:	00e78023          	sb	a4,0(a5)
    80200e3e:	fe843783          	ld	a5,-24(s0)
    80200e42:	0785                	addi	a5,a5,1
    80200e44:	fef43423          	sd	a5,-24(s0)
    80200e48:	fe843703          	ld	a4,-24(s0)
    80200e4c:	fd043783          	ld	a5,-48(s0)
    80200e50:	fcf769e3          	bltu	a4,a5,80200e22 <code_relocate+0x4a>
    80200e54:	00001517          	auipc	a0,0x1
    80200e58:	c1c50513          	addi	a0,a0,-996 # 80201a70 <strcmp+0x1c4>
    80200e5c:	099000ef          	jal	802016f4 <uart_puts>
    80200e60:	fcc42783          	lw	a5,-52(s0)
    80200e64:	853e                	mv	a0,a5
    80200e66:	fc043783          	ld	a5,-64(s0)
    80200e6a:	85be                	mv	a1,a5
    80200e6c:	fe043783          	ld	a5,-32(s0)
    80200e70:	8782                	jr	a5
    80200e72:	0001                	nop
    80200e74:	70e2                	ld	ra,56(sp)
    80200e76:	7442                	ld	s0,48(sp)
    80200e78:	6121                	addi	sp,sp,64
    80200e7a:	8082                	ret

0000000080200e7c <sbi_ecall>:
    80200e7c:	7159                	addi	sp,sp,-112
    80200e7e:	f4a2                	sd	s0,104(sp)
    80200e80:	1880                	addi	s0,sp,112
    80200e82:	fcc43023          	sd	a2,-64(s0)
    80200e86:	fad43c23          	sd	a3,-72(s0)
    80200e8a:	fae43823          	sd	a4,-80(s0)
    80200e8e:	faf43423          	sd	a5,-88(s0)
    80200e92:	fb043023          	sd	a6,-96(s0)
    80200e96:	f9143c23          	sd	a7,-104(s0)
    80200e9a:	87aa                	mv	a5,a0
    80200e9c:	fcf42623          	sw	a5,-52(s0)
    80200ea0:	87ae                	mv	a5,a1
    80200ea2:	fcf42423          	sw	a5,-56(s0)
    80200ea6:	fc043503          	ld	a0,-64(s0)
    80200eaa:	fb843583          	ld	a1,-72(s0)
    80200eae:	fb043603          	ld	a2,-80(s0)
    80200eb2:	fa843683          	ld	a3,-88(s0)
    80200eb6:	fa043703          	ld	a4,-96(s0)
    80200eba:	f9843783          	ld	a5,-104(s0)
    80200ebe:	fc842803          	lw	a6,-56(s0)
    80200ec2:	fcc42883          	lw	a7,-52(s0)
    80200ec6:	00000073          	ecall
    80200eca:	87aa                	mv	a5,a0
    80200ecc:	fcf43823          	sd	a5,-48(s0)
    80200ed0:	87ae                	mv	a5,a1
    80200ed2:	fcf43c23          	sd	a5,-40(s0)
    80200ed6:	fd043783          	ld	a5,-48(s0)
    80200eda:	fef43023          	sd	a5,-32(s0)
    80200ede:	fd843783          	ld	a5,-40(s0)
    80200ee2:	fef43423          	sd	a5,-24(s0)
    80200ee6:	fe043703          	ld	a4,-32(s0)
    80200eea:	fe843783          	ld	a5,-24(s0)
    80200eee:	833a                	mv	t1,a4
    80200ef0:	83be                	mv	t2,a5
    80200ef2:	871a                	mv	a4,t1
    80200ef4:	879e                	mv	a5,t2
    80200ef6:	853a                	mv	a0,a4
    80200ef8:	85be                	mv	a1,a5
    80200efa:	7426                	ld	s0,104(sp)
    80200efc:	6165                	addi	sp,sp,112
    80200efe:	8082                	ret

0000000080200f00 <parse>:
    80200f00:	1101                	addi	sp,sp,-32
    80200f02:	ec22                	sd	s0,24(sp)
    80200f04:	1000                	addi	s0,sp,32
    80200f06:	87aa                	mv	a5,a0
    80200f08:	fef407a3          	sb	a5,-17(s0)
    80200f0c:	fef40783          	lb	a5,-17(s0)
    80200f10:	0007d563          	bgez	a5,80200f1a <parse+0x1a>
    80200f14:	20000793          	li	a5,512
    80200f18:	a0a9                	j	80200f62 <parse+0x62>
    80200f1a:	fef44783          	lbu	a5,-17(s0)
    80200f1e:	0ff7f713          	zext.b	a4,a5
    80200f22:	07f00793          	li	a5,127
    80200f26:	00f70963          	beq	a4,a5,80200f38 <parse+0x38>
    80200f2a:	fef44783          	lbu	a5,-17(s0)
    80200f2e:	0ff7f713          	zext.b	a4,a5
    80200f32:	47a1                	li	a5,8
    80200f34:	00f71563          	bne	a4,a5,80200f3e <parse+0x3e>
    80200f38:	07f00793          	li	a5,127
    80200f3c:	a01d                	j	80200f62 <parse+0x62>
    80200f3e:	fef44783          	lbu	a5,-17(s0)
    80200f42:	0ff7f713          	zext.b	a4,a5
    80200f46:	47b5                	li	a5,13
    80200f48:	00f70963          	beq	a4,a5,80200f5a <parse+0x5a>
    80200f4c:	fef44783          	lbu	a5,-17(s0)
    80200f50:	0ff7f713          	zext.b	a4,a5
    80200f54:	47a9                	li	a5,10
    80200f56:	00f71463          	bne	a4,a5,80200f5e <parse+0x5e>
    80200f5a:	47a9                	li	a5,10
    80200f5c:	a019                	j	80200f62 <parse+0x62>
    80200f5e:	20100793          	li	a5,513
    80200f62:	853e                	mv	a0,a5
    80200f64:	6462                	ld	s0,24(sp)
    80200f66:	6105                	addi	sp,sp,32
    80200f68:	8082                	ret

0000000080200f6a <command_help>:
    80200f6a:	1141                	addi	sp,sp,-16
    80200f6c:	e406                	sd	ra,8(sp)
    80200f6e:	e022                	sd	s0,0(sp)
    80200f70:	0800                	addi	s0,sp,16
    80200f72:	00001517          	auipc	a0,0x1
    80200f76:	b1650513          	addi	a0,a0,-1258 # 80201a88 <strcmp+0x1dc>
    80200f7a:	77a000ef          	jal	802016f4 <uart_puts>
    80200f7e:	00001517          	auipc	a0,0x1
    80200f82:	b2a50513          	addi	a0,a0,-1238 # 80201aa8 <strcmp+0x1fc>
    80200f86:	76e000ef          	jal	802016f4 <uart_puts>
    80200f8a:	00001517          	auipc	a0,0x1
    80200f8e:	b3e50513          	addi	a0,a0,-1218 # 80201ac8 <strcmp+0x21c>
    80200f92:	762000ef          	jal	802016f4 <uart_puts>
    80200f96:	00001517          	auipc	a0,0x1
    80200f9a:	b5250513          	addi	a0,a0,-1198 # 80201ae8 <strcmp+0x23c>
    80200f9e:	756000ef          	jal	802016f4 <uart_puts>
    80200fa2:	00001517          	auipc	a0,0x1
    80200fa6:	b6e50513          	addi	a0,a0,-1170 # 80201b10 <strcmp+0x264>
    80200faa:	74a000ef          	jal	802016f4 <uart_puts>
    80200fae:	0001                	nop
    80200fb0:	60a2                	ld	ra,8(sp)
    80200fb2:	6402                	ld	s0,0(sp)
    80200fb4:	0141                	addi	sp,sp,16
    80200fb6:	8082                	ret

0000000080200fb8 <command_hello>:
    80200fb8:	1141                	addi	sp,sp,-16
    80200fba:	e406                	sd	ra,8(sp)
    80200fbc:	e022                	sd	s0,0(sp)
    80200fbe:	0800                	addi	s0,sp,16
    80200fc0:	00001517          	auipc	a0,0x1
    80200fc4:	b8850513          	addi	a0,a0,-1144 # 80201b48 <strcmp+0x29c>
    80200fc8:	72c000ef          	jal	802016f4 <uart_puts>
    80200fcc:	0001                	nop
    80200fce:	60a2                	ld	ra,8(sp)
    80200fd0:	6402                	ld	s0,0(sp)
    80200fd2:	0141                	addi	sp,sp,16
    80200fd4:	8082                	ret

0000000080200fd6 <command_info>:
    80200fd6:	1101                	addi	sp,sp,-32
    80200fd8:	ec06                	sd	ra,24(sp)
    80200fda:	e822                	sd	s0,16(sp)
    80200fdc:	1000                	addi	s0,sp,32
    80200fde:	4881                	li	a7,0
    80200fe0:	4801                	li	a6,0
    80200fe2:	4781                	li	a5,0
    80200fe4:	4701                	li	a4,0
    80200fe6:	4681                	li	a3,0
    80200fe8:	4601                	li	a2,0
    80200fea:	4581                	li	a1,0
    80200fec:	4541                	li	a0,16
    80200fee:	e8fff0ef          	jal	80200e7c <sbi_ecall>
    80200ff2:	872a                	mv	a4,a0
    80200ff4:	87ae                	mv	a5,a1
    80200ff6:	fee43023          	sd	a4,-32(s0)
    80200ffa:	fef43423          	sd	a5,-24(s0)
    80200ffe:	00001517          	auipc	a0,0x1
    80201002:	b5a50513          	addi	a0,a0,-1190 # 80201b58 <strcmp+0x2ac>
    80201006:	6ee000ef          	jal	802016f4 <uart_puts>
    8020100a:	fe843783          	ld	a5,-24(s0)
    8020100e:	853e                	mv	a0,a5
    80201010:	720000ef          	jal	80201730 <uart_hex>
    80201014:	4881                	li	a7,0
    80201016:	4801                	li	a6,0
    80201018:	4781                	li	a5,0
    8020101a:	4701                	li	a4,0
    8020101c:	4681                	li	a3,0
    8020101e:	4601                	li	a2,0
    80201020:	4585                	li	a1,1
    80201022:	4541                	li	a0,16
    80201024:	e59ff0ef          	jal	80200e7c <sbi_ecall>
    80201028:	872a                	mv	a4,a0
    8020102a:	87ae                	mv	a5,a1
    8020102c:	fee43023          	sd	a4,-32(s0)
    80201030:	fef43423          	sd	a5,-24(s0)
    80201034:	00001517          	auipc	a0,0x1
    80201038:	b4450513          	addi	a0,a0,-1212 # 80201b78 <strcmp+0x2cc>
    8020103c:	6b8000ef          	jal	802016f4 <uart_puts>
    80201040:	fe843783          	ld	a5,-24(s0)
    80201044:	853e                	mv	a0,a5
    80201046:	6ea000ef          	jal	80201730 <uart_hex>
    8020104a:	4881                	li	a7,0
    8020104c:	4801                	li	a6,0
    8020104e:	4781                	li	a5,0
    80201050:	4701                	li	a4,0
    80201052:	4681                	li	a3,0
    80201054:	4601                	li	a2,0
    80201056:	4589                	li	a1,2
    80201058:	4541                	li	a0,16
    8020105a:	e23ff0ef          	jal	80200e7c <sbi_ecall>
    8020105e:	872a                	mv	a4,a0
    80201060:	87ae                	mv	a5,a1
    80201062:	fee43023          	sd	a4,-32(s0)
    80201066:	fef43423          	sd	a5,-24(s0)
    8020106a:	00001517          	auipc	a0,0x1
    8020106e:	b2650513          	addi	a0,a0,-1242 # 80201b90 <strcmp+0x2e4>
    80201072:	682000ef          	jal	802016f4 <uart_puts>
    80201076:	fe843783          	ld	a5,-24(s0)
    8020107a:	853e                	mv	a0,a5
    8020107c:	6b4000ef          	jal	80201730 <uart_hex>
    80201080:	4529                	li	a0,10
    80201082:	584000ef          	jal	80201606 <uart_putc>
    80201086:	0001                	nop
    80201088:	60e2                	ld	ra,24(sp)
    8020108a:	6442                	ld	s0,16(sp)
    8020108c:	6105                	addi	sp,sp,32
    8020108e:	8082                	ret

0000000080201090 <command_load>:
    80201090:	7139                	addi	sp,sp,-64
    80201092:	fc06                	sd	ra,56(sp)
    80201094:	f822                	sd	s0,48(sp)
    80201096:	f426                	sd	s1,40(sp)
    80201098:	0080                	addi	s0,sp,64
    8020109a:	00001517          	auipc	a0,0x1
    8020109e:	b1650513          	addi	a0,a0,-1258 # 80201bb0 <strcmp+0x304>
    802010a2:	652000ef          	jal	802016f4 <uart_puts>
    802010a6:	5c0000ef          	jal	80201666 <uart_getc>
    802010aa:	87aa                	mv	a5,a0
    802010ac:	0007849b          	sext.w	s1,a5
    802010b0:	5b6000ef          	jal	80201666 <uart_getc>
    802010b4:	87aa                	mv	a5,a0
    802010b6:	2781                	sext.w	a5,a5
    802010b8:	0087979b          	slliw	a5,a5,0x8
    802010bc:	2781                	sext.w	a5,a5
    802010be:	8726                	mv	a4,s1
    802010c0:	8fd9                	or	a5,a5,a4
    802010c2:	0007849b          	sext.w	s1,a5
    802010c6:	5a0000ef          	jal	80201666 <uart_getc>
    802010ca:	87aa                	mv	a5,a0
    802010cc:	2781                	sext.w	a5,a5
    802010ce:	0107979b          	slliw	a5,a5,0x10
    802010d2:	2781                	sext.w	a5,a5
    802010d4:	8726                	mv	a4,s1
    802010d6:	8fd9                	or	a5,a5,a4
    802010d8:	0007849b          	sext.w	s1,a5
    802010dc:	58a000ef          	jal	80201666 <uart_getc>
    802010e0:	87aa                	mv	a5,a0
    802010e2:	2781                	sext.w	a5,a5
    802010e4:	0187979b          	slliw	a5,a5,0x18
    802010e8:	2781                	sext.w	a5,a5
    802010ea:	8726                	mv	a4,s1
    802010ec:	8fd9                	or	a5,a5,a4
    802010ee:	fcf42c23          	sw	a5,-40(s0)
    802010f2:	574000ef          	jal	80201666 <uart_getc>
    802010f6:	87aa                	mv	a5,a0
    802010f8:	0007849b          	sext.w	s1,a5
    802010fc:	56a000ef          	jal	80201666 <uart_getc>
    80201100:	87aa                	mv	a5,a0
    80201102:	2781                	sext.w	a5,a5
    80201104:	0087979b          	slliw	a5,a5,0x8
    80201108:	2781                	sext.w	a5,a5
    8020110a:	8726                	mv	a4,s1
    8020110c:	8fd9                	or	a5,a5,a4
    8020110e:	0007849b          	sext.w	s1,a5
    80201112:	554000ef          	jal	80201666 <uart_getc>
    80201116:	87aa                	mv	a5,a0
    80201118:	2781                	sext.w	a5,a5
    8020111a:	0107979b          	slliw	a5,a5,0x10
    8020111e:	2781                	sext.w	a5,a5
    80201120:	8726                	mv	a4,s1
    80201122:	8fd9                	or	a5,a5,a4
    80201124:	0007849b          	sext.w	s1,a5
    80201128:	53e000ef          	jal	80201666 <uart_getc>
    8020112c:	87aa                	mv	a5,a0
    8020112e:	2781                	sext.w	a5,a5
    80201130:	0187979b          	slliw	a5,a5,0x18
    80201134:	2781                	sext.w	a5,a5
    80201136:	8726                	mv	a4,s1
    80201138:	8fd9                	or	a5,a5,a4
    8020113a:	fcf42a23          	sw	a5,-44(s0)
    8020113e:	fd842783          	lw	a5,-40(s0)
    80201142:	0007871b          	sext.w	a4,a5
    80201146:	544f57b7          	lui	a5,0x544f5
    8020114a:	f4278793          	addi	a5,a5,-190 # 544f4f42 <_code_size+0x544ef172>
    8020114e:	00f70963          	beq	a4,a5,80201160 <command_load+0xd0>
    80201152:	00001517          	auipc	a0,0x1
    80201156:	a8650513          	addi	a0,a0,-1402 # 80201bd8 <strcmp+0x32c>
    8020115a:	59a000ef          	jal	802016f4 <uart_puts>
    8020115e:	a869                	j	802011f8 <command_load+0x168>
    80201160:	40100793          	li	a5,1025
    80201164:	07d6                	slli	a5,a5,0x15
    80201166:	fcf43423          	sd	a5,-56(s0)
    8020116a:	fc042e23          	sw	zero,-36(s0)
    8020116e:	a00d                	j	80201190 <command_load+0x100>
    80201170:	fdc46783          	lwu	a5,-36(s0)
    80201174:	fc843703          	ld	a4,-56(s0)
    80201178:	00f704b3          	add	s1,a4,a5
    8020117c:	53a000ef          	jal	802016b6 <uart_getc_raw>
    80201180:	87aa                	mv	a5,a0
    80201182:	00f48023          	sb	a5,0(s1)
    80201186:	fdc42783          	lw	a5,-36(s0)
    8020118a:	2785                	addiw	a5,a5,1
    8020118c:	fcf42e23          	sw	a5,-36(s0)
    80201190:	fdc42783          	lw	a5,-36(s0)
    80201194:	873e                	mv	a4,a5
    80201196:	fd442783          	lw	a5,-44(s0)
    8020119a:	2701                	sext.w	a4,a4
    8020119c:	2781                	sext.w	a5,a5
    8020119e:	fcf769e3          	bltu	a4,a5,80201170 <command_load+0xe0>
    802011a2:	00001517          	auipc	a0,0x1
    802011a6:	a5650513          	addi	a0,a0,-1450 # 80201bf8 <strcmp+0x34c>
    802011aa:	54a000ef          	jal	802016f4 <uart_puts>
    802011ae:	fd446783          	lwu	a5,-44(s0)
    802011b2:	853e                	mv	a0,a5
    802011b4:	5fc000ef          	jal	802017b0 <uart_dec>
    802011b8:	00001517          	auipc	a0,0x1
    802011bc:	a4850513          	addi	a0,a0,-1464 # 80201c00 <strcmp+0x354>
    802011c0:	534000ef          	jal	802016f4 <uart_puts>
    802011c4:	fc843783          	ld	a5,-56(s0)
    802011c8:	853e                	mv	a0,a5
    802011ca:	566000ef          	jal	80201730 <uart_hex>
    802011ce:	00001517          	auipc	a0,0x1
    802011d2:	a4a50513          	addi	a0,a0,-1462 # 80201c18 <strcmp+0x36c>
    802011d6:	51e000ef          	jal	802016f4 <uart_puts>
    802011da:	fc843783          	ld	a5,-56(s0)
    802011de:	00001717          	auipc	a4,0x1
    802011e2:	b5270713          	addi	a4,a4,-1198 # 80201d30 <boot_hart_id>
    802011e6:	4314                	lw	a3,0(a4)
    802011e8:	00001717          	auipc	a4,0x1
    802011ec:	b3870713          	addi	a4,a4,-1224 # 80201d20 <dtb_addr>
    802011f0:	6318                	ld	a4,0(a4)
    802011f2:	85ba                	mv	a1,a4
    802011f4:	8536                	mv	a0,a3
    802011f6:	9782                	jalr	a5
    802011f8:	70e2                	ld	ra,56(sp)
    802011fa:	7442                	ld	s0,48(sp)
    802011fc:	74a2                	ld	s1,40(sp)
    802011fe:	6121                	addi	sp,sp,64
    80201200:	8082                	ret

0000000080201202 <command_unknown>:
    80201202:	1141                	addi	sp,sp,-16
    80201204:	e406                	sd	ra,8(sp)
    80201206:	e022                	sd	s0,0(sp)
    80201208:	0800                	addi	s0,sp,16
    8020120a:	00001517          	auipc	a0,0x1
    8020120e:	a1650513          	addi	a0,a0,-1514 # 80201c20 <strcmp+0x374>
    80201212:	4e2000ef          	jal	802016f4 <uart_puts>
    80201216:	00001517          	auipc	a0,0x1
    8020121a:	b2250513          	addi	a0,a0,-1246 # 80201d38 <buffer>
    8020121e:	4d6000ef          	jal	802016f4 <uart_puts>
    80201222:	00001517          	auipc	a0,0x1
    80201226:	a1650513          	addi	a0,a0,-1514 # 80201c38 <strcmp+0x38c>
    8020122a:	4ca000ef          	jal	802016f4 <uart_puts>
    8020122e:	0001                	nop
    80201230:	60a2                	ld	ra,8(sp)
    80201232:	6402                	ld	s0,0(sp)
    80201234:	0141                	addi	sp,sp,16
    80201236:	8082                	ret

0000000080201238 <command_ls>:
    80201238:	1141                	addi	sp,sp,-16
    8020123a:	e406                	sd	ra,8(sp)
    8020123c:	e022                	sd	s0,0(sp)
    8020123e:	0800                	addi	s0,sp,16
    80201240:	00001797          	auipc	a5,0x1
    80201244:	ae878793          	addi	a5,a5,-1304 # 80201d28 <cpio_addr>
    80201248:	639c                	ld	a5,0(a5)
    8020124a:	eb81                	bnez	a5,8020125a <command_ls+0x22>
    8020124c:	00001517          	auipc	a0,0x1
    80201250:	a0c50513          	addi	a0,a0,-1524 # 80201c58 <strcmp+0x3ac>
    80201254:	4a0000ef          	jal	802016f4 <uart_puts>
    80201258:	a809                	j	8020126a <command_ls+0x32>
    8020125a:	00001797          	auipc	a5,0x1
    8020125e:	ace78793          	addi	a5,a5,-1330 # 80201d28 <cpio_addr>
    80201262:	639c                	ld	a5,0(a5)
    80201264:	853e                	mv	a0,a5
    80201266:	f4bfe0ef          	jal	802001b0 <cpio_ls>
    8020126a:	60a2                	ld	ra,8(sp)
    8020126c:	6402                	ld	s0,0(sp)
    8020126e:	0141                	addi	sp,sp,16
    80201270:	8082                	ret

0000000080201272 <command_cat>:
    80201272:	1101                	addi	sp,sp,-32
    80201274:	ec06                	sd	ra,24(sp)
    80201276:	e822                	sd	s0,16(sp)
    80201278:	1000                	addi	s0,sp,32
    8020127a:	00001797          	auipc	a5,0x1
    8020127e:	abe78793          	addi	a5,a5,-1346 # 80201d38 <buffer>
    80201282:	fef43423          	sd	a5,-24(s0)
    80201286:	a031                	j	80201292 <command_cat+0x20>
    80201288:	fe843783          	ld	a5,-24(s0)
    8020128c:	0785                	addi	a5,a5,1
    8020128e:	fef43423          	sd	a5,-24(s0)
    80201292:	fe843783          	ld	a5,-24(s0)
    80201296:	0007c783          	lbu	a5,0(a5)
    8020129a:	cb91                	beqz	a5,802012ae <command_cat+0x3c>
    8020129c:	fe843783          	ld	a5,-24(s0)
    802012a0:	0007c783          	lbu	a5,0(a5)
    802012a4:	873e                	mv	a4,a5
    802012a6:	02000793          	li	a5,32
    802012aa:	fcf71fe3          	bne	a4,a5,80201288 <command_cat+0x16>
    802012ae:	fe843783          	ld	a5,-24(s0)
    802012b2:	0007c783          	lbu	a5,0(a5)
    802012b6:	eb81                	bnez	a5,802012c6 <command_cat+0x54>
    802012b8:	00001517          	auipc	a0,0x1
    802012bc:	9c050513          	addi	a0,a0,-1600 # 80201c78 <strcmp+0x3cc>
    802012c0:	434000ef          	jal	802016f4 <uart_puts>
    802012c4:	a095                	j	80201328 <command_cat+0xb6>
    802012c6:	fe843783          	ld	a5,-24(s0)
    802012ca:	0007c783          	lbu	a5,0(a5)
    802012ce:	873e                	mv	a4,a5
    802012d0:	02000793          	li	a5,32
    802012d4:	00f71763          	bne	a4,a5,802012e2 <command_cat+0x70>
    802012d8:	fe843783          	ld	a5,-24(s0)
    802012dc:	0785                	addi	a5,a5,1
    802012de:	fef43423          	sd	a5,-24(s0)
    802012e2:	fe843783          	ld	a5,-24(s0)
    802012e6:	0007c783          	lbu	a5,0(a5)
    802012ea:	eb81                	bnez	a5,802012fa <command_cat+0x88>
    802012ec:	00001517          	auipc	a0,0x1
    802012f0:	98c50513          	addi	a0,a0,-1652 # 80201c78 <strcmp+0x3cc>
    802012f4:	400000ef          	jal	802016f4 <uart_puts>
    802012f8:	a805                	j	80201328 <command_cat+0xb6>
    802012fa:	00001797          	auipc	a5,0x1
    802012fe:	a2e78793          	addi	a5,a5,-1490 # 80201d28 <cpio_addr>
    80201302:	639c                	ld	a5,0(a5)
    80201304:	eb81                	bnez	a5,80201314 <command_cat+0xa2>
    80201306:	00001517          	auipc	a0,0x1
    8020130a:	95250513          	addi	a0,a0,-1710 # 80201c58 <strcmp+0x3ac>
    8020130e:	3e6000ef          	jal	802016f4 <uart_puts>
    80201312:	a819                	j	80201328 <command_cat+0xb6>
    80201314:	00001797          	auipc	a5,0x1
    80201318:	a1478793          	addi	a5,a5,-1516 # 80201d28 <cpio_addr>
    8020131c:	639c                	ld	a5,0(a5)
    8020131e:	fe843583          	ld	a1,-24(s0)
    80201322:	853e                	mv	a0,a5
    80201324:	8c0ff0ef          	jal	802003e4 <cpio_cat>
    80201328:	60e2                	ld	ra,24(sp)
    8020132a:	6442                	ld	s0,16(sp)
    8020132c:	6105                	addi	sp,sp,32
    8020132e:	8082                	ret

0000000080201330 <cmp_command>:
    80201330:	1141                	addi	sp,sp,-16
    80201332:	e406                	sd	ra,8(sp)
    80201334:	e022                	sd	s0,0(sp)
    80201336:	0800                	addi	s0,sp,16
    80201338:	00001597          	auipc	a1,0x1
    8020133c:	95858593          	addi	a1,a1,-1704 # 80201c90 <strcmp+0x3e4>
    80201340:	00001517          	auipc	a0,0x1
    80201344:	9f850513          	addi	a0,a0,-1544 # 80201d38 <buffer>
    80201348:	564000ef          	jal	802018ac <strcmp>
    8020134c:	87aa                	mv	a5,a0
    8020134e:	e781                	bnez	a5,80201356 <cmp_command+0x26>
    80201350:	c1bff0ef          	jal	80200f6a <command_help>
    80201354:	a0ed                	j	8020143e <cmp_command+0x10e>
    80201356:	00001597          	auipc	a1,0x1
    8020135a:	94258593          	addi	a1,a1,-1726 # 80201c98 <strcmp+0x3ec>
    8020135e:	00001517          	auipc	a0,0x1
    80201362:	9da50513          	addi	a0,a0,-1574 # 80201d38 <buffer>
    80201366:	546000ef          	jal	802018ac <strcmp>
    8020136a:	87aa                	mv	a5,a0
    8020136c:	e781                	bnez	a5,80201374 <cmp_command+0x44>
    8020136e:	c4bff0ef          	jal	80200fb8 <command_hello>
    80201372:	a0f1                	j	8020143e <cmp_command+0x10e>
    80201374:	00001597          	auipc	a1,0x1
    80201378:	92c58593          	addi	a1,a1,-1748 # 80201ca0 <strcmp+0x3f4>
    8020137c:	00001517          	auipc	a0,0x1
    80201380:	9bc50513          	addi	a0,a0,-1604 # 80201d38 <buffer>
    80201384:	528000ef          	jal	802018ac <strcmp>
    80201388:	87aa                	mv	a5,a0
    8020138a:	e781                	bnez	a5,80201392 <cmp_command+0x62>
    8020138c:	c4bff0ef          	jal	80200fd6 <command_info>
    80201390:	a07d                	j	8020143e <cmp_command+0x10e>
    80201392:	00001597          	auipc	a1,0x1
    80201396:	91658593          	addi	a1,a1,-1770 # 80201ca8 <strcmp+0x3fc>
    8020139a:	00001517          	auipc	a0,0x1
    8020139e:	99e50513          	addi	a0,a0,-1634 # 80201d38 <buffer>
    802013a2:	50a000ef          	jal	802018ac <strcmp>
    802013a6:	87aa                	mv	a5,a0
    802013a8:	e781                	bnez	a5,802013b0 <cmp_command+0x80>
    802013aa:	ce7ff0ef          	jal	80201090 <command_load>
    802013ae:	a841                	j	8020143e <cmp_command+0x10e>
    802013b0:	00001597          	auipc	a1,0x1
    802013b4:	90058593          	addi	a1,a1,-1792 # 80201cb0 <strcmp+0x404>
    802013b8:	00001517          	auipc	a0,0x1
    802013bc:	98050513          	addi	a0,a0,-1664 # 80201d38 <buffer>
    802013c0:	4ec000ef          	jal	802018ac <strcmp>
    802013c4:	87aa                	mv	a5,a0
    802013c6:	e781                	bnez	a5,802013ce <cmp_command+0x9e>
    802013c8:	e71ff0ef          	jal	80201238 <command_ls>
    802013cc:	a88d                	j	8020143e <cmp_command+0x10e>
    802013ce:	00001797          	auipc	a5,0x1
    802013d2:	96a78793          	addi	a5,a5,-1686 # 80201d38 <buffer>
    802013d6:	0007c783          	lbu	a5,0(a5)
    802013da:	873e                	mv	a4,a5
    802013dc:	06300793          	li	a5,99
    802013e0:	04f71d63          	bne	a4,a5,8020143a <cmp_command+0x10a>
    802013e4:	00001797          	auipc	a5,0x1
    802013e8:	95478793          	addi	a5,a5,-1708 # 80201d38 <buffer>
    802013ec:	0017c783          	lbu	a5,1(a5)
    802013f0:	873e                	mv	a4,a5
    802013f2:	06100793          	li	a5,97
    802013f6:	04f71263          	bne	a4,a5,8020143a <cmp_command+0x10a>
    802013fa:	00001797          	auipc	a5,0x1
    802013fe:	93e78793          	addi	a5,a5,-1730 # 80201d38 <buffer>
    80201402:	0027c783          	lbu	a5,2(a5)
    80201406:	873e                	mv	a4,a5
    80201408:	07400793          	li	a5,116
    8020140c:	02f71763          	bne	a4,a5,8020143a <cmp_command+0x10a>
    80201410:	00001797          	auipc	a5,0x1
    80201414:	92878793          	addi	a5,a5,-1752 # 80201d38 <buffer>
    80201418:	0037c783          	lbu	a5,3(a5)
    8020141c:	873e                	mv	a4,a5
    8020141e:	02000793          	li	a5,32
    80201422:	00f70963          	beq	a4,a5,80201434 <cmp_command+0x104>
    80201426:	00001797          	auipc	a5,0x1
    8020142a:	91278793          	addi	a5,a5,-1774 # 80201d38 <buffer>
    8020142e:	0037c783          	lbu	a5,3(a5)
    80201432:	e781                	bnez	a5,8020143a <cmp_command+0x10a>
    80201434:	e3fff0ef          	jal	80201272 <command_cat>
    80201438:	a019                	j	8020143e <cmp_command+0x10e>
    8020143a:	dc9ff0ef          	jal	80201202 <command_unknown>
    8020143e:	0001                	nop
    80201440:	60a2                	ld	ra,8(sp)
    80201442:	6402                	ld	s0,0(sp)
    80201444:	0141                	addi	sp,sp,16
    80201446:	8082                	ret

0000000080201448 <put_char>:
    80201448:	1101                	addi	sp,sp,-32
    8020144a:	ec06                	sd	ra,24(sp)
    8020144c:	e822                	sd	s0,16(sp)
    8020144e:	1000                	addi	s0,sp,32
    80201450:	87aa                	mv	a5,a0
    80201452:	872e                	mv	a4,a1
    80201454:	fef42623          	sw	a5,-20(s0)
    80201458:	87ba                	mv	a5,a4
    8020145a:	fef405a3          	sb	a5,-21(s0)
    8020145e:	fec42783          	lw	a5,-20(s0)
    80201462:	0007871b          	sext.w	a4,a5
    80201466:	20100793          	li	a5,513
    8020146a:	0cf70c63          	beq	a4,a5,80201542 <put_char+0xfa>
    8020146e:	fec42783          	lw	a5,-20(s0)
    80201472:	0007871b          	sext.w	a4,a5
    80201476:	20100793          	li	a5,513
    8020147a:	10e7ec63          	bltu	a5,a4,80201592 <put_char+0x14a>
    8020147e:	fec42783          	lw	a5,-20(s0)
    80201482:	0007871b          	sext.w	a4,a5
    80201486:	47a9                	li	a5,10
    80201488:	04f70563          	beq	a4,a5,802014d2 <put_char+0x8a>
    8020148c:	fec42783          	lw	a5,-20(s0)
    80201490:	0007871b          	sext.w	a4,a5
    80201494:	07f00793          	li	a5,127
    80201498:	0ef71d63          	bne	a4,a5,80201592 <put_char+0x14a>
    8020149c:	00001797          	auipc	a5,0x1
    802014a0:	91c78793          	addi	a5,a5,-1764 # 80201db8 <buf_len>
    802014a4:	439c                	lw	a5,0(a5)
    802014a6:	00f05f63          	blez	a5,802014c4 <put_char+0x7c>
    802014aa:	00001797          	auipc	a5,0x1
    802014ae:	90e78793          	addi	a5,a5,-1778 # 80201db8 <buf_len>
    802014b2:	439c                	lw	a5,0(a5)
    802014b4:	37fd                	addiw	a5,a5,-1
    802014b6:	0007871b          	sext.w	a4,a5
    802014ba:	00001797          	auipc	a5,0x1
    802014be:	8fe78793          	addi	a5,a5,-1794 # 80201db8 <buf_len>
    802014c2:	c398                	sw	a4,0(a5)
    802014c4:	00000517          	auipc	a0,0x0
    802014c8:	7f450513          	addi	a0,a0,2036 # 80201cb8 <strcmp+0x40c>
    802014cc:	228000ef          	jal	802016f4 <uart_puts>
    802014d0:	a0d1                	j	80201594 <put_char+0x14c>
    802014d2:	4529                	li	a0,10
    802014d4:	132000ef          	jal	80201606 <uart_putc>
    802014d8:	00001797          	auipc	a5,0x1
    802014dc:	8e078793          	addi	a5,a5,-1824 # 80201db8 <buf_len>
    802014e0:	439c                	lw	a5,0(a5)
    802014e2:	873e                	mv	a4,a5
    802014e4:	08000793          	li	a5,128
    802014e8:	00f71963          	bne	a4,a5,802014fa <put_char+0xb2>
    802014ec:	00000517          	auipc	a0,0x0
    802014f0:	7d450513          	addi	a0,a0,2004 # 80201cc0 <strcmp+0x414>
    802014f4:	200000ef          	jal	802016f4 <uart_puts>
    802014f8:	a839                	j	80201516 <put_char+0xce>
    802014fa:	00001797          	auipc	a5,0x1
    802014fe:	8be78793          	addi	a5,a5,-1858 # 80201db8 <buf_len>
    80201502:	439c                	lw	a5,0(a5)
    80201504:	00001717          	auipc	a4,0x1
    80201508:	83470713          	addi	a4,a4,-1996 # 80201d38 <buffer>
    8020150c:	97ba                	add	a5,a5,a4
    8020150e:	00078023          	sb	zero,0(a5)
    80201512:	e1fff0ef          	jal	80201330 <cmp_command>
    80201516:	00001797          	auipc	a5,0x1
    8020151a:	8a278793          	addi	a5,a5,-1886 # 80201db8 <buf_len>
    8020151e:	0007a023          	sw	zero,0(a5)
    80201522:	08000613          	li	a2,128
    80201526:	4581                	li	a1,0
    80201528:	00001517          	auipc	a0,0x1
    8020152c:	81050513          	addi	a0,a0,-2032 # 80201d38 <buffer>
    80201530:	31e000ef          	jal	8020184e <memset>
    80201534:	00000517          	auipc	a0,0x0
    80201538:	7c450513          	addi	a0,a0,1988 # 80201cf8 <strcmp+0x44c>
    8020153c:	1b8000ef          	jal	802016f4 <uart_puts>
    80201540:	a891                	j	80201594 <put_char+0x14c>
    80201542:	00001797          	auipc	a5,0x1
    80201546:	87678793          	addi	a5,a5,-1930 # 80201db8 <buf_len>
    8020154a:	439c                	lw	a5,0(a5)
    8020154c:	873e                	mv	a4,a5
    8020154e:	07f00793          	li	a5,127
    80201552:	02e7c963          	blt	a5,a4,80201584 <put_char+0x13c>
    80201556:	00001797          	auipc	a5,0x1
    8020155a:	86278793          	addi	a5,a5,-1950 # 80201db8 <buf_len>
    8020155e:	439c                	lw	a5,0(a5)
    80201560:	0017871b          	addiw	a4,a5,1
    80201564:	0007069b          	sext.w	a3,a4
    80201568:	00001717          	auipc	a4,0x1
    8020156c:	85070713          	addi	a4,a4,-1968 # 80201db8 <buf_len>
    80201570:	c314                	sw	a3,0(a4)
    80201572:	00000717          	auipc	a4,0x0
    80201576:	7c670713          	addi	a4,a4,1990 # 80201d38 <buffer>
    8020157a:	97ba                	add	a5,a5,a4
    8020157c:	feb44703          	lbu	a4,-21(s0)
    80201580:	00e78023          	sb	a4,0(a5)
    80201584:	feb44783          	lbu	a5,-21(s0)
    80201588:	2781                	sext.w	a5,a5
    8020158a:	853e                	mv	a0,a5
    8020158c:	07a000ef          	jal	80201606 <uart_putc>
    80201590:	a011                	j	80201594 <put_char+0x14c>
    80201592:	0001                	nop
    80201594:	0001                	nop
    80201596:	60e2                	ld	ra,24(sp)
    80201598:	6442                	ld	s0,16(sp)
    8020159a:	6105                	addi	sp,sp,32
    8020159c:	8082                	ret

000000008020159e <shell>:
    8020159e:	1101                	addi	sp,sp,-32
    802015a0:	ec06                	sd	ra,24(sp)
    802015a2:	e822                	sd	s0,16(sp)
    802015a4:	1000                	addi	s0,sp,32
    802015a6:	00000517          	auipc	a0,0x0
    802015aa:	75250513          	addi	a0,a0,1874 # 80201cf8 <strcmp+0x44c>
    802015ae:	146000ef          	jal	802016f4 <uart_puts>
    802015b2:	0b4000ef          	jal	80201666 <uart_getc>
    802015b6:	87aa                	mv	a5,a0
    802015b8:	fef407a3          	sb	a5,-17(s0)
    802015bc:	fef44783          	lbu	a5,-17(s0)
    802015c0:	853e                	mv	a0,a5
    802015c2:	93fff0ef          	jal	80200f00 <parse>
    802015c6:	87aa                	mv	a5,a0
    802015c8:	fef42423          	sw	a5,-24(s0)
    802015cc:	fef44703          	lbu	a4,-17(s0)
    802015d0:	fe842783          	lw	a5,-24(s0)
    802015d4:	85ba                	mv	a1,a4
    802015d6:	853e                	mv	a0,a5
    802015d8:	e71ff0ef          	jal	80201448 <put_char>
    802015dc:	0001                	nop
    802015de:	bfd1                	j	802015b2 <shell+0x14>

00000000802015e0 <uart_set_base>:
    802015e0:	1101                	addi	sp,sp,-32
    802015e2:	ec22                	sd	s0,24(sp)
    802015e4:	1000                	addi	s0,sp,32
    802015e6:	fea43423          	sd	a0,-24(s0)
    802015ea:	fe843783          	ld	a5,-24(s0)
    802015ee:	cb81                	beqz	a5,802015fe <uart_set_base+0x1e>
    802015f0:	00000797          	auipc	a5,0x0
    802015f4:	7d078793          	addi	a5,a5,2000 # 80201dc0 <g_uart_base>
    802015f8:	fe843703          	ld	a4,-24(s0)
    802015fc:	e398                	sd	a4,0(a5)
    802015fe:	0001                	nop
    80201600:	6462                	ld	s0,24(sp)
    80201602:	6105                	addi	sp,sp,32
    80201604:	8082                	ret

0000000080201606 <uart_putc>:
    80201606:	1101                	addi	sp,sp,-32
    80201608:	ec06                	sd	ra,24(sp)
    8020160a:	e822                	sd	s0,16(sp)
    8020160c:	1000                	addi	s0,sp,32
    8020160e:	87aa                	mv	a5,a0
    80201610:	fef42623          	sw	a5,-20(s0)
    80201614:	fec42783          	lw	a5,-20(s0)
    80201618:	0007871b          	sext.w	a4,a5
    8020161c:	47a9                	li	a5,10
    8020161e:	00f71563          	bne	a4,a5,80201628 <uart_putc+0x22>
    80201622:	4535                	li	a0,13
    80201624:	fe3ff0ef          	jal	80201606 <uart_putc>
    80201628:	0001                	nop
    8020162a:	00000797          	auipc	a5,0x0
    8020162e:	79678793          	addi	a5,a5,1942 # 80201dc0 <g_uart_base>
    80201632:	639c                	ld	a5,0(a5)
    80201634:	0795                	addi	a5,a5,5
    80201636:	0007c783          	lbu	a5,0(a5)
    8020163a:	2781                	sext.w	a5,a5
    8020163c:	0207f793          	andi	a5,a5,32
    80201640:	2781                	sext.w	a5,a5
    80201642:	d7e5                	beqz	a5,8020162a <uart_putc+0x24>
    80201644:	00000797          	auipc	a5,0x0
    80201648:	77c78793          	addi	a5,a5,1916 # 80201dc0 <g_uart_base>
    8020164c:	639c                	ld	a5,0(a5)
    8020164e:	873e                	mv	a4,a5
    80201650:	fec42783          	lw	a5,-20(s0)
    80201654:	0ff7f793          	zext.b	a5,a5
    80201658:	00f70023          	sb	a5,0(a4)
    8020165c:	0001                	nop
    8020165e:	60e2                	ld	ra,24(sp)
    80201660:	6442                	ld	s0,16(sp)
    80201662:	6105                	addi	sp,sp,32
    80201664:	8082                	ret

0000000080201666 <uart_getc>:
    80201666:	1101                	addi	sp,sp,-32
    80201668:	ec22                	sd	s0,24(sp)
    8020166a:	1000                	addi	s0,sp,32
    8020166c:	0001                	nop
    8020166e:	00000797          	auipc	a5,0x0
    80201672:	75278793          	addi	a5,a5,1874 # 80201dc0 <g_uart_base>
    80201676:	639c                	ld	a5,0(a5)
    80201678:	0795                	addi	a5,a5,5
    8020167a:	0007c783          	lbu	a5,0(a5)
    8020167e:	2781                	sext.w	a5,a5
    80201680:	8b85                	andi	a5,a5,1
    80201682:	2781                	sext.w	a5,a5
    80201684:	d7ed                	beqz	a5,8020166e <uart_getc+0x8>
    80201686:	00000797          	auipc	a5,0x0
    8020168a:	73a78793          	addi	a5,a5,1850 # 80201dc0 <g_uart_base>
    8020168e:	639c                	ld	a5,0(a5)
    80201690:	0007c783          	lbu	a5,0(a5)
    80201694:	fef407a3          	sb	a5,-17(s0)
    80201698:	fef44783          	lbu	a5,-17(s0)
    8020169c:	0ff7f713          	zext.b	a4,a5
    802016a0:	47b5                	li	a5,13
    802016a2:	00f70563          	beq	a4,a5,802016ac <uart_getc+0x46>
    802016a6:	fef44783          	lbu	a5,-17(s0)
    802016aa:	a011                	j	802016ae <uart_getc+0x48>
    802016ac:	47a9                	li	a5,10
    802016ae:	853e                	mv	a0,a5
    802016b0:	6462                	ld	s0,24(sp)
    802016b2:	6105                	addi	sp,sp,32
    802016b4:	8082                	ret

00000000802016b6 <uart_getc_raw>:
    802016b6:	1101                	addi	sp,sp,-32
    802016b8:	ec22                	sd	s0,24(sp)
    802016ba:	1000                	addi	s0,sp,32
    802016bc:	0001                	nop
    802016be:	00000797          	auipc	a5,0x0
    802016c2:	70278793          	addi	a5,a5,1794 # 80201dc0 <g_uart_base>
    802016c6:	639c                	ld	a5,0(a5)
    802016c8:	0795                	addi	a5,a5,5
    802016ca:	0007c783          	lbu	a5,0(a5)
    802016ce:	2781                	sext.w	a5,a5
    802016d0:	8b85                	andi	a5,a5,1
    802016d2:	2781                	sext.w	a5,a5
    802016d4:	d7ed                	beqz	a5,802016be <uart_getc_raw+0x8>
    802016d6:	00000797          	auipc	a5,0x0
    802016da:	6ea78793          	addi	a5,a5,1770 # 80201dc0 <g_uart_base>
    802016de:	639c                	ld	a5,0(a5)
    802016e0:	0007c783          	lbu	a5,0(a5)
    802016e4:	fef407a3          	sb	a5,-17(s0)
    802016e8:	fef44783          	lbu	a5,-17(s0)
    802016ec:	853e                	mv	a0,a5
    802016ee:	6462                	ld	s0,24(sp)
    802016f0:	6105                	addi	sp,sp,32
    802016f2:	8082                	ret

00000000802016f4 <uart_puts>:
    802016f4:	1101                	addi	sp,sp,-32
    802016f6:	ec06                	sd	ra,24(sp)
    802016f8:	e822                	sd	s0,16(sp)
    802016fa:	1000                	addi	s0,sp,32
    802016fc:	fea43423          	sd	a0,-24(s0)
    80201700:	a829                	j	8020171a <uart_puts+0x26>
    80201702:	fe843783          	ld	a5,-24(s0)
    80201706:	00178713          	addi	a4,a5,1
    8020170a:	fee43423          	sd	a4,-24(s0)
    8020170e:	0007c783          	lbu	a5,0(a5)
    80201712:	2781                	sext.w	a5,a5
    80201714:	853e                	mv	a0,a5
    80201716:	ef1ff0ef          	jal	80201606 <uart_putc>
    8020171a:	fe843783          	ld	a5,-24(s0)
    8020171e:	0007c783          	lbu	a5,0(a5)
    80201722:	f3e5                	bnez	a5,80201702 <uart_puts+0xe>
    80201724:	0001                	nop
    80201726:	0001                	nop
    80201728:	60e2                	ld	ra,24(sp)
    8020172a:	6442                	ld	s0,16(sp)
    8020172c:	6105                	addi	sp,sp,32
    8020172e:	8082                	ret

0000000080201730 <uart_hex>:
    80201730:	7179                	addi	sp,sp,-48
    80201732:	f406                	sd	ra,40(sp)
    80201734:	f022                	sd	s0,32(sp)
    80201736:	1800                	addi	s0,sp,48
    80201738:	fca43c23          	sd	a0,-40(s0)
    8020173c:	00000517          	auipc	a0,0x0
    80201740:	5cc50513          	addi	a0,a0,1484 # 80201d08 <strcmp+0x45c>
    80201744:	fb1ff0ef          	jal	802016f4 <uart_puts>
    80201748:	03c00793          	li	a5,60
    8020174c:	fef42623          	sw	a5,-20(s0)
    80201750:	a0a9                	j	8020179a <uart_hex+0x6a>
    80201752:	fec42783          	lw	a5,-20(s0)
    80201756:	873e                	mv	a4,a5
    80201758:	fd843783          	ld	a5,-40(s0)
    8020175c:	00e7d7b3          	srl	a5,a5,a4
    80201760:	8bbd                	andi	a5,a5,15
    80201762:	fef43023          	sd	a5,-32(s0)
    80201766:	fe043703          	ld	a4,-32(s0)
    8020176a:	47a5                	li	a5,9
    8020176c:	00e7f563          	bgeu	a5,a4,80201776 <uart_hex+0x46>
    80201770:	05700793          	li	a5,87
    80201774:	a019                	j	8020177a <uart_hex+0x4a>
    80201776:	03000793          	li	a5,48
    8020177a:	fe043703          	ld	a4,-32(s0)
    8020177e:	97ba                	add	a5,a5,a4
    80201780:	fef43023          	sd	a5,-32(s0)
    80201784:	fe043783          	ld	a5,-32(s0)
    80201788:	2781                	sext.w	a5,a5
    8020178a:	853e                	mv	a0,a5
    8020178c:	e7bff0ef          	jal	80201606 <uart_putc>
    80201790:	fec42783          	lw	a5,-20(s0)
    80201794:	37f1                	addiw	a5,a5,-4
    80201796:	fef42623          	sw	a5,-20(s0)
    8020179a:	fec42783          	lw	a5,-20(s0)
    8020179e:	2781                	sext.w	a5,a5
    802017a0:	fa07d9e3          	bgez	a5,80201752 <uart_hex+0x22>
    802017a4:	0001                	nop
    802017a6:	0001                	nop
    802017a8:	70a2                	ld	ra,40(sp)
    802017aa:	7402                	ld	s0,32(sp)
    802017ac:	6145                	addi	sp,sp,48
    802017ae:	8082                	ret

00000000802017b0 <uart_dec>:
    802017b0:	715d                	addi	sp,sp,-80
    802017b2:	e486                	sd	ra,72(sp)
    802017b4:	e0a2                	sd	s0,64(sp)
    802017b6:	0880                	addi	s0,sp,80
    802017b8:	faa43c23          	sd	a0,-72(s0)
    802017bc:	fe042623          	sw	zero,-20(s0)
    802017c0:	fb843783          	ld	a5,-72(s0)
    802017c4:	e3b1                	bnez	a5,80201808 <uart_dec+0x58>
    802017c6:	03000513          	li	a0,48
    802017ca:	e3dff0ef          	jal	80201606 <uart_putc>
    802017ce:	a8a5                	j	80201846 <uart_dec+0x96>
    802017d0:	fb843703          	ld	a4,-72(s0)
    802017d4:	47a9                	li	a5,10
    802017d6:	02f777b3          	remu	a5,a4,a5
    802017da:	0ff7f713          	zext.b	a4,a5
    802017de:	fec42783          	lw	a5,-20(s0)
    802017e2:	0017869b          	addiw	a3,a5,1
    802017e6:	fed42623          	sw	a3,-20(s0)
    802017ea:	0307071b          	addiw	a4,a4,48
    802017ee:	0ff77713          	zext.b	a4,a4
    802017f2:	17c1                	addi	a5,a5,-16
    802017f4:	97a2                	add	a5,a5,s0
    802017f6:	fce78c23          	sb	a4,-40(a5)
    802017fa:	fb843703          	ld	a4,-72(s0)
    802017fe:	47a9                	li	a5,10
    80201800:	02f757b3          	divu	a5,a4,a5
    80201804:	faf43c23          	sd	a5,-72(s0)
    80201808:	fb843783          	ld	a5,-72(s0)
    8020180c:	cb85                	beqz	a5,8020183c <uart_dec+0x8c>
    8020180e:	fec42783          	lw	a5,-20(s0)
    80201812:	0007871b          	sext.w	a4,a5
    80201816:	47fd                	li	a5,31
    80201818:	fae7dce3          	bge	a5,a4,802017d0 <uart_dec+0x20>
    8020181c:	a005                	j	8020183c <uart_dec+0x8c>
    8020181e:	fec42783          	lw	a5,-20(s0)
    80201822:	37fd                	addiw	a5,a5,-1
    80201824:	fef42623          	sw	a5,-20(s0)
    80201828:	fec42783          	lw	a5,-20(s0)
    8020182c:	17c1                	addi	a5,a5,-16
    8020182e:	97a2                	add	a5,a5,s0
    80201830:	fd87c783          	lbu	a5,-40(a5)
    80201834:	2781                	sext.w	a5,a5
    80201836:	853e                	mv	a0,a5
    80201838:	dcfff0ef          	jal	80201606 <uart_putc>
    8020183c:	fec42783          	lw	a5,-20(s0)
    80201840:	2781                	sext.w	a5,a5
    80201842:	fcf04ee3          	bgtz	a5,8020181e <uart_dec+0x6e>
    80201846:	60a6                	ld	ra,72(sp)
    80201848:	6406                	ld	s0,64(sp)
    8020184a:	6161                	addi	sp,sp,80
    8020184c:	8082                	ret

000000008020184e <memset>:
    8020184e:	1101                	addi	sp,sp,-32
    80201850:	ec22                	sd	s0,24(sp)
    80201852:	1000                	addi	s0,sp,32
    80201854:	fea43423          	sd	a0,-24(s0)
    80201858:	87ae                	mv	a5,a1
    8020185a:	8732                	mv	a4,a2
    8020185c:	fef42223          	sw	a5,-28(s0)
    80201860:	87ba                	mv	a5,a4
    80201862:	fef42023          	sw	a5,-32(s0)
    80201866:	fe042783          	lw	a5,-32(s0)
    8020186a:	2781                	sext.w	a5,a5
    8020186c:	cf85                	beqz	a5,802018a4 <memset+0x56>
    8020186e:	fe442783          	lw	a5,-28(s0)
    80201872:	0ff7f793          	zext.b	a5,a5
    80201876:	fef42223          	sw	a5,-28(s0)
    8020187a:	a829                	j	80201894 <memset+0x46>
    8020187c:	fe843783          	ld	a5,-24(s0)
    80201880:	00178713          	addi	a4,a5,1
    80201884:	fee43423          	sd	a4,-24(s0)
    80201888:	fe442703          	lw	a4,-28(s0)
    8020188c:	0ff77713          	zext.b	a4,a4
    80201890:	00e78023          	sb	a4,0(a5)
    80201894:	fe042783          	lw	a5,-32(s0)
    80201898:	fff7871b          	addiw	a4,a5,-1
    8020189c:	fee42023          	sw	a4,-32(s0)
    802018a0:	fff1                	bnez	a5,8020187c <memset+0x2e>
    802018a2:	a011                	j	802018a6 <memset+0x58>
    802018a4:	0001                	nop
    802018a6:	6462                	ld	s0,24(sp)
    802018a8:	6105                	addi	sp,sp,32
    802018aa:	8082                	ret

00000000802018ac <strcmp>:
    802018ac:	7179                	addi	sp,sp,-48
    802018ae:	f422                	sd	s0,40(sp)
    802018b0:	1800                	addi	s0,sp,48
    802018b2:	fca43c23          	sd	a0,-40(s0)
    802018b6:	fcb43823          	sd	a1,-48(s0)
    802018ba:	fd843783          	ld	a5,-40(s0)
    802018be:	00178713          	addi	a4,a5,1
    802018c2:	fce43c23          	sd	a4,-40(s0)
    802018c6:	0007c783          	lbu	a5,0(a5)
    802018ca:	fef407a3          	sb	a5,-17(s0)
    802018ce:	fd043783          	ld	a5,-48(s0)
    802018d2:	00178713          	addi	a4,a5,1
    802018d6:	fce43823          	sd	a4,-48(s0)
    802018da:	0007c783          	lbu	a5,0(a5)
    802018de:	fef40723          	sb	a5,-18(s0)
    802018e2:	fef44783          	lbu	a5,-17(s0)
    802018e6:	873e                	mv	a4,a5
    802018e8:	fee44783          	lbu	a5,-18(s0)
    802018ec:	0ff77713          	zext.b	a4,a4
    802018f0:	0ff7f793          	zext.b	a5,a5
    802018f4:	00f70d63          	beq	a4,a5,8020190e <strcmp+0x62>
    802018f8:	fef44783          	lbu	a5,-17(s0)
    802018fc:	0007871b          	sext.w	a4,a5
    80201900:	fee44783          	lbu	a5,-18(s0)
    80201904:	2781                	sext.w	a5,a5
    80201906:	40f707bb          	subw	a5,a4,a5
    8020190a:	2781                	sext.w	a5,a5
    8020190c:	a809                	j	8020191e <strcmp+0x72>
    8020190e:	fef44783          	lbu	a5,-17(s0)
    80201912:	0ff7f793          	zext.b	a5,a5
    80201916:	c391                	beqz	a5,8020191a <strcmp+0x6e>
    80201918:	b74d                	j	802018ba <strcmp+0xe>
    8020191a:	0001                	nop
    8020191c:	4781                	li	a5,0
    8020191e:	853e                	mv	a0,a5
    80201920:	7422                	ld	s0,40(sp)
    80201922:	6145                	addi	sp,sp,48
    80201924:	8082                	ret
