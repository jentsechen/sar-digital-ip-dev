#pragma once
#include <vector>

struct BaqOutputFlat
{
    std::vector<size_t> var_idx;
    std::vector<bool>   overflow;
    std::vector<size_t> qntz_I;
    std::vector<size_t> qntz_Q;
};
