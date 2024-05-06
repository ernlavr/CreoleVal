#!/usr/bin/env python3
import os
import re
import zipfile
from tqdm import tqdm


models = ["ZSBert_mBERT", "ZSBert_xlmr"]
this_script_dir = os.path.dirname(os.path.realpath(__file__))
download_dir = os.path.join(this_script_dir, "pretrained_weights")

# check if "pretrained_weights" dir exists
for model in models:
    output_dir = os.path.abspath(os.path.join(download_dir, model))
    # check if output dir exists and is not empty
    if not os.path.exists(output_dir) or not os.listdir(output_dir):
        os.makedirs(output_dir, exist_ok=True)
        os.system("git lfs install")
        os.system(f"git clone https://huggingface.co/yiyic/{model}-finetuned {output_dir}")

print("Downloaded all models")
# walk each model dir and unzip the files
def extract_nested_zip(zippedFile, toFolder):
    """ Unzip a zip file and its contents, including nested zip files
        Delete the zip file(s) after extraction
    """
    file_name = os.path.basename(zippedFile).split(".")[0]
    with zipfile.ZipFile(zippedFile, 'r') as zfile:
        zfile.extractall(path=toFolder)
    os.remove(zippedFile)
    for root, dirs, files in os.walk(os.path.join(toFolder, file_name)):
        for filename in files:
            fileSpec = os.path.join(root, filename)
            extract_nested_zip(fileSpec, root)

for model in tqdm(models, "Extracting archives..."):
    output_dir = os.path.abspath(os.path.join(download_dir, model))
    # get all .zip files
    zipped = [f for f in os.listdir(output_dir) if f.endswith(".zip")]
    for z in zipped:
        file_name = os.path.join(output_dir, z)
        dir_name = output_dir
        extract_nested_zip(file_name, dir_name)
    
print("Done!")