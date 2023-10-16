% Group comparisons
% Authors: Emily Petrucci & Brock Pluimer
% Outputs data used by customROIplot.m

connect = [];

%frequency band(s) of interest
bands = {[8 13]}; %alpha, modify as needed for delta (0.5-4), theta (4-8), beta (13-30), and gamma (30-100)

nt = 1; t = 1; g = 1; b = 1; o = 1; %indices for each tasks connectivity array
nt2 = 1; t2 = 1; g2 = 1; b2 = 1; o2 = 1;

for i = 1:250

    for j = 1:length(bands)
        frq_inds{j} = find(EEG(i).roi.freqs >= bands{j}(1) & EEG(i).roi.freqs < bands{j}(2)); %selects freq range
    end

    if strcmp(EEG(i).group, 'expert')
        switch EEG(i).condition
            case 'notask'
                connect.expert.notask.TRGC(nt,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                connect.all.notask.TRGC(nt,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                %save([EEG(i).filepath '\' EEG(i).subject '_TRGC_notask.mat'], 'connect.expert(nt).notask.TRGC', '-v7.3') %would save this value if needed 
                nt = nt + 1;

            case 'think'
                connect.expert.think.TRGC(t,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                connect.all.think.TRGC(t,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                t = t + 1;

            case 'breath'
                connect.expert.breath.TRGC(b,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                connect.all.breath.TRGC(b,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                b = b + 1;

            case 'gratitude'
                connect.expert.gratitude.TRGC(g,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                connect.all.gratitude.TRGC(g,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                g = g + 1;

            case 'open'
                connect.expert.open.TRGC(o,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                connect.all.open.TRGC(o,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                o = o + 1;

        end

    elseif strcmp(EEG(i).group, 'novice')

        switch EEG(i).condition
            case 'notask'
                connect.novice.notask.TRGC(nt2,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                connect.all.notask.TRGC(nt,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                %save([EEG(i).filepath '\' EEG(i).subject '_TRGC_notask.mat'], 'connect.novice(nt).notask.TRGC', '-v7.3') %would save this value if needed 
                nt = nt + 1;
                nt2 = nt2 + 1;

            case 'think'
                connect.novice.think.TRGC(t2,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                connect.all.think.TRGC(t,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                t = t + 1;
                t2 = t2 + 1;

            case 'breath'
                connect.novice.breath.TRGC(b2,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                connect.all.breath.TRGC(b,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                b = b + 1;
                b2 = b2 + 1;

            case 'gratitude'
                connect.novice.gratitude.TRGC(g2,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                connect.all.gratitude.TRGC(g,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                g = g + 1;
                g2 = g2 + 1;

            case 'open'
                connect.novice.open.TRGC(o2,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                connect.all.open.TRGC(o,:,:) = squeeze(mean(EEG(i).roi.TRGC(frq_inds{1},:,:),1));
                o = o + 1;
                o2 = o2 + 1;

        end
    end
end

%Statistics

%calculate netTRGC
connect.all.notask.netTRGC = sum(connect.all.notask.TRGC, 3);
connect.expert.notask.netTRGC = sum(connect.expert.notask.TRGC, 3);
connect.novice.notask.netTRGC = sum(connect.novice.notask.TRGC, 3);

connect.all.think.netTRGC = sum(connect.all.think.TRGC, 3);
connect.expert.think.netTRGC = sum(connect.expert.think.TRGC, 3);
connect.novice.think.netTRGC = sum(connect.novice.think.TRGC, 3);

connect.all.gratitude.netTRGC = sum(connect.all.gratitude.TRGC, 3);
connect.expert.gratitude.netTRGC = sum(connect.expert.gratitude.TRGC, 3);
connect.novice.gratitude.netTRGC = sum(connect.novice.gratitude.TRGC, 3);

connect.all.breath.netTRGC = sum(connect.all.breath.TRGC, 3);
connect.expert.breath.netTRGC = sum(connect.expert.breath.TRGC, 3);
connect.novice.breath.netTRGC = sum(connect.novice.breath.TRGC, 3);

connect.all.open.netTRGC = sum(connect.all.open.TRGC, 3);
connect.expert.open.netTRGC = sum(connect.expert.open.TRGC, 3);
connect.novice.open.netTRGC = sum(connect.novice.open.TRGC, 3);

%t test
for iroi = 1:EEG(1).roi.nROI %for each roi

    %example group comparisons for each state - 2 way t-test
    %[h(iroi), p(iroi), ~, stats] = ttest2(connect.expert.notask.netTRGC(:, iroi), connect.novice.notask.netTRGC(:, iroi), 'alpha', 0.05); 
    %t(iroi) = sign(stats.tstat);

    %[h(iroi), p(iroi), ci(iroi), stats] = ttest2(connect.expert.think.netTRGC(:, iroi), connect.novice.think.netTRGC(:, iroi), 'alpha', 0.05); 
    %t(iroi) = sign(stats.tstat);    

    %example state comparisons for each state - 1 way t-test
    [h(iroi), p(iroi), ~, stats(iroi)] = ttest(connect.all.notask.netTRGC(:, iroi), connect.all.think.netTRGC(:, iroi), 'alpha', 0.05); 
    t(iroi) = sign(stats(iroi).tstat);

    %Add ANOVA


end

%plot
%load cm17 %colormap
%load cortex

logp = -log10(p).*squeeze(t);
allplots_cortex_BS(cortex, logp, [-max(abs(logp)) max(abs(logp))], cm17a, '-log(p)*sign(t)', 0.3, '', {'printcbar',1})
%if you want to save the plot(s) to a folder, replace the empty string
%(second to last input) with the file path


