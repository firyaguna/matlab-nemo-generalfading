function [ sinr ] = sim_Downlink( sim )
%SIM_DOWNLINK received power chain simulation
%   (c) CONNECT Centre, 2018
%   Trinity College Dublin
%
%   This function computes each gain on the received power
%       - Transmit power
%       - Path loss
%       - Body attenuation
%       - Directivity gain
%       - Fading
%   It outputs the received power of 4 different scenarios:
%       - No fading / min. distance cell association
%       - No fading / max. received power cell association
%       - With fading / min. distance cell association
%       - With fading / max. received power cell association
%
%   Author: Fadhil Firyaguna
%           PhD Student Researcher


    % DOWNLINK TRANSMIT POWER
    % Transmit power per area is constant
    rxPower = sim.txPower;

    % PATH LOSS
    rxPower = rxPower .* sim.PathLoss( ...
                            sim.distance3d,...
                            sim.p0_dB,...
                            sim.attenuationExponent );

    % LOS BALL
    %     Yet due to the significant difference inthe signal strength from
    %     both types of transmitters, we assume that the impact of both 
    %     serving and interfering NLOS devices can be ignored.
    inBall = sim.distance2d < sim.losBallRadius;
    rxPower = rxPower .* inBall;
        
              
                        
    % SMALL-SCALE FADING
    rxPower = rxPower .* sim.FadingGain( ...
                            sim.fadingModel,...
                            size(rxPower),...
                            blockedAps,...
                            1 + ( sim.distanceToUserBody > 0 ) );
                        
    % CELL ASSOCIATION
    % Get the closest AP
    [ ~, servingAP_id_minDist ] = min( sim.distance2d );
    
    % DIRECTIVITY GAIN
    rxPower = rxPower .* sim.DirectivityGain( ...,...
                            size(rxPower),...
                            servingAP_id_minDist,...
                            sim.probBeamAlignment,...
                            sim.sideLobeGainTx,...
                            sim.mainLobeGainTx,...
                            sim.sideLobeGainRx,...
                            sim.mainLobeGainRx );   
    
    % -------------------- WITH FADING ------------------------
    % INTERFERENCE
    interfPower_minDist = rxPower;

    % serving AP is not interferer
    interfPower_minDist( servingAP_id_minDist ) = 0;

    % RECEIVED SINR
    sinr.fading.minDist = rxPower( servingAP_id_minDist ) ./ ...
        ( sim.noisePower + sum( interfPower_minDist ) );

end

