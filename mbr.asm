org 7c00h
use16

jmp loop_protect

loop_protect:
    lea ax, [password_str]
    push ax
    call print
    lea di, [password]
    push di
    call read
    
    lea di, [password]
    push di
    lea di, [original_password]
    push di
    call check_password
        
    mov ax, 0
    int 10h
    jz load_mbr
loop loop_protect

load_mbr:
        cli
        MOV SP, 0x7c00
        XOR AX, AX
        MOV SS, AX
        MOV ES, AX
        MOV DS, AX
        PUSH DX
        mov si, 0x7c00
        mov di, 0x0600
        mov cx, 0x200
        cld
        rep movsb
        jmp near stage2 - $$ + 0x0600 ; calc right offset to jump

stage2:
    sti
    mov bx, 0x7c00
    mov ah, 02h
    mov al, 1
    mov dl, 80h
    mov ch, 0
    mov dh, 0
    mov cl, 1
    int 13h
    xchg bx, bx
    jmp $$ + 0x7600 ; in case of jmp problems
    
print:
    push bp
    mov bp, sp
    xor cx, cx
    mov si, [bp+4]
    loop_print:
        lodsb
        test al, al
        jz end_print
        mov ah, 0Eh
        int 10h
    loop loop_print
    
    end_print:
    mov sp, bp
    pop bp
    ret

read:
    push bp
    mov bp, sp
    mov cx, 6 ;password have only 6 symbols or less
    mov di, [bp+4]
    
    loop_read:
        mov ah, 0
        int 16h    
        
        cmp ah, 1Ch
        je end_read
                
        stosb
                                
        mov ah, 0Eh
        mov al, 2Ah
        int 10h
    loop loop_read
            
    end_read:
    mov sp, bp
    pop bp
    ret

check_password:
    push bp
    mov bp, sp
    
    xor ax, ax
    xor bx, bx
    xor dx, dx
    mov cx, 6
    mov si, [bp+4]

    
    mov dx, [bp+6]

    loop_check:
        lodsb
        mov bx, ax
        push si
        mov si, dx
        lodsb
        cmp bx, ax
        jnz end_check
        mov dx, si
        pop si 
        
    loop loop_check
    
    end_check:
    mov sp, bp
    pop bp
    ret  
  
password_str db 'Enter password:', 0
password db 6 dup(0)
original_password db 'OtUs77', 0
db 510-($-$$) dup(0), 0x55, 0xaa
buf: