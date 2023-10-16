% NFA EEG Pipleline
% Authors: Emily Petrucci & Brock Pluimer
%---------------------------------------

%{ 
Notes
1) code for parts of the pipeline done through EEGLab UX:
-Automated Artifact Rejection (ASR)
-Dipole Fitting (DIPFIT)

2) Data structures necessary for the protocol to be ran / replicated
-STUDY creation
-Badchannel (channels removed from each subject)
%}

for i = 1:400
% Import Data, Filter, Epoch, Average Reference
    % Load dataset
    EEG = pop_loadset('filename', filename,'filepath', filepath, 'loadmode', 'all');
    %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET ,'study',1); % code to load study?
    [EEG, ALLEEG] = importChan('QuikCap 64Ch.csv', ALLEEG);
    EEG = pop_chanedit(EEG, 'convert', 'cart2all', 'nosedir', '+Y'); %converts nosedirection back to +X immediately after calling this :(
    EEG = eeg_checkset( EEG );
    fprintf('\nOpened raw file for %s %s at index %.0f\n', EEG.subject, EEG.condition, i);
    
    % Filter around 1 Hz
    EEG = pop_eegfiltnew(EEG, 'locutoff',[0.75 1.25] ,'plotfreqz',0);
    
    % Epoch 5-min sessions
    if any(strcmp(ALLEEG(i).condition, {'open15', 'story15', 'open15free'}))
        continue
    end

        % find start and end markers for segmentation & delete duplicates
        s = 0; f = 0;
        start_latency = 0; end_latency = 0;
        for j = 1:length(EEG.event)

            if strcmp(num2str(EEG.event(j).type), '21')
                s = s + 1;
                if s > 1
                    fprintf('\n%s %s had 2 start markers. The second was deleted.\n', EEG.subject, EEG.condition);
                    EEG.event(j) = [];
                else
                    start_latency = EEG.event(j).latency/1000;
                end
            elseif  strcmp(num2str(EEG.event(j).type), '22')
                f = f + 1;
                if f > 1
                    fprintf('\n%s %s had 2 end markers. The second was deleted.\n', EEG.subject, EEG.condition);
                    EEG.event(j) = [];
                    continue
                else
                    end_latency = EEG.event(j).latency/1000;
                end
            end
        end


        % Segment to task start and end markers
        EEG = pop_select(EEG, 'time', [start_latency end_latency]);
        
        % Average reference
        EEG = pop_reref(EEG, [],'interpchan',[]);

% Semi-Automated Artifact Rejection (ASR)
    % Done through EEGLab GUI - need to generate history script to get code
    badchannels = {}; % EP has actual bad channel structure to be uploaded to Github
    EEG = pop_select( EEG, 'nochannel', badchannels);

% Event recovery, Channel Interpolation, & Average Reference
    
        % Convert numeric event types to string - EP addition
        for j = 1:length(EEG.event)
            if  isnumeric(EEG.event(j).type)
                EEG.event(j).type = num2str(EEG.event(j).type);
            end
        end

        % Recover the lost events - Makuro UCSD code
        urEventType         = {EEG.urevent.type}';
        urEventLatencyFrame = round([EEG.urevent.latency]);
        cleanSampleMask     = EEG.etc.clean_sample_mask;
        isEventPresent      = cleanSampleMask(urEventLatencyFrame);

        boundaryIdx = find(contains({EEG.event.type}, 'boundary'));
        if any(isEventPresent==false)
            lostEventIdx = find(isEventPresent==0);
            for lostEventIdxIdx = 1:length(lostEventIdx)
                lostEventUrlatencyFrame = urEventLatencyFrame(lostEventIdx(lostEventIdxIdx));
                lostEventCurrentPosition = sum(cleanSampleMask(1:lostEventUrlatencyFrame));
                boundaryLatency = round([EEG.event(boundaryIdx).latency]);
                [differenceInFrame, selectedBoundaryIdx] = min(abs(boundaryLatency-lostEventCurrentPosition));
                if differenceInFrame > 3
                    fprintf('\nFail to recover the lost event %.0f for %s %s at index %.0f.', urEventType{lostEventIdx(lostEventIdxIdx)}, EEG.subject, EEG.condition, index(i))
                    continue
                end
                EEG.event(selectedBoundaryIdx).type = urEventType{lostEventIdx(lostEventIdxIdx)};
            end
        end
        
        % Interpolare removed channels for average reference
        EEG = pop_interp(EEG, EEG.chaninfo.removedchans.labels, 'spherical');
        EEG = pop_reref( EEG, [],'interpchan',[]);
        
        % Save pre-processed file
        filename = EEG.filename;
        newfilepath = fullfile('Z:\\Narrative_Free_Awareness_Study\\06_Data\\EEG\\NFA EEGLab\\NFA_Special_Datasets\\NFA_BIDS\\derivatives\\eeglab\\', EEG.subject, session, 'eeg\');
        newfilename = [filename '_pre-processed'];
        EEG = pop_saveset(EEG, 'savemode', 'onefile', 'filepath', newfilepath, 'filename', newfilename);
        
% ICA (picard), Label & Reject Components (ICLabel), dipole fitting (DIPFIT MNI co-registration)
    % ICA
    if strcmp(EEG.task, 'notask')
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'retrieve', [i:i+7], 'overwrite', 'on', 'gui', 'off', 'study',0);
        fprintf('\nAbout to perform ICA on %s datasets %.0f to %.0f\n', EEG(1).subject, CURRENTSET(1), CURRENTSET(end));

        EEG = pop_runica(EEG, 'icatype','picard','concatcond','on','options',{'maxiter',500});

        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    end

    % ICLabel
    EEG = pop_iclabel(EEG, 'default');
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;0.9 1;0.9 1;0.9 1;NaN NaN]);
    
    % DIPFIT
        % Used EEGLab UX - Need to get code from history scripts
        % Rename CB1 and CB2 index in channellocs
        for j = 1:ALLEEG(i).nbchan

            if strcmp(ALLEEG(i).chanlocs(j).labels, 'CB1')
                ALLEEG(i).chanlocs(j).labels = 'OI1';
            elseif strcmp(ALLEEG(i).chanlocs(j).labels, 'CB2')
                ALLEEG(i).chanlocs(j).labels = 'OI2';
            end

            chan_labels{j} = ALLEEG(i).chanlocs(j).labels;
        end

        % Coregister electrodes with standard electrode positions
        [newlocs transform] = coregister(EEG.chanlocs, 'C:\\Users\\epetrucc\\Documents\\MATLAB\\eeglab\\plugins\\dipfit4.3\\standard_BEM\\elec\\standard_1005.elc', 'warp', chan_labels, 'manual', 'off');
        EEG = pop_dipfit_settings( EEG, 'hdmfile','C:\\Users\\epetrucc\\Documents\\MATLAB\\eeglab\\plugins\\dipfit4.3\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','C:\\Users\\epetrucc\\Documents\\MATLAB\\eeglab\\plugins\\dipfit4.3\\standard_BEM\\standard_mri.mat','chanfile','C:\\Users\\epetrucc\\Documents\\MATLAB\\eeglab\\plugins\\dipfit4.3\\standard_BEM\\elec\\standard_1005.elc','coord_transform',transform ,'chansel',[1:ALLEEG(i).nbchan] );

    
        % Save ICA files  
        for j = 1:8
             % Set up File Input
            session = ''; 
            switch EEG(j).condition
                case 'notask'
                    session = 'ses-1';
                case 'think'
                    session = 'ses-2';
                case 'gratitude'
                    session = 'ses-3';
                case 'breath'
                    session = 'ses-4';
                case 'open'
                    session = 'ses-5';
                case 'story15'
                    session = 'ses-6';
                case 'open15'
                    session = 'ses-7';
                case 'open15free'
                    session = 'ses-8';
            end

            filename = [EEG(j).subject, '_', session, '_task-', EEG(j).condition, '_eeg_ICA.set'];
            filepath = fullfile('Z:\\Narrative_Free_Awareness_Study\\06_Data\\EEG\\NFA EEGLab\\NFA_Special_Datasets\\NFA_BIDS\\derivatives\\eeglab\\', EEG(j).subject, session, 'eeg\');
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'retrieve', i + j - 1, 'overwrite', 'on', 'gui', 'off', 'study',0);
            EEG = pop_saveset(EEG, 'savemode', 'onefile', 'filepath', filepath, 'filename', filename);
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'retrieve', [i:i+7], 'overwrite', 'on', 'gui', 'off', 'study',0);
        end
    
