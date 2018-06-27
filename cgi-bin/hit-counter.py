#!C:/WinPython/python-3.6.3.amd64/python.exe -u

import cgi
import cgitb
import time
import os
cgitb.enable()
hit_count_path = os.path.join(os.path.dirname(__file__), "hit-count.txt")

if os.path.isfile(hit_count_path):
    hit_count = int(open(hit_count_path).read())
    hit_count += 1
else:
    hit_count = 1

hit_counter_file = open(hit_count_path, 'w')
hit_counter_file.write(str(hit_count))
hit_counter_file.close()

header = "Content-type: text/html\n\n"


date_string = time.strftime('%A, %B %d, %Y at %I:%M:%S %p %Z')

html = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Current date</title>
</head>
<body>
  <p>
  Date: {0}
  </p>
  <p>
  Hit count: {1}
  </p>
</body>
</html>
""".format(cgi.escape(date_string), cgi.escape(str(hit_count)))

print(header + html)
