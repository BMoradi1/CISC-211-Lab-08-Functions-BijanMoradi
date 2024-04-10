/*** asmMult.s   ***/
/* SOLUTION; used to test C test harness
 * VB 10/14/2023
 */
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Bijan Moradi"  
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,a_Sign,b_Sign,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
asmUnpack:   
  
    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/
    push {r4-r11,LR} /*save all registers r4,r11 in stack to preserve values*/
    MOV R5, R0 /* store the value in r0 in r5 (Ra in the lab sheet)*/
    ASR R5, R5, 16 /*shift right into r5 LSB using ASR so MS 16bits is the sign bit*/
    STR R5, [R1]  /* store the unpacked number*/
    MOV R6, R0 /* store the value in r0 in r6 (Rb in the lab sheet)*/
    LSL R6, R6, 16 /*shift to the left by 16 bits, throwing away the A value from the R6 register*/
    ASR R6, R6, 16 /*shift back to the proper position using, ASR leaving the MS 16bits as the sign bit*/
    STR R6, [R2]  /* store the unpacked number*/
    pop {r4-r11,LR} /*restore registers from stack*/
    BX LR /*return to where called from*/
    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit 0 = "+", 1 = "-")
 *    outputs:  r0: Absolute value of r0 input. Same value as stored to location given in r1
 *              memory: store absolute value in location given by r1
 *                      store sign bit in location given by r2
 */    
asmAbs:  

    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/
    push {r4-r11,LR} /*save all registers r4,r11 in stack to preserve values*/
     /*now time to negate using RSB */
    MOV r6, 0
    CMP r0, 0 /*check if its negative before negation*/
    BLT neg
    b done
    neg:
	RSB r0, r0, 0 /*r0 = 0 -r0 -> r0 = -r0, heres where we change the sign if negative*/
	MOV r6, 1
    done: /*lets put all the results into the right registers as defined by the function definition*/
	STR r0, [r1]
	STR r6, [r2]
	pop {r4-r11,LR} /*restore registers from stack*/
	BX LR /*return to where called from*/
    pop {r4-r11,LR} /*restore registers from stack*/
    BX LR /*return to where called from*/
	
    
    
    /*store those into a_abs and b_abs*/

     

    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

 
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */ 
asmMult:   

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/
    push {r4-r11,LR} /*save all registers r4,r11 in stack to preserve values*/
    MOV r5,0
    mult:
	/*NOTE: I am using the shift-Add loop from the lecture slides, as it is much more efficent than my first attempt.*/
	CMP r1, 0 /*check to see if multiplier is 0, if so the alg is finished*/
	BEQ donemult
	TST r1, 1 /*if LSB is 1 add*/
	ADDNE r5,r5,r0 /*skip if not 1*/
	LSL r0,r0,1 /*register shifts as per alg*/
	LSR r1,r1,1
    B mult
    donemult:
	mov r0,r5 /*move our temp product into r0 as defined by function*/
	pop {r4-r11,LR} /*restore registers from stack*/
	BX LR /*return to where called from*/


    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/

   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product from previous step: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
	/*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/
	/*lets use r3, r4 for our ASR to make sure we dont mess up the value in r0, r1.*/
	push {r4-r11,LR} /*save all registers r4,r11 in stack to preserve values*/
	CMP r0, 0 /*check to see if either value is 0 if so we skip using EOR*/
	BEQ oneeqzero
	EOR r6, r1, r2 /* use XOR to find out if product is negative*/
	B skip /*skip the oneeqzero label*/
	oneeqzero:/*one of the numbers being multiplied was a zero, therefore the awnser will be zero, and the sign positive*/
	MOV r6,0
	skip:
	CMP r6, 1 /*check if its a negative product*/
	RSBEQ r0, r0, 0 /*its negative, negate the product*/
	pop {r4-r11,LR} /*restore registers from stack*/
	BX LR /*return to where called from*/
   
	
    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */  
asmMain:   
    
    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/
    push {r4-r11,LR} /*save all registers r4,r11 in stack to preserve values*/

   
    /* Step 1:
     * call asmUnpack. Have it store the output values in a_Multiplicand
     * and b_Multiplier.
     */

    LDR r1,= a_Multiplicand/*set the input memory addresses to pass into function based on func definition*/
    LDR r2,= b_Multiplier
    BL asmUnpack /*call function*/


     /* Step 2a:
      * call asmAbs for the multiplicand (a). Have it store the absolute value
      * in a_Abs, and the sign in a_Sign.
      */
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit 0 = "+", 1 = "-")
 *    outputs:  r0: Absolute value of r0 input. Same value as stored to location given in r1
 *              memory: store absolute value in location given by r1
 *                      store sign bit in location given by r2
 */   
     LDR r1, = a_Abs /*set the input memory addresses to pass into function based on func definition*/
     LDR r2,= a_Sign
     LDR r5,= a_Multiplicand /*grab the memory address of the value, then put its value into r0 as defined for passing into function*/
     LDR r0,[r5]
     BL asmAbs/*call function*/

     /* Step 2b:
      * call asmAbs for the multiplier (b). Have it store the absolute value
      * in b_Abs, and the sign in b_Sign.
      */
     LDR r1, = b_Abs
     LDR r2,= b_Sign/*set the input memory addresses to pass into function based on func definition*/
     LDR r5,= b_Multiplier
     LDR r0,[r5] /*grab the memory address of the value, then put its value into r0 as defined for passing into function*/
     BL asmAbs/*call function*/


    /* Step 3:
     * call asmMult. Pass a_Abs as the multiplicand, 
     * and b_Abs as the multiplier.
     * asmMult returns the initial (positive) product in r0.
     * In this function (asmMain), store the output value  
     * returned asmMult in r0 to mem location init_Product.
     */
    LDR r5, = a_Abs
    LDR r0,[r5]
    LDR r5, = b_Abs/*set the input memory addresses to pass into function based on func definition*/
    LDR r1,[r5]
    BL asmMult/*call function*/
    LDR r5, = init_Product /*save output from r0 into init_product*/
    STR r0,[r5]


    /* Step 4:
     * call asmFixSign. Pass in the initial product, and the
     * sign bits for the original a and b inputs. 
     * asmFixSign returns the final product with the correct
     * sign. Store the value returned in r0 to mem location 
     * final_Product.
     */
    /* function: asmFixSign
 *    inputs:   r0: initial product from previous step: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
    LDR r5, = init_Product /* load in the inital product into r0 to pass into function*/
    LDR r0, [r5]
    LDR r5, = a_Sign /* load sign a into register defined by func decleration*/
    LDR r1, [r5]
    LDR r5, = b_Sign /* load sign b into register defined by func decleration*/
    LDR r2, [r5]
    BL asmFixSign/*call function*/
    LDR r5, = final_Product /*save output from r0 into final_product*/
    STR r0,[r5]
    

     /* Step 5:
      * END! Return to caller. Make sure of the following:
      * 1) Stack has been correctly managed.
      * 2) the final answer is stored in r0, so that the C call 
      *    can access it.
      */

    pop {r4-r11,LR} /*restore registers from stack*/
    BX LR /*return to where called from*/
    
    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/


    /***************  END ---- asmMain  ************/

 
    
    
.end   /* the assembler will ignore anything after this line. */
