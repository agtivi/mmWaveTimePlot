%% 1.1 micro-benchmark cdf phase drift removal at 70,80 db 
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["(a) small cardboard", "(b) large cardboard", "(c) small paper bag", ...
    "(d) large paper bag", "(e) small bag of chips", "(f) large bag of chips"];
scenario = 'radar0.5m_source0.5m';
speakers = ["mccs0", "fadg0"]; 
soundfiles = ["sa1", "sa1"];
dbs = [80];

% LLR = -1*ones(length(objects), length(speakers)*length(dbs));
% WSS = -1*ones(length(objects), length(speakers)*length(dbs));
% STOI1 = -1*ones(length(objects), length(speakers)*length(dbs));
% STOI2 = -1*ones(length(objects), length(speakers)*length(dbs));
% STOI = -1*ones(length(objects), length(speakers)*length(dbs));
% NISTSNR = -1*ones(length(objects), length(speakers)*length(dbs));
% SEGSNR = -1*ones(length(objects), length(speakers)*length(dbs));
psd_dc = -1*ones(2, length(objects)*length(speakers)*length(dbs));
seq = 0;
for ii=1:6
    for jj=1:length(speakers)
        for kk=1:length(dbs)
            seq = seq + 1;
%             [yclean, fs_clean] = audioread(sprintf('audios/%s/%s_%ddb.wav',speakers(jj), soundfiles(jj),dbs(kk)));
            folder = sprintf('B:/experiment_data2/%s/%s/profile3/radarcube', objects(ii),scenario);
            name = sprintf('%s/%s_%s_%ddb.mat',folder, speakers(jj), soundfiles(jj), dbs(kk));
            load(name);
            [fftout, I] = rangeFFT(datacube.adcdata(:,1,1), datacube.params);
            close(gcf);
            clear rangecube;
            rangecube = fft(datacube.adcdata, datacube.params.opRangeFFTSize, 1);
            y_drift = angle(reshape(rangecube(I,:,:), [], 1)); % TODO: piecewise phase correction
            Fs_drift = 1/datacube.params.chirpCycleTime;
            
            folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq', objects(ii),scenario);
            name = sprintf('%s/%s_%s_%ddb.wav',folder, speakers(jj), soundfiles(jj), dbs(kk));
            [y_nodrift, Fs_nodrift] = audioread(name);

%             figure; plot(y)
            nsc = fix(0.1*Fs_drift);  nov = fix(nsc*0.8);  nff = max(4096,2^nextpow2(nsc));
            [s,f,t, ps_drift]= spectrogram(y_drift./max(abs(y_drift)),hamming(nsc),nov,nff, Fs_drift, 'yaxis','MinThreshold',-150);
            ps_drift = max(10*log10(ps_drift(1:fix(50/(Fs_drift/nff)), :)), [], 1);
            nsc = fix(0.1*Fs_nodrift);  nov = fix(nsc*0.8);  nff = max(4096,2^nextpow2(nsc));
            [s,f,t, ps_nodrift] = spectrogram(y_nodrift./max(abs(y_nodrift)),hamming(nsc),nov,nff, Fs_nodrift, 'yaxis','MinThreshold',-150);
            ps_nodrift = max(10*log10(ps_nodrift(1:fix(50/(Fs_nodrift/nff)), :)), [], 1);
            
            % see how highpass filtering performs
%             bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
%                 'HalfPowerFrequency1',100,'HalfPowerFrequency2',2000, 'DesignMethod','butter', ...
%                 'SampleRate',Fs_drift);
%             y_highpass = filter(bpFilt, y_drift);
%             y_highpass = y_highpass(1001:end);
%             nsc = fix(0.1*Fs_drift);  nov = fix(nsc*0.8);  nff = max(4096,2^nextpow2(nsc));
%             figure(1);
%             spectrogram(y_drift./max(abs(y_drift)),hamming(nsc),nov,nff, Fs_drift, 'yaxis','MinThreshold',-150);   ylim([0 2]);
%             figure(2);
%             spectrogram(y_highpass./max(abs(y_highpass)),hamming(nsc),nov,nff, Fs_drift, 'yaxis','MinThreshold',-150);   ylim([0 2]);
%             figure(3);
%             spectrogram(y_nodrift./max(abs(y_nodrift)),hamming(nsc),nov,nff, Fs_drift, 'yaxis','MinThreshold',-150);   ylim([0 2]);
%             
%             figure(4); subplot(3,1,1); plot(y_drift); subplot(3,1,2); plot(y_highpass);
%             subplot(3,1,3); plot(y_nodrift);
            
            figure(123); subplot(4,6,seq); plot(ps_drift); hold on;  plot(ps_nodrift);
            psd_dc(1, seq) = mean(ps_drift(1:200));
            psd_dc(2, seq) = mean(ps_nodrift(1:200));
        end
    end
end

fontsize = 13;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*3 200*2]); 
% spacing = [0.1,0.1]; %y spacing, x spacing
% height_margin = 0.1,0.1];
% width_margin = [0.1,0.1];
% ax_move_right = 0.00;
% ax1 = subtightplot(1,2, 1, spacing, height_margin, width_margin);
% cdfplot(STOI1(good_idx)); hold on;
% cdfplot(STOI2(good_idx)); hold on;
[h1, stats1]= cdfplot(psd_dc(1, :)); hold on;
[h2, stats2]= cdfplot(psd_dc(2, :)); hold on;
set(h1 ,'LineWidth',2 , 'LineStyle', '-.');
set(h2 ,'LineWidth',2);
xlabel("Power spectral density (dB/Hz)");
ylabel("CDF");
legend(["wo/ phase drift removed", "w/ phase drift removed"], "Location", "south", "FontSize", fontsize);
% xlim([0 0.2]);
title("");
exportgraphics(fig,sprintf('figures/phase_drift_removal.png'),'Resolution',300) 
fprintf(sprintf('psd median: %.3f, psd median: %.3f \n', ...
    stats1.median, stats2.median));
%% 1.2 micro-benchmark cdf STOI gain at 80 db 
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["(a) small cardboard", "(b) large cardboard", "(c) small paper bag", ...
    "(d) large paper bag", "(e) small bag of chips", "(f) large bag of chips"];
scenario = 'radar0.5m_source0.5m';
speakers = ["mccs0", "fadg0"]; %,"beatles", "adele"];
soundfiles = ["sa1", "sa1", "let_it_be",...
    "someone_like_you_verse"];
dbs = [80];

LLR = -1*ones(length(objects), length(speakers)*length(dbs));
WSS = -1*ones(length(objects), length(speakers)*length(dbs));
STOI1 = -1*ones(length(objects), length(speakers)*length(dbs));
STOI2 = -1*ones(length(objects), length(speakers)*length(dbs));
STOI = -1*ones(length(objects), length(speakers)*length(dbs));
NISTSNR = -1*ones(length(objects), length(speakers)*length(dbs));
SEGSNR = -1*ones(length(objects), length(speakers)*length(dbs));
for ii=1:6
    for jj=1:length(speakers)
        for kk=1:length(dbs)
            [yclean, fs_clean] = audioread(sprintf('audios/%s/%s_%ddb.wav',speakers(jj), soundfiles(jj),dbs(kk)));
%             folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq', objects(ii),scenario);
%             name = sprintf('%s/%s_%s_%ddb.wav',folder, speakers(jj), soundfiles(jj), dbs(kk));
%             [y_eq, Fs] = audioread(name);
            folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq', objects(ii),scenario);
            name = sprintf('%s/%s_%s_%ddb.wav',folder, speakers(jj), soundfiles(jj), dbs(kk));
            [y_noeq, Fs] = audioread(name);
            
            y_eq = noiseReduction_YW(y_noeq, Fs);

            bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',Fs);
            bpFilt1 = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',fs_clean);
            y_eq = filter(bpFilt, y_eq);
            %         y_noeq = filter(bpFilt, y_noeq);
            yclean = filter(bpFilt1, yclean);
            
            [llr1, wss1, stoi_val1, nist_snr1,segsnr1]=get_measures(yclean, fs_clean, y_noeq, Fs, 0);
            [llr2, wss2, stoi_val2, nist_snr2,segsnr2]=get_measures(yclean, fs_clean, y_eq, Fs, 0);
            LLR(ii, (jj-1)*length(dbs)+kk) = (llr1-llr2)/llr1;
            WSS(ii, (jj-1)*length(dbs)+kk) = (wss1-wss2)/wss1;
            STOI1(ii, (jj-1)*length(dbs)+kk) = stoi_val1;
            STOI2(ii, (jj-1)*length(dbs)+kk) = stoi_val2;
            STOI(ii, (jj-1)*length(dbs)+kk) = stoi_val2 - stoi_val1;
            NISTSNR(ii, (jj-1)*length(dbs)+kk) = (nist_snr2-nist_snr1)/nist_snr1;
            %         SEGSNR(ii, jj) = segsnr;
            %     fprintf(sprintf('%s LLR: %.2f  WSS: %.2f  STOI: %.2f\n', titles(ii),llr,wss,stoi_val ));
            
            %         figure(123); subplot(length(dbs), length(speakers), (kk-1)*length(speakers)+jj);
            %         nsc = fix(0.1*Fs);
            %         nov = fix(nsc/2);
            %         nff = max(4096,2^nextpow2(nsc));
            %         spectrogram(y,hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',-150); colorbar('off');
            %         ylim([0 1]);
            %         title(sprintf('%s %s', titles(ii), speakers(jj)  ))
        end
    end
end
% 

fontsize = 13;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*3 200*2]); 
% spacing = [0.1,0.1]; %y spacing, x spacing
% height_margin = [0.1,0.1];
% width_margin = [0.1,0.1];
% ax_move_right = 0.00;
% ax1 = subtightplot(1,2, 1, spacing, height_margin, width_margin);
% good_idx =  find(STOI(:)>-0.1);
% STOI1 = STOI1(:);
% STOI2 = STOI2(:);
% cdfplot(STOI1(good_idx)); hold on;
% cdfplot(STOI2(good_idx)); hold on;
[h1, stats1]= cdfplot(STOI1(:)); hold on;
[h2, stats2]= cdfplot(STOI2(:)); hold on;
set(h1 ,'LineWidth',2 , 'LineStyle', '-.');
set(h2 ,'LineWidth',2);
xlabel(" Intelligibility (STOI)");
ylabel("CDF");
legend(["wo/ noise reduction", "w/ noise reduction"], "Location", "southeast", "FontSize", fontsize);
% xlim([0 0.2]);
title("");
exportgraphics(fig,sprintf('figures/stoi_gain_denoising.png'),'Resolution',300) 
fprintf(sprintf('vibration_mag median: %.3f, phase drift median: %.3f \n', ...
    stats1.median, stats2.median));
