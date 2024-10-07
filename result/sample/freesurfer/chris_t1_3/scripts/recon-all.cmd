

#---------------------------------
# New invocation of recon-all Fri Oct  4 13:24:48 UTC 2024 

 mri_convert /mnt/c/test/result/reface/chris_t1_3/chris_t1_3_deFaced.nii /mnt/c/test/result/freesurfer/chris_t1_3/mri/orig/001.mgz 

#--------------------------------------------
#@# MotionCor Fri Oct  4 13:24:51 UTC 2024

 cp /mnt/c/test/result/freesurfer/chris_t1_3/mri/orig/001.mgz /mnt/c/test/result/freesurfer/chris_t1_3/mri/rawavg.mgz 


 mri_convert /mnt/c/test/result/freesurfer/chris_t1_3/mri/rawavg.mgz /mnt/c/test/result/freesurfer/chris_t1_3/mri/orig.mgz --conform 


 mri_add_xform_to_header -c /mnt/c/test/result/freesurfer/chris_t1_3/mri/transforms/talairach.xfm /mnt/c/test/result/freesurfer/chris_t1_3/mri/orig.mgz /mnt/c/test/result/freesurfer/chris_t1_3/mri/orig.mgz 

#--------------------------------------------
#@# Talairach Fri Oct  4 13:24:56 UTC 2024

 mri_nu_correct.mni --no-rescale --i orig.mgz --o orig_nu.mgz --ants-n4 --n 1 --proto-iters 1000 --distance 50 


 talairach_avi --i orig_nu.mgz --xfm transforms/talairach.auto.xfm 

talairach_avi log file is transforms/talairach_avi.log...

 cp transforms/talairach.auto.xfm transforms/talairach.xfm 

lta_convert --src orig.mgz --trg /usr/local/freesurfer/average/mni305.cor.mgz --inxfm transforms/talairach.xfm --outlta transforms/talairach.xfm.lta --subject fsaverage --ltavox2vox
#--------------------------------------------
#@# Talairach Failure Detection Fri Oct  4 13:27:49 UTC 2024

 talairach_afd -T 0.005 -xfm transforms/talairach.xfm 


 awk -f /usr/local/freesurfer/bin/extract_talairach_avi_QA.awk /mnt/c/test/result/freesurfer/chris_t1_3/mri/transforms/talairach_avi.log 


 tal_QC_AZS /mnt/c/test/result/freesurfer/chris_t1_3/mri/transforms/talairach_avi.log 

#--------------------------------------------
#@# Nu Intensity Correction Fri Oct  4 13:27:49 UTC 2024

 mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --n 2 --ants-n4 


 mri_add_xform_to_header -c /mnt/c/test/result/freesurfer/chris_t1_3/mri/transforms/talairach.xfm nu.mgz nu.mgz 

#--------------------------------------------
#@# Intensity Normalization Fri Oct  4 13:30:34 UTC 2024

 mri_normalize -g 1 -seed 1234 -mprage nu.mgz T1.mgz 

#--------------------------------------------
#@# Skull Stripping Fri Oct  4 13:31:32 UTC 2024

 mri_em_register -skull nu.mgz /usr/local/freesurfer/average/RB_all_withskull_2020_01_02.gca transforms/talairach_with_skull.lta 


 mri_watershed -T1 -brain_atlas /usr/local/freesurfer/average/RB_all_withskull_2020_01_02.gca transforms/talairach_with_skull.lta T1.mgz brainmask.auto.mgz 


 cp brainmask.auto.mgz brainmask.mgz 

#-------------------------------------
#@# EM Registration Fri Oct  4 13:35:20 UTC 2024

 mri_em_register -uns 3 -mask brainmask.mgz nu.mgz /usr/local/freesurfer/average/RB_all_2020-01-02.gca transforms/talairach.lta 

