# sSI and sTraceMIN

MATLAB implementations of subspace iteration (SI), TraceMIN (TrMIN), and their sketched variants, sSI and sTrMIN, for computing the smallest eigenpairs of real symmetric positive definite matrices.

The sketched methods use sketch-based basis whitening and an ordered real Schur decomposition of the projected matrix. They finish with Euclidean QR and ordinary Rayleigh–Ritz extraction. This repository contains the four solvers, their shared utilities, and experiments for convergence, runtime, and projection/sketch costs.

## Repository structure

```text
src/
  SI/                        SI and sSI
  RR/                        RR and sRR
  TrMIN/                     TrMIN and sTrMIN
  linearsolvers/             Batched GMRES implementations
  tools/                     Sketches, residuals, locking, and ordering helpers
matrices/                    Benchmark matrices and FileSVDExp
test/                        SI/sSI and TrMIN/sTrMIN comparison scripts
experiments/
  SI/                        SI/sSI experiments, tables, and plots
  TrMIN/                     TrMIN/sTrMIN experiments, tables, and plots
  explore_apply_projection/  Standard and sketched projection timings
  direct_or_update/          Direct computation versus cached updates
sbatch/                      Slurm submission scripts
report/                      Generated comparison logs and figures
setuppath.m                  Add source, matrices, tests, and experiments to the path
```

## Requirements and setup

Use MATLAB with support for `decomposition`, string arrays, and `exportgraphics`. The Slurm scripts currently request MATLAB R2026a. The solver functions use MATLAB's built-in numerical routines; Slurm and environment modules are needed only for cluster submission.

Open MATLAB in the repository root and run:

```matlab
setuppath;
```

`setuppath` locates the repository from its own file location. Run experiment scripts from their corresponding experiment directories so their relative data and figure paths resolve correctly.

## Quick start

From the repository root, run one of the existing comparison scripts:

```matlab
setuppath;
test_sSI;       % Compare SI and sSI
% test_sTrMIN;  % Compare TrMIN and sTrMIN instead
```

The scripts use their configured benchmark matrices and save console logs and PNG/PDF residual plots under `report/<script_name>/<timestamp>/`.

## Solver inputs and outputs

Each solver returns an `n`-by-`nev` matrix `X`, an ascending vector of Ritz values `d`, and an information structure `info`.

| Input | Meaning |
| --- | --- |
| `A` | Explicit real symmetric positive definite matrix, sparse or dense |
| `X0` | Initial full-column-rank basis of size `n`-by-`nex`, with `nev <= nex <= n` |
| `nev` | Number of requested eigenpairs |
| `S` | Fixed linear function handle mapping a block `Y` to its sketch `S(Y)` |
| `LinSolver` | Correction solver with the interface `[Delta, solver_info] = LinSolver(Afun, B)` |
| `opts.tol` | Outer residual tolerance |
| `opts.maxiter` | Maximum number of outer iterations, including the initial extraction |
| `opts.alpha` | Required by sSI/sTrMIN; the sketch stopping threshold is `opts.alpha * opts.tol` |

The soft-locking threshold is `opts.tol / 100` for SI/TrMIN and `opts.alpha * opts.tol / 100` for sSI/sTrMIN.

The sketch must have full column rank on the bases being whitened. For the supplied `sparse_sign(s, n)`, choose `nex <= s <= n`. Keep the same sketch throughout each solve because the sketched methods cache basis and image sketches.

`myGMRES_fix` performs five GMRES steps for each right-hand side. To choose another step count, use:

```matlab
inner_maxiter = 10;
LinSolver = @(Afun, B) myGMRES(Afun, B, inner_maxiter);
```

Changing `inner_maxiter` alone does not change `myGMRES_fix`. A custom correction solver must return `solver_info.t_gmres_orth`, `solver_info.t_gmres_apply`, and `solver_info.t_gmres_solve`, which the outer solvers accumulate.

| `info` field | Meaning |
| --- | --- |
| `iter` | Number of outer iterations |
| `reason` | `"converged"`, `"sketched_converged"`, or `"maximum_iteration"` |
| `res_hist` | Original-space residual history for SI/TrMIN; sketch-space residual history for sSI/sTrMIN |
| `final_res` | Normalized original-space block residual recomputed from the returned eigenpairs |
| `nlock_hist` | Number of soft-locked columns at each iteration |
| `t_total` | Solver-owned total runtime in seconds |
| Other `t_*` fields | Timings of individual operations; GMRES timings are subdivisions of correction time |

Use `info.final_res` to assess the final accuracy of all four methods. For sSI/sTrMIN, `"sketched_converged"` reports the sketch stopping test; check the returned original-space residual against the desired tolerance as well.

## Benchmark matrices and comparison scripts

The benchmark loader [FileSVDExp.m](matrices/FileSVDExp.m) reads `Problem.A` from a MAT file and applies a diagonal shift when indicated by its smallest-eigenvalue estimate and spectral floor. Results produced through this loader refer to the resulting shifted matrix. Its second output is the identity matrix; the four solvers operate on standard eigenvalue problems.

## Experiments, tables, and plots

Edit [exp_SI_settings.m](experiments/SI/exp_SI_settings.m) or [exp_TrMIN_settings.m](experiments/TrMIN/exp_TrMIN_settings.m) to choose matrices, dimensions, tolerance, repetitions, sketch factors, and output paths. The settings scripts clear workspace variables, so configure them in the files before running the experiment entry points.

Run SI/sSI experiments and then generate tables and residual plots:

```matlab
% From the repository root after setuppath:
cd('experiments/SI');
exp_SI;
exp_sSI;
print_SI;
plot_res_SI;
cd('../..');
```

Run TrMIN/sTrMIN in the same way:

```matlab
cd('experiments/TrMIN');
exp_TrMIN;
exp_sTrMIN;
print_TrMIN;
plot_res_TrMIN;
cd('../..');
```

The experiment scripts save MAT files containing per-run results. The table and residual-plot scripts select the run with median total runtime. Tables report the final original-space residual; plots label sketched histories as `sres`.

For runtime breakdowns, run `plot_ratios_SI` or `plot_ratios_TrMIN` from the corresponding directory after generating the selected data. These scripts currently select matrix indices `[2, 6, 8, 10, 12]`; align their `fileNo_list` with the completed experiments before plotting.

Additional experiment entry points are:

| Directory | Entry points | Purpose |
| --- | --- | --- |
| [explore_apply_projection](experiments/explore_apply_projection/) | `exp_apply_orth_proj`, `exp_apply_sketched_proj`, `plot_projection_parts` | Time sketching, coefficient formation, back multiplication, subtraction, and total projection cost |
| [direct_or_update](experiments/direct_or_update/) | `exp_direct_or_update` | Compare direct computation and updates of `SX`, `AX`, and `SAX` |

Run each entry point from its own directory and configure the accompanying settings file. The projection plot also has its own matrix selection.

Run both `exp_apply_orth_proj` and `exp_apply_sketched_proj` before `plot_projection_parts`, which reads their separate `apply_orth_proj_results_*` and `apply_sketched_proj_results_*` files.

## License

The source code is distributed under the [MIT License](LICENSE).
