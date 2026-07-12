
showEphys('*AAAF*')

%% for voltage traces
MC_dataset{1}.identificator = '*AAAB*';
MC_dataset{1}.NO = [1 2 6 7 10 11 16 17 18 19];
MC_dataset{1}.YES = [3 4 5 8 9 12 13 14 15 20];
MC_dataset{1}.YESstimulat = [13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5  30]; % last one = NaN ?

MC_dataset{2}.identificator = '*AAAD*'; % not very tight and changing access
MC_dataset{2}.NO = [1 2 ];
MC_dataset{2}.YES = [3:6 7 8];
MC_dataset{2}.YESstimulat = [13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5 30];

MC_dataset{3}.identificator = '*AAAF*';
MC_dataset{3}.NO = [1 5:7 11:12 19:22];
MC_dataset{3}.YES = [2:4 8:10 13:18 23:26];
MC_dataset{3}.YESstimulat = [13.5 30;13.5 30;13.5 30;     13.0 30;13.0 30;13.0 30;      13.0 30;13.0 30;13.0 30;13.0 30;13.0 30;13.0 30; 13.0 30;13.0 30;13.0 30;13.0 30 ];

MC_dataset{4}.identificator = '*AAAH*'; % trials 1&2 : 1st trial effect
MC_dataset{4}.NO = [1 2 6 9 10 13 14 19 20 26 31 32];
MC_dataset{4}.YES = [3:5 7:8 11:12 15:18 21:25 27:30];
MC_dataset{4}.YESstimulat = [13.5 30;13.5 30;13.5 30;   13.0 30;13.0 30;   13.0 30;13.0 30;   13.0 30;13.0 30;13.0 30;13.0 30;   13.0 30;13.0 30;13.0 30;13.0 30;13.0 30;    13.0 30;13.0 30;13.0 30;13.0 30;];

%% rasterplot for AAAB

FileList = dir(identificator);
clear spikeTimes B
for k = 1:20

    load(FileList(k).name,'-mat');
    A = data.ephys.trace_1;
    AA = A-medfilt1(A,500);
    spikeTimes{k} = find(AA > 12 & circshift(AA,2) < 12);
end
spikeRaster = ones(20,38000/10,3);
for k = 1:20
    if any(k == MC_dataset{1}.YES)
        spikeRaster(k,round(spikeTimes{k}/100)+1,1:2) = spikeRaster(k,round(spikeTimes{k}/100)+1,1:2) - 1;
    else
        spikeRaster(k,round(spikeTimes{k}/100)+1,:) = spikeRaster(k,round(spikeTimes{k}/100)+1,:) - 1;
    end
    numel(round(spikeTimes{k}/100)),numel(round(spikeTimes{k}/100))
end
figure, imagesc([0:38],[],cat(1,spikeRaster(MC_dataset{1}.NO,:,:),spikeRaster(MC_dataset{1}.YES,:,:)) ); colormap(gray)
setfig3()
set(gca, 'TickDir', 'out')
box off
xlim([12.5 14.5])

%% rasterplot for AAAE

FileList = dir(MC_dataset{4}.identificator);
clear spikeTimes B
for k = 1:11

    load(FileList(k).name,'-mat');
    A = data.ephys.trace_1;
    AA = A-medfilt1(A,500);
    spikeTimes{k} = find(AA > 1 & circshift(AA,2) < 1);
end
spikeRaster = ones(20,38000/5,3);
for k = 1:11
    if any(k == MC_dataset{4}.YES)
        spikeRaster(k,round(spikeTimes{k}/50)+1,1:2) = spikeRaster(k,min(3800*2,round(spikeTimes{k}/200)+1),1:2) - 1;
    else
        spikeRaster(k,round(spikeTimes{k}/50)+1,:) = spikeRaster(k,min(3800*2,round(spikeTimes{k}/200)+1),:) - 1;
    end
    numel(round(spikeTimes{k}/100)),numel(round(spikeTimes{k}/100))