#--------------------------------------
#@# CA Normalize Fri Oct  4 13:37:43 UTC 2024

 mri_ca_normalize -c ctrl_pts.mgz -mask brainmask.mgz nu.mgz /usr/local/freesurfer/average/RB_all_2020-01-02.gca transforms/talairach.lta norm.mgz 

#--------------------------------------
#@# CA Reg Fri Oct  4 13:38:31 UTC 2024

 mri_ca_register -nobigventricles -T transforms/talairach.lta -align-after -mask brainmask.mgz norm.mgz /usr/local/freesurfer/average/RB_all_2020-01-02.gca transforms/talairach.m3z 

#--------------------------------------
#@# SubCort Seg Fri Oct  4 14:30:34 UTC 2024

 mri_ca_label -relabel_unlikely 9 .3 -prior 0.5 -align norm.mgz transforms/talairach.m3z /usr/local/freesurfer/average/RB_all_2020-01-02.gca aseg.auto_noCCseg.mgz 

#--------------------------------------
#@# CC Seg Fri Oct  4 15:07:06 UTC 2024

 mri_cc -aseg aseg.auto_noCCseg.mgz -o aseg.auto.mgz -lta /mnt/c/test/result/freesurfer/chris_t1_3/mri/transforms/cc_up.lta chris_t1_3 

#--------------------------------------
#@# Merge ASeg Fri Oct  4 15:07:38 UTC 2024

 cp aseg.auto.mgz aseg.presurf.mgz 

#--------------------------------------------
#@# Intensity Normalization2 Fri Oct  4 15:07:38 UTC 2024

 mri_normalize -seed 1234 -mprage -aseg aseg.presurf.mgz -mask brainmask.mgz norm.mgz brain.mgz 

#--------------------------------------------
#@# Mask BFS Fri Oct  4 15:09:15 UTC 2024

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# WM Segmentation Fri Oct  4 15:09:16 UTC 2024

 AntsDenoiseImageFs -i brain.mgz -o antsdn.brain.mgz 


 mri_segment -wsizemm 13 -mprage antsdn.brain.mgz wm.seg.mgz 


 mri_edit_wm_with_aseg -keep-in wm.seg.mgz brain.mgz aseg.presurf.mgz wm.asegedit.mgz 


 mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz 

#--------------------------------------------
#@# Fill Fri Oct  4 15:11:18 UTC 2024

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.presurf.mgz wm.mgz filled.mgz 

#--------------------------------------------
#@# Tessellate lh Fri Oct  4 15:12:15 UTC 2024

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Tessellate rh Fri Oct  4 15:12:20 UTC 2024

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Fri Oct  4 15:12:25 UTC 2024

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Smooth1 rh Fri Oct  4 15:12:25 UTC 2024

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Fri Oct  4 15:12:30 UTC 2024

 mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# Inflation1 rh Fri Oct  4 15:12:30 UTC 2024

 mris_inflate -no-save-sulc ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Fri Oct  4 15:12:47 UTC 2024

 mris_sphere -q -p 6 -a 128 -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# QSphere rh Fri Oct  4 15:12:47 UTC 2024

 mris_sphere -q -p 6 -a 128 -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#@# Fix Topology lh Fri Oct  4 15:14:41 UTC 2024

 mris_fix_topology -mgz -sphere qsphere.nofix -inflated inflated.nofix -orig orig.nofix -out orig.premesh -ga -seed 1234 chris_t1_3 lh 

#@# Fix Topology rh Fri Oct  4 15:14:41 UTC 2024

 mris_fix_topology -mgz -sphere qsphere.nofix -inflated inflated.nofix -orig orig.nofix -out orig.premesh -ga -seed 1234 chris_t1_3 rh 


 mris_euler_number ../surf/lh.orig.premesh 


 mris_euler_number ../surf/rh.orig.premesh 


 mris_remesh --remesh --iters 3 --input /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.orig.premesh --output /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.orig 


 mris_remesh --remesh --iters 3 --input /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.orig.premesh --output /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm ../surf/lh.inflated 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm ../surf/rh.inflated 

