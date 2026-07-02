#include "baq_decompressor.h"
#include "json.hpp"
#include <fstream>
#include <stdexcept>
#include <utility>

using json = nlohmann::json;

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

static std::string rep_key(BaqWordLenMode m)
{
    switch (m)
    {
    case BaqWordLenMode::w2:
        return "rep_2";
    case BaqWordLenMode::w3:
        return "rep_3";
    case BaqWordLenMode::w4:
        return "rep_4";
    case BaqWordLenMode::w6:
        return "rep_6";
    case BaqWordLenMode::w8:
        return "rep_8";
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

static json load_json(const std::string& path)
{
    std::ifstream f(path);
    if (!f.is_open())
        throw std::runtime_error("Cannot open: " + path);
    return json::parse(f);
}

BaqDecompressor::BaqDecompressor(BaqWordLenMode word_len_mode, BaqBlockSizeMode block_size_mode,
                                 BaqSegNumMode seg_num_mode)
    : word_len_mode(word_len_mode), block_size_mode(block_size_mode), seg_num_mode(seg_num_mode)
{
    const std::string lut_dir = std::string(DECOMP_LUT_DIR);

    std::vector<double> half =
        load_json(lut_dir + "/baq_rep.json").at(rep_key(word_len_mode)).get<std::vector<double>>();

    // Build full symmetric table: [-half.back(), ..., -half.front(), half.front(), ..., half.back()]
    // Indices [0, N] hold the negative side; [N+1, 2N+1] hold the positive side.
    // This matches the quantization code layout produced by select_qntz_idx.
    rep_table.reserve(half.size() * 2);
    for (auto it = half.rbegin(); it != half.rend(); ++it)
        rep_table.push_back(-(*it));
    rep_table.insert(rep_table.end(), half.begin(), half.end());

    var_table = load_json(lut_dir + "/baq_var.json").at(var_key(seg_num_mode)).get<std::vector<double>>();
}

std::pair<std::vector<double>, std::vector<double>> BaqDecompressor::apply(const BaqOutputFlat& compressed) const
{
    const size_t block_size = block_size_value(block_size_mode);
    const size_t seg_num = seg_num_value(seg_num_mode);
    const size_t n_blocks = compressed.var_idx.size();

    std::vector<double> I_out(n_blocks * block_size);
    std::vector<double> Q_out(n_blocks * block_size);

    for (size_t b = 0; b < n_blocks; b++)
    {
        // recover_var_idx: mirrors the two-path logic of select_var in the compressor.
        // segmod0 low-power blocks are flagged by output_idx >= seg_num.
        size_t table_idx;
        double extra_scale;
        if (select_var_mode == BaqSelectVarMode::segmod0 && compressed.var_idx[b] >= seg_num)
        {
            table_idx = compressed.var_idx[b] - seg_num;
            extra_scale = 8.0;
        }
        else
        {
            table_idx = compressed.var_idx[b];
            extra_scale = 1.0;
        }

        double scale = var_table[table_idx] * extra_scale;

        for (size_t n = 0; n < block_size; n++)
        {
            size_t idx = b * block_size + n;
            I_out[idx] = rep_table[compressed.qntz_I[idx]] / scale;
            Q_out[idx] = rep_table[compressed.qntz_Q[idx]] / scale;
        }
    }

    return {I_out, Q_out};
}