% fontsize = 13;
% figure('DefaultAxesFontSize', fontsize);
% model_series = mean(NISTSNR, 2);%[10 40 50 60; 20 50 60 70; 30 60 80 90];
% model_error = std(NISTSNR,0,2)/2;%[1 4 8 6; 2 5 9 12; 3 6 10 13];
% 
% x = 1:length(model_series);
% b = bar(x, model_series);
% hold on
% er = errorbar(model_series,model_error);    
% er.Color = [0 0 0];                            
% er.LineStyle = 'none';  
% er.MarkerSize = 10;
% er.LineWidth = 1.0;
% hold off
% ylabel('NIST SNR Gain (dB)');
% set(gca,'xticklabel',titles);
% xtickangle(25);
% % print('figures/nistsnr_gain', '-dpng', '-r300');
% ax = gca;
% exportgraphics(ax,'figures/nistsnr_gain.png','Resolution',300) 

% b = bar(model_series, 'grouped');
% hold on
% % Find the number of groups and the number of bars in each group
% [ngroups, nbars] = size(model_series);
% % Calculate the width for each bar group
% groupwidth = min(0.8, nbars/(nbars + 1.5));
% % Set the position of each error bar in the centre of the main bar
% % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
% for i = 1:nbars
%     % Calculate center of each bar
%     x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
%     errorbar(x, model_series(:,i), model_error(:,i), 'k', 'linestyle', 'none');
% end
% hold off
%% 2. speech spectrograms, plot mccs0/fadg0/me sa1/sa2  80db spectrograms
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
% titles = ["small cardboard", "large cardboard", "small paper bag", ...
%     "large paper bag", "small bag of chips", "large bag of chips"];
titles = ["(a) sa1 clean", "(b) sa1 recovered", "(c) sa2 clean", "(d) sa2 recovered", ...
    "(e) sa1 clean", "(f) sa1 recovered", "(g) sa2 clean", "(h) sa2 recovered",...
    "(i) sa1 clean", "(j) sa1 recovered", "(k) sa2 clean", "(l) sa2 recovered"];
scenario = 'radar0.5m_source0.5m';
speakers = ["mccs0", "mccs0", "fadg0", "fadg0", "me", "me", "beatles", "adele"];
soundfiles = ["sa1_80db.wav", "sa2_80db.wav", "sa1_80db.wav","sa2_80db.wav",...
    "sa1_80db.wav", "sa2_80db.wav", "let_it_be_80db.wav", "someone_like_you_verse_80db.wav"];

% save as one figure 
fontsize = 14;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*6 200*3]); 
for ii=6 % layschip
    for jj=1:length(speakers)-2
        [yclean, fs_clean] = audioread(sprintf('audios/%s/%s',speakers(jj), soundfiles(jj)));
        folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq', objects(ii),scenario);
        name = sprintf('%s/%s_%s',folder, speakers(jj), soundfiles(jj));
        [y, Fs] = audioread(name);
       
        x = yclean(:);
        [x2, y2] = alignsignals(x,y);
        zeros_prepended = length(x2) - length(x);
        x2= x2(  zeros_prepended + [1: min(length(y)-zeros_prepended,length(x))] );
        y2= y2(  zeros_prepended + [1: min(length(y)-zeros_prepended,length(x))] );
        yclean = x2;
        y = y2;
        
        spacing = [0.1,0.003]; %y spacing, x spacing
        height_margin = [0.1,0.1];
        width_margin = [0.1,0.1];
        ax_move_right = 0.00;
        spectrogram_min = -90;
        % plot clean signal
        ax1 = subtightplot(3,4, (jj-1)*2+1, spacing, height_margin, width_margin);
        nsc = fix(0.1*fs_clean);
        nov = fix(nsc*0.8);
        nff = max(4096,2^nextpow2(nsc));
        spectrogram(yclean./max(abs(yclean)),hamming(nsc),nov,nff, fs_clean, 'yaxis','MinThreshold',spectrogram_min);
        ylim([0 1]);
        xlabel('');
        ylabel('');
        set(colorbar,'visible','off')
        c1 = narrow_colorbar;
        c1.FontSize = fontsize -1;
        c1.Position(1) = c1.Position(1) - 0.005;
        c1.YLim = [spectrogram_min -20];
        title(titles((jj-1)*2+1));
        
        % plot recovered signal
        ax2 = subtightplot(3,4, (jj-1)*2+2, spacing, height_margin, width_margin);
        nsc = fix(0.1*Fs);
        nov = fix(nsc*0.8);
        nff = max(4096,2^nextpow2(nsc));
        spectrogram(y./max(abs(y)),hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',spectrogram_min);
        ylim([0 1]);
        xlabel('');
        ylabel('');
        set(colorbar,'visible','off')
        c2 = narrow_colorbar;
        c2.FontSize = fontsize -1;
        c2.Position(1) = c2.Position(1) - 0.005;
        c2.YLim = [spectrogram_min -20];
        title(titles((jj-1)*2+2));
        
        if mod(jj,2)==1
            ax1.YLabel.String = 'Frequency (kHz)';
        else
            ylabel(c2,'dB/Hz');
        end
        
        if jj>=5
            ax1.XLabel.String = 'Time (secs)';
            ax2.XLabel.String = 'Time (secs)';
        end
    end
end
% ax = gca;
exportgraphics(fig,sprintf('figures/speech_spectrograms.png'),'Resolution',300) 

% % save as one figure, v2
% fontsize = 14;
% fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*6 200*3]); 
% for ii=6 % layschip
%     for jj=1:length(speakers)
%         for kk=1:2
%             if kk==1 % clean signal
%                 [y, Fs] = audioread(sprintf('audios/%s/%s',speakers(jj), soundfiles(jj)));
%                 if jj==1
%                     y = y(1:fix(8*Fs));
%                 end
%             else % recovered siganl
%                 folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq', objects(ii),scenario);
%                 name = sprintf('%s/%s_%s',folder, speakers(jj), soundfiles(jj));
%                 [y, Fs] = audioread(name);
%                 if jj==1
%                     y = y(fix(0.9*Fs):fix(8.9*Fs));
%                 elseif jj==2
%                     y = y(fix(0.7*Fs):fix(8.7*Fs));
%                 end
%             end
%             
%             plot_seq = (jj-1)*2+kk;
%                     spacing = [0.1,0.003]; %y spacing, x spacing
%                     height_margin = [0.3,0.1];
%                     width_margin = [0.1,0.1];
%                     ax_move_right = 0.00;
%             spectrogram_min = -90; 
% 
%             ax2 = subtightplot(1,4, plot_seq, spacing, height_margin, width_margin);
%             nsc = fix(0.1*Fs);
%             nov = fix(nsc*0.8);
%             nff = max(4096,2^nextpow2(nsc));
%             spectrogram(y./max(abs(y)),hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',spectrogram_min);
%             ylim([0 1.1]);
%             set(colorbar,'visible','off')
%             c2 = narrow_colorbar;
%             c2.FontSize = fontsize-1;
%             c2.Position(1) = c2.Position(1) - 0.005;
%             c2.YLim = [spectrogram_min -20];
%             title(titles(plot_seq));
%             ylabel("");
% %             xlabel("");
%             
%             if mod(plot_seq,4)==0
%                 ylabel(c2,'dB/Hz');
%             end
%             if mod(plot_seq,4)==1
%                 ylabel('Frequency (kHz)');
%             end
%         end
%     end
% end
% exportgraphics(fig,sprintf('figures/music_spectrograms.png'),'Resolution',300) 

%% 3. music spectrograms, plot let_it_be/someone_like_you 80db spectrograms
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
% titles = ["small cardboard", "large cardboard", "small paper bag", ...
%     "large paper bag", "small bag of chips", "large bag of chips"];
titles = ["(m) music1 clean", "(n)  music1 recovered", "(o) music2 clean", "(p) music2 recovered"];
scenario = 'radar0.5m_source0.5m';
speakers = ["beatles", "adele"];
soundfiles = ["let_it_be_80db.wav", "someone_like_you_verse_80db.wav"];

% save as one figure, v2
fontsize = 14;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*6 200*1]); 
for ii=6 % layschip
    for jj=1:length(speakers)
        for kk=1:2
            if kk==1 % clean signal
                [y, Fs] = audioread(sprintf('audios/%s/%s',speakers(jj), soundfiles(jj)));
                if jj==1
                    y = y(1:fix(8*Fs));
                end
            else % recovered siganl
                folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq', objects(ii),scenario);
                name = sprintf('%s/%s_%s',folder, speakers(jj), soundfiles(jj));
                [y, Fs] = audioread(name);
                if jj==1
                    y = y(fix(0.9*Fs):fix(8.9*Fs));
                elseif jj==2
                    y = y(fix(0.7*Fs):fix(8.7*Fs));
                end
            end
            
            plot_seq = (jj-1)*2+kk;
                    spacing = [0.1,0.003]; %y spacing, x spacing
                    height_margin = [0.3,0.1];
                    width_margin = [0.1,0.1];
                    ax_move_right = 0.00;
            spectrogram_min = -90; 

            ax2 = subtightplot(1,4, plot_seq, spacing, height_margin, width_margin);
            nsc = fix(0.1*Fs);
            nov = fix(nsc*0.8);
            nff = max(4096,2^nextpow2(nsc));
            spectrogram(y./max(abs(y)),hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',spectrogram_min);
            ylim([0 1.1]);
            set(colorbar,'visible','off')
            c2 = narrow_colorbar;
            c2.FontSize = fontsize-1;
            c2.Position(1) = c2.Position(1) - 0.005;
            c2.YLim = [spectrogram_min -20];
            title(titles(plot_seq));
            ylabel("");
%             xlabel("");
            
            if mod(plot_seq,4)==0
                ylabel(c2,'dB/Hz');
            end
            if mod(plot_seq,4)==1
                ylabel('Frequency (kHz)');
            end
        end
    end
end
exportgraphics(fig,sprintf('figures/music_spectrograms.png'),'Resolution',300) 

% % save as separate figures 
% for ii=6 % layschip
%     for jj=1:length(speakers)
%         for kk=1:2
%             if kk==1 % clean signal
%                 [y, Fs] = audioread(sprintf('audios/%s/%s',speakers(jj), soundfiles(jj)));
%                 if jj==1
%                     y = y(1:fix(8*Fs));
%                 end
%             else % recovered siganl
%                 folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq', objects(ii),scenario);
%                 name = sprintf('%s/%s_%s',folder, speakers(jj), soundfiles(jj));
%                 [y, Fs] = audioread(name);
%                 if jj==1
%                     y = y(fix(0.9*Fs):fix(8.9*Fs));
%                 elseif jj==2
%                     y = y(fix(0.7*Fs):fix(8.7*Fs));
%                 end
%             end
%             
%             fontsize = 20;
%             fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*3 200*2]);
%             plot_seq = (jj-1)*2+kk;
%             %         spacing = [0.1,0.003]; %y spacing, x spacing
%             %         height_margin = [0.3,0.1];
%             %         width_margin = [0.1,0.1];
%             %         ax_move_right = 0.00;
%             spectrogram_min = -90; 
%             % plot recovered signal
% %             ax2 = subtightplot(1,4, (jj-1)*2+2, spacing, height_margin, width_margin);
%             nsc = fix(0.1*Fs);
%             nov = fix(nsc*0.8);
%             nff = max(4096,2^nextpow2(nsc));
%             spectrogram(y./max(abs(y)),hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',spectrogram_min);
%             ylim([0 1.1]);
%             set(colorbar,'visible','off')
%             c2 = narrow_colorbar;
%             c2.FontSize = fontsize;
%             c2.Position(1) = c2.Position(1) - 0.02;
%             c2.YLim = [spectrogram_min -20];
%             title(titles(plot_seq));
%             ylabel("");
% %             xlabel("");
%             
%             if mod(plot_seq,4)==0
%                 ylabel(c2,'dB/Hz');
%             end
%             if mod(plot_seq,4)==1
%                 ylabel('Frequency (kHz)');
%             end
%             exportgraphics(fig,sprintf('figures/music_spectrograms_%s.png', char(96+plot_seq)),...
%                 'Resolution',300)
%         end
%     end
% end


% % save as one figure 
% fontsize = 14;
% fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*6 200*1]); 
% for ii=6 % layschip
%     for jj=1:length(speakers)
%         [yclean, fs_clean] = audioread(sprintf('audios/%s/%s',speakers(jj), soundfiles(jj)));
%         folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq', objects(ii),scenario);
%         name = sprintf('%s/%s_%s',folder, speakers(jj), soundfiles(jj));
%         [y, Fs] = audioread(name);
%        
% %         x = yclean(:);
% %         [x2, y2] = alignsignals(x,y);
% %         zeros_prepended = length(x2) - length(x);
% %         x2= x2(  zeros_prepended + [1: min(length(y)-zeros_prepended,length(x))] );
% %         y2= y2(  zeros_prepended + [1: min(length(y)-zeros_prepended,length(x))] );
% %         yclean = x2;
% %         y = y2;
%         if jj==1
%             yclean = yclean(1:fix(8*fs_clean));
%             y = y(fix(0.9*Fs):fix(8.9*Fs));
%         elseif jj==2
%             y = y(fix(0.7*Fs):fix(8.7*Fs));
%         end
%         
%         spacing = [0.1,0.003]; %y spacing, x spacing
%         height_margin = [0.3,0.1];
%         width_margin = [0.1,0.1];
%         ax_move_right = 0.00;
%         spectrogram_min = -90;
%         % plot clean signal
%         ax1 = subtightplot(1,4, (jj-1)*2+1, spacing, height_margin, width_margin);
%         nsc = fix(0.1*fs_clean);
%         nov = fix(nsc*0.8);
%         nff = max(4096,2^nextpow2(nsc));
%         spectrogram(yclean./max(abs(yclean)),hamming(nsc),nov,nff, fs_clean, 'yaxis','MinThreshold',spectrogram_min);
%         ylim([0 1.1]);
%         set(colorbar,'visible','off')
%         c1 = narrow_colorbar;
%         c1.FontSize = fontsize-3;
%         c1.Position(1) = c1.Position(1) - 0.005;
%         c1.YLim = [spectrogram_min -20];
%         title(titles((jj-1)*2+1));
%         
%         % plot recovered signal
%         ax2 = subtightplot(1,4, (jj-1)*2+2, spacing, height_margin, width_margin);
%         nsc = fix(0.1*Fs);
%         nov = fix(nsc*0.8);
%         nff = max(4096,2^nextpow2(nsc));
%         spectrogram(y./max(abs(y)),hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',spectrogram_min);
%         ylim([0 1.1]);
%         set(colorbar,'visible','off')
%         c2 = narrow_colorbar;
%         c2.FontSize = fontsize-3;
%         c2.Position(1) = c2.Position(1) - 0.005;
%         c2.YLim = [spectrogram_min -20];
%         title(titles((jj-1)*2+2));
%         
%         if mod(jj,2)==0
%             ax1.YLabel.String = '';
%             ax2.YLabel.String = '';
%             ylabel(c2,'dB/Hz');
% %             c2.FontSize = fontsize-3;
%         else
%             ax2.YLabel.String = '';
%         end
%         
% %         if jj>=5
% %             ax1.XLabel.String = 'Time (secs)';
% %             ax2.XLabel.String = 'Time (secs)';
% %         else
% %             ax1.XLabel.String = '';
% %             ax2.XLabel.String = '';
% %         end
%     end
% end
% % ax = gca;
% exportgraphics(fig,sprintf('figures/music_spectrograms.png'),'Resolution',300) 
%% 4. speech/music  table,  80 db, bag of chips,  sa1/sa2/songs  calculate LLR/WSS/STOI
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["small cardboard", "large cardboard", "small paper bag", ...
    "large paper bag", "small bag of chips", "large bag of chips"];
scenario = 'radar0.5m_source0.5m';
speakers = ["fadg0", "fadg0", "mccs0", "mccs0", "mabw0", "mabw0"];%, ...
%     "me", "me", "beatles", "adele"];
soundfiles = ["sa1_90db.wav", "sa2_90db.wav", "sa1_90db.wav","sa2_90db.wav",...
    "sa1_90db.wav", "sa2_90db.wav", "sa1_80db.wav", "sa2_80db.wav",...
    "let_it_be_80db.wav", "someone_like_you_verse_80db.wav"];

