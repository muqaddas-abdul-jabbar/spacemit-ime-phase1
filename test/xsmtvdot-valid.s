# RUN: llvm-mc -triple=riscv64 -mattr=+xsmtvdot -show-encoding < %s \
# RUN:   | FileCheck --check-prefix=CHECK-ASM %s
# RUN: llvm-mc -triple=riscv64 -mattr=+xsmtvdot -filetype=obj < %s \
# RUN:   | llvm-objdump --mattr=+xsmtvdot -d - \
# RUN:   | FileCheck --check-prefix=CHECK-OBJ %s

# CHECK-ASM: smt.vmadot
# CHECK-OBJ: smt.vmadot
smt.vmadot v8, v10, v11

# CHECK-ASM: smt.vmadotu
# CHECK-OBJ: smt.vmadotu
smt.vmadotu v8, v10, v11

# CHECK-ASM: smt.vmadotsu
# CHECK-OBJ: smt.vmadotsu
smt.vmadotsu v8, v10, v11

# CHECK-ASM: smt.vmadotus
# CHECK-OBJ: smt.vmadotus
smt.vmadotus v8, v10, v11
