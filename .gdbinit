# Connect to QEMU's GDB server
target remote localhost:1234

# Tell GDB we are debugging 16-bit x86 real mode
set architecture i8086

# Show useful 16-bit registers
define regs16
    printf "---- General Purpose ----\n"
    info registers ax bx cx dx si di bp sp

    printf "\n---- Segments ----\n"
    info registers cs ds es ss

    printf "\n---- Instruction Pointer ----\n"
    info registers ip
end

# Show current instruction
define here
    x/5i $pc
end

# Dump bootloader memory
define bootdump
    x/32bx 0x7c00
end

# Examine VGA text buffer
define vga
    x/32bx 0xb8000
end

# Step one instruction
define s
    stepi
end

# Continue execution
define c
    continue
end

# Break at bootloader entry
define bootbreak
    break *0x7c00
end