LLR = -1*ones(length(speakers), 1);
WSS =  -1*ones(length(speakers), 1);
STOI = -1*ones(length(speakers), 1);
% NISTSNR =  -1*ones(length(objects), length(speakers), length(dbs));
% SEGSNR =  -1*ones(length(objects), length(speakers), length(dbs));
for ii=6
    for jj=1:length(speakers)
        [yclean, fs_clean] = audioread(sprintf('audios/%s/%s',speakers(jj), soundfiles(jj)));
        folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq', objects(ii),scenario);
        name = sprintf('%s/%s_%s',folder, speakers(jj), soundfiles(jj));
        [y, Fs] = audioread(name);
%             figure; plot(y)
        y = noiseReduction_YW(y, Fs);

            bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',Fs);
            bpFilt1 = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',fs_clean);
            y = filter(bpFilt, y);
            yclean = filter(bpFilt1, yclean);
            
            [llr, wss, stoi_val, nist_snr,segsnr]=get_measures(yclean, fs_clean, y, Fs, 0);
            LLR(jj) = llr;
            WSS(jj) = wss;
            STOI(jj) = stoi_val;
%             NISTSNR(jj) = nist_snr;
%             SEGSNR(jj) = segsnr;
            %     fprintf(sprintf('%s LLR: %.2f  WSS: %.2f  STOI: %.2f\n', titles(ii),llr,wss,stoi_val ));
            
            %         figure(123); subplot(length(dbs), length(speakers), (kk-1)*length(speakers)+jj);
            %         nsc = fix(0.1*Fs);
            %         nov = fix(nsc/2);
            %         nff = max(4096,2^nextpow2(nsc));
            %         spectrogram(y,hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',-150); colorbar('off');
            %         ylim([0 1]);
            %         title(sprintf('%s %s', titles(ii), speakers(jj)  ))
    end
end

[LLR WSS STOI]
%% 5.  impact of sound level across 6 objects
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["small cardboard", "large cardboard", "small paper bag", ...
    "large paper bag", "small bag of chips", "large bag of chips"];
scenario = 'radar0.5m_source0.5m';
speakers = ["mccs0", "fadg0"]; %,"beatles", "adele"];
soundfiles = ["sa1", "sa1", "let_it_be",...
    "someone_like_you_verse"];
dbs = [60 70 80];

LLR = -1*ones(length(objects), length(speakers), length(dbs));
WSS =  -1*ones(length(objects), length(speakers), length(dbs));
STOI =  -1*ones(length(objects), length(speakers), length(dbs));
% NISTSNR =  -1*ones(length(objects), length(speakers), length(dbs));
% SEGSNR =  -1*ones(length(objects), length(speakers), length(dbs));
for ii=1:6
    for jj=1:length(speakers)
        for kk=1:length(dbs)
            [yclean, fs_clean] = audioread(sprintf('audios/%s/%s_%ddb.wav',speakers(jj), soundfiles(jj),dbs(kk)));
            folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq', objects(ii),scenario);
            name = sprintf('%s/%s_%s_%ddb.wav',folder, speakers(jj), soundfiles(jj), dbs(kk));
            [y, Fs] = audioread(name);
            y = noiseReduction_YW(y, Fs);
            
            bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',Fs);
            bpFilt1 = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',fs_clean);
            y = filter(bpFilt, y);
            yclean = filter(bpFilt1, yclean);
            
%             sound(y./max(abs(y)),Fs);
            [llr, wss, stoi_val, nist_snr,segsnr]=get_measures(yclean, fs_clean, y, Fs, 0);
            LLR(ii,jj,kk) = llr;
            WSS(ii,jj,kk) = wss;
            STOI(ii,jj,kk) = stoi_val;
