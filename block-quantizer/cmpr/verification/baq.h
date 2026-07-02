#ifndef __sar_baq_h_h__
#define __sar_baq_h_h__
#include "utility.h"
enum class BaqWordLenMode
{
    w2,
    w3,
    w4,
    w6,
    w8
};
enum class BaqBlockSizeMode
{
    b128,
    b256,
    b512
};
enum class BaqSegNumMode
{
    s128,
    s256
};
static vector<size_t> BaqWordLen = vector<size_t>({2, 3, 4, 6, 8});
static vector<size_t> BaqBlockSize = vector<size_t>({128, 256, 512});
static vector<size_t> BaqSegNum = vector<size_t>({128, 256});
static vector<string> BaqWordLenName = vector<string>({"w2", "w3", "w4", "w6", "w8"});
static vector<string> BaqBlockSizeName = vector<string>({"b128", "b256", "b512"});
static vector<string> BaqSegNumName = vector<string>({"s128", "s256"});

struct BaqCtrl
{
    BaqWordLenMode word_length_mode;
    BaqBlockSizeMode block_size_mode;
    BaqSegNumMode seg_num_mode;
    BaqCtrl(BaqWordLenMode word_length_mode = BaqWordLenMode::w2, BaqBlockSizeMode block_size_mode = BaqBlockSizeMode::b128,
            BaqSegNumMode seg_num_mode = BaqSegNumMode::s128)
        : word_length_mode(word_length_mode), block_size_mode(block_size_mode), seg_num_mode(seg_num_mode) {}
};

struct BaqOutput
{
    size_t var_idx, overflow;
    pair<vector<size_t>, vector<size_t>> qntz_idx;
    BaqOutput(size_t var_idx, size_t overflow, const pair<vector<size_t>, vector<size_t>> &qntz_idx) : var_idx(var_idx), overflow(overflow), qntz_idx(qntz_idx) {}
};

struct BaqCompressor
{
    json thr_json, var_json;
    map<string, size_t> word_length_table;
    BaqWordLenMode word_length_mode;
    BaqBlockSizeMode block_size_mode;
    BaqSegNumMode seg_num_mode;
    size_t word_length, block_size, seg_num;
    vector<double> thr_table, var_table;
    BaqCompressor();
    void setup(const BaqCtrl &);
    double floating_to_fixed(double, size_t);
    vector<double> floating_to_fixed(const vector<double> &, size_t);
    vector<double> square(const vector<double> &);
    pair<vector<double>, vector<double>> square(const pair<vector<double>, vector<double>> &input)
    {
        return {floating_to_fixed(square(input.first), word_length_table["square"]), floating_to_fixed(square(input.second), word_length_table["square"])};
    }
    double sum_pow(const pair<vector<double>, vector<double>> &);
    // size_t select_var(double);
    pair<size_t, size_t> select_var(double);
    // vector<double> scale(const vector<double>&, size_t);
    vector<double> scale(const vector<double> &, size_t);
    pair<vector<double>, vector<double>> scale(const pair<vector<double>, vector<double>> &input, size_t var_idx) { return {scale(input.first, var_idx), scale(input.second, var_idx)}; }
    pair<size_t, pair<vector<double>, vector<double>>> select_var_and_scale(double sum_pow_out, const pair<vector<double>, vector<double>> &input);
    size_t select_qntz_idx(double);
    vector<size_t> select_qntz_idx(const vector<double> &);
    BaqOutput apply_one_block(const pair<vector<double>, vector<double>> &);
    vector<BaqOutput> apply(const pair<vector<double>, vector<double>> &);
    bool overflow_flag(double sum_pow_out);
};

struct BaqDecompressor
{
    json rep_json, var_json;
    BaqWordLenMode word_length_mode;
    BaqBlockSizeMode block_size_mode;
    BaqSegNumMode seg_num_mode;
    vector<double> rep_table, var_table;
    BaqDecompressor();
    void setup(const BaqCtrl &);
    pair<vector<double>, vector<double>> apply(const BaqOutput &);
    vector<pair<vector<double>, vector<double>>> apply(const vector<BaqOutput> &);
};

#endif