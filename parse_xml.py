import xml.etree.ElementTree as ET
import re

with open('doc_xml.txt', 'r', encoding='utf-8') as f:
    xml_content = f.read()

# Strip namespaces to make searching easier
xml_content = re.sub(r'xmlns:?[^=]*="[^"]*"', '', xml_content)
xml_content = re.sub(r'[a-zA-Z0-9_]+:', '', xml_content)

tree = ET.fromstring(xml_content)
text = []
for node in tree.iter():
    if node.tag == 't':
        if node.text:
            text.append(node.text)

print('\n'.join(text))
