//===--- riscv_spacemit_vector.td - RISC-V SpacemiT Builtin function list ===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the builtins for the RISC-V SpacemiT Vector Dot Product
// Extension (XSMTVDot). See:
//
// https://github.com/spacemit-com/riscv-ime-extension-spec/releases/tag/v1.0
//
//===----------------------------------------------------------------------===//

include "riscv_vector_common.td"

//===----------------------------------------------------------------------===//
// SpacemiT Vector Dot Product Extension (XSMTVDot)
//
// smt_vmadot   vd, vs1, vs2 ; int8 x int8   -> int32 (signed x signed)
// smt_vmadotu  vd, vs1, vs2 ; uint8 x uint8 -> int32 (unsigned x unsigned)
// smt_vmadotsu vd, vs1, vs2 ; int8 x uint8  -> int32 (signed x unsigned)
// smt_vmadotus vd, vs1, vs2 ; uint8 x int8  -> int32 (unsigned x signed)
//
// Hardware note: vd (accumulator) physically occupies a register PAIR
// (VRM2, i.e. LMUL=2 relative to vs1/vs2's LMUL=1 VR), not a same-LMUL
// widened element count. We force this with (LFixedLog2LMUL:1) on the
// accumulator/return type, while vs1/vs2 use (FixedSEW:8) to become int8
// at the base (LMUL=1) register class.
//===----------------------------------------------------------------------===//
multiclass RVVIMEDOT<list<list<string>> suffixes_prototypes> {
  let RequiredFeatures = ["xsmtvdot"],
      UnMaskedPolicyScheme = HasPolicyOperand,
      HasMaskedOffOperand = false,
      Log2LMUL = [0],
      OverloadedName = NAME in {
    defm NAME : RVVOutOp1Op2BuiltinSet<NAME, "i", suffixes_prototypes>;
  }
}

defm smt_vmadot   : RVVIMEDOT<[["vv", "v",
    "(LFixedLog2LMUL:1)v(LFixedLog2LMUL:1)v(FixedSEW:8)v(FixedSEW:8)v"]]>;
defm smt_vmadotu  : RVVIMEDOT<[["vv", "v",
    "(LFixedLog2LMUL:1)v(LFixedLog2LMUL:1)v(FixedSEW:8)Uv(FixedSEW:8)Uv"]]>;
defm smt_vmadotsu : RVVIMEDOT<[["vv", "v",
    "(LFixedLog2LMUL:1)v(LFixedLog2LMUL:1)v(FixedSEW:8)v(FixedSEW:8)Uv"]]>;
defm smt_vmadotus : RVVIMEDOT<[["vv", "v",
    "(LFixedLog2LMUL:1)v(LFixedLog2LMUL:1)v(FixedSEW:8)Uv(FixedSEW:8)v"]]>;
