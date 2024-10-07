# package_path : 라이브러리들이 모여있는 폴더 경로, 이미 설치되어 있으면 지정하지 않아도 됨
# result_path : FreeSurfer 결과들이 저장되어 있는 경로 지정
# csv_save_path : volume 정보를 저장할 csv 파일 경로, 파일 이름까지 지정


def get_args():
    import argparse
    import sys

    parser = argparse.ArgumentParser()
    parser.add_argument('--result_path', required=True)
    parser.add_argument('--csv_save_path', required=True)
    parser.add_argument('--package_path', required=False)    
    args = parser.parse_args()
    result_path = args.result_path
    csv_save_path = args.csv_save_path
    package_path = args.package_path
    if package_path:
        sys.path.append(package_path)    
    return result_path, csv_save_path

def run(result_path, csv_save_path):
    import nibabel as nib
    import numpy as np
    import os
    import pandas as pd

    from glob import glob    

    result_folder_list = [x for x in glob(os.path.join(result_path, "*")) if os.path.isdir(x)]

    id_list =[]
    data = []
    for folder in result_folder_list:
        aseg_path = os.path.join(folder, "mri", "aparc+aseg.mgz")
        if not os.path.exists(aseg_path):
            continue
        _id = os.path.basename(folder)
        print("{} - start".format(_id))
        id_list.append(_id)
        temp = nib.load(aseg_path)
        nii = nib.Nifti1Image(temp.get_fdata(), affine=temp.affine)
        img = nii.get_fdata()

        voxel_dims = (nii.header["pixdim"])[1:4]
        voxel_volume = np.prod(voxel_dims)
        flattened_array = img.flatten()
        flattened_array = flattened_array.astype(int)
        counts = np.bincount(flattened_array)
        counts_dict = dict(enumerate(counts))
        counts_dict = {i: v*voxel_volume for i, v in counts_dict.items()}
        data.append(counts_dict)

    volume_data = pd.DataFrame(data)
    volume_data.insert(0, "id", id_list, allow_duplicates=True)

    for header in volume_data.columns:
        if volume_data[header].nunique() == 1 and volume_data[header][0] == 0:
            volume_data.drop([header], axis=1, inplace=True)
    volume_data.to_csv(csv_save_path, index=False)


if __name__ == "__main__":
    result_path, csv_save_path = get_args()
    run(result_path, csv_save_path)