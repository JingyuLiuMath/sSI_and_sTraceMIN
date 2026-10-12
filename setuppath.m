function setuppath()

root_path = fileparts(mfilename("fullpath"));

src_path = fullfile(root_path, "src");
addpath(genpath(src_path));
data_path = fullfile(root_path, "matrices");
addpath(genpath(data_path));
data_path = fullfile(root_path, "test");
addpath(genpath(data_path));
exp_path = fullfile(root_path, "experiments");
addpath(genpath(exp_path));

end