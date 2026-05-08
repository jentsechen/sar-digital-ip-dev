#pragma once
#include <vector>
#include "baq_enum.h"

class BaqDecompressor
{
public:
    BaqDecompressor(BaqWordLenMode word_len_mode = BaqWordLenMode::w2,
                    BaqBlockSizeMode block_size_mode = BaqBlockSizeMode::b128,
                    BaqSegNumMode seg_num_mode = BaqSegNumMode::s128);

    BaqWordLenMode getWordLenMode() const { return word_len_mode; }
    BaqBlockSizeMode getBlockSizeMode() const { return block_size_mode; }
    BaqSegNumMode getSegNumMode() const { return seg_num_mode; }
    const std::vector<double> &getRepTable() const { return rep_table; }
    const std::vector<double> &getVarTable() const { return var_table; }

private:
    BaqWordLenMode word_len_mode;
    BaqBlockSizeMode block_size_mode;
    BaqSegNumMode seg_num_mode;
    std::vector<double> rep_table;
    std::vector<double> var_table;
};
