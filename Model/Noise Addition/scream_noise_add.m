%Specify the folder where the clean files live.
myFolder = "C:/Users/fairu/Desktop/dataset/conversation";

%'fullfile()' joins directory path string with '*.wav' extension.
filePattern = fullfile(myFolder, '*.wav'); % Change to whatever pattern you need.
%'theFiles' is an array containing info of each file, such as name, directory path, date created, size, etc.
theFiles = dir(filePattern);

%Load noise file. Store default sampling rate in fs.
[n, fsn] = audioread("C:/Users/fairu/Desktop/dataset/background_dataset/comb_back_1.wav");
%Use just single (mono) channel of noise signal.
nMono = n(:,1);

for k = 1 : length(theFiles)
  
  %Clear previous warning.
  lastwarn('');
  
  %'.name' only extracts the file names (with extensions) from string.
  baseFileName = theFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  
  %Load clean speech file and downsample from 48kHz to 16kHz.
  [c, fsc] = audioread(fullFileName);

  %Use just single (mono) channel of noise signal.
  len = size(c,1)
  %Randomly select a section of the noise file equal to clean speech size.
  x = 1; %Number of values picked randomly.
  sMin = 1; %Minimum allowed starting value.
  sMax = length(nMono) - len; %Maximum allowed starting value.
  s = randi([sMin,sMax], x);
  %Resize noise signal to length of clean speech.
  nMonoResize = nMono(s:s+len-1,:);
  
  %Calculate Power of clean speech.
  powClean = sum(c.^2)/length(c);
  
  %Calculate Power of noise (mono).
  powNoise = sum(nMonoResize.^2)/length(nMonoResize);
  
  %Randomly select one out of the three SNR values, -10dB, -5dB or 0dB.
  %snrOptions = [-10, -5, 0];
  SNR = -10;
  
  %Calculate Noise Variance (var) for a given SNR.
  var = (powClean/powNoise)*10^(-SNR/10);
  
  %Noise Standard Deviation (std).
  std = sqrt(var);
  
  %New adjusted noise signal.
  nNew = std.*nMonoResize;
  
  %Add noise signal to clean speech to create noisy signal.
  s = c + nNew;
  
  %Update file name according to noise file and SNR used.
  [filepath,name,ext] = fileparts(baseFileName);
  oldName = name;
  newName = oldName + "_" + "noise" + "_" + string(SNR);
  newNameExt = newName + ".wav";
  newFileName = fullfile(myFolder, newNameExt);
  
  %Save noisy signal as WAV file.
  fprintf(1, 'Good, Now reading %s\n', newFileName);
  audiowrite(newFileName,s,fsc);
    %Check which warning occured (if any)
  [msgstr, msgid] = lastwarn;
  %This is when the clipping warning occurs. Fix: normalize the signal.
  switch msgid
   case 'MATLAB:audiovideo:audiowrite:dataClipped'
      %Normalize the output signal.
      s1 = s / max(abs(s));
      %Save noisy signal as WAV file.
      audiowrite(newFileName,s1,fsc);
      fprintf(1, 'Warning, Now reading %s\n', newFileName);
  end
end

SnR = snr(c, s-c);
SnR