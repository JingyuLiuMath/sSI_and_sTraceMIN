function [Z, T]= sRR(SX, SAX)

% SX must be orthonormal.

% Construct projected matrix Ap
Ap = SX' * SAX;

% Schur decomposition, ascending order eig
[Z, T] = ordered_real_schur(Ap);

end