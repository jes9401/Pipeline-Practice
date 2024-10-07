https://github.com/neurolabusc/niivue-images
- 링크에 있는 chris_t1.nii.gz 파일을 사용

http://users.loni.ucla.edu/~pipeline/viewer
- nifti, mgz 뷰어


# reface 테스트 명령어
python3 /mnt/c/pipeline_test/scripts/run_mri_reface.py --csv_path=/mnt/c/pipeline_test/csv/practice/reface_input.csv --output_path=/mnt/c/pipeline_test/result/practice/reface --multi=1 --threads=4

# freesurfer 컨테이너 생성 명령어
docker run --name=fs_710 -d -v /mnt/c/pipeline_test:/mnt/c/pipeline_test 0799 sleep infinity

# freesurfer 테스트 명령어 
python3 /mnt/c/pipeline_test/scripts/run_freesurfer_for_test.py --csv_path=/mnt/c/pipeline_test/csv/practice/freesurfer_input.csv --multi=1

# freesurfer 결과 추출 명령어
python3 /mnt/c/pipeline_test/scripts/get_freesurfer_result.py --result_path=/mnt/c/pipeline_test/result/sample/freesurfer --csv_save_path=/mnt/c/pipeline_test/freesurfer_result.csv

# petsurfer 결과 추출 명령어
python3 /mnt/c/pipeline_test/scripts/get_petsurfer_result.py --result_path=/mnt/c/pipeline_test/result/sample/freesurfer --csv_save_path=/mnt/c/pipeline_test/petsurfer_result.csv