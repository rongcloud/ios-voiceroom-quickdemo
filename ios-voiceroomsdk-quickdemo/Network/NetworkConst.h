//
//  NetworkConst.h
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/25.
//

#import <Foundation/Foundation.h>

#warning 此处为己方的服务端host，需要部署由融云提供的服务端开源代码，此项为demo成功运行的前置条件
#warning 服务端代码仓库 https://github.com/rongcloud/rongcloud-scene-server-bestcase
//服务端 host
static NSString *const kHost = @"https://rcrtc-api.rongcloud.net/";

#pragma mark - NETWORK PATH

#pragma mark ----------BASIC----------
//登录
static NSString *const np_login = @"user/login";

//创建房间
static NSString *const np_room_creat = @"mic/room/create";

//删除房间
static NSString *const np_room_delete = @"mic/room/%@/delete";

//获取房间列表
static NSString *const np_room_list = @"mic/room/list";

//获取用户列表
static NSString *const np_room_users_list = @"mic/room/%@/members";

//获取用户信息
static NSString *const np_fetch_user_info = @"user/batch";

#pragma mark ----------PK----------

//同步PK状态
static NSString *const np_sync_pk_state = @"mic/room/pk";

//获取房间 PK info
static NSString *const np_fetch_pk_info = @"mic/room/pk/info/%@";

//查询房间是否为pk房间
static NSString *const np_check_room_type_isPk = @"mic/room/pk/%@/isPk";

//获取当前在线的主播
static NSString *const np_fetch_online_creator = @"mic/room/online/created/list";

//同步房间在线状态
static NSString *const np_update_room_online_status = @"user/change";

//获取PK详细信息
static NSString *const np_fetch_pk_detail = @"mic/room/pk/detail/%@";