%             NISTSNR(ii,jj,kk) = nist_snr;
%             SEGSNR(ii,jj,kk) = segsnr;
            %     fprintf(sprintf('%s LLR: %.2f  WSS: %.2f  STOI: %.2f\n', titles(ii),llr,wss,stoi_val ));
            
            %         figure(123); subplot(length(dbs), length(speakers), (kk-1)*length(speakers)+jj);
            %         nsc = fix(0.1*Fs);
            %         nov = fix(nsc/2);
            %         nff = max(4096,2^nextpow2(nsc));
            %         spectrogram(y,hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',-150); colorbar('off');
            %         ylim([0 1]);
            %         title(sprintf('%s %s', titles(ii), speakers(jj)  ))
        end
    end
end

% 4. impact of volume across 6 objects
fontsize = 13;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*3 200*2]); 
h = plot(dbs, squeeze(mean(STOI,2)), "LineWidth", 1.5, "MarkerSize", 8);
xticks(dbs);
set(h,{'Marker'},{'+';'s';'o';'x';'^';'p'});
grid on;
ylim([0.1 0.85]);
legend(titles, "Location", "northwest", "FontSize", fontsize);
ylabel('Intelligibility (STOI) ');
xlabel("Sound pressure level (dB)");
exportgraphics(fig,'figures/impact_volume.png','Resolution',300);

%% 6. impact of sizes (60-80db) 
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["small cardboard", "large cardboard", "small paper bag", ...
    "large paper bag", "small bag of chips", "large bag of chips"];
scenario = 'radar0.5m_source0.5m';
speakers = ["mccs0", "fadg0"]; %,"beatles", "adele"];
soundfiles = ["sa1", "sa1", "let_it_be",...
    "someone_like_you_verse"];
dbs = [80];

LLR = -1*ones(length(objects), length(speakers), length(dbs));
WSS =  -1*ones(length(objects), length(speakers), length(dbs));
STOI =  -1*ones(length(objects), length(speakers), length(dbs));
% NISTSNR =  -1*ones(length(objects), length(speakers), length(dbs));
% SEGSNR =  -1*ones(length(objects), length(speakers), length(dbs));
for ii=1:6
    for jj=1:length(speakers)
        for kk=1:length(dbs)
            [yclean, fs_clean] = audioread(sprintf('audios/%s/%s_%ddb.wav',speakers(jj), soundfiles(jj),dbs(kk)));
            folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq', objects(ii),scenario);
            name = sprintf('%s/%s_%s_%ddb.wav',folder, speakers(jj), soundfiles(jj), dbs(kk));
            [y, Fs] = audioread(name);
            y = noiseReduction_YW(y, Fs);

            bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',Fs);
            bpFilt1 = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',fs_clean);
            y = filter(bpFilt, y);
            yclean = filter(bpFilt1, yclean);
            
            [llr, wss, stoi_val, nist_snr,segsnr]=get_measures(yclean, fs_clean, y, Fs, 0);
            LLR(ii,jj,kk) = llr;
            WSS(ii,jj,kk) = wss;
            STOI(ii,jj,kk) = stoi_val;
%             NISTSNR(ii,jj,kk) = nist_snr;
%             SEGSNR(ii,jj,kk) = segsnr;
            %     fprintf(sprintf('%s LLR: %.2f  WSS: %.2f  STOI: %.2f\n', titles(ii),llr,wss,stoi_val ));
            
            %         figure(123); subplot(length(dbs), length(speakers), (kk-1)*length(speakers)+jj);
            %         nsc = fix(0.1*Fs);
            %         nov = fix(nsc/2);
            %         nff = max(4096,2^nextpow2(nsc));
            %         spectrogram(y,hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',-150); colorbar('off');
            %         ylim([0 1]);
            %         title(sprintf('%s %s', titles(ii), speakers(jj)  ))
        end
    end
end


% STOI(:,:,3)
a = reshape(STOI, length(objects), length(speakers)*length(dbs));
% a = a(:, 3:6);
% mean(a,2)
fontsize = 13;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*3 200*2]); 
model_series = reshape(mean(a, 2), 2, 3).';%[10 40 50 60; 20 50 60 70; 30 60 80 90];
model_error = reshape(std(a, 0, 2), 2, 3).'/2;%[1 4 8 6; 2 5 9 12; 3 6 10 13];

% x = 1:length(model_series);
b = bar(model_series, 'grouped');
hold on
% Find the number of groups and the number of bars in each group
[ngroups, nbars] = size(model_series);
% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar
% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    er = errorbar(x, model_series(:,i), model_error(:,i), 'k*', 'linestyle', 'none');
    er.MarkerSize = 10;
    er.LineWidth = 1.0;
end
hold off
grid on;
ylabel('Intelligibility (STOI) ');
set(gca,'xticklabel', ["Cardboard", "Paper bag", "Bag of chips"]);
% xlabel("Sound Pressure Level (dB SPL)");
legend(["Small", "Large"], "Location", "northwest", "FontSize", fontsize);
% set(gca,'xticklabel',titles);
% xtickangle(25);
% print('figures/nistsnr_gain', '-dpng', '-r300');
% ax = gca;
exportgraphics(fig,'figures/impact_size.png','Resolution',300);

%% 7.  impact of background noise level, bag of chips at 80 dB
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["small cardboard", "large cardboard", "small paper bag", ...
    "large paper bag", "small bag of chips", "large bag of chips"];
scenario = 'radar0.5m_source0.5m';
speakers = ["mccs0", "mccs0", "fadg0",  "fadg0"]; %,"beatles", "adele"];
soundfiles = ["sa1", "sa2","sa1", "sa2"];
noise_suffix = ["acon", "typing", "typing_samedesk"];
% dbs = [80];

% LLR = -1*ones(length(objects), length(speakers), length(dbs));
% WSS =  -1*ones(length(objects), length(speakers), length(dbs));
STOI =  -1*ones(length(noise_suffix)+1, length(speakers));
% NISTSNR =  -1*ones(length(objects), length(speakers), length(dbs));
% SEGSNR =  -1*ones(length(objects), length(speakers), length(dbs));
for ii=6
    for kk=1:length(noise_suffix)
        for jj=1:length(speakers)
            [yclean, fs_clean] = audioread(sprintf('audios/%s/%s_80db.wav',speakers(jj), soundfiles(jj)));
            folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq', objects(ii),scenario);
            name = sprintf('%s/%s_%s_80db.wav',folder, speakers(jj), soundfiles(jj));
            [y, Fs] = audioread(name);
            name = sprintf('%s/%s_%s_80db_%s.wav',folder, speakers(jj), soundfiles(jj), noise_suffix(kk));
            [y_noisy, Fs] = audioread(name);
            
            bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',Fs);
            bpFilt1 = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',fs_clean);
            y = filter(bpFilt, y);
            y_noisy = filter(bpFilt, y_noisy);
            yclean = filter(bpFilt1, yclean);
            
            [llr, wss, stoi_val, nist_snr,segsnr]=get_measures(yclean, fs_clean, y, Fs, 0);
            STOI(1, jj) = stoi_val;
            [llr, wss, stoi_val, nist_snr,segsnr]=get_measures(yclean, fs_clean, y_noisy, Fs, 0);
            STOI(1+kk, jj) = stoi_val;
            %             NISTSNR(ii,jj,kk) = nist_snr;
            %             SEGSNR(ii,jj,kk) = segsnr;
            %     fprintf(sprintf('%s LLR: %.2f  WSS: %.2f  STOI: %.2f\n', titles(ii),llr,wss,stoi_val ));
            
            %         figure(123); subplot(length(dbs), length(speakers), (kk-1)*length(speakers)+jj);
            %         nsc = fix(0.1*Fs);
            %         nov = fix(nsc/2);
            %         nff = max(4096,2^nextpow2(nsc));
            %         spectrogram(y,hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',-150); colorbar('off');
            %         ylim([0 1]);
            %         title(sprintf('%s %s', titles(ii), speakers(jj)  ))
        end
    end
end
% [mean(STOI1) mean(STOI2)]
% [std(STOI1) std(STOI2)]
% % STOI(:,:,3)


fontsize = 13;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*3 200*2]); 
model_series = mean(STOI, 2);%[10 40 50 60; 20 50 60 70; 30 60 80 90];
model_error = std(STOI, 0, 2)/2;%[1 4 8 6; 2 5 9 12; 3 6 10 13];

% x = 1:length(model_series);
b = bar(model_series);
hold on
% Find the number of groups and the number of bars in each group
[ngroups, nbars] = size(model_series);
% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar
% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    er = errorbar(x, model_series(:,i), model_error(:,i), 'k*', 'linestyle', 'none');
    er.MarkerSize = 10;
    er.LineWidth = 1.0;
end
hold off
ylabel('Intelligibility (STOI) ');
set(gca,'xticklabel', ["Quiet", "Window AC", "TYPE I", "TYPE II"]);
% xlabel("Sound Pressure Level (dB SPL)");
% legend(["wo/ noise source", "w/ noise source"], "Location", "northwest");
% set(gca,'xticklabel',titles);
xtickangle(0);
grid on;
% ylim([0 0.9]);
% print('figures/nistsnr_gain', '-dpng', '-r300');
% ax = gca;
exportgraphics(fig,'figures/impact_background_noise.png','Resolution',300);
%% 8.  impact of radar distance, bag of chips at 80 dB
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["small cardboard", "large cardboard", "small paper bag", ...
    "large paper bag", "small bag of chips", "large bag of chips"];
scenario = ["radar0.5m_source0.5m", "radar1.0m_source0.5m", "radar1.5m_source0.5m"];
speakers = ["mccs0", "mccs0", "fadg0",  "fadg0"]; %,"beatles", "adele"];
soundfiles = ["sa1", "sa2","sa1", "sa2"];
% dbs = [80];

% LLR = -1*ones(length(objects), length(speakers), length(dbs));
% WSS =  -1*ones(length(objects), length(speakers), length(dbs));
STOI =  -1*ones(3, length(scenario), length(speakers));
% STOI2 =  -1*ones(length(speakers), 1);
% NISTSNR =  -1*ones(length(objects), length(speakers), length(dbs));
% SEGSNR =  -1*ones(length(objects), length(speakers), length(dbs));
for ii=2:2:6
    for kk=1:length(scenario)
        for jj=1:length(speakers)
            [yclean, fs_clean] = audioread(sprintf('audios/%s/%s_80db.wav',speakers(jj), soundfiles(jj)));
            folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq', objects(ii),scenario(kk));
            name = sprintf('%s/%s_%s_80db.wav',folder, speakers(jj), soundfiles(jj));
            [y, Fs] = audioread(name);
            y = noiseReduction_YW(y, Fs);
            bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',Fs);
            bpFilt1 = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',fs_clean);
            y = filter(bpFilt, y);
            yclean = filter(bpFilt1, yclean);
            
            [llr, wss, stoi_val, nist_snr,segsnr]=get_measures(yclean, fs_clean, y, Fs, 0);
            STOI(ii/2,kk,jj) = stoi_val;
            %             NISTSNR(ii,jj,kk) = nist_snr;
            %             SEGSNR(ii,jj,kk) = segsnr;
            %     fprintf(sprintf('%s LLR: %.2f  WSS: %.2f  STOI: %.2f\n', titles(ii),llr,wss,stoi_val ));
            
            %         figure(123); subplot(length(dbs), length(speakers), (kk-1)*length(speakers)+jj);
            %         nsc = fix(0.1*Fs);
            %         nov = fix(nsc/2);
            %         nff = max(4096,2^nextpow2(nsc));
            %         spectrogram(y,hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',-150); colorbar('off');
            %         ylim([0 1]);
            %         title(sprintf('%s %s', titles(ii), speakers(jj)  ))
        end
    end
end
[mean(STOI,3)]
[std(STOI,0,3) ]
%%
fontsize = 13;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*3 200*2]); 
model_series = mean(STOI, 3);%[10 40 50 60; 20 50 60 70; 30 60 80 90];
model_error = std(STOI,0,3)/2;%[1 4 8 6; 2 5 9 12; 3 6 10 13];

