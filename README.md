# Diffusion tractography with whole-thalamus seeds

Entrypoint is `src/pipeline.sh`. Pipeline is:

- Rigid body registration of the mean b=0 image to the Freesurfer T1 (norm) image.

- Generation of lobar source/target ROIs from Freesurfer segmentation, and network ROIs from Yeo segmentation, in the Freesurfer image geometry.

- Probabilistic tractography with probtrackx2, from the specified source ROI to the specified target ROIs. This is done two ways: INDIV, with a separate run of probtrackx2 for each source/target pair; and MULTI, with a single run of probtrackx2 for each source to all targets. All tractography is performed in a single hemisphere. "Target", "Stop", and "Waypoint" masks are all set to the target ROI(s). The "Exclude" mask consists of white matter plus all source and target ROIs in the opposite hemisphere; plus cerebellum, brainstem, ventricles, CSF, hippocampus, amygdala, accumbens, ventral DC, caudate, putamen, and pallidum in the same hemisphere; plus any non-used target ROIs in the same hemisphere (for INDIV runs). Tractography is performed in the Freesurfer geometry via "-xfm" option.

- Transformation of all output images to MNI space using the supplied forward warp.


## Inputs

    fs_subject_dir            Freesurfer SUBJECT directory:       SUBJECT resource of freesurfer_dev
    fs_nii_thalamus_niigz     Freesurfer thalamus segmentation:   NII_THALAMUS resource of freesurfer_dev
    b0mean_niigz              Mean b=0 image from DWI scan:       B0_MEAN resource of dwipre
    bedpost_dir               BEDPOSTX directory:                 BEDPOSTX resource of ybedpostx
    fwddef_niigz              Forward deformation to MNI space:   DEF_FWD resource of cat12
    invdef_niigz              Inverse deformation:                DEF_INV resource of cat12
    probtrack_samples         Number of streamlines to seed per voxel
    probtrack_options         Any desired of --loopcheck --onewaycondition --verbose=0 --modeuler --pd

    project                   Labels for use with XNAT. Only used on the report pages.
    subject
    session

    out_dir                   Output directory in the container (defaults to /OUTPUTS)

    src_dir                   (optional) Location of codebase and matlab installation in the 
    matlab_dir                    container, if a different codebase is to be used. Only used
    mcr_dir                       for testing purposes.



## Outputs

    PDF                               Summary and QA reference
    ROIS_FS                           Regions of interest from Freesurfer and Yeo segmentations
    PROBTRACKS                        Tractography results
        BIGGEST_MULTI_<source>            Segmentation from find_the_biggest, multi-target run
        BIGGEST_INDIV_<source>            Same, but from combined single-target runs
        PROBMAPS_MULTI_<source>           Fraction of streamlines to each target (proj_thresh), multi-target run
        PROBMAPS_INDIV_<source>           Same, but from combined single-target runs
        <source>_to_<target>              Tractography from source to target
        <source>_to_TARGETS_<LR>          Tractography from source to all targets (multi-target run)
        TRACKMASKS                        Masks used during tractography
        TARGETS_<LR>.txt                  List of target regions
    STATS_MULTI                       Statistics, fractional volumes for each target (multi-target run)
    STATS_INDIV                       Same, but from combined single-target runs
    COREG_MAT                         Transforms between Freesurfer and diffusion native spaces
    B0_MEAN                           Mean b=0 image from diffusion images
    


### CSV/STATS Outputs

Each row of a STATS CSV output contains information about one source/target ROI pair.

- `probtrack_dir`: Directory in `PROBTRACKS` output where the files used to compute this row's stats are located

- `source`: Name of the source (seed) ROI

- `source_voxels`: Number of voxels in the source ROI

- `source_mm3`: Volume of the source ROI in mm^3

- `target`: Name of the target ROI

- `target_voxels`: Number of voxels in the target ROI

- `target_mm3`: Volume of the target ROI in mm^3

- `target_tracks`: Number of tracks from the source ROI that reached this target (distance-corrected if --pd option was used). This is the sum of streamline counts in this _single_ seeds_to_target image, over the entire source ROI.

- `total_tracks`: Total number of tracks from the source (distance-corrected if --pd option was used). This is the sum of streamline counts over _all_ seeds_to_target images and over the entire source ROI.

- `target_tracks_fraction`: Fraction of `total_tracks` that reached this target ROI. This is just the ratio of the two previous.

- `target_seg_voxels`: Number of source ROI voxels that were assigned to this target ROI by find_the_biggest

- `total_seg_voxels`: Total number of source ROI voxels that were assigned to _any_ ROI by find_the_biggest

- `target_seg_voxels_fraction`: Fraction of `total_seg_voxels` that were assigned to this target ROI by find_the_biggest. This is just the ratio of the two previous.

