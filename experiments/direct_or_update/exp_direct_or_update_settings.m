clear;
close all;

if ispc || ismac
    data_path = "./data/";
elseif isunix
    data_path = "/scratch/jyliu/sEVP/direct_or_update/data/";
end
if ~isfolder(data_path)
    mkdir(data_path);
end

MatNames = ["bcsstm21";  % spd
    "rail_5177";  % -A is spd
    "Muu";  % spd
    "fv1";  % spd
    "shuttle_eddy";  % indefinite and singular
    "barth5";  % indefinite
    "Si5H12";  % indefinite
    "mario001";  % indefinite
    "c-65";  % indefinite but nearly singular
    "Andrews";  % psd and singular
    "Ga3As3H12";  % indefinite
    "Ga10As10H30"];  % indefinite
FileNames = MatNames + ".mat";

if ispc || ismac
    fileNo_list = 1 : length(MatNames);
elseif isunix
    fileNo_list = 1 : length(MatNames);
end

nev_func = @(n) 100;
nex_func = @(n, nev) min(n, ceil(1.5 * nev));
s_factor_list = [2];
seed = 0;
