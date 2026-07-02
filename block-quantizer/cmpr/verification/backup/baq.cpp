#include "SAR/data_comp/baq/baq.h"
using namespace SAR;

BAQ_Compressor::BAQ_Compressor() {
    // string folder_name = "./source/pylib/test/sar/data_comp/baq_compressor_lut/";
    // string folder_name = "/workspaces/bbsysdev/source/pylib/test/sar/data_comp/baq_compressor_lut/";
    string folder_name = "./baq_compressor_lut/";
    thr_json = read_json(folder_name + "baq_thr.json");
    var_json = read_json(folder_name + "baq_var.json");
    word_length_table["thr_table"] = 10;
    // word_length_table["var_table"] = 9;
    word_length_table["square"] = 14;
    word_length_table["sum_pow"] = 12;
    word_length_table["scale"] = 13;
}

void BAQ_Compressor::setup(const BAQ_Ctrl& baq_ctrl) {
    this->word_length_mode = baq_ctrl.word_length_mode;
    this->block_size_mode = baq_ctrl.block_size_mode;
    this->seg_num_mode = baq_ctrl.seg_num_mode;
    if (block_size_mode == eSAR_BAQ_BlockSizeMode::b128) {
        block_size = 128;
    }
    else if (block_size_mode == eSAR_BAQ_BlockSizeMode::b256) {
        block_size = 256;
    }
    else { // block_size_mode==eSAR_BAQ_BlockSizeMode::b512
        block_size = 512;
    }
    seg_num = (seg_num_mode == eSAR_BAQ_SegNumMode::s128) ? 128 : 256;
    if (word_length_mode == eSAR_BAQ_WordLenMode::w2) {
        word_length = 2;
        thr_table = thr_json.find("thr_2")->get<vecf>();
    }
    else if (word_length_mode == eSAR_BAQ_WordLenMode::w3) {
        word_length = 3;
        thr_table = thr_json.find("thr_3")->get<vecf>();
    }
    else if (word_length_mode == eSAR_BAQ_WordLenMode::w4) {
        word_length = 4;
        thr_table = thr_json.find("thr_4")->get<vecf>();
    }
    else if (word_length_mode == eSAR_BAQ_WordLenMode::w6) {
        word_length = 6;
        thr_table = thr_json.find("thr_6")->get<vecf>();
    }
    else { // word_length_mode == eSAR_BAQ_WordLenMode::w8
        word_length = 8;
        thr_table = thr_json.find("thr_8")->get<vecf>();
        // thr_table = read_json("./thr_8.json").find("thr_8")->get<vecf>();
    }
    thr_table = floating_to_fixed(thr_table, word_length_table["thr_table"]);
    var_table = (seg_num_mode == eSAR_BAQ_SegNumMode::s128) ? var_json.find("var_128")->get<vecf>() : var_json.find("var_256")->get<vecf>();
    // var_table = floating_to_fixed(var_table, word_length_table["var_table"]);
}

double BAQ_Compressor::floating_to_fixed(double input, size_t word_length) {
    double scaling = pow(2.0, word_length);
    return floor(input * scaling) / scaling;
}
vecf BAQ_Compressor::floating_to_fixed(const vecf& input, size_t word_length) {
    vecf output;
    for (size_t i = 0; i < input.size(); i++) output.emplace_back(floating_to_fixed(input[i], word_length));
    return output;
}

vecf BAQ_Compressor::square(const vecf& input) {
    vecf output = transform<double>(input, [&](double a) { return a * a; });
    return floating_to_fixed(output, word_length_table["square"]);
}

double BAQ_Compressor::sum_pow(const pair<vecf, vecf>& input) {
    double output = sum((input.first + input.second));
    return floating_to_fixed(output, word_length_table["sum_pow"]);
}

