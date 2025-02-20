import getpass

import paramiko

PORT = 22


def run(hostname, username, password, command, port=PORT):
    ssh_client = paramiko.SSHClient()

    try:
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(hostname, port, username, password)

        _, stdout, stderr = ssh_client.exec_command(command)

        for line in stdout:
            print(line.strip())

        if err := stderr.read().decode().strip():
            print("Error:\n", err)
    except paramiko.AuthenticationException:
        print("认证失败：用户名或密码错误。")
    except paramiko.SSHException as e:
        print(f"SSH 连接失败：{e}")
    except Exception as e:
        print(f"未知错误：{e}")
    finally:
        ssh_client.close()


if __name__ == "__main__":
    hostname = input("Enter the target host: ")
    username = input("Enter username: ")
    password = getpass.getpass(prompt="Enter password: ")
    command = input("Enter command: ")

    run(hostname, username, password, command)
