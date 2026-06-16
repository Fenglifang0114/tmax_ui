//原料类别管理弹框
import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';

//// 定义新增原料类型弹框组件
class RawTypeMgrDialog extends StatefulWidget {
  const RawTypeMgrDialog({super.key});
  @override
  RawTypeMgrDialogState createState() => RawTypeMgrDialogState();
}

class RawTypeMgrDialogState extends State<RawTypeMgrDialog> {
  TextEditingController rawTypeCtl = TextEditingController();
  var searchRawTypeCtl = TextEditingController();
  List<CategoryTypeList> searchRawTypeList = [];

  dynamic _eventbus1;
  dynamic _eventbus2;

  void showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowDeleteTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.deleteTypeUnusedConfirm,
        );
      },
    ).then((value) {
      if (value) {
        PublicFunctions.delUnusedRawType();
      }
    });
  }

  // 显示新增配方原料类型对话框
  void showAddRawTypeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return AddRawTypeDialog();
      },
    ).then((value) {
      setState(() {});
    });
  }

  // 显示新增配方原料类型对话框
  void showEditRawTypeDialog(CategoryTypeList categoryTypeInfo) {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return EditRawTypeDialog(categoryTypeInfo: categoryTypeInfo);
      },
    ).then((value) {
      setState(() {});
    });
  }

  void performSearch(String keyword) {
    searchRawTypeList = rawTypeList.where((rawType) {
      final rawName = rawType.categoryName.toLowerCase();
      return rawType.categoryId != 0 && rawName.contains(keyword);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    performSearch('');
    _eventbus1 = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            performSearch('');
            searchRawTypeCtl.clear();
          });
        } else {
          setState(() {
            performSearch('');
            searchRawTypeCtl.clear();
          });
        }
      }
    });
    _eventbus2 = eventBus.on<EventRespRawTypeAdd>().listen((event) {
      if (mounted) {
        PublicFunctions.getRawTypeList();
        showTipInfo(localizedStrings.fSuccessMsg, context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    searchRawTypeCtl.dispose();
    rawTypeCtl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 590,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
              context,
              localizedStrings.fRawCategoryManagement,
              true,
              onClose: () {
                rawDataList.clear();
                PublicFunctions.getRawList(); // 刷新原料列表
                formulaDataList.clear();
                PublicFunctions.getFormulaList(); // 刷新原料类型列表
                Navigator.pop(context);
              },
            ),
            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                    left: largePadding,
                    right: largePadding,
                    bottom: largePadding * 2),
                height: 150,
                // width: 500,
                child: Column(children: [
                  Container(
                    height: 68,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                              height: btnHeight,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextField(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                    controller: searchRawTypeCtl,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            searchRawTypeCtl.clear();
                                            performSearch('');
                                          });
                                        },
                                      ),
                                      hintText: localizedStrings.fSearchHint,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            // 设置提示文本样式
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        // 这里可以添加搜索逻辑

                                        performSearch(value);
                                      });
                                    }),
                              )),
                        ),
                        SizedBox(
                          width: largePadding,
                        ),
                        showTextButton(
                          context,
                          btnHeight,
                          localizedStrings.gBtnClear,
                          () {
                            showDeleteDialog();
                          },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.error,
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                        SizedBox(
                          width: largePadding,
                        ),
                        showTextButton(
                          context,
                          btnHeight,
                          localizedStrings.gBtnAdd,
                          () {
                            showAddRawTypeDialog();
                          },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.onTertiaryFixedVariant,
                          Theme.of(context).colorScheme.onPrimary,
                        )
                      ],
                    ),
                  ), //搜索框
                  Container(
                    height: 42,
                    color: Theme.of(context).colorScheme.surfaceDim,
                    padding: const EdgeInsets.symmetric(
                      horizontal: regularPadding,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          localizedStrings.fRawMaterialTypeNameCol,
                          style: Theme.of(context).textTheme.bodySmall!.apply(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          overflow: TextOverflow.ellipsis,
                        )),
                        SizedBox(
                            width: 80,
                            child: Text(localizedStrings.fTipOperation,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                overflow: TextOverflow.ellipsis))
                      ],
                    ),
                  ),

                  searchRawTypeList.isEmpty
                      ? Expanded(
                          child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            localizedStrings.fTipNoData,
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: searchRawTypeList.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: regularPadding,
                                        vertical: 0),
                                    // minVerticalPadding: 2,
                                    title: Text(
                                      searchRawTypeList[index].categoryName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                    ),
                                    trailing: SizedBox(
                                      width: 80,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                showEditRawTypeDialog(
                                                    searchRawTypeList[index]);
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_forever_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            onPressed: () {
                                              //删除原料前，先判断是否有原料使用了这个类型
                                              for (var raw in rawDataList) {
                                                String rawType = getRawTypeName(
                                                    raw.categoryId!);
                                                if (rawType ==
                                                    searchRawTypeList[index]
                                                        .categoryName) {
                                                  showTipInfo(
                                                      localizedStrings
                                                          .fRawInUseDeleteErrorMsg,
                                                      context);
                                                  return;
                                                }
                                              }

                                              setState(() {
                                                PublicFunctions.deleteRawType(
                                                    searchRawTypeList[index]
                                                        .categoryName);
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  //添加分割线
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 0,
                                    endIndent: 0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceDim,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//// 定义新增原料类型弹框组件
class AddRawTypeDialog extends StatefulWidget {
  const AddRawTypeDialog({super.key});
  @override
  AddRawTypeDialogState createState() => AddRawTypeDialogState();
}

class AddRawTypeDialogState extends State<AddRawTypeDialog> {
  TextEditingController rawTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 376,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部

            ...dialogHeadStyle(
                context, localizedStrings.fAddRawMaterialTypeBtn, true),
            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 150,
                width: 500,
                child: Column(children: [
                  SizedBox(
                    height: 42,
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            localizedStrings.fRawMaterialTypeNameCol,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    // height: 48,

                    child: Row(children: [
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.only(left: 16, right: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline, // 设置边框颜色
                                width: 1, // 设置边框宽度
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: rawTypeCtl,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    localizedStrings.fInputRawMaterialTypeHint,
                                suffixIconConstraints:
                                    BoxConstraints.tight(Size(40, 40)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      rawTypeCtl.clear(); // 清空文本
                                    });
                                  },
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 5,
                              minLines: 1,
                              onChanged: (value) {
                                setState(() {});
                              },
                            )),
                      ),
                    ]),
                  ),
                ]),
              ),
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
                      onPressed: rawTypeCtl.text.isNotEmpty
                          ? () {
                              // 检查原料类型是否已经存在
                              for (var item in rawTypeList) {
                                if (item.categoryName == rawTypeCtl.text) {
                                  showTipInfo(
                                      localizedStrings.fTypeExistsMsg, context);
                                  return;
                                }
                              }
                              PublicFunctions.addRawType(rawTypeCtl.text);
                              Navigator.pop(context);
                            }
                          : null, // 如果文本框为空，则按钮不可点击

                      child: Text(
                        localizedStrings.gBtnConfirm,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
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
}

