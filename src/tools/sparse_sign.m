function S = sparse_sign(s, N)
%SPARSE_SIGN Construct an s-by-N sparse-sign embedding.
%   Every column has zeta=min(s,8) nonzeros in uniformly sampled distinct
%   rows. Their independent Rademacher signs are scaled by 1/sqrt(zeta), so
%   every column has unit Euclidean norm. Random entries use RAND and
%   RANDPERM directly.

if s > N
    error("sparse_sign:s must be less than or equal to N!");
end

zeta = min(s, 8);
nnz_total = N * zeta;
row_indices = zeros(nnz_total, 1);
column_indices = zeros(nnz_total, 1);
values = zeros(nnz_total, 1);

pointer = 1;
for j = 1 : N
    selected_rows = randperm(s, zeta);
    signs = 2 * (rand(zeta, 1) >= 0.5) - 1;

    entries = pointer : (pointer + zeta - 1);
    row_indices(entries) = selected_rows;
    column_indices(entries) = j;
    values(entries) = signs;
    pointer = pointer + zeta;
end

values = values / sqrt(zeta);

S = sparse(row_indices, column_indices, values, s, N);

end
