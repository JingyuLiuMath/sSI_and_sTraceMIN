function [res, R, res_col] = evp_residuals_diag(A, normA, X, d, nev, full_res)
% full_res selects all residual columns (1) or the first nev columns (0).
% res always measures the first nev columns; res_col contains column residuals.

if ~full_res
    X = X(:, 1 : nev);
    d = d(1 : nev);
end

R = A * X - X .* d.';
normd = max(abs(d(1 : nev)));

if nargout > 2
    R_norm = vecnorm(R(:, 1 : nev));
    X_norm = vecnorm(X(:, 1 : nev));

    res_col = R_norm ./ X_norm ./ (normA + normd);
    res = norm(R_norm) / norm(X_norm) / (normA + normd);
else
    res = norm(R(:, 1 : nev), "fro") ...
        / norm(X(:, 1 : nev), "fro") ...
        / (normA + normd);
end

end