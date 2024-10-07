# package_path : 라이브러리들이 모여있는 폴더 경로, 이미 설치되어 있으면 지정하지 않아도 됨
# result_path : FreeSuefer & PetSurfer 결과들이 있는 폴더
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

def get_row(path, _id):
    print("{} - start".format(_id))
    with open(path) as file:
        data = file.readlines()
    data = [x.strip().split() for x in data]
    data = [[x[2].lower().replace("-","_"), x[3], x[6]] for x in data]
    data = [[f"{x[0]}_{x[1]}" if x[0]!=x[1] else x[0], x[-1]] for x in data]
    data.insert(0, ["id", _id])
    temp_dict = {}
    for x in data:
        if x[0] not in temp_dict:
            temp_dict.setdefault(x[0], x[1])
    return temp_dict

def run(result_path, csv_save_path):
    import os 
    import pandas as pd
    from glob import glob
    
    folder_list = glob(os.path.join(result_path, "*"))
    temp = []
    for folder in folder_list:
        _id = os.path.basename(folder)
        file_path = os.path.join(folder, "gtmpvc.output", "gtm.stats.dat")
        if not os.path.exists(file_path):
            continue
        try:
            row = get_row(file_path, _id)
            temp.append(row)
        except Exception as e:
            print(e)
    df = pd.DataFrame.from_dict(temp)
    df.to_csv(csv_save_path, index=False)


if __name__ == "__main__":
    result_path, csv_save_path = get_args()
    run(result_path, csv_save_path)