x = 1:size(model_series,2);
markers = ['+';'s';'o';'*';'^';'p'];
for ii=1:3
    er = errorbar(x, model_series(ii,:),model_error(ii,:));    
    % er.Color = [0 0 0];                            
    er.LineStyle = '-';
    er.Marker = markers(ii+1);
    er.MarkerSize = 8;
    er.LineWidth = 1.5;
    hold on;
end
grid on;
xlabel('Radar distance (meter)');
ylabel('Intelligibility (STOI)');
xticks(x);
set(gca,'xticklabel',[0.5 1.0 1.5]);
% xtickangle(25);
legend(titles(2:2:6), "Location", "southwest", "FontSize", fontsize);
exportgraphics(fig,'figures/impact_radar_distance.png','Resolution',300) 

%% 9.  impact of sampling rate, bag of chips at 80 dB
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["small cardboard", "large cardboard", "small paper bag", ...
    "large paper bag", "small bag of chips", "large bag of chips"];
scenario = ["radar0.5m_source0.5m"];
speakers = ["mccs0", "mccs0", "fadg0",  "fadg0"]; %,"beatles", "adele"];
soundfiles = ["sa1", "sa2","sa1", "sa2"];
% downsample = [1,2,3,4,5];
downsample = [1,0.75,0.5,0.25];
% dbs = [80];

% LLR = -1*ones(length(objects), length(speakers), length(dbs));
% WSS =  -1*ones(length(objects), length(speakers), length(dbs));
STOI =  -1*ones(3, length(downsample), length(speakers));
% STOI2 =  -1*ones(length(speakers), 1);
% NISTSNR =  -1*ones(length(objects), length(speakers), length(dbs));
% SEGSNR =  -1*ones(length(objects), length(speakers), length(dbs));
for ii=2:2:6
    for kk=1:length(downsample)
        for jj=1:length(speakers)
            [yclean, fs_clean] = audioread(sprintf('audios/%s/%s_80db.wav',speakers(jj), soundfiles(jj)));
            folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq', objects(ii),scenario);
            name = sprintf('%s/%s_%s_80db.wav',folder, speakers(jj), soundfiles(jj));
            [y, Fs] = audioread(name);
            
%              yclean = resample(yclean, 10000, floor(fs_clean));
%              y = y(1:downsample(kk):end);
%              new_Fs = Fs/downsample(kk);
%              y = noiseReduction_YW(y, new_Fs);
%              y = resample(y, 10000, floor(new_Fs));
% 
%              bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
%                 'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
%                 'SampleRate',10000);
% %             bpFilt = designfilt('bandpassfir','FilterOrder',20, ...
% %                      'CutoffFrequency1',100,'CutoffFrequency2',1000, ...
% %                      'SampleRate',new_Fs+1);
% %             fvtool(bpFilt)
%             y = filter(bpFilt, y);
%             yclean = filter(bpFilt, yclean);
%              STOI(kk,jj) = stoi(yclean,y, 10000);
%              continue;
            
% %             yclean = [yclean; zeros(2e4,1)];
% %             y = [y; zeros(2e4,1)];
%             yclean = decimate(yclean, downsample(kk));
%             new_fs_clean = fs_clean/downsample(kk);
% 
% %             y = decimate(y, downsample(kk));
% %             yclean = yclean(1:downsample(kk):end);
%             y = y(1:downsample(kk):end);
%             new_Fs = Fs/downsample(kk);
%             y = noiseReduction_YW(y, new_Fs);

            new_Fs = Fs*downsample(kk);
            new_fs_clean = fs_clean*downsample(kk);
            assert(new_Fs == new_fs_clean);
            yclean = resample(yclean, new_fs_clean, fs_clean);
            y =  resample(y, new_Fs, Fs);      
            
            bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',new_Fs);
            bpFilt1 = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',new_fs_clean);
%             bpFilt = designfilt('bandpassfir','FilterOrder',20, ...
%                      'CutoffFrequency1',100,'CutoffFrequency2',1000, ...
%                      'SampleRate',new_Fs+1);
%             fvtool(bpFilt)
            y = filter(bpFilt, y);
            yclean = filter(bpFilt1, yclean);
            
%             sound(yclean, new_fs_clean);
%             sound(y./max(abs(y)), new_Fs);
%             if jj==1
%                 figure(234); subplot(5,1,kk);
%                 wl = fix(0.1*new_Fs); nov = fix(wl*0.8);  nff = max(4096,2^nextpow2(wl));
%                 spectrogram(y,hamming(wl),nov,nff, new_Fs, 'yaxis','MinThreshold',-150);
%             end
            [llr, wss, stoi_val, nist_snr,segsnr]=get_measures(yclean, new_fs_clean,y, new_Fs, 0);
            STOI(ii/2, kk,jj) = stoi_val;
            %             NISTSNR(ii,jj,kk) = nist_snr;
            %             SEGSNR(ii,jj,kk) = segsnr;
            %     fprintf(sprintf('%s LLR: %.2f  WSS: %.2f  STOI: %.2f\n', titles(ii),llr,wss,stoi_val ));
            
            %         figure(123); subplot(length(dbs), length(speakers), (kk-1)*length(speakers)+jj);
            %         nsc = fix(0.1*Fs);
            %         nov = fix(nsc/2);
            %         nff = max(4096,2^nextpow2(nsc));
            %         spectrogram(y,hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',-150); colorbar('off');
            %         ylim([0 1]);
            %         title(sprintf('%s %s', titles(ii), speakers(jj)  ))
        end
    end
end
% [mean(STOI,2)]
% [std(STOI,0,2) ]
%%
fontsize = 13;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*3 200*2]); 
model_series = fliplr(mean(STOI, 3));%[10 40 50 60; 20 50 60 70; 30 60 80 90];
model_error = fliplr(std(STOI,0,3)/2);%[1 4 8 6; 2 5 9 12; 3 6 10 13];

x = 1:size(model_series,2);
markers = ['+';'s';'o';'*';'^';'p'];
for ii=1:3
    er = errorbar(x, model_series(ii,:),model_error(ii,:));    
    % er.Color = [0 0 0];                            
    er.LineStyle = '-';
    er.Marker = markers(ii+1);
    er.MarkerSize = 8;
    er.LineWidth = 1.5;
    hold on;
end
xlabel('Vibration sampling rate (kHz)');
ylabel('Intelligibility (STOI)');
grid on;
xticks(x);
set(gca,'xticklabel',fliplr(round(16.*downsample, 1)));
% xtickangle(25);
ylim([0.45 0.75]);
legend(titles(2:2:6), "Location", "northwest", "FontSize", fontsize);
exportgraphics(fig,'figures/impact_sampling_rate.png','Resolution',300) 

%% 10.  impact of incident angle, bag of chips at 80 dB
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["small cardboard", "large cardboard", "small paper bag", ...
    "large paper bag", "small bag of chips", "large bag of chips"];
scenario = ["radar0.5m_source0.5m", "radar0.5m_source0.5m_15deg", ...
    "radar0.5m_source0.5m_30deg", "radar0.5m_source0.5m_45deg",...
    "radar0.5m_source0.5m_60deg"];
speakers = ["mccs0", "mccs0", "fadg0",  "fadg0"]; %,"beatles", "adele"];
soundfiles = ["sa1", "sa2","sa1", "sa2"];
% dbs = [80];

% LLR = -1*ones(length(objects), length(speakers), length(dbs));
% WSS =  -1*ones(length(objects), length(speakers), length(dbs));
STOI =  -1*ones(3, length(scenario), length(speakers));
% STOI2 =  -1*ones(length(speakers), 1);
% NISTSNR =  -1*ones(length(objects), length(speakers), length(dbs));
% SEGSNR =  -1*ones(length(objects), length(speakers), length(dbs));
for ii=2:2:6
    for kk=1:length(scenario)
        for jj=1:length(speakers)
            [yclean, fs_clean] = audioread(sprintf('audios/%s/%s_80db.wav',speakers(jj), soundfiles(jj)));
            folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq', objects(ii),scenario(kk));
            name = sprintf('%s/%s_%s_80db.wav',folder, speakers(jj), soundfiles(jj));
            [y, Fs] = audioread(name);
            y = noiseReduction_YW(y, Fs);
            bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',Fs);
            bpFilt1 = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',fs_clean);
            y = filter(bpFilt, y);
            yclean = filter(bpFilt1, yclean);
%             sound(y./max(abs(y)), Fs);
            [llr, wss, stoi_val, nist_snr,segsnr]=get_measures(yclean, fs_clean, y, Fs, 0);
            STOI(ii/2,kk,jj) = stoi_val;
            %             NISTSNR(ii,jj,kk) = nist_snr;
            %             SEGSNR(ii,jj,kk) = segsnr;
            %     fprintf(sprintf('%s LLR: %.2f  WSS: %.2f  STOI: %.2f\n', titles(ii),llr,wss,stoi_val ));
            
            %         figure(123); subplot(length(dbs), length(speakers), (kk-1)*length(speakers)+jj);
            %         nsc = fix(0.1*Fs);
            %         nov = fix(nsc/2);
            %         nff = max(4096,2^nextpow2(nsc));
            %         spectrogram(y,hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',-150); colorbar('off');
            %         ylim([0 1]);
            %         title(sprintf('%s %s', titles(ii), speakers(jj)  ))
        end
    end
end
% [mean(STOI,2)]
% [std(STOI,0,2) ]
%%
fontsize = 13;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*3 200*2]); 
model_series = mean(STOI, 3);%[10 40 50 60; 20 50 60 70; 30 60 80 90];
model_error = std(STOI,0,3)/2;%[1 4 8 6; 2 5 9 12; 3 6 10 13];

