import os
from urllib.parse import urlparse

import requests
from tqdm import tqdm

url = "https://www.python.org/ftp/python/3.10.16/Python-3.10.16.tgz"
filename = os.path.basename(urlparse(url).path)
chunk_size = 1024 * 1024

try:
    response = requests.get(url, stream=True)
    response.raise_for_status()

    total_size = int(response.headers.get("content-length", 0))
    with open(filename, "wb") as f, tqdm(
        desc="下载中", total=total_size, unit="B", unit_scale=True
    ) as bar:
        for chunk in response.iter_content(chunk_size):
            f.write(chunk)
            bar.update(len(chunk))
    print("下载完成！")
except requests.RequestException as e:
    print(f"下载失败：{e}")
