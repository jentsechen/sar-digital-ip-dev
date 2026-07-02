#include <fstream>
#include <iostream>
#include <string>
#include "json.hpp"
using json = nlohmann::json;
using namespace std;

#ifndef __utility__
#define __utility__
bool endsWith(const string &mainStr, const string &toMatch)
{
    return (mainStr.size() >= toMatch.size() && mainStr.compare(mainStr.size() - toMatch.size(), toMatch.size(), toMatch) == 0);
}

void save_json(const string fn, const json &j)
{
    if (!j.empty())
    {
        string filename = fn;
        if (!endsWith(filename, ".json"))
            filename = filename + ".json";
        ofstream file(filename, ios::out);
        file << j;
        file.close();
    }
}

bool file_exists(const string &name)
{
    fstream fs(name.c_str(), ios::in);
    return fs.good();
}

inline json read_json(std::string fn)
{
    if (file_exists(fn))
    {
        std::ifstream ifs(fn);
        return json::parse(ifs);
    }
    else
    {
        json j = {};
        return j;
    }
}

template <class T>
vector<T> operator*(const vector<T> &vec_in, T scalar)
{
    vector<T> vec_out(vec_in.size());
    for (auto i = 0; i < vec_in.size(); i++)
        vec_out[i] = vec_in[i] * scalar;
    return vec_out;
}

template <class T>
vector<T> operator*(T scalar, const vector<T> &vec_in)
{
    return vec_in * scalar;
}

template <class T>
vector<T> square(const vector<T> &in)
{
    vector<T> out(in.size());
    for (auto i = 0; i < in.size(); i++)
        out[i] = in[i] * in[i];
    return out;
}

template <class T>
vector<T> operator+(const vector<T> &vec_in1, const vector<T> &vec_in2)
{
    assert(vec_in1.size() == vec_in2.size());
    vector<T> vec_out(vec_in1.size());
    for (auto i = 0; i < vec_in1.size(); i++)
        vec_out[i] = vec_in1[i] + vec_in2[i];
    return vec_out;
}

template <class T>
T sum(const vector<T> &vec_in)
{
    T scalar_out = 0;
    for (auto i = 0; i < vec_in.size(); i++)
        scalar_out += vec_in[i];
    return scalar_out;
}

template <class T>
vector<T> abs(const vector<T> &vec_in)
{
    vector<T> vec_out(vec_in);
    for (auto i = 0; i < vec_in.size(); i++)
        vec_out[i] = abs(vec_in[i]);
    return vec_out;
}

template <class T>
T max(const vector<T> &vec_in)
{
    T scalar_out = vec_in[0];
    for (auto i = 1; i < vec_in.size(); i++)
    {
        if (vec_in[i] > scalar_out)
        {
            scalar_out = vec_in[i];
        }
    }
    return scalar_out;
}

size_t find_enum(vector<string> &v, string str)
{
    vector<string>::iterator it = find(v.begin(), v.end(), str);
    if (it != v.end())
        return it - v.begin();
    else
    {
        cout << "Enum is not found!" << endl;
        return 0;
    }
}

string remove_double_quotes(string input)
{
    string output;
    for (char c : input)
    {
        if (c != '"')
        {
            output += c;
        }
    }
    return output;
}

string json_to_string(json j) { return remove_double_quotes(to_string(j)); }

#endif