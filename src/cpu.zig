/// Instruction opcodes.
pub const Op = enum(u4) {
    br, // Branch.
    add, // Add.
    ld, // Load.
    st, // Store.
    jsr, // Jump register.
    and_, // Bitwise AND.
    ldr, // Load register.
    str, // Store register.
    rti, // Return from interrupt (unused).
    not, // Bitwise NOT.
    ldi, // Load indirect.
    sti, // Store indirect.
    jmp, // Jump.
    res, // Reserved (unused).
    lea, // Load effective address.
    trap, // Execute trap.
};
