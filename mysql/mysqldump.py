import asyncio
import getpass
import os
from datetime import datetime


async def fetch_database_names(password: str) -> list[str]:
    """
    使用 MySQL 命令获取所有数据库名称，并过滤掉系统数据库。
    """
    process = await asyncio.create_subprocess_exec(
        "mysql",
        "-u",
        "root",
        f"-p{password}",
        "-e",
        "SHOW DATABASES;",
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    stdout, stderr = await process.communicate()
    if process.returncode != 0:
        error_message = stderr.decode().strip()
        print(f"错误：无法获取数据库列表 - {error_message}")
        raise Exception(error_message)

    databases = stdout.decode().splitlines()
    return [
        db
        for db in databases
        if db not in ("Database", "information_schema", "performance_schema")
    ]


async def backup_single_database(database: str, backup_dir: str, password: str) -> None:
    """
    使用 mysqldump 工具备份单个数据库，并将备份结果保存到指定目录。
    """
    backup_file = os.path.join(backup_dir, f"{database}.sql")
    process = await asyncio.create_subprocess_exec(
        "mysqldump",
        "-u",
        "root",
        f"-p{password}",
        database,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    stdout, stderr = await process.communicate()
    if process.returncode == 0:
        with open(backup_file, "wb") as file:
            file.write(stdout)
        print(f"数据库 '{database}' 备份成功。")
    else:
        error_message = stderr.decode().strip()
        print(f"错误：备份数据库 '{database}' 失败 - {error_message}")


async def main():
    """
    获取所有需要备份的数据库名称，并并发备份。
    """
    base_backup_dir = "/tmp"
    date_stamp = datetime.now().strftime("%Y_%m_%d")
    backup_folder = os.path.join(base_backup_dir, f"mysql_backup_{date_stamp}")
    os.makedirs(backup_folder, exist_ok=True)

    mysql_password = getpass.getpass("请输入 MySQL 密码: ")

    try:
        databases = await fetch_database_names(mysql_password)
        if not databases:
            print("没有发现需要备份的数据库。")
            return

        # 并发执行每个数据库的备份任务
        backup_tasks = [
            asyncio.create_task(
                backup_single_database(db, backup_folder, mysql_password)
            )
            for db in databases
        ]
        await asyncio.gather(*backup_tasks)
    except Exception as error:
        print(f"备份过程中出现异常：{error}")


if __name__ == "__main__":
    asyncio.run(main())
