// #include <deslib/deslib_inc.h>
// #include "SAR/data_comp/bfpq/bfpq.h"
// #include "SAR/data_comp/bfpq/bfpq.cpp"
// #include "SAR/data_comp/bfpq/bfpq_module.h"
// #include "SAR/data_comp/baq/baq.h"
// #include "SAR/data_comp/baq/baq.cpp"
// #include "SAR/data_comp/baq/baq_module.h"
#include "SAR/data_comp/data_comp.h"
#include "SAR/data_comp/data_comp.cpp"
#include "SAR/paa_model/paa_model.h"
#include <dsplib/fft/fft_ctrl_unit.h>
#include <dsplib/fft/fft.h>
using namespace SAR;

ENUM_Class(eDataCompTestMode, baq, bfpq, bypass);
ENUM_Class(eBAQ_Perf, n_234, n_68);

ENUM_Class(eSAR_Bypass_BlockSizeMode, b8, b16, b32, b64);

struct Read_LUT_Verilog : ToJson {
    // static constexpr size_t bit_len = 12;
    // vecf base;
    json look_up_table;
    vecf qntz_max_list, qntz_step_list;
    vect mantissa_list = vect({2, 3, 4, 6, 8});
    Read_LUT_Verilog() {
        // base.clear();
        // for (size_t i = 0; i < 5; i++) base.emplace_back((1 << (4 - i)));        // decimal point
        // for (size_t i = 0; i < 15; i++) base.emplace_back(1.0 / (1 << (i + 1))); // decimal point
        look_up_table = read_json("/workspaces/bbsysdev/source/cpp/test/SAR/data_comp/look_up_table_verilog.json");
    }
    // double read_qntz_max(size_t idx) {
    //     string qntz_max_string = look_up_table["qntz_max"][idx];
    //     reverse(qntz_max_string.begin(), qntz_max_string.end());
    //     bitset<bit_len> qntz_max_bitset = bitset<bit_len>(qntz_max_string);
    //     double qntz_max_double = 0.0;
    //     for (size_t i = 0; i < bit_len; i++) qntz_max_double += qntz_max_bitset[i] * base[i + 4]; // decimal point
    //     return qntz_max_double;
    // }
    double read_one_threshold(size_t index) {
        string threshold_string = look_up_table.at("threshold").at(index);
        reverse(threshold_string.begin(), threshold_string.end());
        bitset<12> threshold_bitset = bitset<12>(threshold_string);
        double threshold_double = 0.0;
        for (size_t i = 0; i < 12; i++) threshold_double += threshold_bitset[i] / pow(2.0, i + 1);
        return threshold_double;
    }
    vecf read_all_threshold() {
        vecf threshold;
        for (size_t i = 0; i < look_up_table.at("threshold").size(); i++) {
            threshold.emplace_back(read_one_threshold(i));
        }
        return threshold;
    }
};

struct BfpqGolden : ToJson {
    vect MantissaI, MantissaQ, signI, signQ;
    size_t ce, cw;
    BfpqGolden(const vect& MantissaI, const vect& MantissaQ, const vect& signI, const vect& signQ, size_t ce, size_t cw)
        : MantissaI(MantissaI), MantissaQ(MantissaQ), signI(signI), signQ(signQ), ce(ce), cw(cw) {}
    ToJsonIO(MantissaI, MantissaQ, signI, signQ, ce, cw);
};

void test_bfpq_compressor(json j, string file_path) {
    // // eSAR_BFPQ_WordLenMode word_length_mode = j.at("bfpq_word_length_mode");
    // eSAR_BFPQ_BlockSizeMode block_size_mode = j.at("bfpq_block_size_mode");
    // vecf var_db_list = j.at("var_db_list");
    // size_t sig_size = j.at("sig_size");
    // VEC<eSAR_BFPQ_WordLenMode> word_length_mode_list;
    // if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b8) {
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w8);
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w6);
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w4);
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w3);
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w2);
    // }
    // if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b16) {
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w8);
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w6);
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w4);
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w3);
    // }
    // if (block_size_mode == eSAR_BFPQ_BlockSizeMode::b32) {
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w8);
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w6);
    //     word_length_mode_list.emplace_back(eSAR_BFPQ_WordLenMode::w4);
    // }

    // SAR_DataComp sar_data_comp;
    // matf sqnr_db_list_with_adc, sqnr_db_list_no_adc;
    // for (size_t i = 0; i < word_length_mode_list.size(); i++) {
    //     BFPQ_Ctrl bfpq_ctrl(word_length_mode_list[i], block_size_mode);
    //     pair<vecf, vecf> sqnr_db_list = sar_data_comp.cal_sqnr(bfpq_ctrl, var_db_list, sig_size);
    //     sqnr_db_list_with_adc.emplace_back(sqnr_db_list.first);
    //     sqnr_db_list_no_adc.emplace_back(sqnr_db_list.second);
    // }
    // json sqnr_db_list = JSON(sqnr_db_list_with_adc, sqnr_db_list_no_adc);
    // SAVE(sqnr_db_list);

    eSAR_BFPQ_WordLenMode word_length_mode = j.at("word_length_mode");
    eSAR_BFPQ_BlockSizeMode block_size_mode = j.at("block_size_mode");
    pair<vecf, vecf> input({j.at("input").find("I")->get<vecf>(), j.at("input").find("Q")->get<vecf>()});
    BFPQ_Ctrl bfpq_ctrl(word_length_mode, block_size_mode);
    BFPQ_Compressor bfpq_compressor;
    bfpq_compressor.setup(bfpq_ctrl);
    VEC<BFPQ_Output> bfpq_comp_out = bfpq_compressor.apply(input);
    VEC<BfpqGolden> bfpq_golden;
    def vecb2vect = [&](const vecb& input) {
        vect output(input.size());
        for (auto i : range(input.size())) output[i] = input[i] ? 1 : 0;
        return output;
    };
    for (auto i : range(bfpq_comp_out.size())) {
        bfpq_golden.emplace_back(BfpqGolden(bfpq_comp_out[i].mts_idx.first, bfpq_comp_out[i].mts_idx.second, vecb2vect(bfpq_comp_out[i].sign.first),
                                            vecb2vect(bfpq_comp_out[i].sign.second), bfpq_comp_out[i].exp_idx, bfpq_comp_out[i].scaling_idx));
    }
    disp("BFPQ");
    save_json(file_path, "bfpq_golden", bfpq_golden);
}

