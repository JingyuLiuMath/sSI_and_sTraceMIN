function [res, SR, res_col] = evp_sresiduals_schur(normA, SX, SAX, T, nev, full_res)
% full_res selects all residual columns (1) or the first nev columns (0).
% res always measures the first nev columns; res_col contains prefix residuals.
% The caller must choose nev at a complete real Schur block boundary.

if ~full_res
   SX = SX(:, 1 : nev);
   SAX = SAX(:, 1 : nev);
   T = T(1 : nev, 1 : nev);
end

SR = SAX - SX * T;
normT = norm(T(1 : nev, 1 : nev));
if nargout > 2
    SR_fro = sqrt(cumsum(sum(abs(SR(:, 1 : nev)).^2, 1)));
    SX_fro = sqrt(cumsum(sum(abs(SX(:, 1 : nev)).^2, 1)));
    res_col = SR_fro ./ SX_fro ./ (normA + normT);
    res = res_col(end);
else
    res = norm(SR(:, 1 : nev), "fro") ...
        ./ norm(SX(:, 1 : nev), "fro") ...
        ./ (normA + normT);
end

end