#--------------------------------------------
#@# AutoDetGWStats lh Fri Oct  4 15:16:57 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_autodet_gwstats --o ../surf/autodet.gw.stats.lh.dat --i brain.finalsurfs.mgz --wm wm.mgz --surf ../surf/lh.orig.premesh
#--------------------------------------------
#@# AutoDetGWStats rh Fri Oct  4 15:17:01 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_autodet_gwstats --o ../surf/autodet.gw.stats.rh.dat --i brain.finalsurfs.mgz --wm wm.mgz --surf ../surf/rh.orig.premesh
#--------------------------------------------
#@# WhitePreAparc lh Fri Oct  4 15:17:05 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.orig --o ../surf/lh.white.preaparc --white --seg aseg.presurf.mgz --nsmooth 5
#--------------------------------------------
#@# WhitePreAparc rh Fri Oct  4 15:19:26 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --wm wm.mgz --invol brain.finalsurfs.mgz --rh --i ../surf/rh.orig --o ../surf/rh.white.preaparc --white --seg aseg.presurf.mgz --nsmooth 5
#--------------------------------------------
#@# CortexLabel lh Fri Oct  4 15:21:33 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mri_label2label --label-cortex ../surf/lh.white.preaparc aseg.presurf.mgz 0 ../label/lh.cortex.label
#--------------------------------------------
#@# CortexLabel+HipAmyg lh Fri Oct  4 15:21:48 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mri_label2label --label-cortex ../surf/lh.white.preaparc aseg.presurf.mgz 1 ../label/lh.cortex+hipamyg.label
#--------------------------------------------
#@# CortexLabel rh Fri Oct  4 15:22:04 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mri_label2label --label-cortex ../surf/rh.white.preaparc aseg.presurf.mgz 0 ../label/rh.cortex.label
#--------------------------------------------
#@# CortexLabel+HipAmyg rh Fri Oct  4 15:22:19 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mri_label2label --label-cortex ../surf/rh.white.preaparc aseg.presurf.mgz 1 ../label/rh.cortex+hipamyg.label
#--------------------------------------------
#@# Smooth2 lh Fri Oct  4 15:22:34 UTC 2024

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white.preaparc ../surf/lh.smoothwm 

#--------------------------------------------
#@# Smooth2 rh Fri Oct  4 15:22:34 UTC 2024

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white.preaparc ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Fri Oct  4 15:22:40 UTC 2024

 mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated 

#--------------------------------------------
#@# Inflation2 rh Fri Oct  4 15:22:40 UTC 2024

 mris_inflate ../surf/rh.smoothwm ../surf/rh.inflated 

#--------------------------------------------
#@# Curv .H and .K lh Fri Oct  4 15:23:00 UTC 2024

 mris_curvature -w -seed 1234 lh.white.preaparc 


 mris_curvature -seed 1234 -thresh .999 -n -a 5 -w -distances 10 10 lh.inflated 

#--------------------------------------------
#@# Curv .H and .K rh Fri Oct  4 15:23:00 UTC 2024

 mris_curvature -w -seed 1234 rh.white.preaparc 


 mris_curvature -seed 1234 -thresh .999 -n -a 5 -w -distances 10 10 rh.inflated 

#--------------------------------------------
#@# Sphere lh Fri Oct  4 15:23:46 UTC 2024

 mris_sphere -rusage /mnt/c/test/result/freesurfer/chris_t1_3/touch/rusage.mris_sphere.lh.dat -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Sphere rh Fri Oct  4 15:23:46 UTC 2024

 mris_sphere -rusage /mnt/c/test/result/freesurfer/chris_t1_3/touch/rusage.mris_sphere.rh.dat -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#--------------------------------------------
#@# Surf Reg lh Fri Oct  4 15:28:00 UTC 2024

 mris_register -curv -rusage /mnt/c/test/result/freesurfer/chris_t1_3/touch/rusage.mris_register.lh.dat ../surf/lh.sphere /usr/local/freesurfer/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/lh.sphere.reg 

