function [Z, d] = RR(A, X)

% X must be orthonormal.

% Construct projected matrix Ap
AX = A * X;
Ap = X' * AX;
Ap = (Ap' + Ap) / 2;

% Eigen decomposition, ascending order eig
[Z, d] = ordered_sym_eig(Ap);

end