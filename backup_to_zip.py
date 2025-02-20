import shutil
from datetime import datetime
from pathlib import Path

import pytz


def backup(dir_path, target_dir):
    fullpath = Path(dir_path).absolute()
    dirname = fullpath.parents[0]
    basename = fullpath.name

    tz = pytz.timezone("Asia/Shanghai")
    today = datetime.now(tz).date()
    zipFilename = Path(target_dir).absolute() / f"{basename}_{today}.zip"
    if Path(zipFilename).exists():
        print(f"Zip file {zipFilename} already exists.")
        return

    print(f"Creating {zipFilename}...")
    shutil.make_archive(
        zipFilename.with_suffix(""), "zip", root_dir=dirname, base_dir=basename
    )
    print("Completed!")


if __name__ == "__main__":
    backup("text_files", "./dest")