#--------------------------------------------
#@# Surf Reg rh Fri Oct  4 15:28:00 UTC 2024

 mris_register -curv -rusage /mnt/c/test/result/freesurfer/chris_t1_3/touch/rusage.mris_register.rh.dat ../surf/rh.sphere /usr/local/freesurfer/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/rh.sphere.reg 

#--------------------------------------------
#@# Jacobian white lh Fri Oct  4 15:33:19 UTC 2024

 mris_jacobian ../surf/lh.white.preaparc ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# Jacobian white rh Fri Oct  4 15:33:19 UTC 2024

 mris_jacobian ../surf/rh.white.preaparc ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Fri Oct  4 15:33:21 UTC 2024

 mrisp_paint -a 5 /usr/local/freesurfer/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#--------------------------------------------
#@# AvgCurv rh Fri Oct  4 15:33:21 UTC 2024

 mrisp_paint -a 5 /usr/local/freesurfer/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Fri Oct  4 15:33:23 UTC 2024

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 chris_t1_3 lh ../surf/lh.sphere.reg /usr/local/freesurfer/average/lh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.annot 

#-----------------------------------------
#@# Cortical Parc rh Fri Oct  4 15:33:23 UTC 2024

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 chris_t1_3 rh ../surf/rh.sphere.reg /usr/local/freesurfer/average/rh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# WhiteSurfs lh Fri Oct  4 15:33:36 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --seg aseg.presurf.mgz --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.white.preaparc --o ../surf/lh.white --white --nsmooth 0 --rip-label ../label/lh.cortex.label --rip-bg --rip-surf ../surf/lh.white.preaparc --aparc ../label/lh.aparc.annot
#--------------------------------------------
#@# WhiteSurfs rh Fri Oct  4 15:35:36 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --seg aseg.presurf.mgz --wm wm.mgz --invol brain.finalsurfs.mgz --rh --i ../surf/rh.white.preaparc --o ../surf/rh.white --white --nsmooth 0 --rip-label ../label/rh.cortex.label --rip-bg --rip-surf ../surf/rh.white.preaparc --aparc ../label/rh.aparc.annot
#--------------------------------------------
#@# T1PialSurf lh Fri Oct  4 15:37:29 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --seg aseg.presurf.mgz --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.white --o ../surf/lh.pial.T1 --pial --nsmooth 0 --rip-label ../label/lh.cortex+hipamyg.label --pin-medial-wall ../label/lh.cortex.label --aparc ../label/lh.aparc.annot --repulse-surf ../surf/lh.white --white-surf ../surf/lh.white
#--------------------------------------------
#@# T1PialSurf rh Fri Oct  4 15:39:47 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --seg aseg.presurf.mgz --wm wm.mgz --invol brain.finalsurfs.mgz --rh --i ../surf/rh.white --o ../surf/rh.pial.T1 --pial --nsmooth 0 --rip-label ../label/rh.cortex+hipamyg.label --pin-medial-wall ../label/rh.cortex.label --aparc ../label/rh.aparc.annot --repulse-surf ../surf/rh.white --white-surf ../surf/rh.white
#@# white curv lh Fri Oct  4 15:41:56 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --curv-map ../surf/lh.white 2 10 ../surf/lh.curv
#@# white area lh Fri Oct  4 15:41:59 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --area-map ../surf/lh.white ../surf/lh.area
#@# pial curv lh Fri Oct  4 15:42:01 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --curv-map ../surf/lh.pial 2 10 ../surf/lh.curv.pial
#@# pial area lh Fri Oct  4 15:42:03 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --area-map ../surf/lh.pial ../surf/lh.area.pial
#@# thickness lh Fri Oct  4 15:42:05 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --thickness ../surf/lh.white ../surf/lh.pial 20 5 ../surf/lh.thickness
#@# area and vertex vol lh Fri Oct  4 15:42:35 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --thickness ../surf/lh.white ../surf/lh.pial 20 5 ../surf/lh.thickness
#@# white curv rh Fri Oct  4 15:42:41 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --curv-map ../surf/rh.white 2 10 ../surf/rh.curv
#@# white area rh Fri Oct  4 15:42:43 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --area-map ../surf/rh.white ../surf/rh.area
#@# pial curv rh Fri Oct  4 15:42:45 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --curv-map ../surf/rh.pial 2 10 ../surf/rh.curv.pial
#@# pial area rh Fri Oct  4 15:42:48 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --area-map ../surf/rh.pial ../surf/rh.area.pial
#@# thickness rh Fri Oct  4 15:42:49 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --thickness ../surf/rh.white ../surf/rh.pial 20 5 ../surf/rh.thickness
#@# area and vertex vol rh Fri Oct  4 15:43:20 UTC 2024
cd /mnt/c/test/result/freesurfer/chris_t1_3/mri
mris_place_surface --thickness ../surf/rh.white ../surf/rh.pial 20 5 ../surf/rh.thickness

