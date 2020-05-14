#!/bin/bash
#

echo Running ${0}


# Set up
source functions.sh
cd "${rois_dwi_dir}"


# Resample FS ROI images to DWI space (transform obtained from coreg_t1_to_dwi.sh)
mri_convert "${fs_subject_dir}/mri/aparc.DKTatlas+aseg.mgz" aparc.DKTatlas+aseg.nii.gz
flirtopts="-applyxfm -init ${out_dir}/FS_to_DWI.mat -paddingsize 0.0 -interp nearestneighbour -ref ${out_dir}/b0_mean.nii.gz"
flirt ${flirtopts} \
	-in aparc.DKTatlas+aseg \
	-out aparc.DKTatlas+aseg_to_DWI
flirt ${flirtopts} \
	-in "${fs_nii_thalamus_niigz}" \
	-out nii_thalamus_to_DWI


# Create single-ROI masks for FS thalamus using thal segmentation output
fslmaths nii_thalamus_to_DWI -thr 8100 -uthr 8199 -bin FS_THALAMUS_L
fslmaths nii_thalamus_to_DWI -thr 8200 -uthr 8299 -bin FS_THALAMUS_R


# Re-combine aparc into the needed single-ROI masks, files labeled by ROI name
aparc=aparc.DKTatlas+aseg_to_DWI

combine_rois "${aparc}"   FS_WM_L               "2"
combine_rois "${aparc}"   FS_WM_R               "41"
combine_rois "${aparc}"   FS_WM_LR              "2 41"

combine_rois "${aparc}"   FS_BRAINSTEM          "16"

combine_rois "${aparc}"   FS_CEREBELLUM_L       "7 8"
combine_rois "${aparc}"   FS_CEREBELLUM_R       "46 47"

combine_rois "${aparc}"   FS_CAUD_PUT_PALL_L    "11 12 13"
combine_rois "${aparc}"   FS_CAUD_PUT_PALL_R    "50 51 52"

combine_rois "${aparc}"   FS_AMYG_HIPP_L        "17 18"
combine_rois "${aparc}"   FS_AMYG_HIPP_R        "53 54"
	
combine_rois "${aparc}"   FS_MOTOR_L     "1003 1017 1024"
combine_rois "${aparc}"   FS_MOTOR_R     "2003 2017 2024"

combine_rois "${aparc}"   FS_OCC_L       "1005 1011 1013 1021"
combine_rois "${aparc}"   FS_OCC_R       "2005 2011 2013 2021"

combine_rois "${aparc}"   FS_PFC_L       "1002 1012 1014 1018 1019 1020 1026 1027 1028"
combine_rois "${aparc}"   FS_PFC_R       "2002 2012 2014 2018 2019 2020 2026 2027 2028"

combine_rois "${aparc}"   FS_POSTPAR_L   "1008 1025 1029 1010 1023 1031"
combine_rois "${aparc}"   FS_POSTPAR_R   "2008 2025 2029 2010 2023 2031"

combine_rois "${aparc}"   FS_SOMATO_L    "1022"
combine_rois "${aparc}"   FS_SOMATO_R    "2022"

combine_rois "${aparc}"   FS_TEMP_L      "1006 1007 1009 1015 1016 1030 1034"
combine_rois "${aparc}"   FS_TEMP_R      "2006 2007 2009 2015 2016 2030 2034"

combine_rois "${aparc}"   FS_MOFC_L      "1012 1014 1028"
combine_rois "${aparc}"   FS_MOFC_R      "2012 2014 2028"

combine_rois "${aparc}"   FS_LPFC_L      "1018 1019 1020 1027"
combine_rois "${aparc}"   FS_LPFC_R      "2018 2019 2020 2027"

combine_rois "${aparc}"   FS_ACC_L       "1002 1026"
combine_rois "${aparc}"   FS_ACC_R       "2002 2026"

combine_rois "${aparc}"   FS_PPC_L       "1008 1025 1029"
combine_rois "${aparc}"   FS_PPC_R       "2008 2025 2029"

combine_rois "${aparc}"   FS_PARDMN_L    "1010 1031"
combine_rois "${aparc}"   FS_PARDMN_R    "2010 2031"

combine_rois "${aparc}"   FS_AUD_L       "1030 1034"
combine_rois "${aparc}"   FS_AUD_R       "2030 2034"

combine_rois "${aparc}"   FS_ITEMP_L     "1006 1007 1009 1015 1016"
combine_rois "${aparc}"   FS_ITEMP_R     "2006 2007 2009 2015 2016"



# Subcortical mask
fslmaths \
	FS_BRAINSTEM \
	-add FS_CEREBELLUM_L    -add FS_CEREBELLUM_R \
	-add FS_CAUD_PUT_PALL_L -add FS_CAUD_PUT_PALL_R \
	-add FS_AMYG_HIPP_L     -add FS_AMYG_HIPP_R \
	-bin \
	FS_CEREBELLAR_SUBCORTICAL


# Whole brain gray matter mask
fslmaths FS_PFC_R -add FS_MOTOR_R -add FS_SOMATO_R -add FS_POSTPAR_R -add FS_OCC_R -add FS_TEMP_R \
	-add FS_PFC_L -add FS_MOTOR_L -add FS_SOMATO_L -add FS_POSTPAR_L -add FS_OCC_L -add FS_TEMP_L \
	FS_CORTEX


# Add white matter, subcortical to gray matter to make large avoid masks
fslmaths FS_CORTEX -add FS_WM_R -add FS_CEREBELLAR_SUBCORTICAL -bin FS_RH_LHCORTEX_AVOID
fslmaths FS_CORTEX -add FS_WM_L -add FS_CEREBELLAR_SUBCORTICAL -bin FS_LH_RHCORTEX_AVOID


# Avoid masks for specific seed regions
for region in \
  FS_PFC \
  FS_MOTOR \
  FS_SOMATO \
  FS_POSTPAR \
  FS_OCC \
  FS_TEMP \
  FS_MOFC \
  FS_LPFC \
  FS_ACC \
  FS_PPC \
  FS_PARDMN \
  FS_AUD \
  FS_ITEMP \
; do
	fslmaths FS_RH_LHCORTEX_AVOID -sub ${region}_L -thr 1 -bin ${region}_L_AVOID
	fslmaths FS_LH_RHCORTEX_AVOID -sub ${region}_R -thr 1 -bin ${region}_R_AVOID
done

# Stop and avoid masks for hemispheres
for LR in L R ; do

	fslmaths \
			 FS_PFC_${LR} \
		-add FS_MOTOR_${LR} \
		-add FS_SOMATO_${LR} \
		-add FS_POSTPAR_${LR} \
		-add FS_OCC_${LR} \
		-add FS_TEMP_${LR} \
		-bin FS_${LR}HCORTEX_STOP

	fslmaths \
			 FS_${LR}HCORTEX_STOP \
		-add FS_WM_${LR} \
		-add FS_THALAMUS_${LR} \
		-bin FS_${LR}H_AVOID

done


# Clean up
rm -f aparc.DKTatlas+aseg.nii.gz