end
spikeRaster = max(spikeRaster,0);
figure, imagesc([0:38],[],cat(1,spikeRaster(MC_dataset{4}.NO,:,:),spikeRaster(MC_dataset{4}.YES,:,:)) ); colormap(gray)
setfig3()
set(gca, 'TickDir', 'out')
box off
xlim([12.5 14.5])


%% membrane potential change

clear FullVoltageList OdorVoltageList
counter = 1;
counterOdor = 1;
for jj = 1:numel(MC_dataset)
    FileList = dir(MC_dataset{jj}.identificator);
    for k = 1:numel(FileList)
        if any(k == MC_dataset{jj}.YES)
            load(FileList(k).name,'-mat');
            A = data.ephys.trace_1;
            
            Event1 = MC_dataset{jj}.YESstimulat( find(k == MC_dataset{jj}.YES), 1);
            Event2 = MC_dataset{jj}.YESstimulat( find(k == MC_dataset{jj}.YES), 2);
            
            window1 = (Event1*1e4-9999):(Event1*1e4+10000);
            window2 = (Event2*1e4-9999):(Event2*1e4+10000);
            
            A = medfilt1(A,100);
            
            FullVoltageList(counter,:) = A(window1);
            FullVoltageList(counter+1,:) = A(window2);
            counter = counter + 2;
            OdorVoltageList(counterOdor,:) = A(window1);
            counterOdor = counterOdor + 1;
        end
    end
end

for k = 1:size(OdorVoltageList,1)
    OdorVoltageList(k,:) = OdorVoltageList(k,:)  - mean(OdorVoltageList(k,5e3:1e4));
end
for k = 1:size(FullVoltageList,1)
    FullVoltageList(k,:) = FullVoltageList(k,:)  - mean(FullVoltageList(k,5e3:1e4));
end

figure, imagesc(OdorVoltageList)
figure, plot(mean(OdorVoltageList))

times = (1:2e4)/1e4-1;

figure, hold on;
plot(times,mean(FullVoltageList(1:2:end,:))); hold on; plot(times,mean(FullVoltageList(2:2:end,:)),'r')

figure, hold on;
ciplot(mean(FullVoltageList)-std(FullVoltageList),mean(FullVoltageList(1:1:end,:))+std(FullVoltageList(1:1:end,:)),times)
hold on; plot(times,mean(FullVoltageList(1:1:end,:)),'k');




%% for spike traces

MC_dataset{1}.identificator = '*AAAB*';
MC_dataset{1}.NO = [1 2 6 7 10 11 16 17 18 19];
MC_dataset{1}.YES = [3 4 5 8 9 12 13 14 15];
MC_dataset{1}.YESstimulat = [13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5 30]; % last one = NaN ?

MC_dataset{2}.identificator = '*AAAF*';
MC_dataset{2}.NO = [1 5:7 11:12 19:22];
MC_dataset{2}.YES = [2:4 8:10 13:18 23:26];
MC_dataset{2}.YESstimulat = [13.5 30;13.5 30;13.5 30;     13.0 30;13.0 30;13.0 30;      13.0 30;13.0 30;13.0 30;13.0 30;13.0 30;13.0 30; 13.0 30;13.0 30;13.0 30;13.0 30 ];

MC_dataset{3}.identificator = '*AAAH*'; % trials 1&2 : 1st trial effect
MC_dataset{3}.NO = [1 2 6 9 10 13 14 19 20 26 31 32];
MC_dataset{3}.YES = [3:5 7:8 11:12 15:18 21:25 27:30];
MC_dataset{3}.YESstimulat = [13.5 30;13.5 30;13.5 30;   13.0 30;13.0 30;   13.0 30;13.0 30;   13.0 30;13.0 30;13.0 30;13.0 30;   13.0 30;13.0 30;13.0 30;13.0 30;13.0 30;    13.0 30;13.0 30;13.0 30;13.0 30;];

MC_dataset{4}.identificator = '*AAAE*'; % trials 1&2 : 1st trial effect
MC_dataset{4}.NO = [5:6];
MC_dataset{4}.YES = [2:4 7:12];
MC_dataset{4}.YESstimulat = [13.5 30;13.5 30;13.5 30;    13.5 30;13.5 30;13.5 30;13.5 30;13.5 30;13.5 30];

