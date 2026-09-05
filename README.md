# SpacemiT IME — LLVM Phase 1

Enabling SpacemiT's integer matrix instructions (vmadot, vmadotu,
vmadotus, vmadotsu) in LLVM and Clang.

Spec: https://github.com/spacemit-com/riscv-ime-extension-spec/releases/tag/v1.0

## Status

All six deliverables complete. Verified on a BPI-F3 board (SpacemiT K1, VLEN 256).

| | Deliverable | Status |
|---|---|---|
| D1 | Clang builtins | Done |
| D2 | LLVM IR intrinsics | Done |
| D3 | Encoding and pattern matching | Done |
| D4 | Documentation | Done |
| D5 | Regression tests | 3 tests passing |
| D6 | End-to-end tests | 4/4 pass on hardware |

## The builtins

    vint32m2_t __riscv_smt_vmadot  (vint32m2_t vd, vint8m1_t  vs1, vint8m1_t  vs2, size_t vl);
    vint32m2_t __riscv_smt_vmadotu (vint32m2_t vd, vuint8m1_t vs1, vuint8m1_t vs2, size_t vl);
    vint32m2_t __riscv_smt_vmadotus(vint32m2_t vd, vuint8m1_t vs1, vint8m1_t  vs2, size_t vl);
    vint32m2_t __riscv_smt_vmadotsu(vint32m2_t vd, vint8m1_t  vs1, vuint8m1_t vs2, size_t vl);

The accumulator is signed 32-bit in all four cases; the suffix describes
the inputs. One instruction computes C[4][4] += A[4][8] x B[4][8] transposed,
at VLEN 256.

## Contents

    src/   riscv_spacemit_vector.td      Clang builtin definitions
           IntrinsicsRISCVXSpacemit.td   LLVM IR intrinsics

    test/  smt_vmadot.c                  builtin to IR (lit test)
           smt-vmadot.ll                 IR to assembly (lit test)
           smt_validate.c                hardware validation program

    phase1-changes.patch                 changes to existing LLVM files

## Building

    cmake -G Ninja -S llvm -B build \
      -DLLVM_ENABLE_PROJECTS="clang" \
      -DLLVM_TARGETS_TO_BUILD="RISCV" \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_ENABLE_ASSERTIONS=ON
    ninja -C build clang llc

## Running the tests

    build/bin/llvm-lit -v \
      clang/test/CodeGen/RISCV/rvv-intrinsics-spacemit/smt_vmadot.c \
      llvm/test/CodeGen/RISCV/rvv/smt-vmadot.ll


Both pass. The MC round-trip test already exists upstream (llvm/test/MC/RISCV/xsmtvdot-valid.s) and also passes.

## Hardware validation

Output from smt_validate on the BPI-F3 board:

    PASS  smt.vmadot   (s8 x s8)
    PASS  smt.vmadotu  (u8 x u8)
    PASS  smt.vmadotus (u8 x s8)
    PASS  smt.vmadotsu (s8 x u8)

    VALIDATION PASSED (0 failures)

## Notes

Only LMUL 1 is supported. The specification reserves all other LMUL
encodings and requires an illegal instruction exception for them, so the
required configuration space is a set of exactly one.

Accumulator signedness: during development vmadotu was declared with an
unsigned accumulator. The specification states the accumulator is always
interpreted as signed, with the suffix describing the inputs. This was
corrected. The defect was only reachable through end-to-end testing, as
the compiler built cleanly with it in place.

Open item: no vsetvli is emitted immediately before smt.vmadot. This is
safe in the validated example, where the preceding load sequence sets
LMUL 1, but code arriving with a different LMUL would fault.
