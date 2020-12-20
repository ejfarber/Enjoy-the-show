clc
clear all
sample_rate=48000;
frameLength = 24000/16

deviceReader=audioDeviceReader()
deviceReader.SampleRate=sample_rate
deviceReader.SamplesPerFrame=frameLength

deviceWriter = audioDeviceWriter('SampleRate',deviceReader.SampleRate);

a = arduino('COM6','Uno');
configurePin(a,'D5','DigitalOutput');
configurePin(a,'D3','DigitalOutput');

% scope4 = dsp.TimeScope('SampleRate',deviceReader.SampleRate,'TimeSpan',16,'YLimits',[-2,2]); 
 
crossFilt = crossoverFilter(1,200,48);


%LOW RANGE
scope1 = dsp.SpectrumAnalyzer();
scope1.PeakFinder.Enable = true;
scope1.NumInputPorts=1;
scope1.PlotAsTwoSidedSpectrum=false;
scope1.SpectrumType='RMS';
scope1.FrequencyScale='Log';
scope1.SpectralAverages=1;
scope1.AveragingMethod='Running';

%Other Range
scope2 = dsp.SpectrumAnalyzer();
scope2.PeakFinder.Enable = true;
scope2.NumInputPorts=1;
scope2.PlotAsTwoSidedSpectrum=false;
scope2.SpectrumType='RMS';
scope2.FrequencyScale='Log';
scope2.SpectralAverages=1;
scope2.AveragingMethod='Running';

scope3 = dsp.SpectrumAnalyzer();
scope3.PeakFinder.Enable = true;
scope3.NumInputPorts=1;
scope3.PlotAsTwoSidedSpectrum=false;
scope3.SpectrumType='RMS';
scope3.FrequencyScale='Log';
scope3.SpectralAverages=2;
scope3.AveragingMethod='Running';


% 
x=1;
disp('LISTEN')
% pause(2.5)
while x==1
  [band1, band2] = crossFilt(deviceReader());
      deviceWriter(band1+band2);
    %Input different frequencie ranges into the established scopes
    %LOW
    scope1(band1);
%    %MID
    scope2(band2);
    %HIGH
%     scope4(audio);
% EXAMINE LOW RANGE DATA - realtime

    low_data = (getMeasurementsData(scope1,'All'));

    peakvalue_low = low_data.PeakFinder;

    if isstruct(peakvalue_low)==1

        volts_low_range=max(peakvalue_low.Value);

        if isempty(volts_low_range)==0&isnan(volts_low_range)==0

            volts_scaled_low=750*(exp(volts_low_range^3.5)-1);
            if volts_scaled_low>5
                volts_scaled_low=5;
            end 
            writePWMVoltage(a, 'D5', volts_scaled_low);
        end
    end
%     EXAMINE MID RANGE DATA
    
    mid_data = getMeasurementsData(scope2,'All');

    peakvalue_mid= mid_data.PeakFinder;

    if isstruct(peakvalue_mid)==1

        volts_mid_range=max(peakvalue_mid.Value);

        if isempty(volts_mid_range)==0&isnan(volts_mid_range)==0

           volts_scaled_mid= 75*(exp(volts_mid_range.^1.5)-1);
           
            if volts_scaled_mid>5
                volts_scaled_mid=5;
            end
            writePWMVoltage(a, 'D3', volts_scaled_mid);
        end
    end

end                                      

release(fileReader)
release(fileReader2)
release(deviceWriter)  
release(scope1)
release(scope2)

clear all
close all
clc

complete=true;