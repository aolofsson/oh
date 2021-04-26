#!/bin/bash
#FUNCTIONS
echo -n "ret," ; grep "ret " $1  | wc -l
echo -n "jalr," ; grep "jalr " $1  | wc -l
echo -n "jal," ; grep "jal " $1  | wc -l
#BRANCHES
echo -n "beqz," ; grep "beqz " $1  | wc -l
echo -n "beq,"  ; grep "beq " $1   |  wc -l
echo -n "bnez," ; grep "bnez " $1  | wc -l
echo -n "bne,"  ; grep "bne " $1   | wc -l
echo -n "bltu," ; grep "bltu " $1  | wc -l
echo -n "blt,"  ; grep "blt " $1   | wc -l
#MOV
echo -n "mv,"   ; grep "mv " $1    | wc -l
echo -n "li,"   ; grep "li " $1    | wc -l
echo -n "lui,"  ; grep "lui " $1   | wc -l
#INT
echo -n "add,"  ; grep "add " $1   | wc -l
echo -n "addw,"  ; grep "addw " $1 | wc -l
echo -n "sub,"  ; grep "sub " $1   | wc -l
echo -n "subw,"  ; grep "subw " $1 | wc -l
echo -n "addi," ; grep "addi " $1  | wc -l
echo -n "addiw," ; grep "addiw " $1  | wc -l
echo -n "or,"   ; grep " or "  $1  | wc -l
echo -n "ori,"  ; grep " ori "  $1 | wc -l
echo -n "and,"  ; grep " and "  $1 | wc -l
echo -n "andi," ; grep " andi " $1 | wc -l
echo -n "xor,"  ; grep " xor "  $1 | wc -l
echo -n "srli," ; grep "srli " $1  | wc -l
echo -n "slli," ; grep "slli " $1  | wc -l
#MUL
echo -n "mulw," ; grep "mulw " $1  | wc -l
echo -n "mul," ; grep "mul " $1  | wc -l
echo -n "mulu," ; grep "mulu " $1  | wc -l
#L/S
echo -n "lb,"   ; grep "lb " $1    | wc -l
echo -n "lbu,"  ; grep "lbu " $1   | wc -l
echo -n "lh,"   ; grep "lh " $1    | wc -l
echo -n "lhu,"  ; grep "lhu " $1   | wc -l
echo -n "ld,"   ; grep "ld " $1    | wc -l
echo -n "ldsp," ; grep "ldsp " $1  | wc -l
echo -n "sb,"   ; grep "sb " $1    | wc -l
echo -n "sbu,"  ; grep "sbu " $1   | wc -l
echo -n "sh,"   ; grep "sh " $1    | wc -l
echo -n "shu,"  ; grep "shu " $1   | wc -l
echo -n "sd,"   ; grep "sd " $1    | wc -l
echo -n "sdsp," ; grep "sdsp " $1  | wc -l
##FLOAT
echo -n "fmv,"  ; grep "fmv" $1   | wc -l
##TOTAL
echo -n "total" ; wc -l $1








