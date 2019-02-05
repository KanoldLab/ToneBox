function SpeakerCalibration(rpi,filepath,ultra)

global globalparams Response

%%%% Initialize variables and hardware
globalparams.speaker='PUI';
globalparams.microphone='BK4944A';
globalparams.VRef=5;
globalparams.dBSPLRef=60;


%Duration of calibration sounds
globalparams.LStim=10;


if ultra == 1
    %high-pass corner frequency for recordings
    globalparams.highcut = 50000;
    globalparams.SR=192000;
    globalparams.Fband=[1000 50000];
else
    %high-pass corner frequency for recordings
    globalparams.highcut = 23000;
    globalparams.SR=48000;
    globalparams.Fband=[1000 23000];
end

globalparams.R=[];

%%%% Record a broad-noise that is set to +/- the maximum output voltage (VRef)
globalparams.NSteps = round(globalparams.LStim*globalparams.SR);
Noise = wgn(1,globalparams.NSteps,1);
Noise = Noise(:);
ramp = hanning(round(.2 * globalparams.SR*2));
ramp = ramp(1:floor(length(ramp)/2));
Noise(1:length(ramp)) = Noise(1:length(ramp)) .* ramp;
Noise(end-length(ramp)+1:end) = Noise(end-length(ramp)+1:end) .* flipud(ramp);
Noise = Noise./max(abs(Noise));
audiowrite([filepath,'noise.wav'],Noise,globalparams.SR)
putFile(rpi,[filepath,'noise.wav'],'/home/tonebox')
%Play and record the sound
if ultra == 0
    system(rpi, ['sudo amixer set ''Auto Gain Control'' off']);
    system(rpi,'sudo amixer set Speaker 50%');
end
system(rpi,['sudo arecord -D plughw:1,0 -d 11 -f dat -r ' num2str(globalparams.SR) ' -c 1 calnoise.wav | sudo aplay -D plughw:1,0 /home/tonebox/noise.wav']);
getFile(rpi,'/home/tonebox/calnoise.wav',filepath);
system(rpi,'sudo rm /home/tonebox/calnoise.wav | sudo rm /home/tonebox/noise.wav');
AllData = audioread([filepath,'calnoise.wav']);
Response = AllData;
Response(1:length(ramp)) = Response(1:length(ramp)) .* ramp;
Response(end-length(ramp)+1:end) = Response(end-length(ramp)+1:end) .* flipud(ramp);
fprintf(['\n ====== Done Recording ======\n']);
globalparams.Fig=figure('position',[177   216   735   745]);
set(gcf,'Name',['Speaker: ',globalparams.speaker,' (SR=',num2str(globalparams.SR),'Hz)'],'MenuBar','none','Toolbar','figure');

