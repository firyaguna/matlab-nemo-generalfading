% kappamu_pdf.m - evaluates a Kappa - Mu Probability Density.
%   See "The Kappa - Mu Distribution: A General Fading Distribution", 
%   M. D. Yacoub, U. Campinas, IEEE 2001.
%
%   Vector Form of PDF !!!
%
%  Created by Jim Huntley,  09/19/06
%

function [pdf] = kappamu_pdf(x, kappa, mu)


arg = 1+kappa;
tmu = 2 * mu;
coef = tmu * arg^(0.5*(mu+1))/ (kappa^(0.5*(mu-1))*exp(kappa*mu));

pdf = coef .* exp(-mu.*arg.*x.^2) .* x.^mu .* besseli(mu-1,tmu.*sqrt(kappa.*arg).*x);

end