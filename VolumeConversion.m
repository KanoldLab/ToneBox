function out = VolumeConversion(in,direction,Microphone)
% VolumeConversion converts between SPL [dB] and Voltage

switch Microphone
    case 'BK4944A'
        dBSPL0 = 94;
        V0 = 0.0814; % Measurements in Volts based on 100x amplification: 94 dB SPL = 1 Pa. BK4944A measures at 0.000814 V/Pa.
        
    case 'ANL9401'
        dBSPL0 = 94;
        V0 = 1; % Measurements in Volts based on default amplification gain: 94 dB SPL = 1 Pa. ANL9401 measures at 1 V/Pa.
        
    otherwise
        error('Microphone not tested yet.');
        
end

if strcmp(direction,'dB2V')
    out = V0*10.^((in-dBSPL0)/20);
    
elseif strcmp(direction,'V2dB')
    out = dBSPL0 + 20*log10(in/V0);
    
else
    error('Not a valid conversion!');
    
end