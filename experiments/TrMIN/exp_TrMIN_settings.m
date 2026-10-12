clear;
close all;

if ispc || ismac
    data_path = "./data/";
elseif isunix
    data_path = "/scratch/jyliu/sEVP/TrMIN/data/";
end
if ~isfolder(data_path)
    mkdir(data_path);
end

figure_prefix = "./figure/TrMIN";

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
    fileNo_list = 1 : 2;
elseif isunix
    fileNo_list = 1 : length(MatNames);
    % fileNo_list = 1 : 11;
    % fileNo_list = 12;
end

opts = struct();
opts.tol = 1e-10;
opts.maxiter = 1000;
inner_maxiter = 5;
% LinSolver = @(Afun, b) myGMRES(Afun, b, inner_maxiter);
LinSolver = @(Afun, b) myGMRES_fix(Afun, b);

% nev_func = @(n) min(500, max(100, ceil(n / 100)));
nev_func = @(n) 100;
nex_func = @(n, nev) min(n, ceil(1.5 * nev));

if ispc || ismac
    s_factor_list = [2, 4];
    alpha_list = [1.0, 1.0];
    % s_factor_list = [2];
    % alpha_list = [1.0];
    % s_factor_list = [4];
    % alpha_list = [1.0];
elseif isunix
    s_factor_list = [2, 4, 8];
    alpha_list = [1.0, 1.0, 1.0];
    % s_factor_list = [2];
    % alpha_list = [1.0];
    % s_factor_list = [4];
    % alpha_list = [1.0];
    % s_factor_list = [8];
    % alpha_list = [1.0];
end

if ispc || ismac
    num_repeat = 1;
elseif isunix
    num_repeat = 3;
end

seed_list = 0 : (num_repeat - 1);