struct BaqGolden : ToJson {
    vect BAQOutI, BAQOutQ;
    size_t FVarianceAddress, fOverFlow;
    BaqGolden(const vect& BAQOutI, const vect& BAQOutQ, size_t FVarianceAddress, size_t fOverFlow)
        : BAQOutI(BAQOutI), BAQOutQ(BAQOutQ), FVarianceAddress(FVarianceAddress), fOverFlow(fOverFlow) {}
    ToJsonIO(BAQOutI, BAQOutQ, FVarianceAddress, fOverFlow);
};

void test_baq_compressor(json j, string file_path) {
    // eBAQ_Perf baq_perf = j.at("baq_perf");
    // // eSAR_BAQ_WordLenMode word_length_mode = j.at("baq_word_length_mode");
    // // eSAR_BAQ_BlockSizeMode block_size_mode = j.at("baq_block_size_mode");
    // eSAR_BAQ_SegNumMode seg_num_mode = j.at("baq_seg_num_mode");
    // // BAQ_Ctrl baq_ctrl(word_length_mode, block_size_mode, seg_num_mode);
    // vecf var_db_list = j.at("var_db_list");
    // size_t sig_size = j.at("sig_size");

    // VEC<eSAR_BAQ_WordLenMode> word_length_mode_list;
    // if (baq_perf == eBAQ_Perf::n_234) word_length_mode_list = {eSAR_BAQ_WordLenMode::w4, eSAR_BAQ_WordLenMode::w3, eSAR_BAQ_WordLenMode::w2};
    // if (baq_perf == eBAQ_Perf::n_68) word_length_mode_list = {eSAR_BAQ_WordLenMode::w8, eSAR_BAQ_WordLenMode::w6};
    // VEC<eSAR_BAQ_BlockSizeMode> block_size_mode_list = {eSAR_BAQ_BlockSizeMode::b128, eSAR_BAQ_BlockSizeMode::b256, eSAR_BAQ_BlockSizeMode::b512};
    // SAR_DataComp sar_data_comp;
    // matf sqnr_db_list;
    // for (size_t i = 0; i < word_length_mode_list.size(); i++) {
    //     for (size_t j = 0; j < block_size_mode_list.size(); j++) {
    //         BAQ_Ctrl baq_ctrl(word_length_mode_list[i], block_size_mode_list[j], seg_num_mode);
    //         pair<vecf, vecf> sqnr_db_list_tmp = sar_data_comp.cal_sqnr(baq_ctrl, var_db_list, sig_size);
    //         sqnr_db_list.emplace_back(sqnr_db_list_tmp.first);
    //     }
    // }
    // SAVE(sqnr_db_list);

    eSAR_BAQ_WordLenMode word_length_mode = j.at("word_length_mode");
    eSAR_BAQ_BlockSizeMode block_size_mode = j.at("block_size_mode");
    eSAR_BAQ_SegNumMode seg_num_mode = j.at("seg_num_mode");
    pair<vecf, vecf> input({j.at("input").find("I")->get<vecf>(), j.at("input").find("Q")->get<vecf>()});
    BAQ_Ctrl baq_ctrl(word_length_mode, block_size_mode, seg_num_mode);
    // ADC_DataGen adc_gen;
    // pair<vecc, vecc> rand_adc_out = adc_gen.apply(1.0, sig_size);
    BAQ_Compressor baq_compressor;
    baq_compressor.setup(baq_ctrl);
    // VEC<BAQ_Output> baq_comp_out = baq_compressor.apply({real(rand_adc_out.second), imag(rand_adc_out.second)});
    VEC<BAQ_Output> baq_comp_out = baq_compressor.apply(input);
    VEC<BaqGolden> baq_golden;
    for (auto i : range(baq_comp_out.size())) {
        baq_golden.emplace_back(BaqGolden(baq_comp_out[i].qntz_idx.first, baq_comp_out[i].qntz_idx.second, baq_comp_out[i].var_idx, baq_comp_out[i].overflow));
    }
    disp("BAQ");
    save_json(file_path, "baq_golden", baq_golden);

    // BAQ_Decompressor baq_decompressor;
    // baq_decompressor.setup(baq_ctrl);
    // VEC<pair<vecf, vecf>> baq_decomp_out = baq_decompressor.apply(baq_comp_out);
}

