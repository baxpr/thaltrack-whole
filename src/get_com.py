#!/usr/local/fsl6/fslpython/envs/fslpython/bin/python
# 
# Get center of mass of cortex ROI, in voxel index

import sys
import nibabel
import scipy.ndimage

axis = sys.argv[1]
nii_file = sys.argv[2]

img = nibabel.load(nii_file)

com_vox = scipy.ndimage.center_of_mass(img.get_fdata())
com_world = nibabel.affines.apply_affine(img.affine, com_vox)

if axis is 'x':
    print('%d' % com_world[0])

if axis is 'y':
    print('%d' % com_world[1])

if axis is 'z':
    print('%d' % com_world[2])
