
t1=75*1; %75 ms at 1Khz
t2=75*1;  %75 ms at 1Khz
a = 5/-t2;
b = (-5 -a*(2*t1+t2))/2;
Myvoltages =  5+([zeros(1,t1),(a*((t1+1):(t1+t2))+b)]);
figure;plot((1:(t1+t2)),Myvoltages)



ConfirmBit = ProgramPulsePal(ParameterMatrix)


SendCustomWaveform(1, 0.001, Myvoltages); % Uploads waveform. Samples are played at 1khz.

%TriggerPulsePal('0111'); % 4 3 2 1

