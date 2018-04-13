% NEMO MAIN SCRIPT
%   (c) CONNECT Centre, 2018
%   Trinity College Dublin
%
%   This script simulates a set of mmW-APs placed in a hexagonal grid where
%   the user equipment (UE) is placed uniformly over the plane. The APs
%   are deployed in the ceiling 'apHeight' meters above the UE, and they
%   are transmitting a fixed directional beam pointed to the floor.
%
%
%   Author: Fadhil Firyaguna
%           PhD Student Researcher

%% PARAMETERS
sim_Model_Parameters;
sim_Model_Functions;

%% INITIALIZE VECTORS
sinr_vector = zeros( numberOfIterations, ...
                       length( beamWidth_vector ), ...
                       length( apHeight_vector ), ...
                       length( interSiteDistance_vector ), ...
                       length( numberOfRandomBodies_vector ), ...
                       length( bodyAttenuation_vector ), ...
                       length( distanceToUserBody_vector ) );
sinr_struct.maxPower = sinr_vector;
sinr_struct.minDist = sinr_vector;
sinr_struct.fading.maxPower = sinr_vector;
sinr_struct.fading.minDist = sinr_vector;

lobeEdge_matrix = zeros( length( beamWidth_vector ), ...
                       length( apHeight_vector ) );
numberOfAps_vector = zeros( size( interSiteDistance_vector ) );

%% ITERATIONS - CALCULATE SINR
tstart = tic;
currentProgress = 0;

for distanceToBody_id = 1:length( distanceToUserBody_vector )
    
    sim.distanceToUserBody = distanceToUserBody_vector( distanceToBody_id );
    
    for bodyAtt_id = 1:length( bodyAttenuation_vector )
                   
        sim.bodyAttenuation = bodyAttenuation_vector( bodyAtt_id );

        for numBodies_id = 1:length( numberOfRandomBodies_vector )

            sim.numberOfHumanBlockages = numberOfRandomBodies_vector( numBodies_id );

            for height_id = 1:length( apHeight_vector )

                sim.apHeight = apHeight_vector( height_id );

                for beamwidth_id = 1:length( beamWidth_vector )

                    % CELL PROPERTIES
                    beamWidthTx = beamWidth_vector( beamwidth_id );
                    sim.mainLobeGainTx = MainLobeGain( beamWidthTx, sim.sideLobeGainTx );
                    sim.mainLobeEdgeTx = sim.apHeight * tan( beamWidthTx / 2 );
                    lobeEdge_matrix( beamwidth_id, height_id ) = sim.mainLobeEdgeTx;

                    for density_id = 1:length( interSiteDistance_vector )

                        density = 1/(interSiteDistance_vector( density_id ))^2;
                        cellRadius = interSiteDistance * sin( pi/6 ) / sin( 2*pi/3 );

                        
                        for n_iter = 1:numberOfIterations
                            
                         % GENERATE TOPOLOGY
                            % Poisson point process
                            numberOfAps = poissrnd( density );
                            numberOfAps_vector( density_id ) = numberOfAps;
                            % Place UE in origin
                            apPosition = ( -1+2*rand(numberOfAps,1) + -1i+2i*rand(numberOfAps,1) );
                            % Get 2-D distance from AP to UE
                            sim.distance2d = abs( apPosition );
                            % Get angle of arrival from AP to UE
                            sim.angleToAp = angle( apPosition );
                            % Get 3-D distance from AP to UE
                            sim.distance3d = sqrt( sim.distance2d.^2 + sim.apHeight^2 );
                            
                            % COMPUTE DOWNLINK SINR
                            sinr = sim_Downlink( sim );
                            
                            % no fading
                            sinr_struct.maxPower( ...
                                n_iter, ...
                                beamwidth_id, ...
                                height_id, ...
                                density_id,...
                                numBodies_id, ...
                                bodyAtt_id,...
                                distanceToBody_id ) = sinr.maxPower;
                            sinr_struct.minDist( ...
                                n_iter, ...
                                beamwidth_id, ...
                                height_id, ...
                                density_id,...
                                numBodies_id, ...
                                bodyAtt_id,...
                                distanceToBody_id ) = sinr.minDist;
                            % with fading
                            sinr_struct.fading.maxPower( ...
                                n_iter, ...
                                beamwidth_id, ...
                                height_id, ...
                                density_id,...
                                numBodies_id, ...
                                bodyAtt_id,...
                                distanceToBody_id ) = sinr.fading.maxPower;
                            sinr_struct.fading.minDist( ...
                                n_iter, ...
                                beamwidth_id, ...
                                height_id, ...
                                density_id,...
                                numBodies_id, ...
                                bodyAtt_id,...
                                distanceToBody_id ) = sinr.fading.minDist;

                            % DISPLAY PROGRESS
                            totalProgress = length( beamWidth_vector ) * ...
                                            length( interSiteDistance_vector ) * ...
                                            length( apHeight_vector ) * ...
                                            length( numberOfRandomBodies_vector ) * ...
                                            length( bodyAttenuation_vector ) * ...
                                            length( distanceToUserBody_vector ) * ...
                                            numberOfIterations;
                            currentProgress = currentProgress + 1;
                            loopProgress = 100 * currentProgress / totalProgress;
                            if mod(loopProgress,2) == 0
                                clc
                                disp(['Loop progress: ' num2str(loopProgress)  '%']);
                                tnow = toc( tstart );
                                toc( tstart );
                                estimatedEnd = ( tnow * 100 / loopProgress ) - tnow;
                                disp(['Estimated end in ' num2str(estimatedEnd) ' seconds.' ]);
                                hms = fix(mod(estimatedEnd, [0, 3600, 60]) ./ [3600, 60, 1]);
                                disp(['Estimated duration ' ...
                                    num2str(hms(1)) ':' num2str(hms(2)) ':' num2str(hms(3)) ]);
                            end
                        end % n_iter
                    end % density_id
                end % beamwidth_id
            end % height_id
        end % numBodies_id
    end % bodyAtt_id
end % distanceToBody_id
toc(tstart);
%% OUTPUT
outputName = 'output/sinr';
save( strcat( outputName, '_', datestr(now,'yyyymmddHHMM'), '.mat' ) );