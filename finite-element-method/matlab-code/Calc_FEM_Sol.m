function varargout = Calc_FEM_Sol(varargin)
% Legacy compatibility wrapper. Canonical implementation moved to src/matlab.

originalFolder = pwd;
cleanupObj = onCleanup(@() cd(originalFolder));
cd(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'src', 'matlab'));

[varargout{1:nargout}] = Calc_FEM_Sol(varargin{:});
end