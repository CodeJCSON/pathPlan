//
//  AppDelegate.h
//  路径规划（百度）
//
//  Created by 云媒 on 16/11/9.
//  Copyright © 2016年 YunMei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Base/BMKMapManager.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>
{
 UINavigationController *navigationController;
}
@property (strong, nonatomic) UIWindow *window;

@end