x = 1:size(model_series,2);
markers = ['+';'s';'o';'*';'^';'p'];
for ii=1:3
    er = errorbar(x, model_series(ii,:),model_error(ii,:));    
    % er.Color = [0 0 0];                            
    er.LineStyle = '-';
    er.Marker = markers(ii+1);
    er.MarkerSize = 8;
    er.LineWidth = 1.5;
    hold on;
end
xlabel('Incident angle (degree)');
ylabel('Intelligibility (STOI)');
xticks(x);
grid on;
set(gca,'xticklabel',[0:15:60]);
legend(titles(2:2:6), "Location", "southwest", "FontSize", fontsize);
% xtickangle(25);
exportgraphics(fig,'figures/impact_incident_angle.png','Resolution',300) 
%% example denoising result
load( 'B:/experiment_data2/layschip/radar0.5m_source0.5m/profile3/radarcube/fadg0_sa1_80db.mat');
[fftout, I] = rangeFFT(datacube.adcdata(:,1,1), datacube.params);
rangecube = fft(datacube.adcdata, datacube.params.opRangeFFTSize, 1);
y = angle(reshape(rangecube(I,:,:), [], 1)); % TODO: piecewise phase correction
% figure; plot(y)
[y1, Fs1] = audioread('B:/experiment_data2/layschip/radar0.5m_source0.5m/profile3/wav_noeq/fadg0_sa1_80db.wav');
[y2, Fs2] = audioread('B:/experiment_data2/layschip/radar0.5m_source0.5m/profile3/wav_eq/fadg0_sa1_80db.wav');
[y3, Fs3] = audioread('audios/fadg0/SA1.WAV.wav');

% time domain signals
figure;
% subplot(3,1,1); plot([1:length(y)].*datacube.params.chirpCycleTime, y); 
% xlim([0.2, 4]); title("Raw audio signals"); ylabel("Amplitude");
subplot(3,1,1); plot([1:length(y1)]/Fs1, y1); 
% xlim([0.2, 4]); 
title("Hardware drift removed"); ylabel("Amplitude");
subplot(3,1,2); plot([1:length(y2)]/Fs2, y2); 
% xlim([0.2, 4]); 
title("Deniosed audio signals"); ylabel("Amplitude");
subplot(3,1,3); plot([1:length(y3)+1320]/Fs3, [zeros(1320,1); y3]); 
% xlim([0.2, 4]); 
title("Original microphone recording"); ylabel("Amplitude");
xlabel("Time (second)");

% spectrogram
fs = 1/datacube.params.chirpCycleTime;
wl = fix(0.1*fs);
nov = fix(wl*0.8);
nff = max(4096,2^nextpow2(wl));
% y4 = noiseReduction_YW(y4, fs);
bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
         'HalfPowerFrequency1',120,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
         'SampleRate',fs);
y4 = filter(bpFilt, y2);

spectrogram_min = -130;
figure(100); 
subplot(2,2,1);spectrogram(y(fix(0.93*fs):fix(4.13*fs)),hamming(wl),nov,nff, fs, 'yaxis','MinThreshold',spectrogram_min);ylim([0 1.2]); colorbar('off');
subplot(2,2,2);spectrogram(y1(fix(0.93*fs):fix(4.13*fs)),hamming(wl),nov,nff, fs, 'yaxis','MinThreshold',spectrogram_min);ylim([0 1.2]);colorbar('off');
subplot(2,2,3);spectrogram(y4(fix(0.93*fs):fix(4.13*fs)),hamming(wl),nov,nff, fs, 'yaxis','MinThreshold',spectrogram_min);ylim([0 1.2]);colorbar('off');
subplot(2,2,4);spectrogram(y3(fix(0.1*fs):fix(3.3*fs)),hamming(wl),nov,nff, fs, 'yaxis','MinThreshold',spectrogram_min);ylim([0 1.2]);colorbar('off');
% print('figures/fadg0_denoising', '-dpng', '-r300');
%%
fontsize = 17;
spectrogram_min = -130;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*5 200*4]); 
spacing = [0.1,0.04]; %y spacing, x spacing
height_margin = [0.1,0.1];
width_margin = [0.1,0.1];
ax_move_right = 0.00;
ax1 = subtightplot(2,2, 1, spacing, height_margin, width_margin);
spectrogram(y3(fix(0.1*fs):fix(3.3*fs)),hamming(wl),nov,nff, fs, 'yaxis','MinThreshold',spectrogram_min);
ylim([0 1.2]); set(colorbar,'visible','off')
c1 = narrow_colorbar; c1.Position(1) = c1.Position(1) - 0.005;
c1.FontSize = fontsize-1;
% c1.YLim = [spectrogram_min -20]; 
title('(a) Original speech');
ax1.XLabel.String = '';

ax1 = subtightplot(2,2, 2, spacing, height_margin, width_margin);
spectrogram(y(fix(0.93*fs):fix(4.13*fs)),hamming(wl),nov,nff, fs, 'yaxis','MinThreshold',spectrogram_min);
ylim([0 1.2]); set(colorbar,'visible','off')
c1 = narrow_colorbar; c1.Position(1) = c1.Position(1) - 0.005;
c1.FontSize = fontsize-1;
% c1.YLim = [spectrogram_min -20]; 
title('(b) Raw signals');
ax1.XLabel.String = '';
ax1.YLabel.String = '';
ylabel(c1,'dB/Hz');


ax1 = subtightplot(2,2, 3, spacing, height_margin, width_margin);
spectrogram(y1(fix(0.93*fs):fix(4.13*fs)),hamming(wl),nov,nff, fs, 'yaxis','MinThreshold',spectrogram_min);
ylim([0 1.2]); set(colorbar,'visible','off')
c1 = narrow_colorbar; c1.Position(1) = c1.Position(1) - 0.005;
c1.FontSize = fontsize-1;
% c1.YLim = [spectrogram_min -20]; 
title('(c) Phase drift removed');

ax1 = subtightplot(2,2, 4, spacing, height_margin, width_margin);
spectrogram(y4(fix(0.93*fs):fix(4.13*fs)),hamming(wl),nov,nff, fs, 'yaxis','MinThreshold',spectrogram_min);
ylim([0 1.2]); set(colorbar,'visible','off')
c1 = narrow_colorbar; c1.Position(1) = c1.Position(1) - 0.005;
c1.FontSize = fontsize-1;
% c1.YLim = [spectrogram_min -20]; 
title('(d) Filtered and denoised');
ax1.YLabel.String = '';
ylabel(c1,'dB/Hz');
exportgraphics(fig,sprintf('figures/example_processing.png'),'Resolution',300) 

%% plot chirpscan spectrogram for each object
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["(a) small cardboard", "(b) large cardboard", "(c) small paper bag", ...
    "(d) large paper bag", "(e) small bag of chips", "(f) large bag of chips"];seq = ["a", "b", "c", "d", "e", "f"];
scenario = 'radar0.5m_source1.0m';

% save as one figure 

fontsize = 13;
spectrogram_min = -90;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [10 10 200*4 200*4]); 
spacing = [0.08,0.01]; %y spacing, x spacing
height_margin = [0.1,0.1];
width_margin = [0.1,0.1];
ax_move_right = 0.00;
for ii=1:length(objects)
    eq_filename = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq/chirpscan.wav',...
        objects(ii),scenario);
    [y_eq, fs] = audioread(eq_filename);
    y_eq = y_eq(fix(0.2*fs):fix(4.5*fs));
    ax1 = subtightplot(3,2, ii, spacing, height_margin, width_margin);

%     ax.Position(1) = ax.Position(1) + 0.05;
%     subplot(3,2, ii);
    nsc = fix(0.1*fs);
    nov = fix(nsc*0.8);
    nff = max(4096,2^nextpow2(nsc));
%     fig = figure('DefaultAxesFontSize', fontsize); 
    spectrogram(y_eq./max(abs(y_eq)),hamming(nsc),nov,nff, fs, 'yaxis','MinThreshold',spectrogram_min); 
    set(colorbar,'visible','off')
    c = narrow_colorbar;
    c.Position(1) = c.Position(1) - 0.01;
    ax1.XLabel.String = '';
    
    if mod(ii,2)==0
       ax1.YLabel.String = '';
        ylabel(c,'dB/Hz');
        c.FontSize = fontsize-3;
    end
    
    if ii>=5
        ax1.XLabel.String = 'Time (secs)';
    end
%     title(sprintf('(%s) %s', seq(ii), titles(ii)));
%     ylabel('');
    ylim([0 4]);
    title(titles(ii));
end
% ax = gca;
exportgraphics(fig,sprintf('figures/chirpscan.png'),'Resolution',300) 

% % save as separate subfigures 
% fontsize = 14;
% for ii=1:length(objects)
%     eq_filename = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq/chirpscan.wav',...
%         objects(ii),scenario);
%     [y_eq, fs] = audioread(eq_filename);
%     y_eq = y_eq(fix(0.2*fs):fix(4.5*fs));
% 
%     nsc = fix(0.1*fs);
%     nov = fix(nsc*0.8);
%     nff = max(4096,2^nextpow2(nsc));
%     fig = figure('DefaultAxesFontSize', fontsize); 
%     spectrogram(y_eq./max(abs(y_eq)),hamming(nsc),nov,nff, fs, 'yaxis','MinThreshold',-80); 
% 
%     if mod(ii,2)==0
%         ylabel('');
%         c = get(gca, 'colorbar');
%         set(c, 'FontSize', fontsize);
%         ylabel(c,'dB/Hz');
%     else
%         c = get(gca, 'colorbar');
%         ylabel(c,'');
%     end
%     ylim([0 4]);
%     ax = gca;
%     exportgraphics(ax,sprintf('figures/chirpscan%d.png', ii),'Resolution',300) 
% end

% Give common xlabel, ylabel and title to your figure
% han=axes(fig,'visible','off'); 
% han.Title.Visible='on';
% han.XLabel.Visible='on';
% han.YLabel.Visible='on';
% ylabel(han,'Frequency (kHz)');
% xlabel(han,'Time (second)');
% title(han,'yourTitle');
%%
fontsize = 14;
% spectrogram_min = -140;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*2.5 200*3]); 
spacing = [0.08,0.001]; %y spacing, x spacing
height_margin = [0.0,0.1];
width_margin = [0.0,0.0];
ax_move_right = 0.00;

