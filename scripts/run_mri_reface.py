import argparse
import multiprocessing
import os
import subprocess
import shutil
import time
from glob import glob

import pandas as pd


def container_check(container_name, check_type):
    while True:
        try:
            ps_command = 'docker ps -af "name={}"'.format(container_name)
            result = subprocess.check_output(ps_command, shell=True)
            result = result.decode().split("\n")
            result = [" ".join(x.split()).split() for x in result]
            result = [x for x in result if x]
            result.pop(0)
            if check_type == "delete":
                if len(result) == 0:
                    break
                else:
                    rm_command = 'docker rm {} -f'.format(container_name)
                    subprocess.Popen(rm_command, shell=True)
                    time.sleep(2)
                    continue
            elif check_type == "create":
                if len(result) == 0:
                    time.sleep(2)
                    continue
                else:
                    break
        except Exception as e:
            print(e)
            break


def run_reface(rows, output_path, input_tmp, output_tmp, threads):
    start = time.time()
    input_path = rows["input_path"]
    image_type = rows["type"]
    exec_command = "docker exec mri_reface run_mri_reface.sh {} {} -threads {} -imType {}"
    file_name = os.path.basename(input_path)
    _id = file_name.split(".")[0]
    
    deface_check = glob(os.path.join(output_path, _id, "*deFaced*.nii"))
    if deface_check:
        return True
    
    input_tmp_path = os.path.join(input_tmp, file_name)
    output_tmp_path = os.path.join(output_tmp, _id)
    is_dicom = True if os.path.isdir(input_path) else False
    if is_dicom:
        shutil.copytree(input_path, input_tmp_path)
    else:
        shutil.copy(input_path, input_tmp_path)
    run_exec_command = exec_command.format(input_tmp_path, output_tmp_path, threads, image_type)
    p = subprocess.Popen(run_exec_command, shell=True)
    p.wait()
    os.system("cp -r {} {} && rm -rf {}".format(output_tmp_path, output_path, output_tmp_path))

    seconds = abs(start - time.time())
    hours = int(seconds / 3600)
    minutes = int((seconds % 3600) / 60)
    second = int(seconds % 60)
    time_cost = "{}h {}m {}s".format(hours, minutes, second)
    os.system('echo {} > {}'.format(time_cost, os.path.join(output_path, _id, "time.txt")))
    
    if is_dicom:
        shutil.rmtree(input_tmp_path)
    else:
        os.remove(input_tmp_path)
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--csv_path', required=True)
    parser.add_argument('--multi', required=False, type=int, default=1)
    parser.add_argument('--threads', required=False, type=int, default=1)    
    parser.add_argument('--output_path', required=True)
    args = parser.parse_args()
    csv_path = args.csv_path
    multi = args.multi
    threads = args.threads
    output_path = args.output_path
    results = []
    
    pool = multiprocessing.Pool(multi)
    tmpdir = os.popen("mktemp -d").read().strip()
    input_tmp = os.path.join(tmpdir, "inputs")
    output_tmp= os.path.join(tmpdir, "outputs")
    os.makedirs(input_tmp)
    os.makedirs(output_tmp)
    
    data = pd.read_csv(csv_path)
    docker_run_command = "docker run --name=mri_reface --mount type=bind,src\={},target={} neurophet-docker-registry.kr.ncr.ntruss.com/mri_reface sleep infinity".format(tmpdir, tmpdir)
    print("docker_run_command = {}".format(docker_run_command))
    subprocess.Popen(docker_run_command, shell=True)
    container_check("mri_reface", check_type="create")
    
    for i, rows in data.iterrows():
        results.append(pool.apply_async(run_reface, args=(rows, output_path, input_tmp, output_tmp, threads)))
    for result in results:
        result.wait()
        # time.sleep(5)
    pool.close()
    pool.join()
    
    container_check("mri_reface", check_type="delete")
    