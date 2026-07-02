#include "utility.h"
#include "baq.h"
#include "baq.cpp"
#include "bfpq.h"
#include "bfpq.cpp"

enum class DataCompTestMode
{
    bypass,
    baq,
    bfpq
};
enum class BypassBlockSizeMode
{
    b8,
    b16,
    b32,
    b64
};
static vector<size_t> BypassBlockSize({8, 16, 32, 64});
static vector<string> DataCompTestName({"bypass", "baq", "bfpq"});
static vector<string> BypassBlockSizeName({"b8", "b16", "b32", "b64"});

struct BaqGolden
{
    vector<size_t> BAQOutI, BAQOutQ;
    size_t FVarianceAddress, fOverFlow;
    BaqGolden(const vector<size_t> &BAQOutI, const vector<size_t> &BAQOutQ, size_t FVarianceAddress, size_t fOverFlow)
        : BAQOutI(BAQOutI), BAQOutQ(BAQOutQ), FVarianceAddress(FVarianceAddress), fOverFlow(fOverFlow) {}
};

void to_json(json &j, const BaqGolden &baq_golden)
{
    j = json({{"BAQOutI", baq_golden.BAQOutI},
              {"BAQOutQ", baq_golden.BAQOutQ},
              {"FVarianceAddress", baq_golden.FVarianceAddress},
              {"fOverFlow", baq_golden.fOverFlow}});
}

void test_baq_compressor(json j, string file_path)
{
    BaqWordLenMode word_length_mode = static_cast<BaqWordLenMode>(find_enum(BaqWordLenName, json_to_string(j.at("word_length_mode"))));
    BaqBlockSizeMode block_size_mode = static_cast<BaqBlockSizeMode>(find_enum(BaqBlockSizeName, json_to_string(j.at("block_size_mode"))));
    BaqSegNumMode seg_num_mode = static_cast<BaqSegNumMode>(find_enum(BaqSegNumName, json_to_string(j.at("seg_num_mode"))));
    pair<vector<double>, vector<double>> input({j.at("input").find("I")->get<vector<double>>(), j.at("input").find("Q")->get<vector<double>>()});
    BaqCtrl baq_ctrl(word_length_mode, block_size_mode, seg_num_mode);
    BaqCompressor baq_compressor;
    baq_compressor.setup(baq_ctrl);
    vector<BaqOutput> baq_comp_out = baq_compressor.apply(input);
    vector<BaqGolden> baq_golden;
    for (auto i = 0; i < baq_comp_out.size(); i++)
    {
        baq_golden.emplace_back(BaqGolden(baq_comp_out[i].qntz_idx.first, baq_comp_out[i].qntz_idx.second, baq_comp_out[i].var_idx, baq_comp_out[i].overflow));
    }
    cout << "BAQ" << endl;
    save_json(file_path + "/baq_golden", baq_golden);
}

struct BfpqGolden
{
    vector<size_t> MantissaI, MantissaQ, signI, signQ;
    size_t ce, cw;
    BfpqGolden(const vector<size_t> &MantissaI, const vector<size_t> &MantissaQ, const vector<size_t> &signI, const vector<size_t> &signQ, size_t ce, size_t cw)
        : MantissaI(MantissaI), MantissaQ(MantissaQ), signI(signI), signQ(signQ), ce(ce), cw(cw) {}
};

void to_json(json &j, const BfpqGolden &bfpq_golden)
{
    j = json({{"MantissaI", bfpq_golden.MantissaI},
              {"MantissaQ", bfpq_golden.MantissaQ},
              {"signI", bfpq_golden.signI},
              {"signQ", bfpq_golden.signQ},
              {"ce", bfpq_golden.ce},
              {"cw", bfpq_golden.cw}});
}

void test_bfpq_compressor(json j, string file_path)
{
    BfpqWordLenMode word_length_mode = static_cast<BfpqWordLenMode>(find_enum(BfpqWordLenName, json_to_string(j.at("word_length_mode"))));
    BfpqBlockSizeMode block_size_mode = static_cast<BfpqBlockSizeMode>(find_enum(BfpqBlockSizeName, json_to_string(j.at("block_size_mode"))));
    pair<vector<double>, vector<double>> input({j.at("input").find("I")->get<vector<double>>(), j.at("input").find("Q")->get<vector<double>>()});
    BfpqCtrl BfpqCtrl(word_length_mode, block_size_mode);
    BfpqCompressor bfpq_compressor;
    bfpq_compressor.setup(BfpqCtrl);
    vector<BfpqOutput> bfpq_comp_out = bfpq_compressor.apply(input);
    vector<BfpqGolden> bfpq_golden;
    for (auto i = 0; i < bfpq_comp_out.size(); i++)
    {
        bfpq_golden.emplace_back(BfpqGolden(bfpq_comp_out[i].mts_idx.first, bfpq_comp_out[i].mts_idx.second, bfpq_comp_out[i].sign.first,
                                            bfpq_comp_out[i].sign.second, bfpq_comp_out[i].exp_idx, bfpq_comp_out[i].scaling_idx));
    }
    cout << "BFPQ" << endl;
    save_json(file_path + "/bfpq_golden", bfpq_golden);
}

struct BypassGolden
{
    vector<double> BypassOutI, BypassOutQ;
    BypassGolden(const vector<double> &BypassOutI, const vector<double> &BypassOutQ) : BypassOutI(BypassOutI), BypassOutQ(BypassOutQ) {}
};

void to_json(json &j, const BypassGolden &bypass_golden)
{
    j = json({{"BypassOutI", bypass_golden.BypassOutI},
              {"BypassOutQ", bypass_golden.BypassOutQ}});
}

void test_bypass_compressor(json j, string file_path)
{
    BypassBlockSizeMode block_size_mode = static_cast<BypassBlockSizeMode>(find_enum(BypassBlockSizeName, json_to_string(j.at("block_size_mode"))));
    pair<vector<double>, vector<double>> input({j.at("input").find("I")->get<vector<double>>(), j.at("input").find("Q")->get<vector<double>>()});
    size_t block_size = BypassBlockSize[static_cast<size_t>(block_size_mode)];
    assert(input.first.size() % block_size == 0 && input.second.size() % block_size == 0);
    vector<BypassGolden> bypass_golden;
    for (auto i = 0; i < input.first.size() / block_size; i++)
        bypass_golden.emplace_back(BypassGolden(vector<double>(input.first.begin() + i * block_size, input.first.begin() + (i + 1) * block_size),
                                                vector<double>(input.second.begin() + i * block_size, input.second.begin() + (i + 1) * block_size)));
    cout << "Bypass" << endl;
    save_json(file_path + "/bypass_golden", bypass_golden);
}

int main(int argc, char *argv[])
{
    (void)argc;
    (void)argv;
    string fn = "simset.json";
    if (argc > 1)
        fn = argv[1];
    json j = read_json(fn);
    DataCompTestMode mode = static_cast<DataCompTestMode>(find_enum(DataCompTestName, json_to_string(j.at("mode"))));
    string file_path = (argc == 3) ? argv[2] : ".";
    switch (mode)
    {
    case DataCompTestMode::baq:
        test_baq_compressor(j, file_path);
        break;
    case DataCompTestMode::bfpq:
        test_bfpq_compressor(j, file_path);
        break;
    case DataCompTestMode::bypass:
        test_bypass_compressor(j, file_path);
        break;
    default:
        cout << "Mode is not support!" << endl;
        test_bypass_compressor(j, file_path);
        break;
    }
    cout << "C++ done" << endl;
    return 0;
}