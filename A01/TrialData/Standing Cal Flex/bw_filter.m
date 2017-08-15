function[smooth]=bw_filter(data,Fs,Fc,type,order)
% SMOOTH = BW_FILTER(DATA,FS,FC,TYPE,ORDER)
%   This function filters (low-, high-, or band-pass) data
%   using a dual-pass Butterworth digital filter with an order
%   that can be specificed by the user (default is 4th). The
%   cutoff frequency is automatically adjusted to account for
%   the second smoothing pass in the reverse direction.
%
%   The user must provide the raw data to be filtered (DATA),
%   which can be a vector, matrix, or three dimensional array,
%   along with the sampling rate (FS) and cutoff freq (FC), both
%   in Hz. The smoothed data is returned in SMOOTH. Optionally,
%   the user can specify the type of filter ('low','hig', or
%   'bnd'), and the filter order (e.g., 2nd, 4th, 8th, etc).
%
%   Written by Brian Umberger at Univeristy of Kentucky, with
%   contribtutions by Akinori Nagano at RIKEN in Japan.
%
%   Dependencies: filtfilt.m (from signal processing toolbox)


% check to see how many input arguments there are: if there are
% only 3 assume low-pass, dual-pass, 2nd order; if there are only
% 4 assume dual-pass, 2nd order
if nargin == 3
   type = 'low';
   order = 2;
elseif nargin == 4
   order = 2;
end

Fs = Fs./2;                       % nyquist limit
Fc = Fc/(sqrt(2)-1)^(0.5/order);  % adjust Fc for dual-pass
type = lower(type);               % force to lower case text

% deteremine coefs for butterworth filter
if type == 'low'
    [B,A]=butter(order,Fc/Fs);              % low-pass filter.
elseif type == 'hig'
    [B,A]=butter(order,Fc/Fs,'high');       % high-pass filter. 
else
    [B,A]=butter(order,Fc/Fs);              % bandpass filter.
end

% filter the raw data
[rows columns layers] = size(data);
for j = 1:columns
  for k = 1:layers 
    smooth(:,j,k) = filtfilt(B,A,data(:,j,k));
  end
end
