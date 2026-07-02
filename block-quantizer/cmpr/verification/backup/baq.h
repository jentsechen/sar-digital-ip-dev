#ifndef __sar_baq_h_h__
#define __sar_baq_h_h__
#include <commlib/commlib_inc.h>

ENUM_Class(eSAR_BAQ_WordLenMode, w2, w3, w4, w6, w8);
ENUM_Class(eSAR_BAQ_BlockSizeMode, b128, b256, b512);
ENUM_Class(eSAR_BAQ_SegNumMode, s128, s256);

namespace SAR
{

struct BAQ_Ctrl : ToJson {
    eSAR_BAQ_WordLenMode word_length_mode;
    eSAR_BAQ_BlockSizeMode block_size_mode;
    eSAR_BAQ_SegNumMode seg_num_mode;
    BAQ_Ctrl(eSAR_BAQ_WordLenMode word_length_mode = eSAR_BAQ_WordLenMode::w2, eSAR_BAQ_BlockSizeMode block_size_mode = eSAR_BAQ_BlockSizeMode::b128,
             eSAR_BAQ_SegNumMode seg_num_mode = eSAR_BAQ_SegNumMode::s128)
        : word_length_mode(word_length_mode), block_size_mode(block_size_mode), seg_num_mode(seg_num_mode) {}
};

struct BAQ_Output : ToJson {
    size_t var_idx, overflow;
    pair<vect, vect> qntz_idx;
    BAQ_Output(size_t var_idx, size_t overflow, const pair<vect, vect>& qntz_idx) : var_idx(var_idx), overflow(overflow), qntz_idx(qntz_idx) {}
};

struct BAQ_Compressor : ToJson {
    json thr_json, var_json;
    map<string, size_t> word_length_table;
    eSAR_BAQ_WordLenMode word_length_mode;
    eSAR_BAQ_BlockSizeMode block_size_mode;
    eSAR_BAQ_SegNumMode seg_num_mode;
    size_t word_length, block_size, seg_num;
    vecf thr_table, var_table;
    BAQ_Compressor();
    void setup(const BAQ_Ctrl&);
    double floating_to_fixed(double, size_t);
    vecf floating_to_fixed(const vecf&, size_t);
    vecf square(const vecf&);
    pair<vecf, vecf> square(const pair<vecf, vecf>& input) { return {square(input.first), square(input.second)}; }
    double sum_pow(const pair<vecf, vecf>&);
    // size_t select_var(double);
    pair<size_t, size_t> select_var(double);
    // vecf scale(const vecf&, size_t);
    vecf scale(const vecf&, size_t);
    pair<vecf, vecf> scale(const pair<vecf, vecf>& input, size_t var_idx) { return {scale(input.first, var_idx), scale(input.second, var_idx)}; }
    pair<size_t, pair<vecf, vecf>> select_var_and_scale(double sum_pow_out, const pair<vecf, vecf>& input);
    size_t select_qntz_idx(double);
    vect select_qntz_idx(const vecf&);
    BAQ_Output apply_one_block(const pair<vecf, vecf>&);
    VEC<BAQ_Output> apply(const pair<vecf, vecf>&);
};

struct BAQ_Decompressor : ToJson {
    json rep_json, var_json;
    eSAR_BAQ_WordLenMode word_length_mode;
    eSAR_BAQ_BlockSizeMode block_size_mode;
    eSAR_BAQ_SegNumMode seg_num_mode;
    vecf rep_table, var_table;
    BAQ_Decompressor();
    void setup(const BAQ_Ctrl&);
    pair<vecf, vecf> apply(const BAQ_Output&);
    VEC<pair<vecf, vecf>> apply(const VEC<BAQ_Output>&);
};

}; // namespace SAR

#endif //__sar_baq_h_h__