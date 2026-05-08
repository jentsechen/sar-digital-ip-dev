#include "baq_decompressor.h"
#include "json.hpp"
#include <fstream>
#include <stdexcept>

using json = nlohmann::json;

static std::string rep_key(BaqWordLenMode m)
{
    switch (m)
    {
    case BaqWordLenMode::w2: return "rep_2";
    case BaqWordLenMode::w3: return "rep_3";
    case BaqWordLenMode::w4: return "rep_4";
    case BaqWordLenMode::w6: return "rep_6";
    case BaqWordLenMode::w8: return "rep_8";
    }
    throw std::invalid_argument("Unknown BaqWordLenMode");
}

static std::string var_key(BaqSegNumMode m)
{
    switch (m)
    {
    case BaqSegNumMode::s128: return "var_128";
    case BaqSegNumMode::s256: return "var_256";
    }
    throw std::invalid_argument("Unknown BaqSegNumMode");
}

static json load_json(const std::string &path)
{
    std::ifstream f(path);
    if (!f.is_open())
        throw std::runtime_error("Cannot open: " + path);
    return json::parse(f);
}

BaqDecompressor::BaqDecompressor(BaqWordLenMode word_len_mode, BaqBlockSizeMode block_size_mode, BaqSegNumMode seg_num_mode)
    : word_len_mode(word_len_mode), block_size_mode(block_size_mode), seg_num_mode(seg_num_mode)
{
    const std::string lut_dir = std::string(DECOMP_LUT_DIR);
    rep_table = load_json(lut_dir + "/baq_rep.json").at(rep_key(word_len_mode)).get<std::vector<double>>();
    var_table = load_json(lut_dir + "/baq_var.json").at(var_key(seg_num_mode)).get<std::vector<double>>();
}
