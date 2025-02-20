import subprocess

process = subprocess.run(("ls", "-la"), capture_output=True, text=True)
print(process.stdout)
print(process.returncode)
