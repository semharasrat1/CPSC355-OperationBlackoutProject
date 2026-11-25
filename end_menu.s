.data
    //messages after the mission ends
    success_msg: .asciz "\nMISSION SUCCESS!\n"
    failure_msg: .asciz "\nMISSION FAILED!\n"
    score_msg:   .asciz "Final Score: %d\n"

    // choose end menu options
    menu_msg: .asciz "\n--- END MENU ---\n"
               .asciz "1. Play Again\n"
               .asciz "2. Main Menu\n"
               .asciz "3. Exit\n"
               .asciz "Enter choice: "

    invalid_msg: .asciz "Invalid choice. Try again.\n"

    // for scanf
    input_fmt: .asciz "%d"

    // Stores user selection (1, 2, or 3)
    .balign 4
    menu_choice: .word 0


.text
.global mission_success
.global mission_failure
.global end_menu

.extern printf
.extern scanf
.extern getchar
.extern exit

.extern restart_mission
.extern main_menu


// MISSION SUCCESS
mission_success:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // display success
    ldr x0, =success_msg
    bl printf

    // Display final score
    ldr x0, =score_msg
    mov w1, w19 // Assumes the score is stored in w19 ///////////////////////////////////////////////////
    bl printf
    ldp x29, x30, [sp], #16 //restore frame pointer and return address
    b end_menu //continue to the end menu


// MISSION FAILURE
mission_failure:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // display failure message
    ldr x0, =failure_msg
    bl printf

    //display final score
    ldr x0, =score_msg
    mov w1, w19 // Assumes the score is stored in w19 ///////////////////////////////////////////////////
    bl printf
    ldp x29, x30, [sp], #16
    b end_menu


// END MENU
end_menu:
    stp x29, x30, [sp, #-16]!
    mov x29, sp


menu_loop:
    //display the end menu
    ldr x0, =menu_msg
    bl printf

    // read user choice
    ldr x0, =input_fmt
    ldr x1, =menu_choice
    bl scanf

    // check if read as integer
    cmp w0, #1
    b.eq check_choice
    cmp w0, #-1 // If scanf returns -1 input ended
    b.eq exit_game

clear_input:
    bl getchar

    // check for end-of-file
    cmp w0, #-1
    b.eq exit_game

    //check for newline
    cmp w0, #10
    b.ne clear_input
    b invalid_choice // display invalid input message


check_choice:
    //load the users choice from memory
    ldr x9, =menu_choice
    ldr w9, [x9]

    // 1 to play again
    cmp w9, #1
    b.eq restart_game

    // 2 to return to the main menu
    cmp w9, #2
    b.eq return_main_menu

    // 3 to exit
    cmp w9, #3
    b.eq exit_game


invalid_choice:
    // Display invalid choice message
    ldr x0, =invalid_msg
    bl printf
    b menu_loop //repeat the end menu


// MENU ACTIONS
restart_game:
    ldp x29, x30, [sp], #16
    b restart_mission // transfer control to mission restart


return_main_menu:
    ldp x29, x30, [sp], #16
    b main_menu //transfer control to main menu


exit_game:
    ldp x29, x30, [sp], #16
    mov x0, #0 // Exit the program
    bl exit
