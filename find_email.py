import re


def find_email(text):
    email_regex = re.compile(
        r'''(
        [a-zA-Z0-9._%+-]+
        @
        [a-zA-Z0-9.-]+
        (\.[a-zA-z]{2,4})
        )''', re.VERBOSE
    )

    for group in email_regex.findall(text):
        yield group[0]


if __name__ == '__main__':
    text = """\
    If you have any questions, please reach out to our team. You can contact John Doe at john.doe@example.com for technical support or Jane Smith at jane_smith123@mail.org for billing inquiries. Additionally, feel free to email our general support at support@mywebsite.co.uk. We are here to help you!
    """

    for email in find_email(text):
        print(email)