MC_dataset{5}.identificator = '*AAAG*'; % trials 1&2 : 1st trial effect
MC_dataset{5}.NO = [];
MC_dataset{5}.YES = [1 2 3 4 5 6:11];
MC_dataset{5}.YESstimulat = [13.0 30;13.0 30;13.0 30;13.0 30;13.0 30; 2 5;2 5;2 5;2 5;2 5;2 5  ];



%% spike times

clear spikeTimes B

% AAAB
jj = 1;
FileList = dir(MC_dataset{jj}.identificator);
for k = 1:numel(FileList)
    load(FileList(k).name,'-mat');
    A = data.ephys.trace_1;
    AA = A-medfilt1(A,500);
    B{jj}(k,:) = AA;
    spikeTimes{jj,k} = find(AA > 12 & circshift(AA,1) < 12);
end

% AAAF
jj = 2;
FileList = dir(MC_dataset{jj}.identificator);
for k = 1:numel(FileList)
    load(FileList(k).name,'-mat');
    A = data.ephys.trace_1;
    AA = A-medfilt1(A,500);
    B{jj}(k,:) = AA;
    spikeTimes{jj,k} = find(AA > 12 & circshift(AA,1) < 12);
end

% AAAH
jj = 3;
FileList = dir(MC_dataset{jj}.identificator);
for k = 1:numel(FileList)
    load(FileList(k).name,'-mat');
    A = data.ephys.trace_1;
    AA = A-medfilt1(A,500);
    B{jj}(k,:) = AA;
    spikeTimes{jj,k} = find(AA > 12 & circshift(AA,1) < 12);
end

% AAAE
jj = 4;
FileList = dir(MC_dataset{jj}.identificator);
for k = 1:numel(FileList)
    load(FileList(k).name,'-mat');
    A = data.ephys.trace_1;
    AA = A-medfilt1(A,500);
    B{jj}(k,:) = AA;
    spikeTimes{jj,k} = find(AA > 1 & circshift(AA,1) < 1);
end

% AAAG
jj = 5;
FileList = dir(MC_dataset{jj}.identificator);
for k = 1:numel(FileList)
    load(FileList(k).name,'-mat');
    A = data.ephys.trace_1;
    AA = A-medfilt1(A,500);
    B{jj}(k,:) = AA;
    spikeTimes{jj,k} = find(AA > 0.5 & circshift(AA,1) < 0.5 & circshift(AA,2) < 0.5);
end


clear Spiked
counter = 1;
for jj = 1:4%5%:5%:5
    jj
    for k = 1:36%numel(MC_dataset{jj}.NO)
        ST_temp = spikeTimes{jj,k};
        if any(k == MC_dataset{jj}.YES)
            if jj == 5 && k > 5
%                 for pp = 1:10 % special case treatment
%                     offset = 2+(pp-1)*3;
%                     ix = find( abs(ST_temp-offset*1e4) < 1e4);
%                     Spiked{counter} = ST_temp(ix)-offset*1e4;
%                     counter = counter + 1;
%                 end
            else
                for pp = 1:2
                    offset = MC_dataset{jj}.YESstimulat(find(k == MC_dataset{jj}.YES),pp);
%                     if pp == 1
%                         offset = MC_dataset{jj}.YESstimulat(4,pp);
%                     else
%                         offset = 30;
%                     end
                    ix = find( abs(ST_temp-offset*1e4) < 1e4);
                    Spiked{counter} = ST_temp(ix)-offset*1e4;
                    try
                        [k,counter,find(Spiked{counter}>0 & Spiked{counter}<4000),Spiked{counter}(find(Spiked{counter}>0 & Spiked{counter}<4000))]
                    end
                    counter = counter + 1;
                        
                end
            end
        end
    end
end

SpikeD = [];
for p = 1:numel(Spiked)
    SpikeD = [SpikeD,Spiked{p}'];
end

figure, hist(SpikeD/10,400)
figure, hist(SpikeD/10,100)



