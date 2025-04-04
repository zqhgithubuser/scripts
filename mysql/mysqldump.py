import asyncio
import getpass
import os
from datetime import datetime


async def retrieve_db_list(mysql_pwd: str) -> list:
    """
    执行 MySQL 命令，获取所有数据库名称，并过滤掉系统数据库。
    """
    proc = await asyncio.create_subprocess_exec(
        "mysql",
        "-u",
        "root",
        f"-p{mysql_pwd}",
        "-e",
        "SHOW DATABASES;",
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    out, err = await proc.communicate()
    if proc.returncode != 0:
        err_msg = err.decode().strip()
        print(f"错误：获取数据库列表失败 - {err_msg}")
        raise Exception(err_msg)
    db_list = out.decode().splitlines()
    # 排除系统数据库
    return [
        db
        for db in db_list
        if db not in ("Database", "information_schema", "performance_schema")
    ]


async def dump_database(db_name: str, dest_dir: str, mysql_pwd: str) -> None:
    """
    调用 mysqldump 备份单个数据库，并将备份文件保存到目标目录中。
    """
    file_path = os.path.join(dest_dir, f"{db_name}.sql")
    proc = await asyncio.create_subprocess_exec(
        "mysqldump",
        "-u",
        "root",
        f"-p{mysql_pwd}",
        db_name,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    dump_out, dump_err = await proc.communicate()
    if proc.returncode == 0:
        with open(file_path, "wb") as f:
            f.write(dump_out)
        print(f"数据库 '{db_name}' 备份成功。")
    else:
        err_msg = dump_err.decode().strip()
        print(f"错误：备份数据库 '{db_name}' 失败 - {err_msg}")


async def main():
    base_dir = "/tmp"
    current_date = datetime.now().strftime("%Y_%m_%d")
    backup_folder = os.path.join(base_dir, f"mysql_backup_{current_date}")
    os.makedirs(backup_folder, exist_ok=True)

    mysql_pwd = getpass.getpass("请输入 MySQL 密码: ")

    try:
        dbs = await retrieve_db_list(mysql_pwd)
        if not dbs:
            print("没有发现需要备份的数据库。")
            return

        # 并发备份每个数据库
        tasks = [
            asyncio.create_task(dump_database(db, backup_folder, mysql_pwd))
            for db in dbs
        ]
        await asyncio.gather(*tasks)
    except Exception as e:
        print(f"备份过程中出现异常：{e}")


if __name__ == "__main__":
    asyncio.run(main())
