function varargout = Basis_Shape_Func(varargin)
% Legacy compatibility wrapper. Canonical implementation moved to src/matlab.

originalFolder = pwd;
cleanupObj = onCleanup(@() cd(originalFolder));
cd(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'src', 'matlab'));

[varargout{1:nargout}] = Basis_Shape_Func(varargin{:});
end