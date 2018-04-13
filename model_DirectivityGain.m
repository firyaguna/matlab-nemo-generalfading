function [ gain ] = model_DirectivityGain( size, ...
                                           servingAp, ...
                                           probAlignment, ...
                                           mainLobeTx, sideLobeTx, ...
                                           mainLobeRx, sideLobeRx )
%MODEL_DIRECTIVITYGAIN summary
%   Details

gain = ones(1,size);

align_v = gendist( probAlignment, 1, size );
for i=1:size
    switch align_v(i)
        case 1
            gain(i) = mainLobeTx * mainLobeRx;
        case 2
            gain(i) = mainLobeTx * sideLobeRx;
        case 3
            gain(i) = sideLobeTx * mainLobeRx;
        case 4
            gain(i) = sideLobeTx * sideLobeRx;
        otherwise
            gain(i) = 0;
    end
end
gain(servingAp) = mainLobeTx * mainLobeRx;

end