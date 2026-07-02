#include "baq_compressor.h"
#include "json.hpp"
#include <algorithm>
#include <cmath>
#include <fstream>
#include <stdexcept>

using json = nlohmann::json;

static std::string thr_key(BaqWordLenMode m)
{
    switch (m)
    {
    case BaqWordLenMode::w2:
        return "thr_2";
    case BaqWordLenMode::w3:
        return "thr_3";
    case BaqWordLenMode::w4:
        return "thr_4";
    case BaqWordLenMode::w6:
        return "thr_6";
    case BaqWordLenMode::w8:
        return "thr_8";
    }
    throw std::invalid_argument("Unknown BaqWordLenMode");
}

static std::string var_key(BaqSegNumMode m)
{
    switch (m)
    {
    case BaqSegNumMode::s128:
        return "var_128";
    case BaqSegNumMode::s256:
        return "var_256";
    }
    throw std::invalid_argument("Unknown BaqSegNumMode");
}

static size_t block_size_value(BaqBlockSizeMode m)
{
    switch (m)
    {
    case BaqBlockSizeMode::b128:
        return 128;
    case BaqBlockSizeMode::b256:
        return 256;
    case BaqBlockSizeMode::b512:
        return 512;
    }
    throw std::invalid_argument("Unknown BaqBlockSizeMode");
}

static size_t seg_num_value(BaqSegNumMode m)
{
    switch (m)
    {
    case BaqSegNumMode::s128:
        return 128;
    case BaqSegNumMode::s256:
        return 256;
    }
    throw std::invalid_argument("Unknown BaqSegNumMode");
}

static int word_len_bits(BaqWordLenMode m)
{
    switch (m)
    {
    case BaqWordLenMode::w2:
        return 2;
    case BaqWordLenMode::w3:
        return 3;
    case BaqWordLenMode::w4:
        return 4;
    case BaqWordLenMode::w6:
        return 6;
    case BaqWordLenMode::w8:
        return 8;
    }
    throw std::invalid_argument("Unknown BaqWordLenMode");
}

static json load_json(const std::string& path)
{
    std::ifstream f(path);
    if (!f.is_open())
        throw std::runtime_error("Cannot open: " + path);
    return json::parse(f);
}

BaqCompressor::BaqCompressor(BaqWordLenMode word_len_mode, BaqBlockSizeMode block_size_mode, BaqSegNumMode seg_num_mode)
    : word_len_mode(word_len_mode), block_size_mode(block_size_mode), seg_num_mode(seg_num_mode),
      power_config({{16, 10}, {28, 20}, {40, 20}})
{
    const std::string lut_dir = std::string(LUT_DIR);
    thr_table = load_json(lut_dir + "/baq_thr.json").at(thr_key(word_len_mode)).get<std::vector<double>>();
    var_table = load_json(lut_dir + "/baq_var.json").at(var_key(seg_num_mode)).get<std::vector<double>>();
}

VarSelectResult BaqCompressor::select_var(double block_power) const
{
    const size_t blk_sz = block_size_value(block_size_mode);
    const size_t seg_num = seg_num_value(seg_num_mode);

    double blk_var = block_power / static_cast<double>(blk_sz);
    size_t var_idx_tmp = static_cast<size_t>(std::floor(blk_var * seg_num));

    // Overflow: normalise block power to a 128-sample reference before comparing
    double norm_power = block_power / static_cast<double>(blk_sz / 128);
    bool overflow = norm_power > static_cast<double>(seg_num - 1);

    // Saturate
    if (var_idx_tmp >= seg_num - 1)
        return {seg_num - 1, seg_num - 1, 1.0, overflow};

    // segmod0: apply fine-grain sub-index for very low power blocks (var_idx_tmp <= 1)
    if (select_var_mode == BaqSelectVarMode::segmod0 && var_idx_tmp <= 1)
    {
        size_t var_idx_part2 = static_cast<size_t>(std::floor(blk_var * seg_num * 64));
        return {var_idx_part2 + seg_num, var_idx_part2, 8.0, overflow};
    }

    return {var_idx_tmp, var_idx_tmp, 1.0, overflow};
}

std::vector<double> BaqCompressor::calc_block_power(const std::vector<double>& I, const std::vector<double>& Q)
{
    const size_t block_size = block_size_value(block_size_mode);
    const size_t n_blocks = I.size() / block_size;
    const FpFormat& in_fmt = power_config.input_fmt;
    const FpFormat& sq_fmt = power_config.square_fmt;
    const FpFormat& acc_fmt = power_config.accum_fmt;

    std::vector<double> power(n_blocks);
    for (size_t b = 0; b < n_blocks; b++)
    {
        int64_t accum = 0;
        for (size_t n = 0; n < block_size; n++)
        {
            size_t idx = b * block_size + n;

            int64_t i_fixed = to_fixed(I[idx], in_fmt);
            int64_t q_fixed = to_fixed(Q[idx], in_fmt);

            int64_t i_sq = fp_mul(i_fixed, in_fmt.frac_bits, i_fixed, in_fmt.frac_bits, sq_fmt);
            int64_t q_sq = fp_mul(q_fixed, in_fmt.frac_bits, q_fixed, in_fmt.frac_bits, sq_fmt);

            int64_t iq_sq = fp_add(i_sq, sq_fmt.frac_bits, q_sq, sq_fmt.frac_bits, acc_fmt);
            accum = fp_add(accum, acc_fmt.frac_bits, iq_sq, acc_fmt.frac_bits, acc_fmt);
        }
        power[b] = to_double(accum, acc_fmt.frac_bits);
    }
    return power;
}

size_t BaqCompressor::select_qntz_idx(double sample, double scale) const
{
    double scaled = sample * scale;
    const size_t N = thr_table.size(); // 2^(word_len-1) - 1

    if (scaled >= 0.0)
    {
        for (size_t i = 0; i < N; i++)
        {
            if (scaled < thr_table[i])
                return N + 1 + i;
        }
        return 2 * N + 1;
    }
    else
    {
        for (size_t i = 0; i < N; i++)
        {
            if (scaled + thr_table[i] >= 0.0)
                return N - i;
        }
        return 0;
    }
}

BaqOutputFlat BaqCompressor::apply(const std::vector<double>& I, const std::vector<double>& Q)
{
    const size_t block_size = block_size_value(block_size_mode);
    if (I.size() != Q.size())
        throw std::invalid_argument("I and Q must have the same length");
    if (I.size() % block_size != 0)
        throw std::invalid_argument("Input length (" + std::to_string(I.size()) +
                                    ") is not a multiple of block size (" + std::to_string(block_size) + ")");

    std::vector<double> block_power = calc_block_power(I, Q);

    const size_t n_blocks = block_power.size();
    BaqOutputFlat output;
    output.var_idx.resize(n_blocks);
    output.overflow.resize(n_blocks);
    output.qntz_I.resize(I.size());
    output.qntz_Q.resize(Q.size());

    for (size_t b = 0; b < n_blocks; b++)
    {
        VarSelectResult vsr = select_var(block_power[b]);
        output.var_idx[b] = vsr.output_idx;
        output.overflow[b] = vsr.overflow;

        double scale = var_table[vsr.table_idx] * vsr.extra_scale;

        for (size_t n = 0; n < block_size; n++)
        {
            size_t idx = b * block_size + n;
            output.qntz_I[idx] = select_qntz_idx(I[idx], scale);
            output.qntz_Q[idx] = select_qntz_idx(Q[idx], scale);
        }
    }

    return output;
}
