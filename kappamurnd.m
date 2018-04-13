function [ rnd ] = kappamurnd( kappa, mu, s1, s2 )
%KAPPAMURND sample generator of kappa-mu distribution

invpdfKappaMu = @( k, m, u ) 0;

u = rand(s1,s2);
rnd = invpdfKappaMu( kappa, mu , u );

end