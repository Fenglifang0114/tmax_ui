import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/custom_model_info.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class ModelSelectionScreen extends StatefulWidget {
  final List<ModelNameInfo> modelList;
  final ValueChanged onChanged;
  final bool onlyScpX;
  const ModelSelectionScreen(
      {super.key, required this.modelList, required this.onChanged, this.onlyScpX = false});
  @override
  ModelSelectionScreenState createState() => ModelSelectionScreenState();
}

class ModelSelectionScreenState extends State<ModelSelectionScreen> {
  String _searchQuery = '';
  ModelNameInfo? _selModel;
  String _selProtocal = '';
  late Map<String, List<ModelNameInfo>> _groupedModels;
  @override
  void initState() {
    super.initState();
    _groupModels();
  }

  // 按照Category分组数据
  void _groupModels() {
    _groupedModels = {};
    // 过滤数据：根据搜索关键词过滤
    final filteredList = widget.modelList.where((model) {
      final customName = model.customScaleName ?? '';
      final innerName = model.innerScaleName ?? '';
      final category = model.category ?? '';

      bool matchesSearch = customName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          innerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (!matchesSearch) return false;

      if (widget.onlyScpX) {
        if (model.subModel == null || model.subModel!.isEmpty) return false;
        bool hasScpx = model.subModel!.any((sub) => sub.protocolName == 'SCP-X');
        return hasScpx;
      }
      return true;
    }).toList();
    // 分组
    for (var model in filteredList) {
      final category = model.category ?? 'Other';
      if (!_groupedModels.containsKey(category)) {
        _groupedModels[category] = [];
      }
      _groupedModels[category]!.add(model);
    }
  }

  // 处理模型选择
  void _selectModel(ModelNameInfo model) {
    setState(() {
      _selModel = model;
      if (model.subModel != null && model.subModel!.isNotEmpty) {
        if (widget.onlyScpX) {
          int idx = model.subModel!.indexWhere((sub) => sub.protocolName == 'SCP-X');
          if (idx != -1) {
            _selProtocal = model.subModel![idx].protocolName ?? '';
            widget.onChanged(idx);
          } else {
            _selProtocal = model.subModel![0].protocolName ?? '';
            widget.onChanged(0);
          }
        } else {
          _selProtocal = model.subModel![0].protocolName ?? '';
          widget.onChanged(0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _groupModels(); // 每次build时重新分组
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 1002,
        height: 758,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            ...dialogHeadStyle(context, localizedStrings.gModelName, true),
            Expanded(
              child: Row(children: [
                Expanded(
                    flex: 5,
                    child: Column(children: [
                      // 搜索框
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: largePadding, vertical: regularPadding),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: localizedStrings.gModelName,
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              suffixIcon: Icon(
                                Icons.search,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodySmall!,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                      ),

                      // 显示选中的模型
                      if (_selModel != null)
                        Container(
                          height: 40,
                          margin: EdgeInsets.symmetric(
                            horizontal: largePadding,
                          ),
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(30),
                          child: Row(
                            children: [
                              SizedBox(width: smallPadding),
                              Icon(Icons.check_circle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryFixedVariant),
                              Text(
                                '   ${_selModel!.customScaleName ?? _selModel!.innerScaleName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),

                      // 分类显示模型列表
                      Expanded(
                        child: ListView.builder(
                          itemCount: _groupedModels.length,
                          itemBuilder: (context, index) {
                            final category =
                                _groupedModels.keys.elementAt(index);
                            final models = _groupedModels[category]!;
                            return _buildCategorySection(category, models);
                          },
                        ),
                      ),
                    ])),
                if (_selModel != null)
                  Expanded(
                      flex: 8,
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: largePadding,
                            vertical: regularPadding,
                          ),
                          child: Column(
                            children: [
                              Divider(
                                height: 1,
                                color: Theme.of(context).colorScheme.surfaceDim,
                              ),
                              Row(children: [
                                if (_selModel!.subModel != null)
                                  RadioListHorizontalScroll(
                                    key: ValueKey(_selModel),
                                    subModels: _selModel!.subModel!,
                                    onChanged: (value) {
                                      if (value >=
                                          _selModel!.subModel!.length) {
                                        return;
                                      }
                                      setState(() {
                                        _selProtocal = _selModel!
                                            .subModel![value].protocolName!;
                                        widget.onChanged(value);
                                      });
                                    },
                                  )
                              ]),
                              Divider(
                                height: 1,
                                color: Theme.of(context).colorScheme.surfaceDim,
                              ),
                            ],
                          ),
                        ),
                        // 预览
                        Expanded(
                          child: AdvancedImageWithZoom(
                            imagePath: getImagePath(_selProtocal),
                            maxHeight: 700,
                          ),
                        )
                      ])),
              ]),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'model': _selModel,
                          'protocol': _selProtocal,
                        });
                      },
                      child: Text(
                        localizedStrings.gBtnConfirm,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        localizedStrings.gBtnCancel,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ModelNameInfo> models) {
    return Card(
      margin: EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Text(
              category,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          // 模型按钮
          Padding(
            padding: const EdgeInsets.all(regularPadding),
            child: Wrap(
              spacing: regularPadding,
              runSpacing: regularPadding,
              children: models.map((model) {
                final isSelected = _selModel == model;
                return SizedBox(
                    height: 40,
                    child: ActionChip(
                      label: Text(model.customScaleName ?? ''),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                        side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLowest),
                      ),
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface),
                      onPressed: () => _selectModel(model),
                    ));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

String getImagePath(String protocolName) {
  if (protocolName == 'SCP-X' || protocolName == 'None') {
    return '';
  }
  if (protocolName == '') {
    return 'assets/SCP/SCP-01.jpg';
  }
  return 'assets/SCP/$protocolName.jpg';
}

Future<bool> doesAssetExist(String assetPath) async {
  try {
    // 方法2.1: 使用 rootBundle.load (最可靠)
    await rootBundle.load(assetPath);
    return true;
  } catch (_) {
    return false;
  }
}

class AdvancedImageWithZoom extends StatelessWidget {
  final String imagePath;
  final double maxHeight;

  const AdvancedImageWithZoom({
    super.key,
    required this.imagePath,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: regularPadding,
        vertical: 8,
      ),
      child: GestureDetector(
        onTap: () => _showFullScreenImage(context),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
              alignment: Alignment.topLeft,
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return FullScreenImage(
            imagePath: imagePath,
          );
        },
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;
  const FullScreenImage({super.key, required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(230),
      body: SafeArea(
        child: Stack(
          children: [
            // 可缩放图片
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                boundaryMargin: EdgeInsets.all(30),
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 关闭按钮
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  padding: EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RadioListHorizontalScroll extends StatefulWidget {
  final List<SubModel> subModels;
  final ValueChanged<int>? onChanged;
  const RadioListHorizontalScroll(
      {super.key, required this.subModels, this.onChanged});
  @override
  RadioListHorizontalScrollState createState() =>
      RadioListHorizontalScrollState();
}

class RadioListHorizontalScrollState extends State<RadioListHorizontalScroll> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // 固定高度
      width: 500,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // 水平滚动
        itemCount: widget.subModels.length,
        itemBuilder: (context, index) {
          final subModel = widget.subModels[index];
          final label =
              '${subModel.modelName ?? ''}${subModel.protocolName != null ? '' : ''} ${subModel.protocolName ?? ''}';

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Radio<int>(
                  value: index,
                  groupValue: _selectedIndex,
                  onChanged: (value) {
                    setState(() {
                      _selectedIndex = value!;
                      widget.onChanged?.call(value);
                    });
                  },
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
