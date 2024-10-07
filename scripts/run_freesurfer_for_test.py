import argparse
import multiprocessing
import os
import subprocess
import time
    
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
        
        
def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--csv_path', required=True)
    parser.add_argument('--multi', required=False, type=int, default=1)
    args = parser.parse_args()
    csv_path = args.csv_path
    multi = args.multi
    return csv_path, multi


def run_freesurfer(row):
    command = "docker exec fs_710 recon-all -parallel -openmp {3} -s {0} -i {1} -sd {2} -autorecon1"
    run_command = command.format(row['subject_id'], row['input_path'], row['output_path'], row['openmp'])
    os.system(run_command)

def run_petsurfer(row):
    subject_id = row["subject_id"]
    freesurfer_path = os.path.join(row["output_path"], subject_id)
    pet_path = row["pet_path"]
    base_path = os.path.dirname(freesurfer_path)
    template_path = os.path.join(freesurfer_path, "template.reg.lta")
    output_path = os.path.join(freesurfer_path, "gtmpvc.output")
    psf = row["psf"] if row["psf"] else 0
    os.environ["SUBJECTS_DIR"] = base_path
    command1 = "docker exec fs_710 sh -c 'export SUBJECTS_DIR={} && gtmseg --s {}'".format(base_path, subject_id)
    command2 = "docker exec fs_710 sh -c 'export SUBJECTS_DIR={} && mri_coreg --s {} --mov {} --reg {}'".format(base_path, subject_id, pet_path, template_path)
    command3 = "docker exec fs_710 sh -c 'export SUBJECTS_DIR={} && mri_gtmpvc --i {} --reg {} --seg gtmseg.mgz --default-seg-merge --o {}'".format(base_path, pet_path, template_path, output_path)
    if psf:
        command3 = "{} --psf {}".format(command3, psf) 
    os.system(command1)
    os.system(command2)
    os.system(command3)
    
def run_analysis(row):
    run_freesurfer(row)
    if "pet_path" in row:
        if row["pet_path"]:
            run_petsurfer(row)
        
def main():    
    csv_path, multi = get_args()
    results = []
    pool = multiprocessing.Pool(multi)
    data = pd.read_csv(csv_path)
    data.fillna("",inplace=True)
    container_check("fs_710", check_type="create")
    
    for i, row in data.iterrows():
        results.append(pool.apply_async(run_analysis, args=(row,)))
        
    for result in results:
        result.wait()
        time.sleep(1)
    pool.close()
    pool.join()
    
    
if __name__ == "__main__":
    main()