//// 定义新增原料类型弹框组件
class EditRawTypeDialog extends StatefulWidget {
  final CategoryTypeList categoryTypeInfo; // 接收原料类型名称

  const EditRawTypeDialog({super.key, required this.categoryTypeInfo});
  @override
  EditRawTypeDialogState createState() => EditRawTypeDialogState();
}

class EditRawTypeDialogState extends State<EditRawTypeDialog> {
  TextEditingController rawTypeCtl = TextEditingController();
  @override
  void initState() {
    super.initState();
    rawTypeCtl.text = widget.categoryTypeInfo.categoryName;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 376,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部

            ...dialogHeadStyle(
                context, localizedStrings.fEditRawMaterialTypeBtn, true),
            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 150,
                width: 500,
                child: Column(children: [
                  SizedBox(
                    height: 42,
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            localizedStrings.fRawMaterialTypeNameCol,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    // height: 48,

                    child: Row(children: [
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.only(left: 16, right: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline, // 设置边框颜色
                                width: 1, // 设置边框宽度
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: rawTypeCtl,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    localizedStrings.fInputRawMaterialTypeHint,
                                suffixIconConstraints:
                                    BoxConstraints.tight(Size(40, 40)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      rawTypeCtl.clear(); // 清空文本
                                    });
                                  },
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 5,
                              minLines: 1,
                              onChanged: (value) {
                                setState(() {});
                              },
                            )),
                      ),
                    ]),
                  ),
                ]),
              ),
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
                      onPressed: rawTypeCtl.text.isNotEmpty
                          ? () {
                              // 检查原料类型是否已经存在
                              for (var item in rawTypeList) {
                                if (item.categoryName == rawTypeCtl.text) {
                                  showTipInfo(
                                      localizedStrings.fTypeExistsMsg, context);
                                  return;
                                }
                              }
                              PublicFunctions.editRawType(rawTypeCtl.text,
                                  widget.categoryTypeInfo.categoryId);
                              Navigator.pop(context);
                            }
                          : null, // 如果文本框为空，则按钮不可点击
                      child: Text(
                        localizedStrings.gBtnConfirm,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
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
}
