#ifndef __sar_bfpq_h__
#define __sar_bfpq_h__
#include <commlib/commlib_inc.h>

ENUM_Class(eSAR_BFPQ_WordLenMode, w2, w3, w4, w6, w8);
ENUM_Class(eSAR_BFPQ_BlockSizeMode, b8, b16, b32);

namespace SAR
{

struct BFPQ_Ctrl : ToJson {
    eSAR_BFPQ_WordLenMode word_length_mode;
    eSAR_BFPQ_BlockSizeMode block_size_mode;
    BFPQ_Ctrl(eSAR_BFPQ_WordLenMode word_length_mode = eSAR_BFPQ_WordLenMode::w2, eSAR_BFPQ_BlockSizeMode block_size_mode = eSAR_BFPQ_BlockSizeMode::b8)
        : word_length_mode(word_length_mode), block_size_mode(block_size_mode) {}
};

struct BFPQ_Output : ToJson {
    pair<vecb, vecb> sign;
    pair<vect, vect> mts_idx;
    size_t exp_idx, scaling_idx;
    BFPQ_Output(const pair<vecb, vecb>& sign, const pair<vect, vect>& mts_idx, size_t exp_idx, size_t scaling_idx)
        : sign(sign), mts_idx(mts_idx), exp_idx(exp_idx), scaling_idx(scaling_idx) {}
};

struct BFPQ_Compressor : ToJson {
    bool fx_en;
    map<string, size_t> word_length_table;
    eSAR_BFPQ_BlockSizeMode block_size_mode;
    eSAR_BFPQ_WordLenMode word_length_mode;
    size_t block_size, word_length, n_bits_frac_exponent;
    double max_tune_factor, qntz_step, qntz_max;
    vecf scaling_factor_table, scaling_table, qntz_bnd_table, exp_bnd_table;
    BFPQ_Compressor();
    void setup(const BFPQ_Ctrl&);
    double floating_to_fixed(double, size_t);
    double abs_max(const pair<vecf, vecf>&);
    double abs_max_tune(double);
    vecb extract_sign(const vecf&);
    pair<vecb, vecb> extract_sign(const pair<vecf, vecf>& input) { return {extract_sign(input.first), extract_sign(input.second)}; }
    size_t select_exponent(double);
    size_t select_scaling(double, size_t);
    vect select_mantissa(const vecf&, size_t, size_t);
    pair<vect, vect> select_mantissa(const pair<vecf, vecf>& input, size_t scaling_idx, size_t exp_idx) {
        return {select_mantissa(input.first, scaling_idx, exp_idx), select_mantissa(input.second, scaling_idx, exp_idx)};
    }
    BFPQ_Output apply_one_block(const pair<vecf, vecf>&);
    VEC<BFPQ_Output> apply(const pair<vecf, vecf>&, bool);
};

struct BFPQ_Decompressor : ToJson {
    eSAR_BFPQ_BlockSizeMode block_size_mode;
    eSAR_BFPQ_WordLenMode word_length_mode;
    size_t block_size, word_length;
    json lut;
    BFPQ_Decompressor() {}
    void setup(const BFPQ_Ctrl&, size_t);
    pair<vecf, vecf> apply(const BFPQ_Output&);
    VEC<pair<vecf, vecf>> apply(const VEC<BFPQ_Output>&);
};

}; // namespace SAR

#endif //__sar_bfpq_h__