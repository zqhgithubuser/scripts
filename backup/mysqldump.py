import getpass
import os
import subprocess
from concurrent.futures import ProcessPoolExecutor
from datetime import datetime


def get_databases(password):
    try:
        result = subprocess.run(
            ["mysql", "-u", "root", f"-p{password}", "-e", "SHOW DATABASES;"],
            capture_output=True,
            text=True,
            check=True,
        )
        databases = result.stdout.splitlines()
        return [
            db
            for db in databases
            if db not in ["Database", "information_schema", "performance_schema"]
        ]
    except subprocess.CalledProcessError as e:
        print(f"获取数据库时出错: {e.stderr}")
        raise


def backup_database(db, backup_dir, password):
    backup_path = os.path.join(backup_dir, f"{db}.sql")

    try:
        with open(backup_path, "w") as f:
            subprocess.run(
                ["mysqldump", "-u", "root", f"-p{password}", db],
                stdout=f,
                stderr=subprocess.PIPE,
                text=True,
                check=True,
            )
            print(f"数据库 {db} 备份成功。")
    except subprocess.CalledProcessError as e:
        print(f"备份数据库 {db} 时出错: {e.stderr}")


def main():
    date_str = datetime.now().strftime("%Y-%m-%d")
    backup_dir = os.path.join("/tmp", f"backup_{date_str}")

    if not os.path.exists(backup_dir):
        os.makedirs(backup_dir)

    password = getpass.getpass("请输入 MySQL 密码: ")

    try:
        databases = get_databases(password)

        # 创建进程池并为每个数据库备份任务提交任务
        with ProcessPoolExecutor() as executor:
            futures = [
                executor.submit(backup_database, db, backup_dir, password)
                for db in databases
            ]

            for future in futures:
                future.result()

    except Exception as e:
        print(f"备份失败: {e}")


if __name__ == "__main__":
    main()
