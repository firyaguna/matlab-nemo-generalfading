function [ random_gain ] = model_KappaMuFadingGain( kappa, mu, size )
%KAPPAMU_FADING_POWER_GAIN Summary of this function goes here
%   Detailed explanation goes here

gain = linspace(0,3);
a_pdf = model_KappaMuPdf( gain, kappa, mu );
a_pdf = a_pdf / sum(a_pdf);
a_cdf = cumsum( a_pdf );
% remove non-unique elements
[a_cdf, mask] = unique( a_cdf );
gain = gain(mask);

% create array of random numbers
randomValues = rand(size);

% inverse interpolation
random_amplitude_gain = interp1( a_cdf, gain, randomValues );

random_gain = random_amplitude_gain .^ 2;

end

