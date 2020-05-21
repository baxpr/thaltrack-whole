#!/usr/local/fsl6/fslpython/envs/fslpython/bin/python
# 
# Get center of mass of cortex ROI, in voxel index

import sys
import nibabel
import scipy.ndimage

axis = sys.argv[1]
nii_file = sys.argv[2]

img = nibabel.load(nii_file)

com = scipy.ndimage.center_of_mass(img.get_fdata())

if axis is 'i':
    print('%d' % com[0])

if axis is 'j':
    print('%d' % com[1])

if axis is 'k':
    print('%d' % com[2])

