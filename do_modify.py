import sys

with open('lib/print_online/print_online_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace the Layout
layout_start = content.find('Expanded(\n                          child: Container(\n                        color: Theme.of(context).colorScheme.surfaceBright,\n                        child: Column(')

if layout_start != -1:
    layout_end = content.find('Container(\n                                    width: leftBtnWidth,', layout_start)
    
    new_layout = '''Expanded(
                          child: Container(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 220,
                              color: Theme.of(context).colorScheme.surfaceTint,
                              child: SizedBox(
                                height: height,
                                child: Column(
                                  children: [
                                    SizedBox(height: regularPadding),
                                    Expanded(
                                      child: NewAllScaleListWidget(
                                        listWidth: 220,
                                        selScaleId: myDefScaleInfo.defScaleId ?? -1,
                                        clickScale: (scale) {
                                          setState(() {
                                            myDefScaleInfo.defScaleId = scale.scaleId;
                                            PublicFunctions.getWeight(scale.scaleId);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  showHeadWidget(width - 220),
                                  Container(
                                    height: 1,
                                    color: Theme.of(context).colorScheme.outlineVariant,
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Left Side Vars
                                        '''
    
    # We must close the two Expanded/Column we opened at the end of the build method
    # Let's find the end of the Row children that contains leftBtnWidth
    
    content = content[:layout_start] + new_layout + content[layout_end:]
    
    # Now fix the ending braces of build method
    # The original was Column( children: [ Row(children: [ leftBtnWidth, Expanded(Stack(Canvas)), RightSide ] ) ] )
    # The new is Row( children: [ ScaleList, Expanded(child: Column( children: [ showHeadWidget, Expanded(child: Row(children: [ leftBtnWidth, Expanded(Stack(Canvas)), RightSide ] )) ] )) ] )
    
    # Find the end of the build method by finding ));\n  } at the end
    end_of_build = content.rfind('));\n  }')
    if end_of_build != -1:
        # We need to add one more ) or something?
        # Actually: 
        # original: Row -> SizedBox -> children of Column -> Container
        # It's better to just manually fix it if we get a syntax error.
        
        pass

# 2. Replace _showPrintPreview
old_preview = '''  void _showPrintPreview() async {
    // Generate CSV from current canvas
    _exportCSV();

    // We will send this CSV along with the real-time weight to the backend

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String protocol = prefs.getString('printOnline_protocol') ?? 'Lp50';
    String serialPort = prefs.getString('printOnline_serialPort') ?? 'COM1';
    String baudRateStr = prefs.getString('printOnline_baudRate') ?? '9600';
    int baudRate = int.tryParse(baudRateStr) ?? 9600;

    String weightVal = '0.000';
    String weightUnit = 'kg';
    bool isNet = false;
    bool isZero = false;

    if (_currentWeight != null) {
      weightVal = _currentWeight!.weightVal ?? '0.000';
      weightUnit = _currentWeight!.weightUnit ?? 'kg';
      isNet = _currentWeight!.isNet ?? false;
      isZero = _currentWeight!.isZero ?? false;
    }

    Map<String, dynamic> requestBody = {
      'protocol': protocol,
      'serialPort': serialPort,
      'baudRate': baudRate,
      'formatCsv': csv,
      'weightVal': weightVal,
      'weightUnit': weightUnit,
      'isNet': isNet,
      'isZero': isZero,
    };

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:7878/api/print/online'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        showTipInfo('Print command sent successfully', context);
      } else {
        showTipInfo('Failed to print: ', context);
      }
    } catch (e) {
      showTipInfo('Error communicating with backend: ', context);
    }
  }'''

new_preview = '''  void _executePrint(List<DraggableElement> previewElements) async {
    _exportCSV(exportElements: previewElements);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String protocol = prefs.getString('printOnline_protocol') ?? 'Lp50';
    String serialPort = prefs.getString('printOnline_serialPort') ?? 'COM1';
    String baudRateStr = prefs.getString('printOnline_baudRate') ?? '9600';
    int baudRate = int.tryParse(baudRateStr) ?? 9600;

    String weightVal = '0.000';
    String weightUnit = 'kg';
    bool isNet = false;
    bool isZero = false;

    if (_currentWeight != null) {
      weightVal = _currentWeight!.weightVal ?? '0.000';
      weightUnit = _currentWeight!.weightUnit ?? 'kg';
      isNet = _currentWeight!.isNet ?? false;
      isZero = _currentWeight!.isZero ?? false;
    }

    Map<String, dynamic> requestBody = {
      'protocol': protocol,
      'serialPort': serialPort,
      'baudRate': baudRate,
      'formatCsv': csv,
      'weightVal': weightVal,
      'weightUnit': weightUnit,
      'isNet': isNet,
      'isZero': isZero,
    };

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:7878/api/print/online'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        if (mounted) showTipInfo('Print command sent successfully', context);
      } else {
        if (mounted) showTipInfo('Failed to print: ', context);
      }
    } catch (e) {
      if (mounted) showTipInfo('Error communicating with backend: ', context);
    }
  }

  void _showPrintPreview() {
    List<DraggableElement> previewElements = elements.map((e) => e.copy()).toList();
    for (var element in previewElements) {
      if (element.type == ElementType.data && element.varName != null) {
        String varName = element.varName!;
        String val = varName;
        if (varName == "Gross" || varName == "Net") {
          val = _currentWeight?.weightVal ?? '0.000';
        } else if (varName == "Tare") {
          val = '0.000';
        } else if (varName == "WeightUnit") {
          val = _currentWeight?.weightUnit ?? 'kg';
        } else if (varName == "Date") {
          val = DateFormat('dd/MM/yyyy').format(DateTime.now());
        } else if (varName == "Time") {
          val = DateFormat('HH:mm:ss').format(DateTime.now());
        } else if (varName == "NO.") {
          val = "1";
        } else if (varName == "PCS") {
          val = "1";
        }
        element.type = ElementType.text;
        element.content = val;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(localizedStrings.printPreview),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          content: Container(
            width: canvasSize.width * currentScale,
            height: canvasSize.height * currentScale,
            color: Colors.white,
            child: Stack(
              children: previewElements.map((element) {
                Widget child;
                int quarterTurns = (element.rotation! / 90).round();
                
                String displayContent = element.content ?? 'Text';

                child = RotatedBox(
                  quarterTurns: quarterTurns,
                  child: SizedBox(
                      width: element.size.width,
                      height: element.size.height,
                      child: Text(displayContent,
                          softWrap: true,
                          style: TextStyle(
                              fontFamily: "simsunb",
                              fontSize: double.parse(element.fontSize.toString()),
                              color: Colors.black,
                              fontWeight: (element.fontBold == 'true')
                                  ? FontWeight.bold
                                  : FontWeight.normal))),
                );

                return Positioned(
                  left: element.position.dx,
                  top: element.position.dy,
                  child: child,
                );
              }).toList(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _executePrint(previewElements);
              },
              child: const Text('print'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }'''

content = content.replace(old_preview, new_preview)

with open('lib/print_online/print_online_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('done')
