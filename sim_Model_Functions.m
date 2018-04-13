%% DIRECTIVITY GAIN MODEL
SideLobeGain = @(beamWidth) ( 1 - 2*pi .* beamWidth )...
                            ./( beamWidth .* (2*pi - beamWidth) );

sim.DirectivityGain = @(servingAp,m,M) ...
    model_DirectivityGain( servingAp, m, M );

% Probabilities of beam alignment
probMM = 1;     % both aligned
probMm = 1;     % tx aligned only
probmM = 1;     % rx aligned only
probmm = 1;     % none aligned
sim.probBeamAlignment = [probMM, probMm, probmM, probmm];

%% PATH LOSS MODEL
sim.PathLoss = @(d,p0_dB,n) db2pow( -p0_dB ) .* d .^( -n );

%% FADING MODEL
sim.FadingGain = @(model,size,nlos,hold) ...
    model_FadingGain( model, size, nlos, hold );