ax1 = subtightplot(2,2, 1, spacing, height_margin, width_margin);
imshow('figures/IWR1443 (1).jpg'); title('(a) IWR 1443');
ax1 = subtightplot(2,2, 2, spacing, height_margin, width_margin);
imshow('figures/cardboards (1).jpg'); title('(b) Cardboards');
ax1 = subtightplot(2,2, 3, spacing, height_margin, width_margin);
imshow('figures/paperbags (1).jpg'); title('(c) Paper bags');
ax1 = subtightplot(2,2, 4, spacing, height_margin, width_margin);
imshow('figures/bagofchips (1).jpg'); title('(d) Bags of chips');
exportgraphics(fig,sprintf('figures/experiment_stuffs.png'),'Resolution',300) 
%% plot cdf of RMS vibration phase magnitude for each object
close all;
clear all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["small cardboard", "large cardboard", "small paper bag", "large paper bag", "small bag of chips", "large bag of chips"];
scenario = 'radar0.5m_source0.5m';
% titles = ["george", "jackson", "lucas", "me"];
% rms_phases = zeros(10*5, length(objects));
% fontsize = 13;
% f1 = figure('DefaultAxesFontSize', fontsize);
vibration_mag = [];
phase_drift = [];
for ii=1:length(objects)
    folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq', objects(ii),scenario);
    name = sprintf('%s/fadg0_sa1_80db.wav',folder);
    %     copyfile(eq_filename, sprintf("B:/%s",eq_filename));
    [y_eq, fs] = audioread(name);
%     figure; plot(y_eq)
    r = abs(y_eq);
    mean_r = mean(r(1:fix(0.2*fs)));
    std_r = std(r(1:fix(0.2*fs)));
%     wl = fix(0.1*fs);
%     nov = fix(wl/2);
%     r = buffer( abs(y_eq), wl, nov);
%     r2 = rms(r, 1);
%     rms_phases(5*jj+kk,ii) = max(r2);
    
    vibration_mag = [vibration_mag(:); rad2deg(r(r>mean_r+3*std_r))];
    
    load(sprintf('B:/experiment_data2/%s/%s/profile3/radarcube/fadg0_sa1_80db.mat', objects(ii),scenario));
    [fftout, I] = rangeFFT(datacube.adcdata(:,1,1), datacube.params);
    rangecube = fft(datacube.adcdata, datacube.params.opRangeFFTSize, 1);
    y = angle(reshape(rangecube(I,:,:), [], 1)); 
    clear rangecube;
    figure; plot(rad2deg(y)); 
    yy = rad2deg(y(fix([0.4:0.1:1]/datacube.params.chirpCycleTime))) - rad2deg(y(1));
    phase_drift = [phase_drift; yy(:)];
%     figure(f1);
%     [h, stats]= cdfplot(  rad2deg(r(r>mean_r+3*std_r))); hold on;
%     set(h ,'LineWidth',2);
%     fprintf(sprintf('%s: %.3f\n', titles(ii), stats.median));
end
%%

fontsize = 16;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*4 200*2]); 
spacing = [0.1,0.12]; %y spacing, x spacing
height_margin = [0.2,0.1];
width_margin = [0.1,0.1];
ax_move_right = 0.00;

ax1 = subtightplot(1,2, 1, spacing, height_margin, width_margin);
% f1 = figure('DefaultAxesFontSize', fontsize);
% figure(f1); 
[h1, stats1]= cdfplot(1000*vibration_mag); hold on;
set(h1 ,'LineWidth',2);
xlabel(" Millidegree");
ylabel("CDF");
xlim([0 0.2]*1000);
xticks([0:0.05:0.2]*1000);
title("(a) RMS vibration magnitude");
% exportgraphics(f1,sprintf('figures/cdf_rms_phase_variation.png'),'Resolution',300) 

ax1 = subtightplot(1,2, 2, spacing, height_margin, width_margin);
% f2 = figure('DefaultAxesFontSize', fontsize);
% figure(f2); 
[h2, stats2]= cdfplot(phase_drift); hold on;
set(h2 ,'LineWidth',2);
% fprintf(sprintf('%s: %.3f\n', titles(ii), stats.median));
xlabel(" Degree");
ylabel("CDF");
title("(b) RMS phase drift");
xlim([6 14]);
xticks([6:2:14]);
% legend(titles);
exportgraphics(fig,sprintf('figures/cdf_rms_phase_variation.png'),'Resolution',300) 

fprintf(sprintf('vibration_mag median: %.3f, phase drift median: %.3f \n', ...
    stats1.median, stats2.median));
%% plot example Range FFT
load( 'B:/experiment_data2/smallpaperbag/radar0.5m_source0.5m/profile3/radarcube/fadg0_sa1_80db.mat');
% [fftout, I] = rangeFFT(datacube.adcdata(:,1,1), datacube.params);
params = datacube.params;
adc_data = datacube.adcdata(:,1,1);
fft_output = fft(adc_data, params.opRangeFFTSize);
    freq_interval = params.sampleRate/params.opRangeFFTSize;
    dist_interval = freq_interval*3e8/(2*params.freqSlope);
    % find objects within 0.1 - 1 m
    min_distance = 0.1;
    max_distance = 2.0;
    min_idx = ceil(min_distance/dist_interval);
    max_idx =  ceil(max_distance/dist_interval);
    [M, I] = max(abs(fft_output(min_idx:max_idx)));
    % [M, I] = max(abs(rangefft_output(1:end)));
    I = I + (min_idx-1) ;
    object_dist = dist_interval * (I-1);
    fprintf('Within %.2f - %.2f m, object found at %.3f m index=%d \n', min_distance, max_distance,...
        object_dist, I);
    
 %%   
fontsize = 13;
fig = figure('DefaultAxesFontSize', fontsize, 'Position', [100 100 200*3 200*2]); 
    plot(dist_interval*[0:params.opRangeFFTSize-1], abs(fft_output)); hold on ;
    stem(([153 175 534]-1)*dist_interval, abs(fft_output([153 175 534])));
    xlabel('range (m)'); ylabel('range FFT output (dB)'); title('Range FFT'); xlim([min_distance max_distance]);
    text(0.25, abs(fft_output(153))+0.3e5, sprintf('%.2fm', (153-1)*dist_interval), "FontSize", fontsize);
    text(0.5, abs(fft_output(175))+0.3e5, sprintf('%.2fm', (175-1)*dist_interval), "FontSize", fontsize);
    text(1.5, abs(fft_output(534))+0.3e5, sprintf('%.2fm', (534-1)*dist_interval), "FontSize", fontsize);
xlabel("Range (meter)");
ylabel("Range FFT Magnitude");
% legend(["phase drift unremoved", "phase drift removed"], "Location", "south");
% xlim([0 0.2]);
title("");
exportgraphics(fig,sprintf('figures/range_fft.png'),'Resolution',300) 
    %     subplot(3,1,2); plot(db(fft_output));
%     xlabel('index'); ylabel('range FFT output (dB)');
%     subplot(3,1,3); plot(abs(fft_output)); hold on;
%     xlabel('index'); ylabel('range FFT output (abs)'); xlim([1 max_idx]);
%     stem(I, M);
%% generate demo audio files
close all;
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["small_cardboard", "large_cardboard", "small_paper_bag", ...
    "large_paper_bag", "small_bag_of_chips", "large_bag_of_chips"];
scenario = 'radar0.5m_source0.5m';
speakers = ["mccs0", "fadg0", "beatles", "adele"]; 
soundfiles = ["sa1", "sa1","let_it_be", "someone_like_you_verse"];
soundtitles = ["sa1", "sa1","let_it_be", "someone_like_you"];
dbs = [60,70,80];
for ii=1:6
    for jj=1:length(speakers)
        mkdir(sprintf("B:/demo/%s", titles(ii)));
        [yclean, fs_clean] = audioread(sprintf('audios/%s/%s_80db.wav',speakers(jj), soundfiles(jj)));
        audiowrite(sprintf('B:/demo/%s_%s_%s_clean.wav',titles(ii), ...
            speakers(jj), soundtitles(jj)) ,0.3*yclean./max(abs(yclean)), fs_clean);
        
        for kk=1:length(dbs)
            folder = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq', objects(ii),scenario);
            name = sprintf('%s/%s_%s_%ddb.wav',folder, speakers(jj), soundfiles(jj), dbs(kk));
            [y, Fs] = audioread(name);
            y = noiseReduction_YW(y, Fs);
            bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
                'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
                'SampleRate',Fs);
            y = filter(bpFilt, y);
            audiowrite(sprintf('B:/demo/%s_%s_%s_recovered_SPL%ddB.wav',titles(ii), speakers(jj), ...
                soundtitles(jj), dbs(kk)) ,0.3*y./max(abs(y)), Fs);
        end
    end
end
fprintf('Done\n');
%% compare speech sa1, my voice vs loudspeaker
[y1, Fs1] = audioread('experiment_data2/layschip/radar0.5m_source1.0m/profile3/wav_eq/myself_sa1.wav');
[y2, Fs2] = audioread('experiment_data2/layschip/radar0.5m_source1.0m/profile3/wav_eq/loudspeaker_sa1_v2.wav');
[y3, Fs3] = audioread('audios/sa1_myvoice_recorded_macbook.wav');

y1 = noiseReduction_YW(y1, Fs1);
y2 = noiseReduction_YW(y2, Fs2);
bpFilt = designfilt('bandpassiir','FilterOrder',10, ...
        'HalfPowerFrequency1',100,'HalfPowerFrequency2',1000, 'DesignMethod','butter', ...
        'SampleRate',Fs2);
y1= filter(bpFilt, y1);
y2 = filter(bpFilt, y2);

y1 = y1(1:fix(3.8*Fs1));
y2 = y2(fix(1.45*Fs2):fix(5.25*Fs2));
y3 = y3(fix(0.13*Fs3):fix(3.93*Fs3)); % 3.8 s in length
% figure; plot(y2);
% sound(y1./max(abs(y1)), Fs1);
sound(y2./max(abs(y2)), Fs2);
audiowrite('B:/demo/loudspeaker_sa1.wav', y2./max(abs(y2)), Fs2);

wl = fix(0.1*Fs1);
nov = fix(wl*0.8);
nff = max(4096,2^nextpow2(wl));

