#!/usr/bin/env python3

import pycurl
from xml.etree import ElementTree as ET
from datetime import datetime, timedelta
import sys
import json

emoji_mapping = {
    '1': '☀️',
    '2': '🌙',
    '3': '🌤',
    '4': '☁️',
    '6': '🌫',
    '8': '🌧',
    '9': '💨',
    '10': '🌁',
    '11': '🌦',
    '12': '🌧',
    '13': '🌪',
    '14': '❄️',
    '15': '❄️',
    '16': '⛈',
    '17': '🌦',
    '18': '🌧',
    '19': '🌀',
}


def fetch_xml_content(url):
    buffer = []

    def write_callback(data):
        buffer.append(data.decode('utf-8'))

    def curl():
        c = pycurl.Curl()
        c.setopt(c.URL, url)
        c.setopt(c.WRITEFUNCTION, write_callback)
        c.perform()
        c.close()

    curl()
    xml_content = ''.join(buffer)
    return xml_content

def print_forecast_period(forecast_period):
    start_time_utc = forecast_period.attrib['start-time-utc']
    start_time_local = datetime.strptime(start_time_utc, '%Y-%m-%dT%H:%M:%SZ') + timedelta(hours=11)
    day_of_week = start_time_local.strftime('%A')

    print(f"{day_of_week}")

    for element in forecast_period.iter():
        if element.tag != forecast_period.tag:
            element_type = element.attrib.get('type', '')
            units = element.attrib.get('units', '')
            element_text = element.text if element.text else 'No data'

            if element_type == 'forecast_icon_code' and element_text in emoji_mapping:
                element_text = emoji_mapping[element_text]

            print(f"  {element_type}: {element_text} {units}")

    print('-' * 40)

def parse_forecast(xml_content, target_description=None):
    try:
        root = ET.fromstring(xml_content)
    except ET.ParseError as e:
        print(f"Error parsing XML content: {e}")
        return

    for area in root.iter('area'):
        description = area.attrib.get('description', '')

        if target_description and description.lower() != target_description.lower():
            continue

        print(f"{description} Forecast:")

        for forecast_period in area.iter('forecast-period'):
            print_forecast_period(forecast_period)

def list_descriptions(xml_content):
    try:
        root = ET.fromstring(xml_content)
    except ET.ParseError as e:
        print(f"Error parsing XML content: {e}")
        return
    
    descriptions = set()

    for area in root.iter('area'):
        description = area.attrib.get('description', '')
        descriptions.add(description)

    print("List of queryable descriptions:")
    for desc in sorted(descriptions):
        print(f"    {desc}")


def main():
    # url = 'ftp://ftp.bom.gov.au/anon/gen/fwo/IDN10064.xml'
    url = 'ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11060.xml'

    xml_content = fetch_xml_content(url)
    if len(sys.argv) > 1:
        target_description = sys.argv[1]
        parse_forecast(xml_content, target_description)
    else:
        list_descriptions(xml_content)

if __name__ == "__main__":
    main()


