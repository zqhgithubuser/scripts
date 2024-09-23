#!/usr/bin/python3

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dataclasses import dataclass


@dataclass
class Config:
    smtp_server: str
    port: int
    login_email: str
    password: str


def send_email(config: Config, receiver_email: str, subject: str,
               html_content: str):
    sender_email = config.login_email

    message = MIMEMultipart()
    message["Subject"] = subject
    message["From"] = sender_email
    message["To"] = receiver_email
    message.attach(MIMEText(html_content, "html"))

    with smtplib.SMTP_SSL(config.smtp_server, config.port) as server:
        server.login(config.login_email, config.password)
        server.sendmail(sender_email, receiver_email, message.as_string())
        print("邮件发送成功!")


config = Config(
    smtp_server="smtp.163.com",
    port=465,
    login_email="15815085647@163.com",
    password="XXXX"
)

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

if __name__ == "__main__":
    send_email(config, receiver_email, "这是一封HTML邮件", html)
