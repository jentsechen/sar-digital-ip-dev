#ifndef __sar_bfpq_h__
#define __sar_bfpq_h__
#include "utility.h"
enum class BfpqWordLenMode
{
    w2,
    w3,
    w4,
    w6,
    w8
};
enum class BfpqBlockSizeMode
{
    b8,
    b16,
    b32
};
static vector<size_t> BfpqWordLen = vector<size_t>({2, 3, 4, 6, 8});
static vector<size_t> BfpqBlockSize = vector<size_t>({8, 16, 32});
static vector<double> BfpqQntzStep = vector<double>({0.32, 0.195, 0.105, 0.03, 0.00775});
static vector<string> BfpqWordLenName = vector<string>({"w2", "w3", "w4", "w6", "w8"});
static vector<string> BfpqBlockSizeName = vector<string>({"b8", "b16", "b32"});

struct BfpqCtrl
{
    BfpqWordLenMode word_length_mode;
    BfpqBlockSizeMode block_size_mode;
    BfpqCtrl(BfpqWordLenMode word_length_mode = BfpqWordLenMode::w2, BfpqBlockSizeMode block_size_mode = BfpqBlockSizeMode::b8)
        : word_length_mode(word_length_mode), block_size_mode(block_size_mode) {}
};

struct BfpqOutput
{
    pair<vector<size_t>, vector<size_t>> sign;
    pair<vector<size_t>, vector<size_t>> mts_idx;
    size_t exp_idx, scaling_idx;
    BfpqOutput(const pair<vector<size_t>, vector<size_t>> &sign, const pair<vector<size_t>, vector<size_t>> &mts_idx, size_t exp_idx, size_t scaling_idx)
        : sign(sign), mts_idx(mts_idx), exp_idx(exp_idx), scaling_idx(scaling_idx) {}
};

struct BfpqCompressor
{
    bool fx_en;
    map<string, size_t> word_length_table;
    BfpqBlockSizeMode block_size_mode;
    BfpqWordLenMode word_length_mode;
    size_t block_size, word_length, n_bits_frac_exponent;
    double max_tune_factor, qntz_step, qntz_max;
    vector<double> scaling_factor_table, scaling_table, qntz_bnd_table, exp_bnd_table;
    BfpqCompressor();
    void setup(const BfpqCtrl &);
    double floating_to_fixed(double, size_t);
    double abs_max(const pair<vector<double>, vector<double>> &);
    double abs_max_tune(double);
    vector<size_t> extract_sign(const vector<double> &);
    pair<vector<size_t>, vector<size_t>> extract_sign(const pair<vector<double>, vector<double>> &input) { return {extract_sign(input.first), extract_sign(input.second)}; }
    size_t select_exponent(double);
    size_t select_scaling(double, size_t);
    vector<size_t> select_mantissa(const vector<double> &, size_t, size_t);
    pair<vector<size_t>, vector<size_t>> select_mantissa(const pair<vector<double>, vector<double>> &input, size_t scaling_idx, size_t exp_idx)
    {
        return {select_mantissa(input.first, scaling_idx, exp_idx), select_mantissa(input.second, scaling_idx, exp_idx)};
    }
    BfpqOutput apply_one_block(const pair<vector<double>, vector<double>> &);
    vector<BfpqOutput> apply(const pair<vector<double>, vector<double>> &, bool);
};

struct BfpqDecompressor
{
    BfpqBlockSizeMode block_size_mode;
    BfpqWordLenMode word_length_mode;
    size_t block_size, word_length;
    json lut;
    BfpqDecompressor() {}
    void setup(const BfpqCtrl &, size_t);
    pair<vector<double>, vector<double>> apply(const BfpqOutput &);
    vector<pair<vector<double>, vector<double>>> apply(const vector<BfpqOutput> &);
};

#endif