function [x, info] = myGMRES_fix(A, b)

info.t_gmres_orth = 0;
info.t_gmres_apply = 0;
info.t_gmres_solve = 0;

[N, nrhs] = size(b);

if ~isa(A, 'function_handle')
    A = @(x) A*x;
end

% Hessenberg coefficients
H = zeros(6, 5, nrhs);

%--------------------------------------------------------------
% v1
%--------------------------------------------------------------
t_gmres_orth_start = tic;
beta = vecnorm(b);
V1 = b ./ beta;
info.t_gmres_orth = info.t_gmres_orth + toc(t_gmres_orth_start);

%==============================================================
% Step 1
%==============================================================
t_gmres_apply_start = tic;
w = A(V1);
info.t_gmres_apply = info.t_gmres_apply + toc(t_gmres_apply_start);

t_gmres_orth_start = tic;
h = sum(conj(V1) .* w, 1);
H(1,1,:) = reshape(h, 1,1,nrhs);
w = w - V1 .* h;

h = vecnorm(w);
H(2,1,:) = reshape(h, 1,1,nrhs);

V2 = w ./ h;
info.t_gmres_orth = info.t_gmres_orth + toc(t_gmres_orth_start);

%==============================================================
% Step 2
%==============================================================
t_gmres_apply_start = tic;
w = A(V2);
info.t_gmres_apply = info.t_gmres_apply + toc(t_gmres_apply_start);

t_gmres_orth_start = tic;
h = sum(conj(V1) .* w, 1);
H(1,2,:) = reshape(h, 1,1,nrhs);
w = w - V1 .* h;

h = sum(conj(V2) .* w, 1);
H(2,2,:) = reshape(h, 1,1,nrhs);
w = w - V2 .* h;

h = vecnorm(w);
H(3,2,:) = reshape(h, 1,1,nrhs);

V3 = w ./ h;
info.t_gmres_orth = info.t_gmres_orth + toc(t_gmres_orth_start);

%==============================================================
% Step 3
%==============================================================
t_gmres_apply_start = tic;
w = A(V3);
info.t_gmres_apply = info.t_gmres_apply + toc(t_gmres_apply_start);

t_gmres_orth_start = tic;
h = sum(conj(V1) .* w, 1);
H(1,3,:) = reshape(h, 1,1,nrhs);
w = w - V1 .* h;

h = sum(conj(V2) .* w, 1);
H(2,3,:) = reshape(h, 1,1,nrhs);
w = w - V2 .* h;

h = sum(conj(V3) .* w, 1);
H(3,3,:) = reshape(h, 1,1,nrhs);
w = w - V3 .* h;

h = vecnorm(w);
H(4,3,:) = reshape(h, 1,1,nrhs);

V4 = w ./ h;
info.t_gmres_orth = info.t_gmres_orth + toc(t_gmres_orth_start);

%==============================================================
% Step 4
%==============================================================
t_gmres_apply_start = tic;
w = A(V4);
info.t_gmres_apply = info.t_gmres_apply + toc(t_gmres_apply_start);

t_gmres_orth_start = tic;
h = sum(conj(V1) .* w, 1);
H(1,4,:) = reshape(h, 1,1,nrhs);
w = w - V1 .* h;

h = sum(conj(V2) .* w, 1);
H(2,4,:) = reshape(h, 1,1,nrhs);
w = w - V2 .* h;

h = sum(conj(V3) .* w, 1);
H(3,4,:) = reshape(h, 1,1,nrhs);
w = w - V3 .* h;

h = sum(conj(V4) .* w, 1);
H(4,4,:) = reshape(h, 1,1,nrhs);
w = w - V4 .* h;

h = vecnorm(w);
H(5,4,:) = reshape(h, 1,1,nrhs);

V5 = w ./ h;
info.t_gmres_orth = info.t_gmres_orth + toc(t_gmres_orth_start);

%==============================================================
% Step 5
%==============================================================
t_gmres_apply_start = tic;
w = A(V5);
info.t_gmres_apply = info.t_gmres_apply + toc(t_gmres_apply_start);

t_gmres_orth_start = tic;
h = sum(conj(V1) .* w, 1);
H(1,5,:) = reshape(h, 1,1,nrhs);
w = w - V1 .* h;

h = sum(conj(V2) .* w, 1);
H(2,5,:) = reshape(h, 1,1,nrhs);
w = w - V2 .* h;

h = sum(conj(V3) .* w, 1);
H(3,5,:) = reshape(h, 1,1,nrhs);
w = w - V3 .* h;

h = sum(conj(V4) .* w, 1);
H(4,5,:) = reshape(h, 1,1,nrhs);
w = w - V4 .* h;

h = sum(conj(V5) .* w, 1);
H(5,5,:) = reshape(h, 1,1,nrhs);
w = w - V5 .* h;

h = vecnorm(w);
H(6,5,:) = reshape(h, 1,1,nrhs);
info.t_gmres_orth = info.t_gmres_orth + toc(t_gmres_orth_start);

%==============================================================
% GMRES least-squares problems
%==============================================================
t_gmres_solve_start = tic;
x = zeros(size(b));

for irhs = 1:nrhs
    Hnow = H(:,:,irhs);

    e1 = zeros(6,1);
    e1(1) = beta(irhs);

    y = Hnow \ e1;

    x(:,irhs) = ...
        V1(:,irhs) * y(1) ...
        + V2(:,irhs) * y(2) ...
        + V3(:,irhs) * y(3) ...
        + V4(:,irhs) * y(4) ...
        + V5(:,irhs) * y(5);
end
info.t_gmres_solve = info.t_gmres_solve + toc(t_gmres_solve_start);

end
