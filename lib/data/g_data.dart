//全局数据
import 'package:t_max/data/sys_user_from_db.dart';
import 'package:t_max/data/custom_model_info.dart';

SysUserDetailFromDb mySysUser = SysUserDetailFromDb(); //登录的系统用户信息

//全部的页面ID
final List<int> allPageIdList = List.generate(24, (index) => index);
final superAdminRoleId = 1;
final adminRoleId = 2;
final operatorRoleId = 3;

bool firstLogin = true;

ModelNameInfoList modelNameInfoData = ModelNameInfoList([]);
