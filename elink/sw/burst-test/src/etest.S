#include "common.h"

/* ANSI concatenation macros.  */

#define CONCAT1(a, b) CONCAT2(a, b)
#define CONCAT2(a, b) a ## b
#define STRINGIFY2(a, b) STRINGIFY(a##b)
#define STRINGIFY(a) #a

/* Use the right prefix for global labels.  */

#define SYM(x) CONCAT1 (__USER_LABEL_PREFIX__, x)

#define FUNC(X)         .type SYM(X),@function

FUNC(test_dram)
.global SYM(test_dram)
.align 3
SYM(test_dram):
	mov	r20, %low(EXPECTED_0)
	movt	r20, %high(EXPECTED_0)
	mov	r21, %low(EXPECTED_1)
	movt	r21, %high(EXPECTED_1)
	mov	r22, %low(EXPECTED_2)
	movt	r22, %high(EXPECTED_2)
	mov	r23, %low(EXPECTED_3)
	movt	r23, %high(EXPECTED_3)
	mov	r24, %low(EXPECTED_4)
	movt	r24, %high(EXPECTED_4)
	mov	r25, %low(EXPECTED_5)
	movt	r25, %high(EXPECTED_5)
	mov	r26, %low(EXPECTED_6)
	movt	r26, %high(EXPECTED_6)
	mov	r27, %low(EXPECTED_7)
	movt	r27, %high(EXPECTED_7)

	mov	r30, %low(DRAM_RESULT_ADDR)
	movt	r30, %high(DRAM_RESULT_ADDR)

	# 32-bit writes

	# 1 writes
	str	r20,[r30],+1

	# 2 writes
	str	r20,[r30]
	str	r21,[r30],+1

	# 3 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30],+1

	# 4 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30]
	str	r23,[r30],+1

	# 5 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30]
	str	r23,[r30]
	str	r24,[r30],+1

	# 6 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30]
	str	r23,[r30]
	str	r24,[r30]
	str	r25,[r30],+1

	# 7 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30]
	str	r23,[r30]
	str	r24,[r30]
	str	r25,[r30]
	str	r26,[r30],+1

	# 8 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30]
	str	r23,[r30]
	str	r24,[r30]
	str	r25,[r30]
	str	r26,[r30]
	str	r27,[r30],+1

	;; repeat w/ 64-bit writes

	# 1 writes
	strd	r20,[r30],+1

	# 2 writes
	strd	r20,[r30]
	strd	r22,[r30],+1

	# 3 writes
	strd	r20,[r30]
	strd	r22,[r30]
	strd	r24,[r30],+1

	# 4 writes
	strd	r20,[r30]
	strd	r22,[r30]
	strd	r24,[r30]
	strd	r26,[r30],+1

	rts
.size SYM(test_dram), .-SYM(test_dram)

FUNC(test_eram)
.global SYM(test_eram)
.align 3
SYM(test_eram):
	mov	r20, %low(EXPECTED_0)
	movt	r20, %high(EXPECTED_0)
	mov	r21, %low(EXPECTED_1)
	movt	r21, %high(EXPECTED_1)
	mov	r22, %low(EXPECTED_2)
	movt	r22, %high(EXPECTED_2)
	mov	r23, %low(EXPECTED_3)
	movt	r23, %high(EXPECTED_3)
	mov	r24, %low(EXPECTED_4)
	movt	r24, %high(EXPECTED_4)
	mov	r25, %low(EXPECTED_5)
	movt	r25, %high(EXPECTED_5)
	mov	r26, %low(EXPECTED_6)
	movt	r26, %high(EXPECTED_6)
	mov	r27, %low(EXPECTED_7)
	movt	r27, %high(EXPECTED_7)

	mov	r30, %low(ERAM_RESULT_ADDR)
	movt	r30, %high(ERAM_RESULT_ADDR)

	# 32-bit writes

	# 1 writes
	str	r20,[r30],+1

	# 2 writes
	str	r20,[r30]
	str	r21,[r30],+1

	# 3 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30],+1

	# 4 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30]
	str	r23,[r30],+1

	# 5 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30]
	str	r23,[r30]
	str	r24,[r30],+1

	# 6 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30]
	str	r23,[r30]
	str	r24,[r30]
	str	r25,[r30],+1

	# 7 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30]
	str	r23,[r30]
	str	r24,[r30]
	str	r25,[r30]
	str	r26,[r30],+1

	# 8 writes
	str	r20,[r30]
	str	r21,[r30]
	str	r22,[r30]
	str	r23,[r30]
	str	r24,[r30]
	str	r25,[r30]
	str	r26,[r30]
	str	r27,[r30],+1

	;; repeat w/ 64-bit writes

	# 1 writes
	strd	r20,[r30],+1

	# 2 writes
	strd	r20,[r30]
	strd	r22,[r30],+1

	# 3 writes
	strd	r20,[r30]
	strd	r22,[r30]
	strd	r24,[r30],+1

	# 4 writes
	strd	r20,[r30]
	strd	r22,[r30]
	strd	r24,[r30]
	strd	r26,[r30],+1

	rts
.size SYM(test_eram), .-SYM(test_eram)
