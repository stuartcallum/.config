import urllib.request
from xml.etree import ElementTree as ET

def fetch_xml_content(url):
    try:
        with urllib.request.urlopen(url) as response:
            return response.read().decode('utf-8')
    except Exception as e:
        print(f"Error fetching XML content: {e}")
        return None

def get_bondi_forecast_icon_code(xml_content):
    try:
        root = ET.fromstring(xml_content)
    except ET.ParseError as e:
        print(f"Error parsing XML content: {e}")
        return None

    for area in root.iter('area'):
        description = area.attrib.get('description', '')
        if description.lower() == 'bondi':
            current_forecast_icon = area.find('.//forecast-period/element[@type="forecast_icon_code"]')
            if current_forecast_icon is not None:
                return current_forecast_icon.text

    print("Could not find Bondi forecast_icon_code.")
    return None

def get_emoji_for_forecast_icon_code(forecast_icon_code):
    emoji_mapping = {
        '1': '☀️',
        '2': '🌞',
        '3': '⛅',
        '4': '☁️',
        '6': '🌫️',
        '8': '🌧️',
        '9': '🌬️',
        '10': '🌫️',
        '11': '🌧️',
        '12': '🌧️',
        '13': '🌪️',
        '14': '❄️',
        '15': '⚡',
        '16': '⚡',
        '17': '🌧️',
        '18': '🌧️',
        '19': '🌀',
    }

    return emoji_mapping.get(forecast_icon_code, 'Unknown Emoji')

def main():
    bom_url = 'ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11060.xml'
    xml_content = fetch_xml_content(bom_url)

    if xml_content:
        forecast_icon_code = get_bondi_forecast_icon_code(xml_content)
        if forecast_icon_code is not None:
            emoji = get_emoji_for_forecast_icon_code(forecast_icon_code)
            print(emoji)
        else:
            print("Failed to get Bondi forecast_icon_code.")
    else:
        print("Failed to fetch XML content.")

if __name__ == "__main__":
    main()