#-----------------------------------------
#@# Curvature Stats lh Fri Oct  4 15:43:24 UTC 2024

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm chris_t1_3 lh curv sulc 


#-----------------------------------------
#@# Curvature Stats rh Fri Oct  4 15:43:29 UTC 2024

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm chris_t1_3 rh curv sulc 

#--------------------------------------------
#@# Cortical ribbon mask Fri Oct  4 15:43:34 UTC 2024

 mris_volmask --aseg_name aseg.presurf --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon --parallel chris_t1_3 

#-----------------------------------------
#@# Cortical Parc 2 lh Fri Oct  4 15:47:30 UTC 2024

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 chris_t1_3 lh ../surf/lh.sphere.reg /usr/local/freesurfer/average/lh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 2 rh Fri Oct  4 15:47:30 UTC 2024

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 chris_t1_3 rh ../surf/rh.sphere.reg /usr/local/freesurfer/average/rh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 3 lh Fri Oct  4 15:47:47 UTC 2024

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 chris_t1_3 lh ../surf/lh.sphere.reg /usr/local/freesurfer/average/lh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# Cortical Parc 3 rh Fri Oct  4 15:47:47 UTC 2024

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 chris_t1_3 rh ../surf/rh.sphere.reg /usr/local/freesurfer/average/rh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# WM/GM Contrast lh Fri Oct  4 15:48:00 UTC 2024

 pctsurfcon --s chris_t1_3 --lh-only 

#-----------------------------------------
#@# WM/GM Contrast rh Fri Oct  4 15:48:00 UTC 2024

 pctsurfcon --s chris_t1_3 --rh-only 

#-----------------------------------------
#@# Relabel Hypointensities Fri Oct  4 15:48:09 UTC 2024

 mri_relabel_hypointensities aseg.presurf.mgz ../surf aseg.presurf.hypos.mgz 

#-----------------------------------------
#@# APas-to-ASeg Fri Oct  4 15:48:25 UTC 2024

 mri_surf2volseg --o aseg.mgz --i aseg.presurf.hypos.mgz --fix-presurf-with-ribbon /mnt/c/test/result/freesurfer/chris_t1_3/mri/ribbon.mgz --threads 4 --lh-cortex-mask /mnt/c/test/result/freesurfer/chris_t1_3/label/lh.cortex.label --lh-white /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.white --lh-pial /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.pial --rh-cortex-mask /mnt/c/test/result/freesurfer/chris_t1_3/label/rh.cortex.label --rh-white /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.white --rh-pial /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.pial 


 mri_brainvol_stats chris_t1_3 

