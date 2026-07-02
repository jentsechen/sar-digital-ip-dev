#include "utility.h"
#include "baq.h"
#include "baq.cpp"
#include "bfpq.h"
#include "bfpq.cpp"

void save_waveform(const vector<pair<vector<double>, vector<double>>> &decomp_output, string save_file_name)
{
    vector<double> re, im;
    for (size_t i = 0; i < decomp_output.size(); i++)
    {
        re.insert(re.end(), decomp_output[i].first.begin(), decomp_output[i].first.end());
        im.insert(im.end(), decomp_output[i].second.begin(), decomp_output[i].second.end());
    }
    save_json(save_file_name, json({{"re", re}, {"im", im}}));
}

void run_baq_decomp(json data, const BaqCtrl &ctrl, string save_file_name)
{
    BaqDecompressor baq_decomp;
    baq_decomp.setup(ctrl);
    vector<BaqOutput> decomp_input;
    for (size_t i = 0; i < data.size(); i++)
    {
        size_t var_idx = data[i].at("FVarianceAddress"), overflow = data[i].at("fOverFlow");
        pair<vector<size_t>, vector<size_t>> qntz_idx({data[i].find("BAQOutI")->get<vector<size_t>>(), data[i].find("BAQOutQ")->get<vector<size_t>>()});
        decomp_input.emplace_back(BaqOutput(var_idx, overflow, qntz_idx));
    }
    vector<pair<vector<double>, vector<double>>> decomp_output = baq_decomp.apply(decomp_input);
    save_waveform(decomp_output, save_file_name);
}

void run_bfpq_decomp(json data, const BfpqCtrl &ctrl, string save_file_name)
{
    BfpqDecompressor bfpq_decomp;
    auto n_bits_frac_exp = [&]() -> size_t
    {
        if ((ctrl.block_size_mode == BfpqBlockSizeMode::b16 && ctrl.word_length_mode == BfpqWordLenMode::w3) ||
            (ctrl.block_size_mode == BfpqBlockSizeMode::b32))
            return 3;
        return 2;
    };
    bfpq_decomp.setup(ctrl, n_bits_frac_exp());
    vector<BfpqOutput> decomp_input;
    for (size_t i = 0; i < data.size(); i++)
    {
        pair<vector<size_t>, vector<size_t>> sign({data[i].find("signI")->get<vector<size_t>>(), data[i].find("signQ")->get<vector<size_t>>()});
        pair<vector<size_t>, vector<size_t>> mts_idx({data[i].find("MantissaI")->get<vector<size_t>>(), data[i].find("MantissaQ")->get<vector<size_t>>()});
        size_t exp_idx = data[i].at("ce"), scaling_idx = data[i].at("cw");
        decomp_input.emplace_back(BfpqOutput(sign, mts_idx, exp_idx, scaling_idx));
    }
    vector<pair<vector<double>, vector<double>>> decomp_output = bfpq_decomp.apply(decomp_input);
    save_waveform(decomp_output, save_file_name);
}

int main(int argc, char *argv[])
{
    if (argc == 3)
    {
        json j = read_json(argv[1]);
        string save_file_name = argv[2];
        size_t compression = j.at("compression");
        if (compression == 2)
        {
            BfpqCtrl bfpq_ctrl(static_cast<BfpqWordLenMode>(j.find("word_length_mode")->get<int>()),
                               static_cast<BfpqBlockSizeMode>(j.find("block_size_mode")->get<int>()));
            run_bfpq_decomp(j.at("data_field"), bfpq_ctrl, save_file_name);
        }
        else if (compression == 1)
        {
            BaqCtrl baq_ctrl(static_cast<BaqWordLenMode>(j.find("word_length_mode")->get<int>()),
                             static_cast<BaqBlockSizeMode>(j.find("block_size_mode")->get<int>()),
                             static_cast<BaqSegNumMode>(j.find("baq_seg_mode")->get<int>()));
            run_baq_decomp(j.at("data_field"), baq_ctrl, save_file_name);
        }
        else
        {
            cout << "Setting of compression is not supported!" << endl;
        }
    }
    else
    {
        cout << "Number of argument is wrong!" << endl;
    }
    cout << "C++ decompression done!" << endl;
    return 0;
}