% Leadfield Matrix & LCMV beamformer
    EEG = pop_leadfield(EEG, 'sourcemodel','C:\\Users\\epetrucc\\Documents\\MATLAB\\eeglab\\plugins\\dipfit4.3\\tess_cortex_mid_low_2000V.mat','sourcemodel2mni',[0 -24 -45 0 0 -1.5708 1000 1000 1000] ,'downsample',1);
    EEG = pop_roi_activity(EEG, 'resample',100,'model','LCMV','modelparams',{0.05},'atlas','Desikan-Killiany','nPCA',3);

    EEG = pop_saveset( EEG, 'savemode','resave');
    
% 
    EEG = pop_roi_connect(EEG, 'methods', { 'MIM'}, 'snippet', 'off', 'snip_length', 60, 'fcsave_format', 'mean_snips'); %computes connectivity measure
    matnet{i} = pop_roi_connectplot(EEG, 'measure', 'mim', 'freqrange', [8 13], 'plotcortexseedregion', 52, 'plotmatrix',  'off', 'plotcortex', 'on'); %plots on cortex
    barplot = pop_roi_connectplot(EEG(i), 'measure', 'roipsd', 'plotbarplot', 'on','plotcortex', 'off', 'freqrange', [8 13]); %plots freq bar plot

end