#-----------------------------------------
#@# AParc-to-ASeg aparc Fri Oct  4 15:48:44 UTC 2024

 mri_surf2volseg --o aparc+aseg.mgz --label-cortex --i aseg.mgz --threads 4 --lh-annot /mnt/c/test/result/freesurfer/chris_t1_3/label/lh.aparc.annot 1000 --lh-cortex-mask /mnt/c/test/result/freesurfer/chris_t1_3/label/lh.cortex.label --lh-white /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.white --lh-pial /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.pial --rh-annot /mnt/c/test/result/freesurfer/chris_t1_3/label/rh.aparc.annot 2000 --rh-cortex-mask /mnt/c/test/result/freesurfer/chris_t1_3/label/rh.cortex.label --rh-white /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.white --rh-pial /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.pial 

#-----------------------------------------
#@# AParc-to-ASeg aparc.a2009s Fri Oct  4 15:50:36 UTC 2024

 mri_surf2volseg --o aparc.a2009s+aseg.mgz --label-cortex --i aseg.mgz --threads 4 --lh-annot /mnt/c/test/result/freesurfer/chris_t1_3/label/lh.aparc.a2009s.annot 11100 --lh-cortex-mask /mnt/c/test/result/freesurfer/chris_t1_3/label/lh.cortex.label --lh-white /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.white --lh-pial /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.pial --rh-annot /mnt/c/test/result/freesurfer/chris_t1_3/label/rh.aparc.a2009s.annot 12100 --rh-cortex-mask /mnt/c/test/result/freesurfer/chris_t1_3/label/rh.cortex.label --rh-white /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.white --rh-pial /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.pial 

#-----------------------------------------
#@# AParc-to-ASeg aparc.DKTatlas Fri Oct  4 15:52:27 UTC 2024

 mri_surf2volseg --o aparc.DKTatlas+aseg.mgz --label-cortex --i aseg.mgz --threads 4 --lh-annot /mnt/c/test/result/freesurfer/chris_t1_3/label/lh.aparc.DKTatlas.annot 1000 --lh-cortex-mask /mnt/c/test/result/freesurfer/chris_t1_3/label/lh.cortex.label --lh-white /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.white --lh-pial /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.pial --rh-annot /mnt/c/test/result/freesurfer/chris_t1_3/label/rh.aparc.DKTatlas.annot 2000 --rh-cortex-mask /mnt/c/test/result/freesurfer/chris_t1_3/label/rh.cortex.label --rh-white /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.white --rh-pial /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.pial 

#-----------------------------------------
#@# WMParc Fri Oct  4 15:54:19 UTC 2024

 mri_surf2volseg --o wmparc.mgz --label-wm --i aparc+aseg.mgz --threads 4 --lh-annot /mnt/c/test/result/freesurfer/chris_t1_3/label/lh.aparc.annot 3000 --lh-cortex-mask /mnt/c/test/result/freesurfer/chris_t1_3/label/lh.cortex.label --lh-white /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.white --lh-pial /mnt/c/test/result/freesurfer/chris_t1_3/surf/lh.pial --rh-annot /mnt/c/test/result/freesurfer/chris_t1_3/label/rh.aparc.annot 4000 --rh-cortex-mask /mnt/c/test/result/freesurfer/chris_t1_3/label/rh.cortex.label --rh-white /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.white --rh-pial /mnt/c/test/result/freesurfer/chris_t1_3/surf/rh.pial 


 mri_segstats --seed 1234 --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject chris_t1_3 --surf-wm-vol --ctab /usr/local/freesurfer/WMParcStatsLUT.txt --etiv 

#-----------------------------------------
#@# Parcellation Stats lh Fri Oct  4 15:57:09 UTC 2024

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab chris_t1_3 lh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.pial.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab chris_t1_3 lh pial 

#-----------------------------------------
#@# Parcellation Stats rh Fri Oct  4 15:57:09 UTC 2024

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab chris_t1_3 rh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.pial.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab chris_t1_3 rh pial 

#-----------------------------------------
#@# Parcellation Stats 2 lh Fri Oct  4 15:57:37 UTC 2024

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab chris_t1_3 lh white 

