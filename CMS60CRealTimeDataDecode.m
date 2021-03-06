function [RealTimeData RealTimeArray] = CMS60CRealTimeDataDecode(DataPackage)
%
% decode the data package sent by the CMS60C
% based on the specfication in the communication protocol v7.0
%
% input is an 8 byte message from the pulse oximeter
% outputs
%  RealTimeData - a matlab data structure
%  RealTimeArray - same data as a matlab array

RealTimeData.decoded = false;

if length(DataPackage) ~= 8
    RealTimeData.Status = 'DataPackage was not 8 bytes long';
    RealTimeArray  = zeros(14,1);
    return;
end

%Byte 1 - not sure - think this is just a marker

%Byte 2 - monitor status info
RealTimeData.SignalStrength = bitand(DataPackage(2), 15);  % bits 0-3
RealTimeData.SearchTimeOut  = bitand(DataPackage(2), 16) == 16;  % bit 4
RealTimeData.LowSPO2        = bitand(DataPackage(2), 32) == 32 ;  % bit 5 
RealTimeData.PulseBeep      = bitand(DataPackage(2), 64) == 64;  % bit 6
RealTimeData.ProbeError     = bitand(DataPackage(2), 128) == 128;  % bit 7

%Byte 3 - Pulse Waveform Data
RealTimeData.PulseWaveForm         = bitand(DataPackage(3), 127);  % bits 0-6
RealTimeData.SearchingForPulse     = bitand(DataPackage(3), 128) == 128;  % bit 7

%Byte 4 - Bar Graph Data
RealTimeData.BarGraph         = bitand(DataPackage(4), 15);  % bits 0-3
RealTimeData.PIInvalid        = bitand(DataPackage(4), 16) == 16;  % bit 4

%Byte 5 - Pulse Rate
RealTimeData.PulseRate         = bitand(DataPackage(5), 255);  % bits 0-7
if RealTimeData.PulseRate > 254 % only valid upto 254
    RealTimeData.PulseRate = -1;
elseif RealTimeData.PulseRate > 196 %kludge for weird CMS60S data
    RealTimeData.PulseRate = RealTimeData.PulseRate - 128;
end

%Byte 6 - SPO2
RealTimeData.SPO2               = bitand(DataPackage(6), 127);  % bits 0-7
if RealTimeData.SPO2 > 100 %only valid upto 100
    RealTimeData.SPO2 = -1;
end

%Byte 7 - LowPI 
RealTimeData.LowPI              = bitand(DataPackage(7), 255);  % bits 0-7
if RealTimeData.LowPI > 220  %not entirely sure about this one.
    RealTimeData.LowPI = -1;
end

%Byte 8 - HighPI 
RealTimeData.HighPI               = bitand(DataPackage(8), 255);  % bits 0-7
if RealTimeData.HighPI > 220
    RealTimeData.HighPI = -1;
end

RealTimeArray = [   1
                    RealTimeData.SignalStrength 
                    RealTimeData.SearchTimeOut 
                    RealTimeData.LowSPO2      
                    RealTimeData.PulseBeep    
                    RealTimeData.ProbeError    
                    RealTimeData.PulseWaveForm  
                    RealTimeData.SearchingForPulse    
                    RealTimeData.BarGraph    
                    RealTimeData.PIInvalid     
                    RealTimeData.PulseRate     
                    RealTimeData.SPO2      
                    RealTimeData.LowPI  
                    RealTimeData.HighPI 
                ]';
RealTimeData.decoded = true;
RealTimeData.status = 'Success';