%%%% Estimate the whitening filter
%This program uses the recorded response to a noise played through a speaker to estimate (1) the transfer function from the speaker to the
%microphone and (2) the "Inverse" transfer function, which is the equalizing spectrum that flatens the spectral output of the speaker. The
%inverse transfer function is found by divding an idealized flat spectrum by the forward transfer function.
R = globalparams.R;
R.Fs = globalparams.SR;
ResponseSpec =(1/length(Response))*abs(fft(Response));
ResponseSpec=smooth(ResponseSpec,2^10);
ResponseSpecdB = VolumeConversion(ResponseSpec,'V2dB',globalparams.microphone);
%Estimate whitening filter
f = linspace(0,R.Fs,length(ResponseSpecdB));
fidx = find(f>=globalparams.Fband(1) & f<=globalparams.Fband(2));
WhiteSpecdB = min(ResponseSpecdB(fidx))-ResponseSpecdB;
R.WhiteningSpec = VolumeConversion(WhiteSpecdB','dB2V',globalparams.microphone);
figure(globalparams.Fig)
subplot(2,2,1:2)
cla
plot(f/1000,ResponseSpecdB,'b','linewidth',2);
set(gca,'Xscale','log')
hold on;
grid on
xlim(globalparams.Fband./1000)
aa=axis;
ylim([0 aa(4)+1]);
ylabel('dB SPL')
xlabel('Frequency (kHz)');
title('Recorded Noise Spectrum Level','fontsize',10);
R.ResponseSpecdB=ResponseSpecdB;
globalparams.R = R;

%%%% Estimate amplifier gain
WhiteningSpec=globalparams.R.WhiteningSpec';
R = globalparams.R;
Noise = wgn(1,length(WhiteningSpec),1);
Noise = Noise(:);
ramp = hanning(round(.2 * globalparams.SR*2));
ramp = ramp(1:floor(length(ramp)/2));
Noise(1:length(ramp)) = Noise(1:length(ramp)) .* ramp;
Noise(end-length(ramp)+1:end) = Noise(end-length(ramp)+1:end) .* flipud(ramp);
CalbNoise = Noise./max(abs(Noise));
[b a] = butter(6,globalparams.Fband./(globalparams.SR/2));
CalbNoise = filtfilt(b,a,CalbNoise);
CalbNoise = CalbNoise./max(abs(CalbNoise));
%Whiten the noise for gain calibration
CalbNoiseSpec=fft(CalbNoise);
CalbNoiseSpecPhase=angle(CalbNoiseSpec);
CalbNoiseSpecdB=VolumeConversion(abs(CalbNoiseSpec),'V2dB',globalparams.microphone);
WhiteningSpecdB=VolumeConversion(WhiteningSpec,'V2dB',globalparams.microphone);
CalbNoiseSpecdBWhite=CalbNoiseSpecdB + WhiteningSpecdB;
CalbNoiseSpecWhite=VolumeConversion(CalbNoiseSpecdBWhite,'dB2V',globalparams.microphone);
CalbNoiseSpecWhite=CalbNoiseSpecWhite.*exp(j.*CalbNoiseSpecPhase);
CalbNoiseWhite=real(ifft(CalbNoiseSpecWhite));
CalbNoiseWhite = CalbNoiseWhite(1:globalparams.SR);
ramp = hanning(round(.2 * globalparams.SR*2));
ramp=ramp(1:floor(length(ramp)/2));
CalbNoiseWhite(1:length(ramp))=CalbNoiseWhite(1:length(ramp)) .* ramp;
CalbNoiseWhite(end-length(ramp)+1:end)=CalbNoiseWhite(end-length(ramp)+1:end) .* flipud(ramp);
CalbNoiseWhite = CalbNoiseWhite./max(abs(CalbNoiseWhite));

%Play noise and adjust amplifier gain
CurrentdB=0;
VolPercent=100;
if ultra == 0
    system(rpi,['sudo amixer set Speaker ' num2str(VolPercent) '%']);
else
    disp('Manually adjust speaker gain on soundcard')
end
while abs(globalparams.dBSPLRef-CurrentdB) > 3
    audiowrite([filepath,'CalbNoiseWhite.wav'],CalbNoiseWhite,globalparams.SR)
    putFile(rpi,[filepath,'CalbNoiseWhite.wav'],'/home/tonebox')
    system(rpi,['sudo arecord -D plughw:1,0 -d 2 -f dat -r ' num2str(globalparams.SR) ' -c 1 CalbNoiseWhiteGain.wav | sudo aplay -D plughw:1,0 /home/tonebox/CalbNoiseWhite.wav']);
    getFile(rpi,'/home/tonebox/CalbNoiseWhiteGain.wav',filepath);
    system(rpi,'sudo rm /home/tonebox/CalbNoiseWhiteGain.wav | sudo rm /home/tonebox/CalbNoiseWhite.wav');
    AIdata = audioread([filepath,'CalbNoiseWhiteGain.wav']);
    AIdata(1:length(ramp))=AIdata(1:length(ramp)) .* ramp;
    AIdata(end-length(ramp)+1:end)=AIdata(end-length(ramp)+1:end) .* flipud(ramp);
    Vcurrent = rms(AIdata);
    CurrentdB = VolumeConversion(Vcurrent,'V2dB',globalparams.microphone);
    disp(['dB Goal Difference: ' num2str(globalparams.dBSPLRef-CurrentdB)])
    VolPercent = VolPercent-10;
    if ultra == 0
        system(rpi,['sudo amixer set Speaker ' num2str(VolPercent) '%']);
    else
        disp('Manually adjust speaker gain on soundcard')
    end
    pause(2)
end
R.cdBSPL = VolumeConversion(Vcurrent,'V2dB',globalparams.microphone);
fprintf(['\n=> Level: ',num2str(R.cdBSPL),'\n']);
R.Fs=globalparams.SR;
R.VolPercent = VolPercent;
globalparams.R = R;

%Test calibration
globalparams.NSteps = round(globalparams.LStim*globalparams.SR);
F=1000.*2.^[0:.5:5.5];
if ~ultra
    F=F(F<23000);
end
tonedur=0.2;
t=0:1/globalparams.SR:(tonedur)-(1/globalparams.SR);
fprintf(['\n ====== Calibration Tones ====== \n']);
Tones =[];
for i = 1:length(F)
    tone = sin(2*pi*F(i).*t)';
    %Normalize tone to +/-VRef
    MAX = max(abs(tone));
    tone = globalparams.VRef*(tone./MAX);
    ramp = hanning(round(.02 * globalparams.SR*2));
    ramp = ramp(1:floor(length(ramp)/2));
    tone(1:length(ramp)) = tone(1:length(ramp)) .* ramp;
    tone(end-length(ramp)+1:end) = tone(end-length(ramp)+1:end).*flipud(ramp);
    %Whiten the tone
    spec = globalparams.R.WhiteningSpec';
    mic = globalparams.microphone;
    toneWhite = IOCalibrationFilter(tone, spec, mic);
    toneWhite(1:length(ramp)) = toneWhite(1:length(ramp)) .* ramp;
    toneWhite(end-length(ramp)+1:end) = toneWhite(end-length(ramp)+1:end) .* flipud(ramp);
    toneWhite = [zeros(length(tone),1); toneWhite; zeros(length(tone),1)];
    Tones=[Tones; toneWhite];
end
Tones=Tones./max(abs(Tones));
L = ceil(length(Tones)./globalparams.SR);

%Play tones
if ultra == 0
    system(rpi,['sudo amixer set Speaker ' num2str(R.VolPercent) '%']);
end
audiowrite([filepath,'Tones.wav'],Tones,globalparams.SR)
putFile(rpi,[filepath,'Tones.wav'],'/home/tonebox')
system(rpi,['sudo arecord -D plughw:1,0 -d ' num2str(L) ' -f dat -r ' num2str(globalparams.SR) ' -c 1 TonesCalb.wav | sudo aplay -D plughw:1,0 /home/tonebox/Tones.wav']);
getFile(rpi,'/home/tonebox/TonesCalb.wav',filepath);
system(rpi,'sudo rm /home/tonebox/TonesCalb.wav | sudo rm /home/tonebox/Tones.wav');
AIdata = audioread([filepath,'TonesCalb.wav']);
f1 = globalparams.Fband(1)-500;
f2 = globalparams.Fband(2)+500;
[b a] = butter(6,[f1 f2]./(globalparams.SR/2));
AIdata = filtfilt(b,a,AIdata);
AIdata(1:length(ramp))=AIdata(1:length(ramp)) .* ramp;
AIdata(end-length(ramp)+1:end)=AIdata(end-length(ramp)+1:end) .* flipud(ramp);
figure(globalparams.Fig)
subplot(2,2,3)
AIdB=VolumeConversion(rms(AIdata),'V2dB',globalparams.microphone);
t=0:1/globalparams.SR:(length(AIdata)/R.Fs)-(1/globalparams.SR);
plot(t,AIdata,'k')
xlabel('Time (s)')
ylabel('Volts')
title([{'Calibrated Test Tone Waveform'};{['RMS Level: ' num2str(roundTo(AIdB,1)) ' dB SPL']}],'fontsize',10)
aa=axis;
ylim([-max(aa(3:end)) max(aa(3:end))].*1.5)
grid on
f=linspace(0,R.Fs,length(AIdata));
subplot(2,2,4)
AIDataSpec=(2/length(AIdata))*(abs(fft(AIdata)));
AIDataSpecdB=VolumeConversion(AIDataSpec,'V2dB',globalparams.microphone);
plot(f/1000,AIDataSpecdB-mean(AIDataSpecdB),'k')
xlim([0 (1000+globalparams.Fband(2))/1000])
xlabel('Frequency (kHz)')
ylabel('dB SPL')
title('Calibrated Test Tone Spectrum','fontsize',10)
aa=axis;
ylim([0 aa(4)])
grid on
globalparams.R = R;

%Save calibration
FileName = ['SpeakerCalibration_',globalparams.speaker,'_',globalparams.microphone,'.mat'];
globalparams.R.VRef = globalparams.VRef;
globalparams.R.dBSPLRef = globalparams.dBSPLRef;
R = globalparams.R;
fprintf(['\n ====== Saving Calibration ======\n']);
save([filepath, FileName],'R')
putFile(rpi,[filepath, FileName],'/home/tonebox')

%Save calibrated tones
try
    system(rpi,'sudo rm /home/tonebox/*.wav');
end
fs=globalparams.SR;
t0 = 0:1/fs:1-(1/fs);
t1=t0;
t2 = 0:1/fs:2.5-(1/fs);
AllWhiteTones=[];
M=[];
for i = 1:length(F)
    Trial =[];
    tone = sin(2*pi*F(i).*t1)';
    %Normalize tone to +/-VRef
    MAX = max(abs(tone));
    tone = globalparams.VRef*(tone./MAX);
    ramp = hanning(round(.02 * globalparams.SR*2));
    ramp = ramp(1:floor(length(ramp)/2));
    tone(1:length(ramp)) = tone(1:length(ramp)) .* ramp;
    tone(end-length(ramp)+1:end) = tone(end-length(ramp)+1:end).*flipud(ramp);
    %Whiten the tone
    spec = globalparams.R.WhiteningSpec';
    mic = globalparams.microphone;
    toneWhite = IOCalibrationFilter(tone, spec, mic);
    toneWhite(1:length(ramp)) = toneWhite(1:length(ramp)) .* ramp;
    toneWhite(end-length(ramp)+1:end) = toneWhite(end-length(ramp)+1:end) .* flipud(ramp);
    Trial = [zeros(length(t0),1); toneWhite; zeros(length(t2),1)];
    AllWhiteTones{i} = Trial;
    M(i) = max(abs(Trial));
end
%Level attentuations
LL = -30:5:0;
for i = 1:length(F)
    for ii = 1:length(LL)
        AttendB=10^(LL(ii)/20);
        Trial = AttendB*(AllWhiteTones{i}./max(M));
        fname = ['Tone_' num2str(roundTo(F(i)./1000,1)) 'kHz_' num2str(LL(ii)) 'dB.wav'];
        audiowrite([filepath, fname],Trial,globalparams.SR)
        putFile(rpi,[filepath, fname],'/home/tonebox');
        delete([filepath, fname]);
    end
end

fprintf(['\n ====== Done! ======\n']);


