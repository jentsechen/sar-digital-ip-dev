#include "baq_fixed_point.h"
#include <algorithm>
#include <cmath>

static int64_t clamp_to_fmt(int64_t val, FpFormat fmt)
{
    int64_t max_val =  (1LL << (fmt.total_bits - 1)) - 1;
    int64_t min_val = -(1LL << (fmt.total_bits - 1));
    return std::clamp(val, min_val, max_val);
}

// Arithmetic right shift — matches Verilog >>> on signed wires
static int64_t arith_rshift(int64_t val, int shift)
{
    if (shift <= 0) return val << (-shift);
    return val >> shift;  // arithmetic on all target architectures
}

int64_t to_fixed(double val, FpFormat fmt)
{
    int64_t raw = static_cast<int64_t>(std::round(val * (1LL << fmt.frac_bits)));
    return clamp_to_fmt(raw, fmt);
}

double to_double(int64_t val, int frac_bits)
{
    return static_cast<double>(val) / static_cast<double>(1LL << frac_bits);
}

int64_t fp_mul(int64_t a, int a_frac, int64_t b, int b_frac, FpFormat out_fmt)
{
    // Full-precision product: (a_frac + b_frac) fractional bits, up to 128 bits wide
    __int128 product = static_cast<__int128>(a) * b;
    int shift = (a_frac + b_frac) - out_fmt.frac_bits;
    int64_t truncated = (shift >= 0) ? static_cast<int64_t>(product >> shift)
                                     : static_cast<int64_t>(product << (-shift));
    return clamp_to_fmt(truncated, out_fmt);
}

int64_t fp_add(int64_t a, int a_frac, int64_t b, int b_frac, FpFormat out_fmt)
{
    // Align both operands to out_fmt.frac_bits before adding
    int64_t a_aligned = arith_rshift(a, a_frac - out_fmt.frac_bits);
    int64_t b_aligned = arith_rshift(b, b_frac - out_fmt.frac_bits);
    return clamp_to_fmt(a_aligned + b_aligned, out_fmt);
}
