from datetime import datetime
import os
import pytz
import shutil


def backup(dir_path, target_dir):
    fullDirname = os.path.abspath(dir_path)
    dirname = os.path.dirname(fullDirname)
    basename = os.path.basename(fullDirname)

    tz = pytz.timezone("Asia/Shanghai")
    today = datetime.now(tz).date()
    zipFilename = os.path.join(target_dir, f"{basename}_{today}")
    if os.path.exists(zipFilename):
        print("Zip file already exists.")
        return

    print(f"Creating {zipFilename}...")
    shutil.make_archive(
        zipFilename,
        "zip",
        root_dir=dirname,
        base_dir=basename
    )
    print("Completed!")


if __name__ == '__main__':
    backup("text_files", "/home/runner/scripts/dst")