// size_t BAQ_Compressor::select_var(double sum_pow_out) {
//     size_t var_idx_tmp = floor(sum_pow_out * (double)seg_num / (double)block_size);
//     size_t var_idx = (var_idx_tmp > seg_num - 1) ? seg_num - 1 : var_idx_tmp;
//     return var_idx;
// }

pair<size_t, size_t> BAQ_Compressor::select_var(double sum_pow_out) {
    double blk_var = sum_pow_out / (double)block_size;
    size_t var_idx_tmp = floor(blk_var * seg_num);
    if (seg_num_mode == eSAR_BAQ_SegNumMode::s128) { // SEGMOD == 0
        if (var_idx_tmp >= seg_num - 1) {            // 127
            return {seg_num - 1, 0};
        }
        else if (var_idx_tmp > 1 && var_idx_tmp < (seg_num - 1)) { // 2~126
            return {var_idx_tmp, 0};
        }
        else { // 0, 1
            size_t var_idx_part2 = floor(blk_var * seg_num * 64);
            return {var_idx_tmp, var_idx_part2 + 128};
        }
    }
    else { // SEGMOD == 1
        if (var_idx_tmp >= seg_num - 1) {
            return {seg_num - 1, 0};
        }
        return {var_idx_tmp, 0};
    }
}

vecf BAQ_Compressor::scale(const vecf& input, size_t var_idx) {
    vecf output = input * var_table[var_idx];
    return floating_to_fixed(output, word_length_table["scale"]);
}

pair<size_t, pair<vecf, vecf>> BAQ_Compressor::select_var_and_scale(double sum_pow_out, const pair<vecf, vecf>& input) {
    pair<size_t, size_t> var_idx_info = select_var(sum_pow_out);
    if (seg_num_mode == eSAR_BAQ_SegNumMode::s128 && (var_idx_info.first <= 1)) {
        pair<vecf, vecf> scale_out_tmp = scale(input, var_idx_info.second - 128);
        double s = 8; // sqrt(2/(1/128)) / 2
        return {var_idx_info.second, {scale_out_tmp.first * s, scale_out_tmp.second * s}};
    }
    return {var_idx_info.first, scale(input, var_idx_info.first)};
}

size_t BAQ_Compressor::select_qntz_idx(double input) {
    if (input >= 0) {
        for (size_t i = 0; i < thr_table.size(); i++) {
            if (input < thr_table[i]) return (thr_table.size() + 1 + i);
        }
    }
    else {
        for (size_t i = 0; i < thr_table.size(); i++) {
            if (input + thr_table[i] >= 0) return (thr_table.size() - i);
        }
    }
    return (input >= 0) ? ((thr_table.size() + 1) * 2 - 1) : 0;
}

vect BAQ_Compressor::select_qntz_idx(const vecf& input) {
    vect output;
    for (size_t i = 0; i < input.size(); i++) output.emplace_back(select_qntz_idx(input[i]));
    return output;
}

BAQ_Output BAQ_Compressor::apply_one_block(const pair<vecf, vecf>& input) {
    assert(input.first.size() == block_size);
    assert(input.second.size() == block_size);
    pair<vecf, vecf> square_out = square(input);
    double sum_pow_out = sum_pow(square_out);
    // size_t var_idx = select_var(sum_pow_out);
    // pair<vecf, vecf> scale_out = scale(input, var_idx);
    // vect qntz_idx_i = select_qntz_idx(scale_out.first);
    // vect qntz_idx_q = select_qntz_idx(scale_out.second);
    // return BAQ_Output(var_idx, (sum_pow_out > seg_num - 1), {qntz_idx_i, qntz_idx_q});
    pair<size_t, pair<vecf, vecf>> var_idx_and_scale_out = select_var_and_scale(sum_pow_out, input);
    vect qntz_idx_i = select_qntz_idx(var_idx_and_scale_out.second.first);
    vect qntz_idx_q = select_qntz_idx(var_idx_and_scale_out.second.second);
    return BAQ_Output(var_idx_and_scale_out.first, (sum_pow_out > seg_num - 1), {qntz_idx_i, qntz_idx_q});
}

