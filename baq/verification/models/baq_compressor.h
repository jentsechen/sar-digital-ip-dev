#pragma once
#include <vector>
#include "baq_enum.h"
#include "baq_fixed_point.h"
#include "baq_output.h"

struct BaqPowerConfig
{
    FpFormat input_fmt;   // format of I/Q input samples
    FpFormat square_fmt;  // format after squaring (I² or Q²)
    FpFormat accum_fmt;   // format of the block power accumulator
};

struct VarSelectResult
{
    size_t output_idx;   // var_idx written to bitstream output
    size_t table_idx;    // index into var_table used for scaling
    double extra_scale;  // additional scale factor (8.0 for segmod0 low-power, 1.0 otherwise)
    bool   overflow;     // true when block power exceeds the maximum variance entry
};

class BaqCompressor
{
public:
    BaqCompressor(BaqWordLenMode word_len_mode = BaqWordLenMode::w2,
                  BaqBlockSizeMode block_size_mode = BaqBlockSizeMode::b128,
                  BaqSegNumMode seg_num_mode = BaqSegNumMode::s128);

    void setPowerConfig(BaqPowerConfig cfg)         { power_config = cfg; }
    void setSelectVarMode(BaqSelectVarMode mode)    { select_var_mode = mode; }

    BaqOutputFlat apply(const std::vector<double> &I, const std::vector<double> &Q);

    VarSelectResult select_var(double block_power) const;

    BaqWordLenMode    getWordLenMode()   const { return word_len_mode; }
    BaqBlockSizeMode  getBlockSizeMode() const { return block_size_mode; }
    BaqSegNumMode     getSegNumMode()    const { return seg_num_mode; }
    const std::vector<double> &getThrTable() const { return thr_table; }
    const std::vector<double> &getVarTable() const { return var_table; }

private:
    BaqWordLenMode    word_len_mode;
    BaqBlockSizeMode  block_size_mode;
    BaqSegNumMode     seg_num_mode;
    BaqSelectVarMode  select_var_mode = BaqSelectVarMode::segmod0;
    std::vector<double> thr_table;
    std::vector<double> var_table;
    BaqPowerConfig power_config;

    std::vector<double> calc_block_power(const std::vector<double> &I, const std::vector<double> &Q);
};
