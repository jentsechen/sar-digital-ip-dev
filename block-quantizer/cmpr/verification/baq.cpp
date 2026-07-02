#include "baq.h"

BaqCompressor::BaqCompressor()
{
    string folder_name = "./baq_compressor_lut/";
    thr_json = read_json(folder_name + "baq_thr.json");
    var_json = read_json(folder_name + "baq_var.json");
    word_length_table["thr_table"] = 10;
    // word_length_table["var_table"] = 9;
    word_length_table["square"] = 14;
    word_length_table["sum_pow"] = 12;
    word_length_table["scale"] = 13;
}

void BaqCompressor::setup(const BaqCtrl &baq_ctrl)
{
    this->word_length_mode = baq_ctrl.word_length_mode;
    this->block_size_mode = baq_ctrl.block_size_mode;
    this->seg_num_mode = baq_ctrl.seg_num_mode;
    word_length = BaqWordLen[static_cast<size_t>(word_length_mode)];
    block_size = BaqBlockSize[static_cast<size_t>(block_size_mode)];
    seg_num = BaqSegNum[static_cast<size_t>(seg_num_mode)];
    thr_table = thr_json.find("thr_" + to_string(word_length))->get<vector<double>>();
    thr_table = floating_to_fixed(thr_table, word_length_table["thr_table"]);
    var_table = var_json.find("var_" + to_string(BaqSegNum[static_cast<size_t>(seg_num_mode)]))->get<vector<double>>();
    // var_table = floating_to_fixed(var_table, word_length_table["var_table"]);
}

double BaqCompressor::floating_to_fixed(double input, size_t word_length)
{
    double scaling = pow(2.0, word_length);
    return floor(input * scaling) / scaling;
}
vector<double> BaqCompressor::floating_to_fixed(const vector<double> &input, size_t word_length)
{
    vector<double> output;
    for (size_t i = 0; i < input.size(); i++)
        output.emplace_back(floating_to_fixed(input[i], word_length));
    return output;
}

vector<double> BaqCompressor::square(const vector<double> &input)
{
    vector<double> output;
    for (size_t i = 0; i < input.size(); i++)
        output.emplace_back(input[i] * input[i]);
    return output;
}

double BaqCompressor::sum_pow(const pair<vector<double>, vector<double>> &input)
{
    double output = sum(input.first + input.second);
    return floating_to_fixed(output, word_length_table["sum_pow"]);
}

// size_t BaqCompressor::select_var(double sum_pow_out) {
//     size_t var_idx_tmp = floor(sum_pow_out * (double)seg_num / (double)block_size);
//     size_t var_idx = (var_idx_tmp > seg_num - 1) ? seg_num - 1 : var_idx_tmp;
//     return var_idx;
// }

pair<size_t, size_t> BaqCompressor::select_var(double sum_pow_out)
{
    double blk_var = sum_pow_out / (double)block_size;
    size_t var_idx_tmp = floor(blk_var * seg_num);
    if (seg_num_mode == BaqSegNumMode::s128)
    { // SEGMOD == 0
        if (var_idx_tmp >= seg_num - 1)
        { // 127
            return {seg_num - 1, 0};
        }
        else if (var_idx_tmp > 1 && var_idx_tmp < (seg_num - 1))
        { // 2~126
            return {var_idx_tmp, 0};
        }
        else
        { // 0, 1
            size_t var_idx_part2 = floor(blk_var * seg_num * 64);
            return {var_idx_tmp, var_idx_part2 + 128};
        }
    }
    else
    { // SEGMOD == 1
        if (var_idx_tmp >= seg_num - 1)
        {
            return {seg_num - 1, 0};
        }
        return {var_idx_tmp, 0};
    }
}

vector<double> BaqCompressor::scale(const vector<double> &input, size_t var_idx)
{
    vector<double> output = input * var_table[var_idx];
    return floating_to_fixed(output, word_length_table["scale"]);
}

pair<size_t, pair<vector<double>, vector<double>>> BaqCompressor::select_var_and_scale(double sum_pow_out, const pair<vector<double>, vector<double>> &input)
{
    pair<size_t, size_t> var_idx_info = select_var(sum_pow_out);
    if (seg_num_mode == BaqSegNumMode::s128 && (var_idx_info.first <= 1))
    {
        pair<vector<double>, vector<double>> scale_out_tmp = scale(input, var_idx_info.second - 128);
        double s = 8; // sqrt(2/(1/128)) / 2
        return {var_idx_info.second, {scale_out_tmp.first * s, scale_out_tmp.second * s}};
    }
    return {var_idx_info.first, scale(input, var_idx_info.first)};
}

size_t BaqCompressor::select_qntz_idx(double input)
{
    if (input >= 0)
    {
        for (size_t i = 0; i < thr_table.size(); i++)
        {
            if (input < thr_table[i])
                return (thr_table.size() + 1 + i);
        }
    }
    else
    {
        for (size_t i = 0; i < thr_table.size(); i++)
        {
            if (input + thr_table[i] >= 0)
                return (thr_table.size() - i);
        }
    }
    return (input >= 0) ? ((thr_table.size() + 1) * 2 - 1) : 0;
}

