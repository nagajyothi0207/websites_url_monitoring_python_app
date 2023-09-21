import csv
import requests
import time
from datetime import datetime, timedelta
from flask import Flask, jsonify
import threading

app = Flask(__name__)

# print a nice greeting.
def say_hello(username = "Monitoring Application"):
    return '<h1 style="text-align:center"> <p>URL %s!</p></h1>\n' % username

# some bits of text for the page.
header_text = '''
   <html>
   <body>
   <h1 style="text-align:center"><head><title>URL Monitoring Application</title></head></h1>\n'''
instructions = '''
    <p> <h2 style="text-align:center"> <em>Hint</em>: This is a RESTful web service! Append a status
    to the URL (for example: <code>/status</code>) to view the status of website monitoring.</h2></p>\n'''
home_link = '<p><a href="/">Back</a></p>\n'
footer_text = '</body>\n</html>'

# add a rule for the index page.
app.add_url_rule('/', 'index', (lambda: header_text +
    say_hello() + instructions + footer_text))

# Function to check the HTTP status of a URL
def check_url(url):
    try:
        response = requests.get(url)
        return response.status_code
    except requests.exceptions.RequestException:
        return -1  # Connection error

# Load URLs from the CSV file
def load_urls_from_csv(file_path):
    urls = []
    with open(file_path, 'r') as csv_file:
        csv_reader = csv.reader(csv_file)
        for row in csv_reader:
            urls.extend(row)
    return urls

# Initialize the global monitoring_results dictionary
monitoring_results = {}

# Function to monitor URLs
def monitor_urls():
    while True:
        csv_file_path = 'urls.csv'
        urls = load_urls_from_csv(csv_file_path)
        current_time = datetime.now()

        for url in urls:
            status_code = check_url(url)
            if url not in monitoring_results:
                monitoring_results[url] = []

            monitoring_results[url].append((current_time, status_code))

            # Remove data older than 1 hour
            monitoring_results[url] = [(time, status) for time, status in monitoring_results[url] if current_time - time <= timedelta(hours=1)]

        time.sleep(600)  # Sleep for 10 minutes

# Thread to periodically monitor URLs
monitoring_thread = threading.Thread(target=monitor_urls)
monitoring_thread.daemon = True
monitoring_thread.start()

# Route to get monitoring status
@app.route('/status')
def get_monitoring_status():
    return jsonify(monitoring_results)

if __name__ == "__main__":
    # Setting debug to True enables debug output. This line should be
    # removed before deploying a production app.
    # Run the Flask app on port 5000
    app.debug = True
    app.run(host="0.0.0.0")
