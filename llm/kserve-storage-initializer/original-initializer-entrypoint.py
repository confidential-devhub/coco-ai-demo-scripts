#!/usr/bin/env python3
import os
import tarfile
import sys
import logging
import shutil
import subprocess
import warnings
import urllib3

logging.basicConfig(level = logging.INFO)

warnings.filterwarnings("ignore", category=UserWarning, module="pydantic")
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

from kserve.storage import Storage

if len(sys.argv) != 3:
    print("Usage: initializer-entrypoint src_uri dest_path")
    sys.exit()

src_uri = sys.argv[1]
dest_path = sys.argv[2]

model_path = f"{dest_path}" # /mnt/models
key_file = 'keys/key.bin'
model_f = 'flan-t5-small'
model_file = f'{model_path}/{model_f}.tar.gz'
encr_file = f'{model_file}.enc'
decr_file = f'{encr_file}.dec'

os.environ["S3_VERIFY_SSL"] = "0"
logging.info(os.getenv("S3_VERIFY_SSL"))

logging.info("Initializing, args: src_uri [%s] dest_path[ [%s]" % (src_uri, dest_path))
Storage.download(src_uri, dest_path)

logging.info("##############################")
logging.info("Models...")
out = subprocess.check_output(['/bin/ls', model_path])
logging.info('ls /mnt/models\n' + out.decode('ascii'))
logging.info("##############################")

logging.info("current_path...")
out = subprocess.check_output(['/bin/ls'])
logging.info('ls \n' + out.decode('ascii'))
logging.info("##############################")

logging.info("Download key...")
out = subprocess.check_output(['/bin/ls', 'keys'])
logging.info('ls keys\n' + out.decode('ascii'))
# out =subprocess.check_output(['/bin/curl', '-L', 'http://127.0.0.1:8006/cdh/resource/default/kbsres1/key.bin', '-o', key_file])
out =subprocess.check_output(['/bin/curl', '-L', '-k', 'https://people.redhat.com/eesposit/key.bin', '-o', key_file])
logging.info(out)
out = subprocess.check_output(['/bin/ls', 'keys'])
logging.info('ls keys\n' + out.decode('ascii'))
logging.info("##############################")

logging.info("fenc...")
out =subprocess.check_output(['/bin/fenc', '-file', encr_file, '-key', key_file, '-operation', 'decryption'])
logging.info("File decrypted successfully!")
out = subprocess.check_output(['/bin/ls', model_path])
logging.info('ls /mnt/models\n' + out.decode('ascii'))
logging.info("##############################")

tarfile.TarFile.extraction_filter = staticmethod(tarfile.fully_trusted_filter)

def extract_tar(tar_path, extract_to='.'):
    try:
        with tarfile.open(tar_path, 'r') as tar:
            tar.extractall(path=extract_to)
            logging.info(f"Extracted all files to {extract_to}")
    except Exception as e:
        logging.info(f"Error extracting {tar_path}: {e}")

logging.info("tar...")
extract_tar(decr_file, model_path)
out = subprocess.check_output(['/bin/ls', model_path])
logging.info('ls /mnt/models\n' + out.decode('ascii'))
logging.info("##############################")

def move_files_outside(folder_path):
    parent_dir = os.path.dirname(folder_path)
    for file_name in os.listdir(folder_path):
        file_path = os.path.join(folder_path, file_name)
        if os.path.isfile(file_path):
            shutil.move(file_path, parent_dir)

logging.info("mv...")
move_files_outside(f'{model_path}/{model_f}')
out = subprocess.check_output(['/bin/ls', model_path])
logging.info('ls /mnt/models\n' + out.decode('ascii'))
logging.info("##############################")


logging.info("rm...")
out =subprocess.check_output(['rm', '-rf', f'{model_path}/{model_f}'])
out = subprocess.check_output(['/bin/ls', model_path])
logging.info("##############################")