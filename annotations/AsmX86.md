# x86 Assembly Annotations

## Jump Instructions

### Unconditional
- `jmp [label]`: Unconditional jump to label

### Equality
- `je  [label]`: Jump if equal (`ZF = 1`)
- `jne [label]`: Jump if not equal (`ZF = 0`)
- `jz  [label]`: Jump if zero (alias for `je`)
- `jnz [label]`: Jump if not zero (alias for `jne`)

### Unsigned Comparisons
- `ja  [label]`: Jump if above (`CF = 0 and ZF = 0`) — unsigned `>`
- `jae [label]`: Jump if above or equal (`CF = 0`) — unsigned `>=`
- `jb  [label]`: Jump if below (`CF = 1`) — unsigned `<`
- `jbe [label]`: Jump if below or equal (`CF = 1 or ZF = 1`) — unsigned `<=`

### Signed Comparisons
- `jg  [label]`: Jump if greater (`ZF = 0 and SF = OF`) — signed `>`
- `jge [label]`: Jump if greater or equal (`SF = OF`) — signed `>=`
- `jl  [label]`: Jump if less (`SF ≠ OF`) — signed `<`
- `jle [label]`: Jump if less or equal (`ZF = 1 or SF ≠ OF`) — signed `<=`

### Flag-Based Jumps
- `jc  [label]`: Jump if carry (`CF = 1`)
- `jnc [label]`: Jump if not carry (`CF = 0`)
- `jo  [label]`: Jump if overflow (`OF = 1`)
- `jno [label]`: Jump if not overflow (`OF = 0`)
- `js  [label]`: Jump if sign (`SF = 1`)
- `jns [label]`: Jump if not sign (`SF = 0`)
- `jp  [label]`: Jump if parity (`PF = 1`)
- `jnp [label]`: Jump if not parity (`PF = 0`)