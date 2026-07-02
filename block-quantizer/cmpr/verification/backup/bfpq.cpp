#include "SAR/data_comp/bfpq/bfpq.h"
using namespace SAR;

BFPQ_Compressor::BFPQ_Compressor() {
    word_length_table.clear();
    word_length_table["scaling_factor"] = 9;
    word_length_table["scaling"] = 10;
    word_length_table["qntz_bnd"] = 12;
    word_length_table["exp_bnd"] = 9;
    word_length_table["abs_max"] = 11;
    word_length_table["max_tune_factor"] = 9;
    word_length_table["mul_tune"] = 12;
    word_length_table["mul_scale"] = 15;
}

void BFPQ_Compressor::setup(const BFPQ_Ctrl& bfpq_ctrl) {
    this->block_size_mode = bfpq_ctrl.block_size_mode;
    this->word_length_mode = bfpq_ctrl.word_length_mode;
    assert(!(block_size_mode == eSAR_BFPQ_BlockSizeMode::b16 && word_length_mode == eSAR_BFPQ_WordLenMode::w2));
    assert(!(block_size_mode == eSAR_BFPQ_BlockSizeMode::b32 && word_length_mode == eSAR_BFPQ_WordLenMode::w2));
    assert(!(block_size_mode == eSAR_BFPQ_BlockSizeMode::b32 && word_length_mode == eSAR_BFPQ_WordLenMode::w3));
    // block size
    if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b8)
        block_size = 8;
    else if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b16)
        block_size = 16;
    else // block_size_mode == eSAR_BFPQ_BlockSizeMode::b32
        block_size = 32;
    // number of bits for fractional exponent
    n_bits_frac_exponent =
        (block_size_mode == eSAR_BFPQ_BlockSizeMode::b16 && word_length_mode == eSAR_BFPQ_WordLenMode::w3) || (block_size_mode == eSAR_BFPQ_BlockSizeMode::b32)
            ? 3
            : 2;
    // maximum tuning factor
    if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b32 && word_length_mode == eSAR_BFPQ_WordLenMode::w4)
        max_tune_factor = 1.05;
    else if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b32 && word_length_mode == eSAR_BFPQ_WordLenMode::w6)
        max_tune_factor = 1.02;
    else if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b32 && word_length_mode == eSAR_BFPQ_WordLenMode::w8)
        max_tune_factor = 1.004;
    else
        max_tune_factor = 1;
    // quantization step
    if (word_length_mode == eSAR_BFPQ_WordLenMode::w2) {
        word_length = 2;
        qntz_step = 0.32;
    }
    else if (word_length_mode == eSAR_BFPQ_WordLenMode::w3) {
        word_length = 3;
        qntz_step = 0.195;
    }
    else if (word_length_mode == eSAR_BFPQ_WordLenMode::w4) {
        word_length = 4;
        qntz_step = 0.105;
    }
    else if (word_length_mode == eSAR_BFPQ_WordLenMode::w6) {
        word_length = 6;
        qntz_step = 0.03;
    }
    else if (word_length_mode == eSAR_BFPQ_WordLenMode::w8) {
        word_length = 8;
        qntz_step = 0.00775;
    }
    else
        disp("word_length_mode does not exist!");
    // quantization maximum
    qntz_max = qntz_step * pow(2.0, word_length - 1);
    // scaling
    scaling_factor_table.clear();
    scaling_table.clear();
    for (size_t i = 0; i < pow(2, n_bits_frac_exponent); i++) {
        double scaling_factor_tmp = pow(2.0, n_bits_frac_exponent) / (pow(2.0, n_bits_frac_exponent + 1) - 1 - (double)i);
        scaling_factor_table.emplace_back(floating_to_fixed(scaling_factor_tmp, word_length_table["scaling_factor"]));
        scaling_table.emplace_back(floating_to_fixed(1.0 / scaling_factor_table[i], word_length_table["scaling"]));
    }
    // quantization boundary
    qntz_bnd_table.clear();
    double qntz_bnd_unit_step = 1.0 / pow(2.0, word_length - 1), qntz_bnd_unit = 0;
    for (size_t i = 0; i < pow(2, word_length - 1); i++) {
        qntz_bnd_unit += qntz_bnd_unit_step;
        double qntz_bnd_tmp = qntz_bnd_unit * qntz_max / sqrt(2.0);
        qntz_bnd_table.emplace_back(floating_to_fixed(qntz_bnd_tmp, word_length_table["qntz_bnd"]));
    }
    // exponent boundary
    exp_bnd_table.clear();
    for (size_t i = 0; i < 8; i++) {
        double exp_bnd_tmp = ((i < 4) ? 1.0 / pow(2.0, 4 - i) : pow(2.0, i - 4)) * qntz_max / sqrt(2.0);
        exp_bnd_table.emplace_back(floating_to_fixed(exp_bnd_tmp, word_length_table["exp_bnd"]));
    }
}

