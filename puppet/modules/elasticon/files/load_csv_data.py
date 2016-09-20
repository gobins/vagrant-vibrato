import csv
import urllib2
import json
import argparse
import sys


def check_argument(args):
    parser = argparse.ArgumentParser(
        description='Python script to parse and load csv data'
    )

    parser.add_argument(
        '-f',
        '--file',
        help='Path to the csv file',
        required=True,
        action='store',
        dest='file'
    )

    results = parser.parse_args(args)
    return results


def read_file(file_path, headers):
    csvfile = open(file_path, 'rb')
    reader = csv.DictReader(csvfile, headers)
    csv_contents = []
    for row in reader:
        if row['Cluster'] != "" and row['Cluster'] != 'Cluster':
            csv_contents.append(dict((k, v) for k, v in row.iteritems() if k != None))
    return csv_contents


def main():
    results = check_argument(sys.argv[1:])
    file_path = results.file

    hearders = ['Cluster', 'Social media platform', '2012-2013', '2013-2014', '2014-2015']
    report = read_file(file_path, hearders)
    url = 'http://localhost:9200/ict/data'

    # Parse and load data
    for row in report:
        row1 = dict(filter(lambda i:i[0] in ('Cluster', 'Social media platform', '2012-2013'), row.iteritems()))
        row2 = dict(filter(lambda i:i[0] in ('Cluster', 'Social media platform', '2013-2014'), row.iteritems()))
        row3 = dict(filter(lambda i:i[0] in ('Cluster', 'Social media platform', '2014-2015'), row.iteritems()))
        post_data(row1, url)
        post_data(row2, url)
        post_data(row3, url)


def post_data(data, url):
    req = urllib2.Request(url, json.dumps(data, ensure_ascii=False), {'Content-Type': 'application/json'})
    response = urllib2.urlopen(req)
    print response.read()

if __name__ == "__main__":
    main()
