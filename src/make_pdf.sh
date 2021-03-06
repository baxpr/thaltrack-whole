#!/bin/bash
#
# Generate PDF for QA

echo Running ${0}

wkdir="${out_dir}"/makepdf
mkdir -p "${wkdir}"
cd "${wkdir}"


# Images we'll need for coreg verification
mkdir coreg_imgs

# Make an overlay ROI for coreg check (seeds and full cortex)
fslmaths \
	"${rois_fs_dir}"/FS_THALAMUS_L     -add "${rois_fs_dir}"/FS_THALAMUS_R \
	-mul 2 \
	-add "${rois_fs_dir}"/FS_PFC_L     -add "${rois_fs_dir}"/FS_PFC_R \
	-add "${rois_fs_dir}"/FS_MOTOR_L   -add "${rois_fs_dir}"/FS_MOTOR_R \
	-add "${rois_fs_dir}"/FS_SOMATO_L  -add "${rois_fs_dir}"/FS_SOMATO_R \
	-add "${rois_fs_dir}"/FS_POSTPAR_L -add "${rois_fs_dir}"/FS_POSTPAR_R \
	-add "${rois_fs_dir}"/FS_OCC_L     -add "${rois_fs_dir}"/FS_OCC_R \
	-add "${rois_fs_dir}"/FS_TEMP_L    -add "${rois_fs_dir}"/FS_TEMP_R \
	-add "${rois_fs_dir}"/FS_INSULA_L  -add "${rois_fs_dir}"/FS_INSULA_R \
	coreg_imgs/coregmask

# b=0 image transformed to FS space using inverse matrix from 
# coreg_FS_to_DWI.sh. The forward matrix was used for probtrack.
flirtopts="-applyxfm -init ${out_dir}/DWI_to_FS.mat -ref ${out_dir}/norm.nii.gz"
flirt ${flirtopts} \
	-in "${out_dir}"/b0_mean \
	-out coreg_imgs/b0_mean_to_FS

# Get into MNI space
gunzip coreg_imgs/*.nii.gz
"${matlab_dir}"/run_spm12.sh "${mcr_dir}" function warp "${out_dir}/y_fwddef.nii" "${wkdir}"/coreg_imgs/coregmask.nii 0
"${matlab_dir}"/run_spm12.sh "${mcr_dir}" function warp "${out_dir}/y_fwddef.nii" "${wkdir}"/coreg_imgs/b0_mean_to_FS.nii 1
gzip coreg_imgs/*.nii

# Coreg verification - outline of FS cortex ROI on mean b=0 DWI. Center on L thal
vx=$(get_com.py x "${rois_fs_dir}"/FS_THALAMUS_L.nii.gz)
vy=$(get_com.py y "${rois_fs_dir}"/FS_THALAMUS_L.nii.gz)
vz=$(get_com.py z "${rois_fs_dir}"/FS_THALAMUS_L.nii.gz)
fsleyes render --outfile coreg_fs.png \
	--size 600 1800 \
	--worldLoc ${vx} ${vy} ${vz} \
	--displaySpace world \
	--hideCursor --layout vertical \
	--xzoom 1000 --yzoom 1000 --zzoom 1000 \
	coreg_imgs/b0_mean_to_FS --displayRange 0 "99%" \
	coreg_imgs/coregmask --overlayType label --outline --outlineWidth 3 --lut harvard-oxford-subcortical

# Repeat for MNI space
vx=$(get_com.py x "${rois_fs_dir}"/wFS_THALAMUS_L.nii.gz)
vy=$(get_com.py y "${rois_fs_dir}"/wFS_THALAMUS_L.nii.gz)
vz=$(get_com.py z "${rois_fs_dir}"/wFS_THALAMUS_L.nii.gz)
fsleyes render --outfile coreg_mni.png \
	--size 400 1200 \
	--worldLoc ${vx} ${vy} ${vz} \
	--displaySpace world \
	--hideCursor --layout vertical \
	--xzoom 800 --yzoom 800 --zzoom 700 \
	coreg_imgs/wb0_mean_to_FS --displayRange 0 "99%" \
	coreg_imgs/wcoregmask --overlayType label --outline --outlineWidth 3 --lut harvard-oxford-subcortical


# Combine
montage -mode concatenate coreg_fs.png coreg_mni.png -tile 2x1 -quality 100 -background white -gravity center \
	-border 20 -bordercolor black -resize 600x coreg.png

convert \
	-size 2600x3365 xc:white \
	-gravity center \( "coreg.png" -resize 1800x \) -geometry +0+0 -composite \
	-gravity North -pointsize 48 -annotate +0+150 "Coregistration of FS segmentation (color) and mean b=0 DWI\nNative space (left), MNI space (right)" \
	-gravity SouthEast -pointsize 48 -annotate +50+50 "${thedate}" \
	-gravity NorthWest -pointsize 48 -annotate +50+50 "${project} ${subject} ${session}" \
	"coreg.png"


# Finalize PDF
mkdir -p "${out_dir}"/PDF
convert \
	biggest_*.png \
	coreg.png \
	tracts_*.png \
	"${out_dir}"/PDF/thaltrack_whole.pdf

