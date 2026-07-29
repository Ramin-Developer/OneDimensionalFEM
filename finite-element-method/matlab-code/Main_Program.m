% Legacy compatibility wrapper. Canonical implementation moved to src/matlab.

legacyFile = mfilename('fullpath');
legacyDir = fileparts(legacyFile);
srcDir = fullfile(legacyDir, '..', '..', 'src', 'matlab');

addpath(genpath(srcDir));
run(fullfile(srcDir, 'Main_Program.m'));