VEC<BAQ_Output> BAQ_Compressor::apply(const pair<vecf, vecf>& input) {
    assert(input.first.size() == input.second.size());
    assert(input.first.size() % block_size == 0);
    size_t n_block = input.first.size() / block_size;
    VEC<BAQ_Output> output;
    for (size_t i = 0; i < n_block; i++) {
        vecf input_i = vecf(input.first.begin() + i * block_size, input.first.begin() + (i + 1) * block_size);
        vecf input_q = vecf(input.second.begin() + i * block_size, input.second.begin() + (i + 1) * block_size);
        output.emplace_back(apply_one_block({input_i, input_q}));
    }
    return output;
}

BAQ_Decompressor::BAQ_Decompressor() {
    // string folder_path = "/workspaces/bbsysdev/source/pylib/test/sar/data_comp/baq_decompressor_lut";
    string folder_path = "./baq_decompressor_lut";
    rep_json = read_json(folder_path + "/baq_rep.json");
    var_json = read_json(folder_path + "/baq_var.json");
}

void BAQ_Decompressor::setup(const BAQ_Ctrl& baq_ctrl) {
    this->word_length_mode = baq_ctrl.word_length_mode;
    this->block_size_mode = baq_ctrl.block_size_mode;
    this->seg_num_mode = baq_ctrl.seg_num_mode;
    if (word_length_mode == eSAR_BAQ_WordLenMode::w2) {
        rep_table = rep_json.find("rep_2")->get<vecf>();
    }
    else if (word_length_mode == eSAR_BAQ_WordLenMode::w3) {
        rep_table = rep_json.find("rep_3")->get<vecf>();
    }
    else if (word_length_mode == eSAR_BAQ_WordLenMode::w4) {
        rep_table = rep_json.find("rep_4")->get<vecf>();
    }
    else if (word_length_mode == eSAR_BAQ_WordLenMode::w6) {
        rep_table = rep_json.find("rep_6")->get<vecf>();
    }
    else if (word_length_mode == eSAR_BAQ_WordLenMode::w8) {
        rep_table = rep_json.find("rep_8")->get<vecf>();
    }
    else {
        disp("Setting of word length mode is wrong!");
    }
    rep_table = concate(-1.0 * reverse(rep_table), rep_table);
    var_table = (seg_num_mode == eSAR_BAQ_SegNumMode::s128) ? var_json.find("var_128")->get<vecf>() : var_json.find("var_256")->get<vecf>();
}

pair<vecf, vecf> BAQ_Decompressor::apply(const BAQ_Output& baq_out) {
    def recover_var_idx = [&]() {
        if (seg_num_mode == eSAR_BAQ_SegNumMode::s128 && baq_out.var_idx >= 128) return baq_out.var_idx * 16 / 2;
        return baq_out.var_idx;
    };
    size_t var_idx = recover_var_idx();
    pair<vecf, vecf> output;
    for (size_t i = 0; i < baq_out.qntz_idx.first.size(); i++) {
        // output.first.emplace_back(rep_table[baq_out.qntz_idx.first[i]] / var_table[baq_out.var_idx]);
        // output.second.emplace_back(rep_table[baq_out.qntz_idx.second[i]] / var_table[baq_out.var_idx]);
        output.first.emplace_back(rep_table[baq_out.qntz_idx.first[i]] / var_table[var_idx]);
        output.second.emplace_back(rep_table[baq_out.qntz_idx.second[i]] / var_table[var_idx]);
    }
    return output;
}

VEC<pair<vecf, vecf>> BAQ_Decompressor::apply(const VEC<BAQ_Output>& baq_out) {
    VEC<pair<vecf, vecf>> output;
    for (size_t i = 0; i < baq_out.size(); i++) output.emplace_back(apply(baq_out[i]));
    return output;
}