struct BypassGolden : ToJson {
    vecf BypassOutI, BypassOutQ;
    BypassGolden(const vecf& BypassOutI, const vecf& BypassOutQ) : BypassOutI(BypassOutI), BypassOutQ(BypassOutQ) {}
    ToJsonIO(BypassOutI, BypassOutQ);
};

void test_bypass_compressor(json j, string file_path) {
    eSAR_Bypass_BlockSizeMode block_size_mode = j.at("block_size_mode");
    pair<vecf, vecf> input({j.at("input").find("I")->get<vecf>(), j.at("input").find("Q")->get<vecf>()});
    def block_size_val = [&](eSAR_Bypass_BlockSizeMode block_size_mode) -> size_t
    {
        switch (block_size_mode)
        {
        case eSAR_Bypass_BlockSizeMode::b8:
            return 8;
        case eSAR_Bypass_BlockSizeMode::b16:
            return 16;
        case eSAR_Bypass_BlockSizeMode::b32:
            return 32;
        case eSAR_Bypass_BlockSizeMode::b64:
            return 64;
        default:
            throw runtime_error("Invalid block size mode");
        }
    };
    file_path
        size_t block_size = block_size_val(block_size_mode);
    assert(input.first.size() % block_size == 0 && input.second.size() % block_size == 0);
    VEC<BypassGolden> bypass_golden;
    for (auto i : range(input.first.size() / block_size))
        bypass_golden.emplace_back(BypassGolden(vecf(input.first.begin() + i * block_size, input.first.begin() + (i + 1) * block_size),
                                          vecf(input.second.begin() + i * block_size, input.second.begin() + (i + 1) * block_size)));
    disp("Bypass");
    save_json(file_path, "bypass_golden", bypass_golden);
}

struct FFTMod_vecmode : FFTMod {
    FFTMod_vecmode() { ModuleX::set_local_clock(true); }
    vecc apply(const vecc& data, const vecb& valid) {
        function run_per_cycle = [&](cpx data, bool valid) {
            clock_run();
            FFTMod::apply(data, valid);
            return;
        };
        vecc out_data;
        set_ctrl(log2Ceil(data.size()), true);
        clock_run();
        set_ctrl(0, false);
        for (size_t i = 0; i < data.size() + 50; i++) {
            cpx in_data = (i < data.size()) ? data[i] : cpx(0);
            bool in_valid = (i < data.size()) ? valid[i] : false;
            run_per_cycle(in_data, in_valid);
            if (out.valid) out_data.emplace_back(out.data);
        }
        return out_data;
    }
};

void test_fft() {
    size_t data_len = 16;
    size_t log2_data_len = log2Ceil(data_len);
    vecb valid = vecb(data_len, true);
    vecc data = vecc(data_len, cpx(1));
    FFTMod_vecmode fft;
    fft.init({"fft_module", en_t::off, true, en_t::off});
    qt fft_in_qfmt = qt(true, Signed, 1, 6, Sat, Rnd), fft_twd_qfmt = qt(true, Signed, 1, 6, Sat, Rnd);
    bool bf_reg_en = true, tm_reg_en = true, twf_reg_en = false, cfg_en = false, sqrt_scale = false;
    vect scale_table_fft = vect(log2_data_len, 0), ibit_ctrl_table_fft = vect(log2_data_len, 0);
    size_t mr = 3, cfg_buf_depth = 4;
    fft.setup(data_len, false, cfg_en, false, mr, fft_in_qfmt.en, fft_in_qfmt, fft_twd_qfmt, fft_in_qfmt.msb, fft_in_qfmt.lsb, scale_table_fft,
              ibit_ctrl_table_fft, bf_reg_en, tm_reg_en, twf_reg_en, cfg_buf_depth, sqrt_scale);
    vecc out_data = fft.apply(data, valid);
    print(out_data);
    fft.save("bittrue/fft/");
    fft.save_waveform("bittrue/fft/waveform");
}

int main(int argc, char* argv[]) {
    (void)argc;
    (void)argv;
    string fn = "simset.json";
    if (argc > 1) fn = argv[1];
    // json j = read_json(fn).at("simset");
    json j = read_json(fn);
    eDataCompTestMode mode = j.at("mode");
    string file_path = (argc == 3) ? argv[2] : "./";
    switch (mode) {
    case eDataCompTestMode::baq: test_baq_compressor(j, file_path); break;
    case eDataCompTestMode::bfpq: test_bfpq_compressor(j, file_path); break;
    default: test_bypass_compressor(j, file_path); break;
    }
    // test_fft();
    disp("C++ done");
    return 0;
}