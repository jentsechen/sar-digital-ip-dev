#pragma once
#include <cstdint>

struct FpFormat
{
    int total_bits;  // word length including sign bit
    int frac_bits;   // number of fractional bits
};

// Convert double to fixed-point integer (rounds to nearest, clamps to range)
int64_t to_fixed(double val, FpFormat fmt);

// Convert fixed-point integer back to double
double to_double(int64_t val, int frac_bits);

// Multiply a * b, truncate result to out_fmt
int64_t fp_mul(int64_t a, int a_frac, int64_t b, int b_frac, FpFormat out_fmt);

// Add a + b (may have different frac_bits), align binary points, truncate to out_fmt
int64_t fp_add(int64_t a, int a_frac, int64_t b, int b_frac, FpFormat out_fmt);
