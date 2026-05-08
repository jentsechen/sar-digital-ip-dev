#include <iostream>
#include <cmath>
#include <vector>
#include "models/baq_compressor.h"
#include "models/baq_decompressor.h"
#include "models/baq_fixed_point.h"

static bool check(const char *label, auto actual, auto expected)
{
    bool ok = (actual == expected);
    std::cout << label << ": " << (ok ? "correct" : "WRONG") << std::endl;
    return ok;
}

static bool check_table(const char *label, const std::vector<double> &table, size_t expected_size, double expected_front, double expected_back)
{
    bool ok = true;
    ok &= check((std::string(label) + " size").c_str(),  table.size(), expected_size);
    ok &= check((std::string(label) + " front").c_str(), table.front(), expected_front);
    ok &= check((std::string(label) + " back").c_str(),  table.back(),  expected_back);
    return ok;
}

int main()
{
    std::cout << "=== BaqCompressor ===\n";
    {
        BaqCompressor c;
        bool ok = true;
        ok &= check("Default word_len_mode",  c.getWordLenMode(),   BaqWordLenMode::w2);
        ok &= check("Default block_size_mode", c.getBlockSizeMode(), BaqBlockSizeMode::b128);
        ok &= check("Default seg_num_mode",    c.getSegNumMode(),    BaqSegNumMode::s128);
        ok &= check_table("thr_table(w2)",  c.getThrTable(), 1,   0.9765625,   0.9765625);
        ok &= check_table("var_table(s128)", c.getVarTable(), 128, 22.626953125, 1.416015625);
        std::cout << "Default construction: " << (ok ? "correct" : "WRONG") << "\n\n";
    }
    {
        BaqCompressor c(BaqWordLenMode::w8, BaqBlockSizeMode::b512, BaqSegNumMode::s256);
        bool ok = true;
        ok &= check("Explicit word_len_mode",  c.getWordLenMode(),   BaqWordLenMode::w8);
        ok &= check("Explicit block_size_mode", c.getBlockSizeMode(), BaqBlockSizeMode::b512);
        ok &= check("Explicit seg_num_mode",    c.getSegNumMode(),    BaqSegNumMode::s256);
        ok &= check_table("thr_table(w8)",  c.getThrTable(), 127, 0.0166015625, 4.3955078125);
        ok &= check_table("var_table(s256)", c.getVarTable(), 256, 32.0,         1.4140625);
        std::cout << "Explicit construction (w8, b512, s256): " << (ok ? "correct" : "WRONG") << "\n";
    }

    std::cout << "\n=== BaqDecompressor ===\n";
    {
        BaqDecompressor d;
        bool ok = true;
        ok &= check("Default word_len_mode",  d.getWordLenMode(),   BaqWordLenMode::w2);
        ok &= check("Default block_size_mode", d.getBlockSizeMode(), BaqBlockSizeMode::b128);
        ok &= check("Default seg_num_mode",    d.getSegNumMode(),    BaqSegNumMode::s128);
        ok &= check_table("rep_table(w2)",  d.getRepTable(), 2,   0.4527990860592986, 1.510459485210897);
        ok &= check_table("var_table(s128)", d.getVarTable(), 128, 22.62741699796952,  1.4169838168641524);
        std::cout << "Default construction: " << (ok ? "correct" : "WRONG") << "\n\n";
    }
    {
        BaqDecompressor d(BaqWordLenMode::w8, BaqBlockSizeMode::b512, BaqSegNumMode::s256);
        bool ok = true;
        ok &= check("Explicit word_len_mode",  d.getWordLenMode(),   BaqWordLenMode::w8);
        ok &= check("Explicit block_size_mode", d.getBlockSizeMode(), BaqBlockSizeMode::b512);
        ok &= check("Explicit seg_num_mode",    d.getSegNumMode(),    BaqSegNumMode::s256);
        ok &= check_table("rep_table(w8)",  d.getRepTable(), 128, 0.0084462,           4.603594700895072);
        ok &= check_table("var_table(s256)", d.getVarTable(), 256, 32.0,                1.4155966566521883);
        std::cout << "Explicit construction (w8, b512, s256): " << (ok ? "correct" : "WRONG") << "\n";
    }

    std::cout << "\n=== select_var ===\n";
    {
        // segmod0 (s128): normal range (var_idx_tmp = 50 → simple lookup)
        BaqCompressor c(BaqWordLenMode::w2, BaqBlockSizeMode::b128, BaqSegNumMode::s128);
        // blk_var = 50/128, block_power = blk_var * 128 = 50
        auto r = c.select_var(50.0);
        bool ok = true;
        ok &= check("segmod0 normal output_idx",  r.output_idx,  size_t(50));
        ok &= check("segmod0 normal table_idx",   r.table_idx,   size_t(50));
        ok &= check("segmod0 normal extra_scale", r.extra_scale, 1.0);
        ok &= check("segmod0 normal overflow",    r.overflow,    false);
        std::cout << "segmod0 normal: " << (ok ? "correct" : "WRONG") << "\n";
    }
    {
        // segmod0 (s128): low-power case (var_idx_tmp = 1)
        // blk_var = 1/128, block_power = 1.0
        // var_idx_part2 = floor(1/128 * 128 * 64) = floor(64) = 64
        // expected: output_idx = 64+128 = 192, table_idx = 64, extra_scale = 8
        BaqCompressor c(BaqWordLenMode::w2, BaqBlockSizeMode::b128, BaqSegNumMode::s128);
        auto r = c.select_var(1.0);
        bool ok = true;
        ok &= check("segmod0 low-power output_idx",  r.output_idx,  size_t(192));
        ok &= check("segmod0 low-power table_idx",   r.table_idx,   size_t(64));
        ok &= check("segmod0 low-power extra_scale", r.extra_scale, 8.0);
        ok &= check("segmod0 low-power overflow",    r.overflow,    false);
        std::cout << "segmod0 low-power: " << (ok ? "correct" : "WRONG") << "\n";
    }
    {
        // segmod0 (s128): saturated (block_power = 200 → var_idx_tmp >= 127)
        BaqCompressor c(BaqWordLenMode::w2, BaqBlockSizeMode::b128, BaqSegNumMode::s128);
        auto r = c.select_var(200.0);
        bool ok = true;
        ok &= check("segmod0 saturated output_idx", r.output_idx, size_t(127));
        ok &= check("segmod0 saturated overflow",   r.overflow,   true);
        std::cout << "segmod0 saturated: " << (ok ? "correct" : "WRONG") << "\n";
    }
    {
        // segmod1 (s256): low-power case — no special handling, simple lookup
        BaqCompressor c(BaqWordLenMode::w2, BaqBlockSizeMode::b128, BaqSegNumMode::s256);
        c.setSelectVarMode(BaqSelectVarMode::segmod1);
        // blk_var = 1/128 → var_idx_tmp = floor(1/128 * 256) = 2, extra_scale = 1
        auto r = c.select_var(1.0);
        bool ok = true;
        ok &= check("segmod1 low-power output_idx",  r.output_idx,  size_t(2));
        ok &= check("segmod1 low-power extra_scale", r.extra_scale, 1.0);
        std::cout << "segmod1 low-power: " << (ok ? "correct" : "WRONG") << "\n";
    }
    std::cout << "\n=== Fixed-point power calculation ===\n";
    {
        // One block of 128 samples: I = 1.0, Q = 0.0
        // Expected power = 128 * (1^2 + 0^2) = 128.0
        BaqCompressor c(BaqWordLenMode::w2, BaqBlockSizeMode::b128, BaqSegNumMode::s128);
        std::vector<double> I(128, 1.0), Q(128, 0.0);
        c.apply(I, Q);
        std::cout << "apply (constant I=1, Q=0, 128 samples): no exception\n";
    }
    {
        // Verify fp_mul and fp_add directly
        FpFormat fmt{16, 10};
        int64_t a = to_fixed(1.0, fmt);   // 1024
        int64_t b = to_fixed(1.0, fmt);   // 1024
        int64_t sq = fp_mul(a, fmt.frac_bits, b, fmt.frac_bits, fmt);
        double result = to_double(sq, fmt.frac_bits);
        bool ok = std::abs(result - 1.0) < 1e-6;
        std::cout << "fp_mul(1.0 * 1.0) = " << result << ": " << (ok ? "correct" : "WRONG") << "\n";

        int64_t sum = fp_add(sq, fmt.frac_bits, sq, fmt.frac_bits, fmt);
        result = to_double(sum, fmt.frac_bits);
        ok = std::abs(result - 2.0) < 1e-6;
        std::cout << "fp_add(1.0 + 1.0) = " << result << ": " << (ok ? "correct" : "WRONG") << "\n";
    }

    return 0;
}