#-----------------------------------------
#@# Parcellation Stats 2 rh Fri Oct  4 15:57:37 UTC 2024

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab chris_t1_3 rh white 

#-----------------------------------------
#@# Parcellation Stats 3 lh Fri Oct  4 15:57:56 UTC 2024

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas.stats -b -a ../label/lh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab chris_t1_3 lh white 

#-----------------------------------------
#@# Parcellation Stats 3 rh Fri Oct  4 15:57:56 UTC 2024

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas.stats -b -a ../label/rh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab chris_t1_3 rh white 

#--------------------------------------------
#@# ASeg Stats Fri Oct  4 15:58:15 UTC 2024

 mri_segstats --seed 1234 --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /usr/local/freesurfer/ASegStatsLUT.txt --subject chris_t1_3 

#--------------------------------------------
#@# BA_exvivo Labels lh Fri Oct  4 15:59:00 UTC 2024

 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA1_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.BA1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA2_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.BA2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA3a_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.BA3a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA3b_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.BA3b_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA4a_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.BA4a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA4p_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.BA4p_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA6_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.BA6_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA44_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.BA44_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA45_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.BA45_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.V1_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.V1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.V2_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.V2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.MT_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.MT_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.entorhinal_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.entorhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.perirhinal_exvivo.label --trgsubject chris_t1_3 --trglabel ./lh.perirhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.FG1.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./lh.FG1.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.FG2.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./lh.FG2.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.FG3.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./lh.FG3.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.FG4.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./lh.FG4.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.hOc1.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./lh.hOc1.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.hOc2.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./lh.hOc2.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.hOc3v.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./lh.hOc3v.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.hOc4v.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./lh.hOc4v.mpm.vpnl.label --hemi lh --regmethod surface 


 mris_label2annot --s chris_t1_3 --ctab /usr/local/freesurfer/average/colortable_vpnl.txt --hemi lh --a mpm.vpnl --maxstatwinner --noverbose --l lh.FG1.mpm.vpnl.label --l lh.FG2.mpm.vpnl.label --l lh.FG3.mpm.vpnl.label --l lh.FG4.mpm.vpnl.label --l lh.hOc1.mpm.vpnl.label --l lh.hOc2.mpm.vpnl.label --l lh.hOc3v.mpm.vpnl.label --l lh.hOc4v.mpm.vpnl.label 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA1_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.BA1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA2_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.BA2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA3a_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.BA3a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA3b_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.BA3b_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA4a_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.BA4a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA4p_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.BA4p_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA6_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.BA6_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA44_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.BA44_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.BA45_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.BA45_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.V1_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.V1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.V2_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.V2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.MT_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.MT_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.entorhinal_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.entorhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/lh.perirhinal_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./lh.perirhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mris_label2annot --s chris_t1_3 --hemi lh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l lh.BA1_exvivo.label --l lh.BA2_exvivo.label --l lh.BA3a_exvivo.label --l lh.BA3b_exvivo.label --l lh.BA4a_exvivo.label --l lh.BA4p_exvivo.label --l lh.BA6_exvivo.label --l lh.BA44_exvivo.label --l lh.BA45_exvivo.label --l lh.V1_exvivo.label --l lh.V2_exvivo.label --l lh.MT_exvivo.label --l lh.perirhinal_exvivo.label --l lh.entorhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s chris_t1_3 --hemi lh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l lh.BA1_exvivo.thresh.label --l lh.BA2_exvivo.thresh.label --l lh.BA3a_exvivo.thresh.label --l lh.BA3b_exvivo.thresh.label --l lh.BA4a_exvivo.thresh.label --l lh.BA4p_exvivo.thresh.label --l lh.BA6_exvivo.thresh.label --l lh.BA44_exvivo.thresh.label --l lh.BA45_exvivo.thresh.label --l lh.V1_exvivo.thresh.label --l lh.V2_exvivo.thresh.label --l lh.MT_exvivo.thresh.label --l lh.perirhinal_exvivo.thresh.label --l lh.entorhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.stats -b -a ./lh.BA_exvivo.annot -c ./BA_exvivo.ctab chris_t1_3 lh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.thresh.stats -b -a ./lh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab chris_t1_3 lh white 

