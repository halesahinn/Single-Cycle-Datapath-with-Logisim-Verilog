LD R0,#0
LD R1,#2
LD R3,#3
ADD R2,R1,R0
PUSH R3
ADD R3,R2,R3
ST R3,#10
POP R3
ADDI R3,R3,#7
AND R4,R0,R1
ANDI R0,R1,#3
JMP #0
ORI R2,R3,#5
OR R2,R3,R1