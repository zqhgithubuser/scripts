import paramiko
from dotenv import load_dotenv
import os

load_dotenv()

host = os.getenv("SSH_HOST")
username = os.getenv("SSH_USERNAME")
password = os.getenv("SSH_PASSWORD")

def run(cmd):
    with paramiko.SSHClient() as sshClient:
        sshClient.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        sshClient.connect(hostname=host, username=username, password=password)

        _, stdout, stderr = sshClient.exec_command(command=cmd)

        for line in stdout:
            print(line.strip())

        if err := stderr.read().decode():
            print(err)

if __name__ == '__main__':
    run("ls -l /tmp")