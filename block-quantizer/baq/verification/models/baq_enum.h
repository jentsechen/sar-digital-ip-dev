#pragma once

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

enum class BaqSelectVarMode
{
    segmod0,  // special fine-grain sub-index for very low power blocks (s128 method)
    segmod1   // simple floor + clamp (s256 method)
};
