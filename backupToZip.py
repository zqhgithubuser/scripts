from datetime import datetime
import os
import pytz
import shutil


def backup(dir_path, target_dir):
    fullpath = os.path.abspath(dir_path)
    dirname = os.path.dirname(fullpath)
    basename = os.path.basename(fullpath)

    tz = pytz.timezone("Asia/Shanghai")
    today = datetime.now(tz).date()
    zipBasename = os.path.join(target_dir, f"{basename}_{today}")
    zipFilename = zipBasename + ".zip"
    if os.path.exists(zipFilename):
        print(f"Zip file {zipFilename} already exists.")
        return

    print(f"Creating {zipFilename}...")
    shutil.make_archive(
        zipBasename,
        "zip",
        root_dir=dirname,
        base_dir=basename
    )
    print("Completed!")


if __name__ == '__main__':
    backup("text_files", "/home/runner/scripts/dst")
