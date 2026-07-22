import sys

def modify_layout(content):
    start = content.find('Expanded(\n                          child: Container(\n                        color: Theme.of(context).colorScheme.surfaceBright,\n                        child: Column(')
    if start == -1:
        start = content.find('Expanded(\n                          child: Container(')
        if start == -1:
            return content

    # Use a regex or find to locate the children
    print('Found start of layout')
    return content

with open('lib/print_online/print_online_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = modify_layout(content)