figure(100); 
subplot(3,1,1);spectrogram(y1,hamming(wl),nov,nff, Fs1, 'yaxis','MinThreshold',-150);ylim([0 1]); title('Me speaking');
subplot(3,1,2);spectrogram(y2,hamming(wl),nov,nff, Fs2, 'yaxis','MinThreshold',-150);ylim([0 1]); title('speech played by loudspeaker');
subplot(3,1,3);spectrogram(y3,hamming(wl),nov,nff, Fs3, 'yaxis','MinThreshold',-150);ylim([0 1]); title('Microphone recording');
%% compare 1 kHz tone, loudspeaker vs passive bag of chips
[y1, Fs1] = audioread('experiment_data2/layschip/radar0.5m_source1.0m/profile3/wav_eq/1khztone.wav');
[y2, Fs2] = audioread('experiment_data2/layschip/radar0.5m_source1.0m/profile3/wav_eq/loudspeaker_1khztone.wav');
[y2, Fs2] = audioread('experiment_data2/layschip/radar0.5m_source1.0m/profile3/wav_eq/loudspeaker_1khztone.wav');

y1 = y1(fix(1.5*Fs1):fix(4.2*Fs1));
y2 = y2(fix(1.5*Fs2):fix(4.2*Fs2));

wl = fix(0.1*Fs1);
nov = fix(wl*0.8);
nff = max(4096,2^nextpow2(wl));

y1_deg = rms(rad2deg(buffer(y1,fix(0.01*Fs1), 0)), 1);
y2_deg = rms(rad2deg(buffer(y2,fix(0.01*Fs2), 0)), 1);

figure; 
cdfplot(y1_deg); hold on; cdfplot(y2_deg);

figure(100); 
subplot(2,1,1);spectrogram(y1,hamming(wl),nov,nff, Fs1, 'yaxis','MinThreshold',-140);ylim([0 2]);
subplot(2,1,2);spectrogram(y2,hamming(wl),nov,nff, Fs2, 'yaxis','MinThreshold',-140);ylim([0 2]);
%% plot 0-9 spectrogram for each object
objects = ["smallpaperbag", "smallcardboard", "layschip", "microphone"];
titles = ["paperbag", "cardboard", "chips bag", "microphone"];
scenario = 'radar0.5m_source1.5m';
% titles = ["george", "jackson", "lucas", "me"];
figure;
for ii=0:9
    for kk=1:4
        folder = sprintf('B:/experiment_data/%s/%s/wav_eq', objects(kk),scenario);
        name = sprintf('%s/%d_%s_profile3_voice%d_1.wav',folder,ii,scenario,ii);
        if kk==4
            folder = sprintf('B:/experiment_data/%s/wav_noeq_fs8k', objects(kk));
            name = sprintf('%s/%d_myvoice%d_1.wav',folder,ii,ii);
%         else
%             malename = ["george", "jackson", "lucas"];
%             folder = "C:/Users/Weihan/Desktop/free-spoken-digit-dataset-master/recordings";
%             name = sprintf('%s/%d_%s_%d.wav',folder,ii,malename(kk),ii);
        end
        [y, Fs] = audioread(name);
%         sound(y, Fs); pause(0.6);
        subplot(4,10, (kk-1)*10+ii+1);
        nsc = fix(0.1*Fs);
        nov = fix(nsc/2);
        nff = max(4096,2^nextpow2(nsc));
        spectrogram(y,hamming(nsc),nov,nff, Fs, 'yaxis','MinThreshold',-150); colorbar('off');
        ylim([0 2]);
        
%         image(imread(name));
        title(sprintf('%s %d', titles(kk), ii))
    end
end

%%
% pick one object, check per digit PSNR over distance
figure(3);
psnr_db_object = psnr_db(:,:,3);
psnr_db_object = reshape(psnr_db_object, 10, Nperdigit, length(scenarios));
model_series = squeeze(mean(psnr_db_object,2)).'; %[10 40 50 60; 20 50 60 70; 30 60 80 90];
% model_error = squeeze((max(psnr_db,[],2)-min(psnr_db,[],2))/2).'; %[1 4 8 6; 2 5 9 12; 3 6 10 13];
model_error = squeeze(std(psnr_db_object,0,2)/2).';

b = bar(model_series, 'grouped');
hold on
% Find the number of groups and the number of bars in each group
[ngroups, nbars] = size(model_series);
% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar
% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, model_series(:,i), model_error(:,i), 'k', 'linestyle', 'none');
end
hold off
%% PSNR for objects with different sizes
scenarios = ["radar0.5m_source1.0m"];
objects = ["smallcardboard", "spindrift", "smallpaperbag", "traderjoebag", "smalllayschip", "layschip"];
titles = ["small cardboard", "large cardboard", "small paperbag", "large paperbag", "small packaging", "large packaging"];
Nperdigit = 5;
psnr_db = zeros(10*Nperdigit,length(scenarios), length(objects)); % 10 digit, 10 measurements per digit
% noeq_psnr_db = zeros(10*Nperdigit,length(scenarios), length(objects)); 
for ii=1:length(objects)
    for jj=0:9
        for kk=1:length(scenarios)
            for ll=1:Nperdigit
%                 filename = sprintf('B:/experiment_data/%s/%s/wav_eq/%d_%s_profile3_voice%d_%d.wav',...
%                     objects(ii),scenarios(kk), jj,scenarios(kk),jj,ll);
                eq_filename = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq/%d_%d.wav',...
                objects(ii),scenarios(kk), jj,ll);
%                 noeq_filename = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq/%d_%d.wav',...
%                 objects(ii),scenarios(kk), jj,ll);
                [y_eq, fs] = audioread(eq_filename);
                psnr_db(jj*Nperdigit+ll, kk, ii) = get_psnr(y_eq,fs);
%                 [y_noeq, fs] = audioread(noeq_filename);
%                 noeq_psnr_db(jj*Nperdigit+ll, kk, ii) = get_psnr(y_noeq,fs);
            end
        end
    end
end

% object PSNR over distance
figure(2);
% model_series = squeeze(mean(psnr_db,1)); %[10 40 50 60; 20 50 60 70; 30 60 80 90];
% model_error =squeeze(std(psnr_db,0,1)/2);
model_series = reshape(squeeze(mean(psnr_db,1)), 2, []).'; %[10 40 50 60; 20 50 60 70; 30 60 80 90];
model_error = reshape(squeeze(std(psnr_db,0,1)/2), 2, []).';
b = bar(model_series, 'grouped');
hold on
% Find the number of groups and the number of bars in each group
[ngroups, nbars] = size(model_series);
% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar
% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, model_series(:,i), model_error(:,i), 'k', 'linestyle', 'none');
end
hold off
% xlabel('Material');
ylabel('PSNR (dB)');
% xticklabels(arrayfun(@num2str, round(0.5*[1:length(scenarios)],1), 'UniformOutput', false));
xticklabels(["cardboard", "paperbag", "plastic packaging"]);
legend(["small size", "large size"]);

%% PSNR
scenarios = ["radar0.5m_source0.5m","radar0.5m_source1.0m",...
    "radar0.5m_source1.5m", "radar0.5m_source2.0m"];
objects = ["smallpaperbag", 'layschip', 'smallcardboard'];
titles = ["paperbag", 'chips bag', 'cardboard'];
Nperdigit = 5;
psnr_db = zeros(10*Nperdigit,length(scenarios), length(objects)); % 10 digit, 10 measurements per digit
noeq_psnr_db = zeros(10*Nperdigit,length(scenarios), length(objects)); 
for ii=1:length(objects)
    for jj=0:9
        for kk=1:length(scenarios)
            for ll=1:Nperdigit
%                 filename = sprintf('B:/experiment_data/%s/%s/wav_eq/%d_%s_profile3_voice%d_%d.wav',...
%                     objects(ii),scenarios(kk), jj,scenarios(kk),jj,ll);
                eq_filename = sprintf('B:/experiment_data2/%s/%s/profile3/wav_eq/%d_%d.wav',...
                objects(ii),scenarios(kk), jj,ll);
                noeq_filename = sprintf('B:/experiment_data2/%s/%s/profile3/wav_noeq/%d_%d.wav',...
                objects(ii),scenarios(kk), jj,ll);
                [y_eq, fs] = audioread(eq_filename);
%                 y_eq = noiseReduction_YW(y_eq, fs);
                psnr_db(jj*Nperdigit+ll, kk, ii) = get_psnr(y_eq,fs);
                [y_noeq, fs] = audioread(noeq_filename);
                noeq_psnr_db(jj*Nperdigit+ll, kk, ii) = get_psnr(y_noeq,fs);
            end
        end
    end
end

% object PSNR over distance
figure(2);
model_series = squeeze(mean(psnr_db,1)); %[10 40 50 60; 20 50 60 70; 30 60 80 90];
% model_error = squeeze((max(psnr_db,[],1)-min(psnr_db,[],1))/2); %[1 4 8 6; 2 5 9 12; 3 6 10 13];
model_error = squeeze(std(psnr_db,0,1)/2);
b = bar(model_series, 'grouped');
hold on
% Find the number of groups and the number of bars in each group
[ngroups, nbars] = size(model_series);
% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar
% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, model_series(:,i), model_error(:,i), 'k', 'linestyle', 'none');
end
hold off
xlabel('distance (m)');
ylabel('PSNR (dB)');
xticklabels(arrayfun(@num2str, round(0.5*[1:length(scenarios)],1), 'UniformOutput', false));
legend(titles);

% check layschip
% figure;
% plot(1:10*Nperdigit, squeeze(psnr_db(:,:,2)))
%% PSNR before/after denoising 
% pick distance = 1m
figure(2);
model_series = [squeeze(mean(noeq_psnr_db(:,2,:),1)) squeeze(mean(psnr_db(:,2,:),1)) ]; %[10 40 50 60; 20 50 60 70; 30 60 80 90];
% model_error = squeeze((max(psnr_db,[],1)-min(psnr_db,[],1))/2); %[1 4 8 6; 2 5 9 12; 3 6 10 13];
model_error = [squeeze(std(noeq_psnr_db(:,2,:),0,1)/2)  squeeze(std(psnr_db(:,2,:),0,1)/2)];
b = bar(model_series, 'grouped');
hold on
% Find the number of groups and the number of bars in each group
[ngroups, nbars] = size(model_series);
% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar
% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, model_series(:,i), model_error(:,i), 'k', 'linestyle', 'none');
end
hold off
xlabel('objects');
ylabel('PSNR (dB)');
xticklabels(titles);
% xticklabels(arrayfun(@num2str, round(0.5*[1:length(scenarios)],1), 'UniformOutput', false));
legend('undenoised', 'denoised');