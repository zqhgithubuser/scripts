import subprocess


command_ping = "/usr/bin/ping"
ping_parameter = "-c 1"
domain = "www.baidu.com"

p = subprocess.Popen(
    [command_ping, ping_parameter, domain],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True,
)
stdout, stderr = p.communicate()

print("Output:\n", stdout)
if stderr:
    print("Error:\n", stderr)
