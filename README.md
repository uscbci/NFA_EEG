NFA EEG Connectivity Analysis README

Authors: Emily Petrucci & Brock Pluimer

**Overview**

These scripts are part of the connectivity analysis pipeline developed for the EEG portion of the Narrative Free Awareness project. Collectively, they use EEGLAB to handle EEG preprocessing, source localization, and group connectivity analyses.

**NFA_EEG_pipeline.m**

**Overview**

This EEG pipeline is designed for efficient and reliable preprocessing, Independent Component Analysis (ICA), and source localization of EEG data. It utilizes EEGLab for various functionalities like Automated Artifact Rejection (ASR) and Dipole Fitting (DIPFIT). The pipeline is tailored for batch processing of up to 400 datasets.

**Notes**
* Some functionalities, like ASR and DIPFIT, are done through EEGLab's GUI. Their history scripts are needed for full code to run.
* Necessary data structures for the pipeline: STUDY creation, Badchannel (channels removed from each subject).
  
**Workflow**
1. Data Import, Filtering, and Epoching
* Load dataset
* Apply 1 Hz filter
* Epoching based on condition
* Average reference
2. Artifact Rejection (ASR)
* Semi-automated, requires EEGLab GUI
3. Event Recovery and Channel Interpolation
* Recover lost events
* Interpolate removed channels
* Save pre-processed file
4. ICA, Labeling, and Rejection
* ICA using Picard algorithm
* ICLabel for labeling components
* DIPFIT for dipole fitting
5. Leadfield Matrix & LCMV beamformer
* Generate leadfield matrix
* Use LCMV beamforming for source localization
6. Connectivity Analysis
* ROI-based connectivity analysis
* Various visualizations including barplots and cortical maps

**File Structure**
* Main pipeline code located in NFA_EEG_Pipeline.m
* Requires channel location file QuikCap 64Ch.csv
* Output files saved in specific directories (see code)

**Requirements**

* MATLAB
* EEGLab
* Picard Algorithm for ICA

**How to Run**

Run the main pipeline script NFA_EEG_Pipeline.m in MATLAB after ensuring all dependencies are installed and data files are in place.

**NFA_EEG_groupconnectivity.m**

Conducts group-level connectivity analyses for the preprocessed NFA data. 

**Notes**
* Frequency bands are specified within the script.
* Outputs user-specified connectivity matrices.
  
**How To Run**
1. Make sure all individual-level data files are accessible to working directory.
2. Run NFA_EEG_groupconnectivity.m in MATLAB terminal
   
**Dependencies**
* MATLAB
* Pre-processed and source-localized EEG data
* **This script depends on `pop_roi_connectplot.m` developed by Arnaud Delorme. Download it from EEGlab's website (https://sccn.ucsd.edu/eeglab/download.php).
	`customROIplot.m` is designed to analyze and visualize EEG data 	focusing on 	ROI (Region of Interest) connectivity plots. It calculates Time-Reversal 	GC 	(TRGC) within a certain frequency range (currently hardcoded to alpha, 8-13 	Hz) for 	a specific seed region in the brain, (currently hardcoded to Region 52, the 	right 	precuneus).

**Output**

* Connectivity matrices for selected frequency bands and cortical heatmaps representing either subject maps or group comparisons
  
**License**
MIT License
