#!/usr/bin/python3

import smtplib
from dataclasses import dataclass
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


@dataclass
class SmtpServerConfig:
    password: str
    sender_email: str = "15815085647@163.com"
    smtp_server: str = "smtp.163.com"
    smtp_port: int = 465


def create_email_message(subject, sender_email, recipient_email, html_content):
    """创建邮件消息"""
    message = MIMEMultipart()
    message["Subject"] = subject
    message["From"] = sender_email
    message["To"] = recipient_email
    message.attach(MIMEText(html_content, "html"))
    return message


def send_email(config, subject, recipient_email, html_content):
    """发送邮件"""
    sender_email = config.sender_email
    password = config.password
    smtp_server = config.smtp_server
    smtp_port = config.smtp_port

    # 创建邮件消息
    email_message = create_email_message(
        subject, sender_email, recipient_email, html_content
    )

    # 使用 SMTP 发送邮件
    with smtplib.SMTP_SSL(smtp_server, smtp_port) as server:
        server.login(sender_email, password)
        server.sendmail(sender_email, recipient_email, email_message.as_string())
        print("邮件发送成功!")


if __name__ == "__main__":
    config = SmtpServerConfig(password="XXXX")

    recipient_email = "3535521945@qq.com"
    subject = "这是一封HTML邮件"
    html_content = """\
    <html>
      <body>
        <div>
          <h2>你好</h2>
          <a href="http://www.baidu.com">百度一下</a>
        </div>
      </body>
    </html>
    """

    send_email(config, subject, recipient_email, html_content)
