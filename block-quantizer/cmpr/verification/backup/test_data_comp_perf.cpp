// #include "SAR/data_comp/data_comp.h"
// #include "SAR/data_comp/data_comp.cpp"
// #include "SAR/paa_model/paa_model.h"
#include <commlib/commlib_inc.h>
#include "SAR/data_comp/bfpq/bfpq.h"
#include "SAR/data_comp/bfpq/bfpq.cpp"
// #include "SAR/data_comp/bfpq/bfpq_module.h"
#include "SAR/data_comp/baq/baq.h"
#include "SAR/data_comp/baq/baq.cpp"
// #include "SAR/data_comp/baq/baq_module.h"
using namespace SAR;

ENUM_Class(eDataCompTestMode, baq, bfpq);

void run_bfpq_decomp(json data, const BFPQ_Ctrl& ctrl, string save_file_name) {
    BFPQ_Decompressor bfpq_decomp;
    def n_bits_frac_exp = [&]() -> size_t {
        if ((ctrl.block_size_mode == eSAR_BFPQ_BlockSizeMode::b16 && ctrl.word_length_mode == eSAR_BFPQ_WordLenMode::w3) ||
            (ctrl.block_size_mode == eSAR_BFPQ_BlockSizeMode::b32))
            return 3;
        return 2;
    };
    bfpq_decomp.setup(ctrl, n_bits_frac_exp());
    VEC<BFPQ_Output> decomp_input;
    def veci2vecb = [&](const veci& in) {
        vecb out;
        for (auto i : range(in.size())) out.emplace_back(in[i]);
        return out;
    };
    for (auto i : range(data.size())) {
        pair<vecb, vecb> sign({veci2vecb(data[i].find("signI")->get<veci>()), veci2vecb(data[i].find("signQ")->get<veci>())});
        pair<vect, vect> mts_idx({data[i].find("MantissaI")->get<vect>(), data[i].find("MantissaQ")->get<vect>()});
        size_t exp_idx = data[i].at("ce"), scaling_idx = data[i].at("cw");
        decomp_input.emplace_back(BFPQ_Output(sign, mts_idx, exp_idx, scaling_idx));
    }
    VEC<pair<vecf, vecf>> decomp_output = bfpq_decomp.apply(decomp_input);
    vecf re, im;
    for (auto i : range(decomp_output.size())) {
        re.insert(re.end(), decomp_output[i].first.begin(), decomp_output[i].first.end());
        im.insert(im.end(), decomp_output[i].second.begin(), decomp_output[i].second.end());
    }
    save_json(save_file_name, JSON(re, im));
}

void run_baq_decomp(json data, const BAQ_Ctrl& ctrl, string save_file_name) {
    BAQ_Decompressor baq_decomp;
    baq_decomp.setup(ctrl);
    VEC<BAQ_Output> decomp_input;
    def veci2vecb = [&](const veci& in) {
        vecb out;
        for (auto i : range(in.size())) out.emplace_back(in[i]);
        return out;
    };
    for (auto i : range(data.size())) {
        size_t var_idx = data[i].at("FVarianceAddress"), overflow = data[i].at("fOverFlow");
        pair<vect, vect> qntz_idx({data[i].find("BAQOutI")->get<vect>(), data[i].find("BAQOutQ")->get<vect>()});
        decomp_input.emplace_back(BAQ_Output(var_idx, overflow, qntz_idx));
    }
    VEC<pair<vecf, vecf>> decomp_output = baq_decomp.apply(decomp_input);
    vecf re, im;
    for (auto i : range(decomp_output.size())) {
        re.insert(re.end(), decomp_output[i].first.begin(), decomp_output[i].first.end());
        im.insert(im.end(), decomp_output[i].second.begin(), decomp_output[i].second.end());
    }
    save_json(save_file_name, JSON(re, im));
}

int main(int argc, char* argv[]) {
    (void)argc;
    (void)argv;
    if (argc == 3) {
        json j = read_json(argv[1]);
        string save_file_name = argv[2];
        size_t compression = j.at("compression");
        if (compression == 2) {
            BFPQ_Ctrl bfpq_ctrl(static_cast<eSAR_BFPQ_WordLenMode>(j.find("word_length_mode")->get<int>()),
                                static_cast<eSAR_BFPQ_BlockSizeMode>(j.find("block_size_mode")->get<int>()));
            run_bfpq_decomp(j.at("data_field"), bfpq_ctrl, save_file_name);
        }
        else if (compression == 1) {
            BAQ_Ctrl baq_ctrl(static_cast<eSAR_BAQ_WordLenMode>(j.find("word_length_mode")->get<int>()),
                              static_cast<eSAR_BAQ_BlockSizeMode>(j.find("block_size_mode")->get<int>()),
                              static_cast<eSAR_BAQ_SegNumMode>(j.find("baq_seg_mode")->get<int>()));
            run_baq_decomp(j.at("data_field"), baq_ctrl, save_file_name);
        }
        else {
            disp("Setting of compression is not support!");
        }
    }
    else {
        disp("Lack of argument!");
    }
    disp("C++ done");
    return 0;
}