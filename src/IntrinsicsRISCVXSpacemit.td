//===- IntrinsicsRISCVXSpacemit.td - SpacemiT intrinsics -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines all of the SpacemiT-specific intrinsics.
//
//===----------------------------------------------------------------------===//

let TargetPrefix = "riscv" in {
  // SpacemiT Vector Dot Product Extension (XSMTVDot)
  defm smt_vmadot   : RISCVTernaryWide;
  defm smt_vmadotu  : RISCVTernaryWide;
  defm smt_vmadotsu : RISCVTernaryWide;
  defm smt_vmadotus : RISCVTernaryWide;
} // TargetPrefix = "riscv"