double BFPQ_Compressor::floating_to_fixed(double input, size_t word_length) {
    if (fx_en) {
        double scaling = pow(2.0, word_length);
        return floor(input * scaling) / scaling;
    }
    return input;
}

double BFPQ_Compressor::abs_max(const pair<vecf, vecf>& input) {
    double abs_max_i = max(abs(input.first)), abs_max_q = max(abs(input.second));
    return floating_to_fixed(max({abs_max_i, abs_max_q}), word_length_table["abs_max"]);
}

double BFPQ_Compressor::abs_max_tune(double input) {
    double max_tune_factor_inv = floating_to_fixed(1.0 / max_tune_factor, word_length_table["max_tune_factor"]);
    return floating_to_fixed(input * max_tune_factor_inv, word_length_table["mul_tune"]);
}

vecb BFPQ_Compressor::extract_sign(const vecf& input) {
    vecb sign_list;
    for (size_t i = 0; i < input.size(); i++) sign_list.emplace_back(input[i] < 0);
    return sign_list;
}

size_t BFPQ_Compressor::select_exponent(double input) {
    size_t exp_idx;
    for (size_t i = 0; i < exp_bnd_table.size(); i++) {
        if (input <= exp_bnd_table[i]) {
            exp_idx = i;
            break;
        }
        else
            exp_idx = i;
    }
    return exp_idx;
}

size_t BFPQ_Compressor::select_scaling(double abs_max_tune, size_t exp_idx) {
    double qntz_bnd_max = max(qntz_bnd_table);
    vecf scaling_bnd_table;
    def mul_qntz_bnd_max = [&](double input) -> double {
        double output = input * qntz_bnd_max;
        return floating_to_fixed(output, word_length_table["mul_tune"]);
    };
    def mul_exp_scaling = [&](double input, size_t exp_idx) -> double {
        double exp_scaling = exp_idx < 4 ? 1. / pow(2.0, 4 - exp_idx) : pow(2.0, exp_idx - 4);
        double output = input * exp_scaling;
        return floating_to_fixed(output, word_length_table["mul_tune"]);
    };
    for (size_t i = 0; i < scaling_table.size(); i++) {
        double scaling_bnd_qntz_bnd_max = mul_qntz_bnd_max(scaling_factor_table[i]);
        double scaling_bnd_exp = mul_exp_scaling(scaling_bnd_qntz_bnd_max, exp_idx);
        scaling_bnd_table.emplace_back(scaling_bnd_exp);
    }
    size_t scaling_idx;
    for (size_t i = 0; i < scaling_bnd_table.size(); i++) {
        if (abs_max_tune <= scaling_bnd_table[i]) {
            scaling_idx = i;
            break;
        }
        else
            scaling_idx = i;
    }
    return scaling_idx;
}

vect BFPQ_Compressor::select_mantissa(const vecf& input, size_t exp_idx, size_t scaling_idx) {
    def scale = [&](double input, double scaling) -> double { return floating_to_fixed(abs(input) * scaling, word_length_table["mul_scale"]); };
    vecf input_scale;
    for (size_t i = 0; i < input.size(); i++) input_scale.emplace_back(scale(input[i], scaling_table[scaling_idx]));
    def mul_exp_scaling = [&](double input, size_t exp_idx) -> double {
        double exp_scaling = exp_idx < 4 ? 1. / pow(2.0, 4 - exp_idx) : pow(2.0, exp_idx - 4);
        double output = input * exp_scaling;
        return floating_to_fixed(output, word_length_table["qntz_bnd"] + 3);
    };
    vecf qntz_bnd_table_scale;
    for (size_t i = 0; i < qntz_bnd_table.size(); i++) qntz_bnd_table_scale.emplace_back(mul_exp_scaling(qntz_bnd_table[i], exp_idx));
    def sel_mts_idx = [&](double input) -> size_t {
        size_t mts_idx;
        for (size_t i = 0; i < qntz_bnd_table.size(); i++) {
            if (input <= qntz_bnd_table_scale[i]) {
                mts_idx = i;
                break;
            }
            else
                mts_idx = i;
        }
        return mts_idx;
    };
    vect mts_idx_list;
    for (size_t i = 0; i < input.size(); i++) mts_idx_list.emplace_back(sel_mts_idx(input_scale[i]));
    return mts_idx_list;
}

