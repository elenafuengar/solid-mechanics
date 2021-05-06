function [clone,version]=matlab_clone;
% detecta si se esta ejecutando Matlab u Octave
try
   version=OCTAVE_VERSION;
   clone='OCTAVE';
catch
   clone='MATLAB';
   a=ver('matlab');
   version=a.Version;
end