#--------------------------------------------
#@# BA_exvivo Labels rh Fri Oct  4 16:00:50 UTC 2024

 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA1_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.BA1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA2_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.BA2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA3a_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.BA3a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA3b_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.BA3b_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA4a_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.BA4a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA4p_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.BA4p_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA6_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.BA6_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA44_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.BA44_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA45_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.BA45_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.V1_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.V1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.V2_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.V2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.MT_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.MT_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.entorhinal_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.entorhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.perirhinal_exvivo.label --trgsubject chris_t1_3 --trglabel ./rh.perirhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.FG1.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./rh.FG1.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.FG2.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./rh.FG2.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.FG3.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./rh.FG3.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.FG4.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./rh.FG4.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.hOc1.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./rh.hOc1.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.hOc2.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./rh.hOc2.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.hOc3v.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./rh.hOc3v.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.hOc4v.mpm.vpnl.label --trgsubject chris_t1_3 --trglabel ./rh.hOc4v.mpm.vpnl.label --hemi rh --regmethod surface 


 mris_label2annot --s chris_t1_3 --ctab /usr/local/freesurfer/average/colortable_vpnl.txt --hemi rh --a mpm.vpnl --maxstatwinner --noverbose --l rh.FG1.mpm.vpnl.label --l rh.FG2.mpm.vpnl.label --l rh.FG3.mpm.vpnl.label --l rh.FG4.mpm.vpnl.label --l rh.hOc1.mpm.vpnl.label --l rh.hOc2.mpm.vpnl.label --l rh.hOc3v.mpm.vpnl.label --l rh.hOc4v.mpm.vpnl.label 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA1_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.BA1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA2_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.BA2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA3a_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.BA3a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA3b_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.BA3b_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA4a_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.BA4a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA4p_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.BA4p_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA6_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.BA6_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA44_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.BA44_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.BA45_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.BA45_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.V1_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.V1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.V2_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.V2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.MT_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.MT_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.entorhinal_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.entorhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /mnt/c/test/result/freesurfer/fsaverage/label/rh.perirhinal_exvivo.thresh.label --trgsubject chris_t1_3 --trglabel ./rh.perirhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mris_label2annot --s chris_t1_3 --hemi rh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l rh.BA1_exvivo.label --l rh.BA2_exvivo.label --l rh.BA3a_exvivo.label --l rh.BA3b_exvivo.label --l rh.BA4a_exvivo.label --l rh.BA4p_exvivo.label --l rh.BA6_exvivo.label --l rh.BA44_exvivo.label --l rh.BA45_exvivo.label --l rh.V1_exvivo.label --l rh.V2_exvivo.label --l rh.MT_exvivo.label --l rh.perirhinal_exvivo.label --l rh.entorhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s chris_t1_3 --hemi rh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l rh.BA1_exvivo.thresh.label --l rh.BA2_exvivo.thresh.label --l rh.BA3a_exvivo.thresh.label --l rh.BA3b_exvivo.thresh.label --l rh.BA4a_exvivo.thresh.label --l rh.BA4p_exvivo.thresh.label --l rh.BA6_exvivo.thresh.label --l rh.BA44_exvivo.thresh.label --l rh.BA45_exvivo.thresh.label --l rh.V1_exvivo.thresh.label --l rh.V2_exvivo.thresh.label --l rh.MT_exvivo.thresh.label --l rh.perirhinal_exvivo.thresh.label --l rh.entorhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.stats -b -a ./rh.BA_exvivo.annot -c ./BA_exvivo.ctab chris_t1_3 rh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.thresh.stats -b -a ./rh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab chris_t1_3 rh white 

