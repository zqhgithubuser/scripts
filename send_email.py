#!/usr/bin/python3

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# 配置信息
port = 465
smtp_server = "smtp.163.com"
login = "15815085647@163.com"
password = "XXXX"

sender_email = login
receiver_email = "3535521945@qq.com"

html = """\
<html>
  <body>
    <div>
      <h2>你好</h2>
      <a href="http://www.baidu.com">百度一下</a>
    </div>
  </body>
</html>
"""

message = MIMEMultipart()
message["Subject"] = "这是一封HTML邮件"
message["From"] = sender_email
message["To"] = receiver_email
message.attach(MIMEText(html, "html"))

with smtplib.SMTP_SSL(smtp_server, port) as server:
  server.login(login, password)
  server.sendmail(sender_email, receiver_email, message.as_string())
  print("邮件发送成功!")
