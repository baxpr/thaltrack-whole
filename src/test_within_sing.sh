#!/bin/bash
#

export PATH=/wkdir/src:$PATH

xwrapper.sh pipeline.sh \
	--fs_subject_dir /INPUTS/SUBJECT \
	--fs_nii_thalamus_niigz /INPUTS/ThalamicNuclei.v10.T1.FSvoxelSpace.nii.gz \
	--b0mean_niigz /INPUTS/b0_mean.nii.gz \
	--invdef_niigz /INPUTS/iy_t1.nii.gz \
	--fwddef_niigz /INPUTS/y_t1.nii.gz \
	--bedpost_dir /INPUTS/BEDPOSTX \
	--probtrack_samples 50 \
	--dirname_tag "Yeo7" \
	--source_regions "FS_THALAMUS" \
	--target_regions "Yeo7_N1 Yeo7_N2 Yeo7_N3 Yeo7_N4 Yeo7_N5 Yeo7_N6 Yeo7_N7" \
	--project TESTPROJ \
	--subject TESTSUBJ \
	--session TESTSESS \
	--out_dir /OUTPUTS \
	--src_dir /wkdir/src \
	--matlab_dir /wkdir/matlab/bin


exit 0

# Run container:
singularity shell \
	--bind $(pwd):/wkdir \
	--bind freesurfer_license.txt:/usr/local/freesurfer/.license \
	--bind $(pwd)/INPUTS:/INPUTS \
	--bind $(pwd)/OUTPUTS:/OUTPUTS \
	baxpr-thaltrack-whole-master-v3.0.2.simg
