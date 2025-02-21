import requests

data = {"id": "0123456789"}

headers = {"Content-Type": "application/json", "Accept": "application/json"}
response = requests.post(
    "http://httpbin.org/post", data=data, headers=headers, json=data
)
print("HTTP Status Code: " + str(response.status_code))

if response.status_code == 200:
    results = response.json()
    for result in results.items():
        print(result)
    print("Headers response: ")
    for header, value in response.headers.items():
        print(f"{header}: {value}")
    print("Headers request: ")
    for header, value in response.request.headers.items():
        print(f"{header}: {value}")
else:
    print(f"Error code: ", str(response.status_code))
