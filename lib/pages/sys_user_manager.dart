import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/sys_user_from_db.dart';
import 'package:t_max/data/sys_user_req.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/add_sys_user_page.dart';

import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/page_info.dart';

import 'package:t_max/widget/sticky_table.dart';
import '../data/language.dart';

// 定义 EncryptedValue 枚举
enum RoleValue {
  admin,
  operator,
}

// 扩展 EncryptedValue 枚举以添加翻译方法
extension RoleValueExtension on RoleValue {
  String getTranslation(BuildContext context) {
    switch (this) {
      case RoleValue.admin:
        return localizedStrings.admin; // 这里可以替换为翻译函数
      case RoleValue.operator:
        return localizedStrings.operator; // 这里可以替换为翻译函数
    }
  }
}

class SysUserManagerPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const SysUserManagerPage(
      {super.key, required this.onNavigate, required this.lastRouteName});
  @override
  State<SysUserManagerPage> createState() => SysUserManagerPageState();
}

class SysUserManagerPageState extends State<SysUserManagerPage>
    with SingleTickerProviderStateMixin {
  bool sort = false;
  final ScrollController _scrollController =
      ScrollController(); // 添加 ScrollController
  final TextEditingController _searchUserNameCtl = TextEditingController();
  final TextEditingController searchRoleCtl = TextEditingController();
  List<SysUserFromDb> searchUserList = [];
  List<SysUserFromDb> allUserList = [];
  SysUserFromDb? superAdminUser;

  Set<int> selectedUserRows = {};
  bool selectUserAll = false; // 添加全选状态

  int? clickedUserRow; // 添加点击行状态
  int selRoleId = -1;
  int selScaleId = -1; //选择的秤ID

  SysUserFromDb? selectedUser; //选中的配方，用于展示原料列表

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;
  dynamic _eventbus10;
  dynamic _eventbus11;
  dynamic _eventbus12;

  @override
  void initState() {
    super.initState();
    PublicFunctions.getAllSysUsers();

    _eventbus1 = eventBus.on<EventRespGetAllUsers>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        allUserList = sysUserFromDbFromJson(dataStr);
        if (allUserList.length == 1 && allUserList[0].isChanged == false) {
          superAdminUser = allUserList[0];
          allUserList = [];
        }
        setState(() {
          searchUserList = List.from(allUserList);
          selectedUserRows.clear();
          selectUserAll = false;
          if (allUserList.isNotEmpty && mySysUser.roleId == superAdminRoleId) {
            for (var user in allUserList) {
              if (user.userId == mySysUser.userId) {
                mySysUser.isChanged = user.isChanged;
              }
            }
          }
        });
        eventBus.fire(EventMySysUser(""));
      }
    });
    _eventbus2 = eventBus.on<EventRespDeleteSysUser>().listen((event) {
      if (mounted) {
        showTipInfo(localizedStrings.fSuccessMsg, context);
        PublicFunctions.getAllSysUsers();
      }
    });

    _eventbus3 = eventBus.on<EventRespAddSysUser>().listen((event) {
      if (mounted) {
        String dataString = (event.obj ?? '').toString();
        if (dataString.contains('rfid duplicate')) {
          showTipInfo(localizedStrings.tipRfidBoundOther, context);
        } else if (dataString.contains('fail')) {
          showTipInfo(localizedStrings.tipAddUserFailed, context);
        } else {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          PublicFunctions.getAllSysUsers();
        }
      }
    });

    _eventbus4 = eventBus.on<EventRespUpdateSysUser>().listen((event) {
      if (mounted) {
        String dataString = (event.obj ?? '').toString();
        if (dataString.contains('rfid duplicate')) {
          showTipInfo(localizedStrings.tipRfidBoundOther, context);
        } else if (dataString.contains('fail')) {
          showTipInfo(localizedStrings.tipUpdateUserFailed, context);
        } else {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          PublicFunctions.getAllSysUsers();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchUserNameCtl.dispose();
    searchRoleCtl.dispose();

    _scrollController.dispose();

    allUserList.clear();

    _eventbus1?.cancel();
    _eventbus2?.cancel();
    _eventbus3?.cancel();
    _eventbus4?.cancel();
    _eventbus5?.cancel();
    _eventbus6?.cancel();
    _eventbus7?.cancel();
    _eventbus8?.cancel();
    _eventbus9?.cancel();
    _eventbus10?.cancel();
    _eventbus11?.cancel();
    _eventbus12?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
            color: colorScheme.surfaceDim,
            child: Column(
              children: [
                thisPageHeadInfo(context, width - headWidthPadding,
                    localizedStrings.userManagement, '',
                    showHelp: false),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Divider(
                              color: colorScheme.surfaceDim,
                              thickness: 1,
                              height: 1,
                            ),
                            showUserSearch(),
                            showUserTable(),
                            Container(
                              height: 14,
                              color: colorScheme.surface,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )

            // ),
            ));
  }

  Widget thisPageHeadInfo(
      dynamic context, double maxWidth, String pageTitle, String helpInfo,
      {bool showHelp = true}) {
    return Container(
        height: pageTopTitleHeight,
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                subTitle(context, maxWidth, pageTitle),
                if (showHelp)
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    PageInfoButton(helpInfo: helpInfo, onRefresh: () {}),
                    const SizedBox(
                      width: largePadding,
                    ),
                  ])
              ],
            ),
          ),
          Divider(
            color:
                Theme.of(context).colorScheme.surfaceContainerLow, // 设置分割线的颜色
            height: 1, // 设置分割线的高度
            thickness: 1, // 设置分割线的粗细
          ),
        ]));
  }

  Widget subTitle(
    dynamic context,
    double maxWidth,
    String pageTitle,
  ) {
    return Row(
      children: [
        SizedBox(
          width: largePadding,
        ),
        SizedBox(
          child: IconButton(
              onPressed: () {
                widget.onNavigate(widget.lastRouteName);
              },
              icon: getSvgIcon(returnSvgIcon(), 28, 28,
                  Theme.of(context).colorScheme.primary)),
        ),
        SizedBox(
          width: regularPadding,
        ),
        SizedBox(
          width: maxWidth,
          child: Text(
            pageTitle,
            style: Theme.of(context).textTheme.labelMedium!.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 搜索方法
  void performSearch() {
    final String keyword = _searchUserNameCtl.text.trim();

    setState(() {
      searchUserList = allUserList.where((user) {
        final userId = user.userId!;
        final userName = user.userName!;
        return userId.toString().contains(keyword) ||
            userName.contains(keyword);
      }).where((user) {
        if (selRoleId == -1) {
          return true;
        }

        final roleId = user.roleId!;

        return roleId == selRoleId;
      }).toList();
    });
  }

  // 切换全选状态
  void toggleFmaSelectAll(bool? value) {
    setState(() {
      selectUserAll = value ?? false;
      if (selectUserAll) {
        //如果选择的角色是管理员，那么全选时，排除roleId = 2 和 roleId =1 的用户
        if (mySysUser.roleId == 2) {
          selectedUserRows = searchUserList
              .where((user) => user.roleId != 1 && user.roleId != 2)
              .map((user) => user.userId!)
              .toSet();
        } else {
          selectedUserRows = searchUserList
              .where((user) => user.roleId != 1)
              .map((user) => user.userId!)
              .toSet();
        }
      } else {
        selectedUserRows.clear();
      }
    });
  }

  // 切换选择状态
  void toggleFmaSelection(SysUserFromDb user) {
    setState(() {
      if (selectedUserRows.contains(user.userId)) {
        selectedUserRows.remove(user.userId);
      } else {
        selectedUserRows.add(user.userId!);
      }
    });
  }

  void deleteUser(Object? data) {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowNormalTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.fConfirmDelete,
        );
      },
    ).then((value) {
      if (value == null) {
        return;
      }
      if (value) {
        ReqDelSysUsers reqDelSysUsers = ReqDelSysUsers(
          userIds: [
            (data as SysUserFromDb).userId!,
          ],
        );

        PublicFunctions.deleteSysUser(reqDelSysUsersToJson(reqDelSysUsers));
      } else {
        return;
      }
    });
  }

  showUserTable() {
    return Expanded(
      child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          color: colorScheme.surface,
          child: LayoutBuilder(builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;
            double cellWidth = (totalWidth - 120 - 60 - 200 - 200 - 100) / 5;
            cellWidth = cellWidth > 150 ? cellWidth : 150;

            return StickyTable(
              controller: _scrollController, // 传递 ScrollController
              // 修改 data 属性
              data: searchUserList.isEmpty
                  ? []
                  : mySysUser.roleId == superAdminRoleId // 如果是管理员角色
                      ? searchUserList.toList()
                      : searchUserList
                          .where((user) => user.userId != 1) // 排除userId=1的用户
                          .toList(),
              defaultColumnWidth: const FixedColumnWidth(130),
              titleHeight: 48,
              cellHeight: 44,
              clickedRow: clickedUserRow,
              onRowClick: (row) {
                setState(() {
                  clickedUserRow = row;
                  selectedUser = searchUserList[row];
                });
              },

              cellDecoration: (context, column, data, row, columnIndex) {
                // 添加点击行背景色
                if (row == clickedUserRow) {
                  return BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    border: Border(
                      bottom: BorderSide(color: colorScheme.primary, width: 1),
                    ),
                  );
                }
                return BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom:
                        BorderSide(color: colorScheme.outlineVariant, width: 1),
                  ),
                );
              },
              columns: [
                StickyTableColumn(
                  "",
                  fixedStart: true,
                  columnWidth: const FixedColumnWidth(60),
                  renderTitle: (context, title) {
                    // 添加全选复选框
                    return Checkbox(
                        value: selectUserAll, onChanged: toggleFmaSelectAll);
                  },
                  renderCell: (context, title, data, row, column) {
                    return Checkbox(
                      value: selectedUserRows
                          .contains((data as SysUserFromDb).userId),
                      onChanged: mySysUser.roleId == superAdminRoleId &&
                              (data).roleId == superAdminRoleId
                          ? null
                          : mySysUser.roleId == adminRoleId &&
                                  (data).roleId == adminRoleId
                              ? null
                              : (value) {
                                  toggleFmaSelection(data);
                                },
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.userAccount,
                  fixedStart: true,
                  showSort: true,
                  sort: sort,
                  columnWidth: FixedColumnWidth(cellWidth),
                  alignment: Alignment.centerLeft,
                  onTitleClick: (context, title) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return showRenderCellText(
                      (data as SysUserFromDb).userName!,
                    );
                  },
                  renderTitle: (context, title) {
                    return showRenderTitleText(
                      title.title,
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.userUsername,
                  fixedStart: true,
                  showSort: true,
                  sort: sort,
                  columnWidth: FixedColumnWidth(cellWidth),
                  alignment: Alignment.centerLeft,
                  onTitleClick: (context, title) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return showRenderCellText(
                      (data as SysUserFromDb).nickName!,
                    );
                  },
                  renderTitle: (context, title) {
                    return showRenderTitleText(
                      title.title,
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.userRole,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(cellWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return showRenderCellText(
                        (data as SysUserFromDb).roleId == 1
                            ? localizedStrings.superAdmin
                            : (data).roleId == 2
                                ? localizedStrings.admin
                                : localizedStrings.operator);
                  },
                  renderTitle: (context, title) {
                    return showRenderTitleText(
                      title.title,
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.userPhone,
                  columnWidth: FixedColumnWidth(cellWidth),
                  showSort: true,
                  sort: false,
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return showRenderCellText((data as SysUserFromDb).phone!);
                  },
                  renderTitle: (context, title) {
                    return showRenderTitleText(
                      title.title,
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.userEmail,
                  columnWidth: FixedColumnWidth(cellWidth),
                  showSort: true,
                  sort: false,
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return showRenderCellText(
                      (data as SysUserFromDb).email!,
                    );
                  },
                  renderTitle: (context, title) {
                    return showRenderTitleText(
                      title.title,
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fCreatedTimeCol,
                  columnWidth: FixedColumnWidth(200),
                  showSort: true,
                  sort: false,
                  alignment: Alignment.centerLeft,

                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return showRenderCellText(DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format((data as SysUserFromDb).createdTime!));
                  },
                  renderTitle: (context, title) {
                    return showRenderTitleText(
                      title.title,
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fUpdateTimeCol,
                  columnWidth: FixedColumnWidth(200),
                  showSort: true,
                  sort: false,
                  alignment: Alignment.centerLeft,

                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return showRenderCellText(DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format((data as SysUserFromDb).updatedTime!));
                  },
                  renderTitle: (context, title) {
                    return showRenderTitleText(
                      title.title,
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.userIsEnabled,
                  fixedEnd: true,
                  columnWidth: FixedColumnWidth(100),
                  renderCell: (context, title, data, row, column) {
                    return IconButton(
                        iconSize: 28,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        icon: Icon((data as SysUserFromDb).isEnabled!
                            ? Icons.toggle_on_outlined
                            : Icons.toggle_off_outlined),
                        color: data.isEnabled! ||
                                (mySysUser.roleId == 2 && data.roleId! == 2)
                            ? Theme.of(context)
                                .colorScheme
                                .onTertiaryFixedVariant
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        onPressed: data.userId == mySysUser.userId ||
                                (mySysUser.roleId == 2 && data.roleId! == 2)
                            ? null
                            : () {
                                ReqEnableSysUser reqEnableSysUser =
                                    ReqEnableSysUser(
                                  userId: data.userId,
                                  isEnabled: !data.isEnabled!,
                                );
                                String jsonData =
                                    reqEnableSysUserToJson(reqEnableSysUser);
                                PublicFunctions.enableSysUser(jsonData);
                                setState(() {
                                  data.isEnabled = !(data).isEnabled!;
                                });
                              });
                  },
                  renderTitle: (context, title) {
                    return showRenderTitleText(
                      title.title,
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fTipOperation,
                  fixedEnd: true,
                  columnWidth: const FixedColumnWidth(120),
                  renderCell: (context, title, data, row, column) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                          onPressed: mySysUser.roleId == superAdminRoleId
                              ? () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddSysUserPage(
                                                sysUserList: allUserList,
                                                initUserInfo:
                                                    data as SysUserFromDb,
                                                type: 2,
                                                isSuperAccount:
                                                    data.userId == 1,
                                              )));
                                }
                              : mySysUser.roleId == 1 ||
                                      //如果是管理员角色，那么只能编辑非管理员和非超级管理员的用户
                                      (data as SysUserFromDb).roleId ==
                                          superAdminRoleId ||
                                      (data).roleId == adminRoleId ||
                                      (data).userId == mySysUser.userId ||
                                      !data.isEnabled! ||
                                      (mySysUser.roleId == 2 &&
                                          data.roleId! == 2)
                                  ? null
                                  : () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddSysUserPage(
                                                    sysUserList: allUserList,
                                                    initUserInfo: data,
                                                    type: 2,
                                                    isSuperAccount:
                                                        data.userId == 1,
                                                  )));
                                    },
                          minWidth: 0,
                          child: Center(
                              child: Icon(
                            size: 20,
                            Icons.edit_outlined,
                            color: mySysUser.roleId == 1
                                ? colorScheme.primary
                                : (data as SysUserFromDb).userId ==
                                            mySysUser.userId ||
                                        !data.isEnabled! ||
                                        (mySysUser.roleId == 2 &&
                                            data.roleId! == 2)
                                    ? colorScheme.surfaceContainerHighest
                                    : colorScheme.primary,
                          )),
                        ),
                        MaterialButton(
                          onPressed: mySysUser.roleId == 1
                              ? () {
                                  if ((data as SysUserFromDb).roleId == 1) {
                                    return;
                                  }
                                  deleteUser(data);
                                }
                              : (data as SysUserFromDb).userId ==
                                          mySysUser.userId ||
                                      (mySysUser.roleId == 2 &&
                                          data.roleId! == 2)
                                  ? null
                                  : () {
                                      deleteUser(data);
                                    },
                          minWidth: 0,
                          child: Center(
                              child: Icon(
                            size: 20,
                            Icons.delete_forever_outlined,
                            color: (data as SysUserFromDb).userId ==
                                        mySysUser.userId ||
                                    (mySysUser.roleId == 2 && data.roleId! == 2)
                                ? colorScheme.surfaceContainerHighest
                                : colorScheme.error,
                          )),
                        ),
                      ],
                    );
                  },
                  renderTitle: (context, title) {
                    return showRenderTitleText(
                      title.title,
                    );
                  },
                ),
              ],
            );
          })),
    );
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  TextStyle getTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return textTheme.bodySmall!.apply(
      color: color,
    );
  }

  TextStyle getTitleTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return textTheme.bodyMedium!.apply(
      color: color,
    );
  }

  showRenderCellText(String context, {Color? color}) {
    color ??= colorScheme.onSurfaceVariant;
    return Text(context,
        style: getTextStyle(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis);
  }

  showRenderTitleText(String title) {
    return Text(title,
        style: getTextStyle(color: colorScheme.onSurface),
        maxLines: 1,
        overflow: TextOverflow.ellipsis);
  }

  void showAddRawInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return SizedBox(); // AddRawDialog();
      },
    ).then((value) {
      setState(() {});
    });
  }

