clear;
close all;
rng(0);

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

FileNames = MatNames + '.mat';

maxiter = 300;
tol = 1e-10;

if ispc || ismac
    fileNo_list = 1 : 3;
elseif isunix
    fileNo_list = 1 : 12;
end

% Save each run separately, independently of the current working directory.
project_dir = fileparts(fileparts(mfilename('fullpath')));
run_name = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS'));
output_dir = fullfile(project_dir, 'report', mfilename, run_name);
mkdir(output_dir);
log_path = fullfile(output_dir, "console_output.txt");
diary(log_path);

fprintf("Text output will be saved to: %s\n", log_path);
fprintf("Figures will be saved to: %s\n", output_dir);

figure_visible = 'off';
if usejava('desktop')
    figure_visible = 'on';
end

for fileNo = fileNo_list

    mat_name = MatNames(fileNo);
    disp(mat_name);

    [A, ~] = FileSVDExp(FileNames(fileNo));

    % initial guess
    n = size(A, 1);
    nev = 100;
    nex = ceil(1.5 * nev);
    X = randn(n, nex);

    % sketch
    s = 2 * nex;
    S_mat = sparse_sign(s, n);
    S = @(Y) S_mat * Y;

    alpha = 1.0;

    % opts
    opts = struct();
    opts.tol = tol;
    opts.maxiter = maxiter;

    % Use the same RNG state for the standard and sketched methods.
    solver_rng = rng;

    % standard method
    opts_si = opts;
    [~, ~, info_SI] = SI(A, X, nev, opts_si);
    fprintf("SI\n");
    fprintf("  time: %.1e\n", info_SI.t_total);
    fprintf("  reason: %s\n", info_SI.reason);
    fprintf("  iteration number: %d\n", info_SI.iter);
    fprintf("  relative residual: %.1e\n", info_SI.final_res);
    fprintf("  decomp time: %.1e\n", info_SI.t_decomp);

    % sketched method
    rng(solver_rng);
    opts_ssi = opts;
    opts_ssi.alpha = alpha;
    [~, ~, info_sSI] = sSI(A, S, X, nev, opts_ssi);
    fprintf("sSI\n");
    fprintf("  alpha: %.1e\n", alpha);
    fprintf("  time: %.1e\n", info_sSI.t_total);
    fprintf("  reason: %s\n", info_sSI.reason);
    fprintf("  iteration number: %d\n", info_sSI.iter);
    fprintf("  relative residual: %.1e\n", info_sSI.final_res);
    fprintf("  decomp time: %.1e\n", info_sSI.t_decomp);

    % plot
    fig = figure('Visible', figure_visible, 'Color', 'w');

    semilogy(1 : info_SI.iter, info_SI.res_hist, '-o', 'linewidth', 2, ...
        "DisplayName", "SI (res)");
    hold on;
    semilogy(1 : info_sSI.iter, info_sSI.res_hist, '-x', 'linewidth', 2, ...
        "DisplayName", "sSI (sres)");

    legend;
    xlabel('Iteration');
    ylabel('Relative residual');
    title(mat_name, 'Interpreter', 'none');

    figure_path = fullfile(output_dir, mat_name + "_res_hist");
    exportgraphics(fig, figure_path + ".pdf", 'ContentType', 'vector');
    exportgraphics(fig, figure_path + ".png", 'Resolution', 300);
    fprintf('Saved: %s.pdf\n       %s.png\n', figure_path, figure_path);
    if strcmp(figure_visible, 'off')
        close(fig);
    end

end

fprintf("Text output saved to: %s\n", log_path);
diary off;
