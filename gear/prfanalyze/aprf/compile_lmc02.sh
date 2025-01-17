#!/bin/bash
module load matlab/glerma

cat > build.m <<END
% We do not want ToolboxToolbox to mess up the compiling
restoredefaultpath();

toolbox_dir = '/export/home/glerma/glerma/toolboxes'


if ~isdir(fullfile(toolbox_dir,'PRFmodel','gear','prfanalyze','aprf','compiled'))
    mkdir(fullfile(toolbox_dir,'PRFmodel','gear','prfanalyze','aprf','compiled'))
end

addpath(genpath(fullfile(toolbox_dir,'vistasoft')));
% addpath(genpath(fullfile(toolbox_dir,'analyzePRF')));
% we still need to maintain garikoitzanalyzeprf with branch extract_modelpred so that we have it in the output
addpath(genpath(fullfile(toolbox_dir,'garikoitzanalyzePRF')));
addpath(genpath(fullfile(toolbox_dir,'jsonlab_v1.2')));
addpath(genpath(fullfile(toolbox_dir,'JSONio')));
addpath(genpath(fullfile(toolbox_dir,'freesurfer_mrtrix_afni_matlab_tools')));
addpath(genpath(fullfile(toolbox_dir, 'PRFmodel')));
rmpath(genpath(fullfile(toolbox_dir, 'PRFmodel/local')));

mcc -m -R -nodisplay -a /export/home/glerma/glerma/toolboxes/PRFmodel/data -d compiled prfanalyze_aprf.m 
exit
END

matlab -nodisplay -nosplash -r build && rm build.m