vector<size_t> BaqCompressor::select_qntz_idx(const vector<double> &input)
{
    vector<size_t> output;
    for (size_t i = 0; i < input.size(); i++)
        output.emplace_back(select_qntz_idx(input[i]));
    return output;
}

bool BaqCompressor::overflow_flag(double sum_pow_out)
{
    switch (block_size_mode)
    {
    case BaqBlockSizeMode::b128:
        return sum_pow_out > (seg_num - 1);
    case BaqBlockSizeMode::b256:
        return sum_pow_out / 2.0 > (seg_num - 1);
    default: // BaqBlockSizeMode::b512
        return sum_pow_out / 4.0 > (seg_num - 1);
    }
}

BaqOutput BaqCompressor::apply_one_block(const pair<vector<double>, vector<double>> &input)
{
    assert(input.first.size() == block_size);
    assert(input.second.size() == block_size);
    pair<vector<double>, vector<double>> square_out = square(input);
    double sum_pow_out = sum_pow(square_out);
    // size_t var_idx = select_var(sum_pow_out);
    // pair<vector<double>, vector<double>> scale_out = scale(input, var_idx);
    // vector<size_t> qntz_idx_i = select_qntz_idx(scale_out.first);
    // vector<size_t> qntz_idx_q = select_qntz_idx(scale_out.second);
    // return BaqOutput(var_idx, (sum_pow_out > seg_num - 1), {qntz_idx_i, qntz_idx_q});
    pair<size_t, pair<vector<double>, vector<double>>> var_idx_and_scale_out = select_var_and_scale(sum_pow_out, input);
    vector<size_t> qntz_idx_i = select_qntz_idx(var_idx_and_scale_out.second.first);
    vector<size_t> qntz_idx_q = select_qntz_idx(var_idx_and_scale_out.second.second);
    // return BaqOutput(var_idx_and_scale_out.first, (sum_pow_out > seg_num - 1), {qntz_idx_i, qntz_idx_q});
    return BaqOutput(var_idx_and_scale_out.first, overflow_flag(sum_pow_out), {qntz_idx_i, qntz_idx_q});
}

vector<BaqOutput> BaqCompressor::apply(const pair<vector<double>, vector<double>> &input)
{
    assert(input.first.size() == input.second.size());
    assert(input.first.size() % block_size == 0);
    size_t n_block = input.first.size() / block_size;
    vector<BaqOutput> output;
    for (size_t i = 0; i < n_block; i++)
    {
        vector<double> input_i = vector<double>(input.first.begin() + i * block_size, input.first.begin() + (i + 1) * block_size);
        vector<double> input_q = vector<double>(input.second.begin() + i * block_size, input.second.begin() + (i + 1) * block_size);
        output.emplace_back(apply_one_block({input_i, input_q}));
    }
    return output;
}

BaqDecompressor::BaqDecompressor()
{
    string folder_path = "./baq_decompressor_lut";
    rep_json = read_json(folder_path + "/baq_rep.json");
    var_json = read_json(folder_path + "/baq_var.json");
}

void BaqDecompressor::setup(const BaqCtrl &baq_ctrl)
{
    this->word_length_mode = baq_ctrl.word_length_mode;
    this->block_size_mode = baq_ctrl.block_size_mode;
    this->seg_num_mode = baq_ctrl.seg_num_mode;
    // rep_table = concate(-1.0 * vector<double>(rep_table.rbegin(), rep_table.rend()), rep_table);
    rep_table = rep_json.find("rep_" + to_string(BaqWordLen[static_cast<size_t>(word_length_mode)]))->get<vector<double>>();
    vector<double> rep_table_first_half = -1.0 * vector<double>(rep_table.rbegin(), rep_table.rend());
    rep_table.insert(rep_table.begin(), rep_table_first_half.begin(), rep_table_first_half.end());
    var_table = var_json.find("var_" + to_string(BaqSegNum[static_cast<size_t>(seg_num_mode)]))->get<vector<double>>();
}

pair<vector<double>, vector<double>> BaqDecompressor::apply(const BaqOutput &baq_out)
{
    auto recover_var_idx = [&]()
    {
        if (seg_num_mode == BaqSegNumMode::s128 && baq_out.var_idx >= 128)
            return (baq_out.var_idx - 128) * 16 / 2;
        return baq_out.var_idx;
    };
    size_t var_idx = recover_var_idx();
    pair<vector<double>, vector<double>> output;
    for (size_t i = 0; i < baq_out.qntz_idx.first.size(); i++)
    {
        output.first.emplace_back(rep_table[baq_out.qntz_idx.first[i]] / var_table[var_idx]);
        output.second.emplace_back(rep_table[baq_out.qntz_idx.second[i]] / var_table[var_idx]);
    }
    return output;
}

vector<pair<vector<double>, vector<double>>> BaqDecompressor::apply(const vector<BaqOutput> &baq_out)
{
    vector<pair<vector<double>, vector<double>>> output;
    for (size_t i = 0; i < baq_out.size(); i++)
        output.emplace_back(apply(baq_out[i]));
    return output;
}
