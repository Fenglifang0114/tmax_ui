import re

with open('lib/print_online/print_online_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find _exportCSV method
start_idx = content.find('void _exportCSV()')
if start_idx == -1:
    print('Not found')
    exit()

end_idx = content.find('Widget buildBtnText', start_idx)

export_block = content[start_idx:end_idx]

# Replace elements with targetElements
export_block = export_block.replace('void _exportCSV() async {', 'void _exportCSV({List<DraggableElement>? exportElements}) async {\n    List<DraggableElement> targetElements = exportElements ?? elements;')
export_block = export_block.replace('elements.length', 'targetElements.length')
export_block = export_block.replace('elements[i]', 'targetElements[i]')

# Write back
content = content[:start_idx] + export_block + content[end_idx:]
with open('lib/print_online/print_online_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Done')
