// D6 end-to-end validation for SpacemiT IME vmadot instructions.
// Tile shape on K1/A60 at VLEN=256:  C[4][4] += A[4][8] x B[4][8]^T
#include <riscv_vector.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#pragma clang riscv intrinsic vector
#pragma clang riscv intrinsic spacemit_vector

#define M 4
#define N 4
#define K 8

/* Scalar reference. Same maths for all four variants;
   only the operand types differ, so one macro makes all four. */
#define REF(NAME, AT, BT)                                   \
static void NAME(const AT A[M][K], const BT B[N][K],        \
                 int32_t C[M][N]) {                         \
  for (int m = 0; m < M; ++m)                               \
    for (int n = 0; n < N; ++n) {                           \
      int32_t acc = C[m][n];                                \
      for (int k = 0; k < K; ++k)                           \
        acc += (int32_t)A[m][k] * (int32_t)B[n][k];         \
      C[m][n] = acc;                                        \
    }                                                       \
}

REF(ref_ss, int8_t,  int8_t)     /* vmadot   */
REF(ref_uu, uint8_t, uint8_t)    /* vmadotu  */
REF(ref_us, uint8_t, int8_t)     /* vmadotus */
REF(ref_su, int8_t,  uint8_t)    /* vmadotsu */

/* Hardware versions, using your builtins. */
static void hw_ss(const int8_t A[M][K], const int8_t B[N][K], int32_t C[M][N]) {
  size_t vl = __riscv_vsetvl_e8m1(M * K);
  vint8m1_t  va = __riscv_vle8_v_i8m1((const int8_t *)A, vl);
  vint8m1_t  vb = __riscv_vle8_v_i8m1((const int8_t *)B, vl);
  vint32m2_t vc = __riscv_vle32_v_i32m2((const int32_t *)C, M * N);
  vc = __riscv_smt_vmadot(vc, va, vb, vl);
  __riscv_vse32_v_i32m2((int32_t *)C, vc, M * N);
}

static void hw_uu(const uint8_t A[M][K], const uint8_t B[N][K], int32_t C[M][N]) {
  size_t vl = __riscv_vsetvl_e8m1(M * K);
  vuint8m1_t va = __riscv_vle8_v_u8m1((const uint8_t *)A, vl);
  vuint8m1_t vb = __riscv_vle8_v_u8m1((const uint8_t *)B, vl);
  vint32m2_t vc = __riscv_vle32_v_i32m2((const int32_t *)C, M * N);
  vc = __riscv_smt_vmadotu(vc, va, vb, vl);
  __riscv_vse32_v_i32m2((int32_t *)C, vc, M * N);
}

static void hw_us(const uint8_t A[M][K], const int8_t B[N][K], int32_t C[M][N]) {
  size_t vl = __riscv_vsetvl_e8m1(M * K);
  vuint8m1_t va = __riscv_vle8_v_u8m1((const uint8_t *)A, vl);
  vint8m1_t  vb = __riscv_vle8_v_i8m1((const int8_t  *)B, vl);
  vint32m2_t vc = __riscv_vle32_v_i32m2((const int32_t *)C, M * N);
  vc = __riscv_smt_vmadotus(vc, va, vb, vl);
  __riscv_vse32_v_i32m2((int32_t *)C, vc, M * N);
}

static void hw_su(const int8_t A[M][K], const uint8_t B[N][K], int32_t C[M][N]) {
  size_t vl = __riscv_vsetvl_e8m1(M * K);
  vint8m1_t  va = __riscv_vle8_v_i8m1((const int8_t  *)A, vl);
  vuint8m1_t vb = __riscv_vle8_v_u8m1((const uint8_t *)B, vl);
  vint32m2_t vc = __riscv_vle32_v_i32m2((const int32_t *)C, M * N);
  vc = __riscv_smt_vmadotsu(vc, va, vb, vl);
  __riscv_vse32_v_i32m2((int32_t *)C, vc, M * N);
}

static int compare(const char *name, const int32_t got[M][N],
                                     const int32_t want[M][N]) {
  if (memcmp(got, want, sizeof(int32_t) * M * N) == 0) {
    printf("PASS  %s\n", name);
    return 0;
  }
  printf("FAIL  %s\n", name);
  for (int m = 0; m < M; ++m)
    for (int n = 0; n < N; ++n)
      if (got[m][n] != want[m][n])
        printf("      C[%d][%d]  got %11d  want %11d\n",
               m, n, got[m][n], want[m][n]);
  return 1;
}

int main(void) {
  int8_t  As[M][K], Bs[N][K];
  uint8_t Au[M][K], Bu[N][K];
  int32_t C0[M][N], ref[M][N], hw[M][N];
  int failures = 0;

  srand(12345);   /* fixed seed: any failure is reproducible */

  /* Boundary values first (-128 / 255 expose sign bugs), then random. */
  for (int m = 0; m < M; ++m)
    for (int k = 0; k < K; ++k) {
      As[m][k] = (int8_t)((k == 0) ? -128 : (rand() % 256) - 128);
      Au[m][k] = (uint8_t)((k == 0) ? 255  :  rand() % 256);
    }
  for (int n = 0; n < N; ++n)
    for (int k = 0; k < K; ++k) {
      Bs[n][k] = (int8_t)((k == 1) ? -128 : (rand() % 256) - 128);
      Bu[n][k] = (uint8_t)((k == 1) ? 255  :  rand() % 256);
    }
  /* Non-zero start proves the instruction ADDS to vd, not overwrites it. */
  for (int m = 0; m < M; ++m)
    for (int n = 0; n < N; ++n)
      C0[m][n] = (rand() % 2001) - 1000;

  memcpy(ref, C0, sizeof C0); memcpy(hw, C0, sizeof C0);
  ref_ss(As, Bs, ref); hw_ss(As, Bs, hw);
  failures += compare("smt.vmadot   (s8 x s8)", hw, ref);

  memcpy(ref, C0, sizeof C0); memcpy(hw, C0, sizeof C0);
  ref_uu(Au, Bu, ref); hw_uu(Au, Bu, hw);
  failures += compare("smt.vmadotu  (u8 x u8)", hw, ref);

  memcpy(ref, C0, sizeof C0); memcpy(hw, C0, sizeof C0);
  ref_us(Au, Bs, ref); hw_us(Au, Bs, hw);
  failures += compare("smt.vmadotus (u8 x s8)", hw, ref);

  memcpy(ref, C0, sizeof C0); memcpy(hw, C0, sizeof C0);
  ref_su(As, Bu, ref); hw_su(As, Bu, hw);
  failures += compare("smt.vmadotsu (s8 x u8)", hw, ref);

  printf("\n%s (%d failure%s)\n",
         failures ? "VALIDATION FAILED" : "VALIDATION PASSED",
         failures, failures == 1 ? "" : "s");
  return failures != 0;
}
