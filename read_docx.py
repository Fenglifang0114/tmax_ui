import zipfile
import xml.etree.ElementTree as ET

doc = zipfile.ZipFile(r'C:\Users\Administrator\Desktop\modbus\SW40 Modbus 使用参考.docx')
xml_content = doc.read('word/document.xml')
tree = ET.fromstring(xml_content)
text = []
for node in tree.iter():
    if node.tag == '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t':
        if node.text:
            text.append(node.text)
        
print(' '.join(text))
