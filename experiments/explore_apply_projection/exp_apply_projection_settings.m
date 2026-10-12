clear;
close all;

if ispc || ismac
    data_path = "./data/";
elseif isunix
    data_path = "/scratch/jyliu/sEVP/explore_apply_projection/data/";
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
fileNo_list = 1 : length(MatNames);

nex = 150;
nrhs_list = [100, 150];
s_factor_list = [2, 4, 8];

if ispc || ismac
    num_repeat = 1;
elseif isunix
    num_repeat = 3;
end

seed_list = 0 : (num_repeat - 1);
