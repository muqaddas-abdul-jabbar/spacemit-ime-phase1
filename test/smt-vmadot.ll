; RUN: llc -mtriple=riscv64 -mattr=+v,+zvl256b,+xsmtvdot \
; RUN:   -verify-machineinstrs < %s | FileCheck %s

declare <vscale x 4 x i32> @llvm.riscv.smt.vmadot.nxv4i32.nxv8i8.nxv8i8.i64(
  <vscale x 4 x i32>, <vscale x 8 x i8>, <vscale x 8 x i8>, i64, i64)

define <vscale x 4 x i32> @smt_vmadot(<vscale x 4 x i32> %vd,
                                      <vscale x 8 x i8> %vs1,
                                      <vscale x 8 x i8> %vs2,
                                      i64 %vl) {
; CHECK-LABEL: smt_vmadot:
; CHECK: smt.vmadot
entry:
  %r = call <vscale x 4 x i32> @llvm.riscv.smt.vmadot.nxv4i32.nxv8i8.nxv8i8.i64(
        <vscale x 4 x i32> %vd, <vscale x 8 x i8> %vs1,
        <vscale x 8 x i8> %vs2, i64 %vl, i64 3)
  ret <vscale x 4 x i32> %r
}

declare <vscale x 4 x i32> @llvm.riscv.smt.vmadotu.nxv4i32.nxv8i8.nxv8i8.i64(
  <vscale x 4 x i32>, <vscale x 8 x i8>, <vscale x 8 x i8>, i64, i64)

define <vscale x 4 x i32> @smt_vmadotu(<vscale x 4 x i32> %vd,
                                       <vscale x 8 x i8> %vs1,
                                       <vscale x 8 x i8> %vs2,
                                       i64 %vl) {
; CHECK-LABEL: smt_vmadotu:
; CHECK: smt.vmadotu
entry:
  %r = call <vscale x 4 x i32> @llvm.riscv.smt.vmadotu.nxv4i32.nxv8i8.nxv8i8.i64(
        <vscale x 4 x i32> %vd, <vscale x 8 x i8> %vs1,
        <vscale x 8 x i8> %vs2, i64 %vl, i64 3)
  ret <vscale x 4 x i32> %r
}

declare <vscale x 4 x i32> @llvm.riscv.smt.vmadotsu.nxv4i32.nxv8i8.nxv8i8.i64(
  <vscale x 4 x i32>, <vscale x 8 x i8>, <vscale x 8 x i8>, i64, i64)

define <vscale x 4 x i32> @smt_vmadotsu(<vscale x 4 x i32> %vd,
                                        <vscale x 8 x i8> %vs1,
                                        <vscale x 8 x i8> %vs2,
                                        i64 %vl) {
; CHECK-LABEL: smt_vmadotsu:
; CHECK: smt.vmadotsu
entry:
  %r = call <vscale x 4 x i32> @llvm.riscv.smt.vmadotsu.nxv4i32.nxv8i8.nxv8i8.i64(
        <vscale x 4 x i32> %vd, <vscale x 8 x i8> %vs1,
        <vscale x 8 x i8> %vs2, i64 %vl, i64 3)
  ret <vscale x 4 x i32> %r
}

declare <vscale x 4 x i32> @llvm.riscv.smt.vmadotus.nxv4i32.nxv8i8.nxv8i8.i64(
  <vscale x 4 x i32>, <vscale x 8 x i8>, <vscale x 8 x i8>, i64, i64)

define <vscale x 4 x i32> @smt_vmadotus(<vscale x 4 x i32> %vd,
                                        <vscale x 8 x i8> %vs1,
                                        <vscale x 8 x i8> %vs2,
                                        i64 %vl) {
; CHECK-LABEL: smt_vmadotus:
; CHECK: smt.vmadotus
entry:
  %r = call <vscale x 4 x i32> @llvm.riscv.smt.vmadotus.nxv4i32.nxv8i8.nxv8i8.i64(
        <vscale x 4 x i32> %vd, <vscale x 8 x i8> %vs1,
        <vscale x 8 x i8> %vs2, i64 %vl, i64 3)
  ret <vscale x 4 x i32> %r
}