//导出配方的json文件，只要导出勾选的配方
  exportFormula() async {
    if (selectedUserRows.isEmpty) {
      showTipInfo(localizedStrings.gTipNoDataSelected, context);
      return;
    }
  }

  showUserSearch() {
    return Container(
      height: 70,
      color: colorScheme.surface,
      child: Row(children: [
        SizedBox(
          width: 20,
        ),
        SizedBox(
            width: 245,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  controller: _searchUserNameCtl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchUserNameCtl.clear();
                          performSearch();
                        });
                      },
                    ),
                    hintText: localizedStrings.fSearchHint,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintStyle: textTheme.bodySmall!.copyWith(
                      // 设置提示文本样式
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // 这里可以添加搜索逻辑
                      performSearch();
                    });
                  }),
            )),
        SizedBox(
          width: 14,
        ),
        Container(
          width: 245,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 20),
          decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(
                color: colorScheme.outline,
                width: 1,
              )),
          child: DropdownButton<RoleValue>(
            underline: SizedBox(),
            hint: Text(
              localizedStrings.userRole,
              style: textTheme.bodySmall!.copyWith(
                // 设置提示文本样式
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .primary, //surfaceContainerHighest,
              ),
            ),
            isExpanded: true,
            value: searchRoleCtl.text == ""
                ? null
                : RoleValue.values.firstWhere((element) =>
                    element.getTranslation(context) == searchRoleCtl.text),
            items: [
              DropdownMenuItem<RoleValue>(
                value: null,
                child: Text(localizedStrings.userRole,
                    style: textTheme.bodySmall!.copyWith(
                      // 设置提示文本样式
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    )),
              ),
              ...RoleValue.values.map((value) {
                return DropdownMenuItem<RoleValue>(
                  value: value,
                  child: Text(
                    value.getTranslation(context),
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                if (value == null) {
                  searchRoleCtl.text = "";
                  selRoleId = -1;
                } else {
                  searchRoleCtl.text = value.getTranslation(context);
                  if (value == RoleValue.admin) {
                    selRoleId = 2;
                  } else if (value == RoleValue.operator) {
                    selRoleId = 3;
                  }
                }
                performSearch();
              });
            },
            style: textTheme.bodySmall!.copyWith(
              // 设置提示文本样式
              color: colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          width: 14,
        ),
        Tooltip(
            message: localizedStrings.fClearSearchConditionBtn, // 提示信息
            child: IconButton(
              icon: Icon(
                Icons.cleaning_services_outlined,
                color: colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _searchUserNameCtl.clear();
                  searchRoleCtl.clear();
                  selRoleId = -1;
                  performSearch(); // 调用搜索方法
                });
              },
              iconSize: 24,
            )),
        Spacer(),
        SizedBox(
          width: regularPadding,
        ),
        showTextButton(context, 40, localizedStrings.gBtnAdd, () {
          if (mySysUser.roleId == superAdminRoleId && !mySysUser.isChanged!) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddSysUserPage(
                          sysUserList: allUserList,
                          initUserInfo: superAdminUser ?? SysUserFromDb(),
                          type: 2,
                          isSuperAccount: true,
                        )));
            showTipInfo(localizedStrings.pleaseSetSuperAdmin, context);
            return;
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddSysUserPage(
                        sysUserList: allUserList,
                        initUserInfo: SysUserFromDb(),
                        type: 1,
                        isSuperAccount: false,
                      )));
        }, colorScheme.onPrimary, colorScheme.onTertiaryFixedVariant,
            colorScheme.surface),
        SizedBox(
          width: regularPadding,
        ),
        showTextButton(
            context,
            40,
            localizedStrings.gBtnDelete,
            selectedUserRows.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      barrierDismissible: false, // 点击对话框外部不关闭对话框
                      builder: (BuildContext context) {
                        return ShowNormalTipDialog(
                          title: localizedStrings.fTipTitle,
                          msg: localizedStrings.fConfirmDelete,
                        );
                      },
                    ).then((value) {
                      if (value == null) {
                        return;
                      }
                      if (value) {
                        ReqDelSysUsers reqDelSysUsers = ReqDelSysUsers(
                            userIds: selectedUserRows.map((e) => e).toList());

                        PublicFunctions.deleteSysUser(
                            reqDelSysUsersToJson(reqDelSysUsers));
                      } else {
                        return;
                      }
                    });
                  },
            colorScheme.onPrimary,
            colorScheme.error,
            colorScheme.surface),
        SizedBox(
          width: regularPadding,
        ),
        SizedBox(
          width: regularPadding,
        ),
      ]),
    );
  }
}