BFPQ_Output BFPQ_Compressor::apply_one_block(const pair<vecf, vecf>& input) {
    assert(input.first.size() == block_size);
    assert(input.second.size() == block_size);
    double max_value = abs_max(input);
    double max_value_tune = abs_max_tune(max_value);
    pair<vecb, vecb> sign = extract_sign(input);
    size_t exp_idx = select_exponent(max_value_tune);
    size_t scaling_idx = select_scaling(max_value_tune, exp_idx);
    pair<vect, vect> mts_idx = select_mantissa(input, exp_idx, scaling_idx);
    return BFPQ_Output(sign, mts_idx, exp_idx, scaling_idx);
}

VEC<BFPQ_Output> BFPQ_Compressor::apply(const pair<vecf, vecf>& input, bool fx_en = true) {
    assert(input.first.size() == input.second.size());
    assert(input.first.size() % block_size == 0);
    this->fx_en = fx_en;
    size_t n_block = input.first.size() / block_size;
    VEC<BFPQ_Output> output;
    for (size_t i = 0; i < n_block; i++) {
        vecf input_i = vecf(input.first.begin() + i * block_size, input.first.begin() + (i + 1) * block_size);
        vecf input_q = vecf(input.second.begin() + i * block_size, input.second.begin() + (i + 1) * block_size);
        output.emplace_back(apply_one_block({input_i, input_q}));
    }
    return output;
}

void BFPQ_Decompressor::setup(const BFPQ_Ctrl& bfpq_ctrl, size_t n_bits_frac_exp) {
    this->block_size_mode = bfpq_ctrl.block_size_mode;
    this->word_length_mode = bfpq_ctrl.word_length_mode;
    // block size
    if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b8)
        block_size = 8;
    else if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b16)
        block_size = 16;
    else if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b32)
        block_size = 32;
    else
        disp("block_size_mode does not exists!");
    // word length
    if (word_length_mode == eSAR_BFPQ_WordLenMode::w2)
        word_length = 2;
    else if (word_length_mode == eSAR_BFPQ_WordLenMode::w3)
        word_length = 3;
    else if (word_length_mode == eSAR_BFPQ_WordLenMode::w4)
        word_length = 4;
    else if (word_length_mode == eSAR_BFPQ_WordLenMode::w6)
        word_length = 6;
    else if (word_length_mode == eSAR_BFPQ_WordLenMode::w8)
        word_length = 8;
    else
        disp("word_length_mode does not exists!");
    string file_name = "rep_level_m_" + to_string(word_length) + "_f_" + to_string(n_bits_frac_exp) + ".json";
    // lut = read_json("./source/pylib/test/sar/data_comp/bfpq_decompressor_lut/" + file_name);
    lut = read_json("./bfpq_decompressor_lut/" + file_name);
}

pair<vecf, vecf> BFPQ_Decompressor::apply(const BFPQ_Output& bfpq_out) {
    def decomp = [&](size_t exp_idx, size_t frac_idx, size_t mts_idx, bool sign) -> double {
        double lut_out = lut[exp_idx][frac_idx]["value"][mts_idx];
        return lut_out / sqrt(2.0) * (sign ? -1.0 : 1.0);
    };
    pair<vecf, vecf> output;
    for (size_t i = 0; i < block_size; i++) {
        output.first.emplace_back(decomp(bfpq_out.exp_idx, bfpq_out.scaling_idx, bfpq_out.mts_idx.first[i], bfpq_out.sign.first[i]));
        output.second.emplace_back(decomp(bfpq_out.exp_idx, bfpq_out.scaling_idx, bfpq_out.mts_idx.second[i], bfpq_out.sign.second[i]));
    }
    return output;
}

VEC<pair<vecf, vecf>> BFPQ_Decompressor::apply(const VEC<BFPQ_Output>& bfpq_out) {
    VEC<pair<vecf, vecf>> output;
    for (size_t i = 0; i < bfpq_out.size(); i++) output.emplace_back(apply(bfpq_out[i]));
    return output;
}