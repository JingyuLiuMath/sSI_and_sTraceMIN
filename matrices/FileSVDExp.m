function [A, B] = FileSVDExp(filename)

data = load(filename, "Problem");
A = data.Problem.A;

[n] = size(A, 1);

scaleA = norm(A, inf);
[~, Dmin] = eigs(A, 1, 'smallestreal');
el = real(Dmin(1, 1));

shift_rel = 1e-4;
lambda_floor = shift_rel * scaleA;
shift = max([0, -1.05 * el, lambda_floor - el]);

if shift > 0
    A = A + shift * speye(size(A, 1));
end

B = speye(n);
