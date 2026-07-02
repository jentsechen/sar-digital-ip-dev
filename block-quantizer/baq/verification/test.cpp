#include "models/baq_compressor.h"
#include "models/baq_decompressor.h"
#include "models/json.hpp"
#include <cmath>
#include <fstream>
#include <vector>

using json = nlohmann::json;

int main()
{
    // Generate a linear chirp: s(n) = A * exp(j * pi * k * (n/N)^2)
    const size_t N = 512; // 4 blocks of 128 samples
    const double A = 3.0;
    const double k = 1.0; // sweeps full normalized bandwidth over N samples

    std::vector<double> I(N), Q(N);
    for (size_t n = 0; n < N; n++)
    {
        double t = static_cast<double>(n) / N;
        double phase = M_PI * k * t * t;
        I[n] = A * std::cos(phase);
        Q[n] = A * std::sin(phase);
    }

    // Save input
    {
        json j;
        j["I"] = I;
        j["Q"] = Q;
        std::ofstream("input.json") << j.dump(2);
    }

    // Compress
    BaqCompressor compressor(BaqWordLenMode::w4, BaqBlockSizeMode::b128, BaqSegNumMode::s128);
    BaqOutputFlat compressed = compressor.apply(I, Q);

    // Decompress
    BaqDecompressor decompressor(BaqWordLenMode::w4, BaqBlockSizeMode::b128, BaqSegNumMode::s128);
    auto [I_out, Q_out] = decompressor.apply(compressed);

    // Save output
    {
        json j;
        j["I"] = I_out;
        j["Q"] = Q_out;
        std::ofstream("output.json") << j.dump(2);
    }

    return 0;
}
