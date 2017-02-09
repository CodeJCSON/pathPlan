//
//  ViewController.m
//  路径规划（百度）
//
//  Created by 云媒 on 16/11/9.
//  Copyright © 2016年 YunMei. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件
#import <BaiduMapAPI_Search/BMKRouteSearch.h>
#import "CustomAnnotationView.h"

//路径规划（以下）-----
@interface RouteAnnotation : BMKPointAnnotation
{
    int _type; //0:起点 1：终点 2：公交 3：地铁 4：驾乘 5：途经点
    int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;

@end
//以上-----
@interface ViewController ()<BMKLocationServiceDelegate,BMKMapViewDelegate,BMKGeoCodeSearchDelegate,UITextFieldDelegate,BMKPoiSearchDelegate,BMKRouteSearchDelegate>
{
    BMKLocationService *_locService;
    UILabel *_latitude;
    UILabel *_longitude;
    BMKMapView *_mapView;
    BMKGeoCodeSearch *_geoCodeSearch;
    BMKPointAnnotation *_pointAnnotation;
    BMKPoiSearch *_poiSearch;
}

@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch;
@property (nonatomic, strong) BMKRouteSearch *routeSearch;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建地图
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _mapView.delegate = self;
    
    _geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
    _geoCodeSearch.delegate = self;
    
    [self.view addSubview:_mapView];
    [_mapView setMapType:BMKMapTypeStandard];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    UIButton *positionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    positionBtn.frame = CGRectMake(30, 64, 70, 20);
    [positionBtn setTitle:@"定位" forState:UIControlStateNormal];
    [positionBtn addTarget:self action:@selector(position:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:positionBtn];
    
    _pointAnnotation = [[BMKPointAnnotation alloc] init];
    _pointAnnotation.title = @"我在这个地方";
    _pointAnnotation.subtitle = @"你在哪呢";
    
    [_mapView addAnnotation:_pointAnnotation];
    [_mapView selectAnnotation:_pointAnnotation animated:YES];
    
    
    UITextField *poiTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 30, 100, 20)];
    poiTextField.backgroundColor = [UIColor lightGrayColor];
    [poiTextField addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventEditingChanged];
    poiTextField.delegate = self;
    [self.view addSubview:poiTextField];

    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 190, 100, 30)];
    [button setTitle:@"路径规划" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    button.alpha = 0;
//    [button sizeToFit];
    [button addTarget:self action:@selector(PlanBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:button];
    
    UIButton *baiduBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 250, 100, 30)];
    [baiduBtn setTitle:@"调起百度地图" forState:UIControlStateNormal];
    [baiduBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    //    button.alpha = 0;
    //    [button sizeToFit];
    [baiduBtn addTarget:self action:@selector(baiduAPPScheme ) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:baiduBtn];
}
//调起百度地图
- (void)baiduAPPScheme{

    BMKOpenTransitRouteOption *opt = [[BMKOpenTransitRouteOption alloc] init];
    opt.appScheme = @"mapsdk.com://";//用于调起成功后，返回原应用
    //初始化起点节点
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    //指定起点经纬度
    CLLocationCoordinate2D coor1;
    coor1.latitude = 39.90868;
    coor1.longitude = 116.204;
    //指定起点名称
    start.name = @"山东交通学院";
//    start.pt = coor1;
    //指定起点
    opt.startPoint = start;
    
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    CLLocationCoordinate2D coor2;
    coor2.latitude = 39.90868;
    coor2.longitude = 116.3956;
//    end.pt = coor2;
    //指定终点名称
    end.name = @"济南市华强电子世界";
    opt.endPoint = end;
    
    BMKTransitRoutePlanOption *transiRouteS = [[BMKTransitRoutePlanOption alloc] init];
    transiRouteS.city = @"济南市";
    transiRouteS.from = start;
    transiRouteS.to = end;

    //打开地图公交路线检索
    BMKOpenErrorCode code = [BMKOpenRoute openBaiduMapTransitRoute:opt];
}

//路径规划
- (void)PlanBtn:(UIButton *)btn {
    _routeSearch = [[BMKRouteSearch alloc] init];
    _routeSearch.delegate = self;
    
    //发起检索
    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    start.name = @"利农花园";

    BMKPlanNode *end = [[BMKPlanNode alloc] init];
    end.name = @"华强国际中心";
    //检索所在的城市
    BMKTransitRoutePlanOption *transiRouteS = [[BMKTransitRoutePlanOption alloc] init];
    transiRouteS.city = @"济南市";
    transiRouteS.from = start;
    transiRouteS.to = end;
    
    BOOL flag = [_routeSearch transitSearch:transiRouteS];
    if (flag) {
        NSLog(@"transtion检索发送成功");
    } else {
        NSLog(@"fail");
    }
}
//路径规划
- (void)onGetTransitRouteResult:(BMKRouteSearch *)searcher result:(BMKTransitRouteResult *)result errorCode:(BMKSearchErrorCode)error {
        
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        BMKTransitRouteLine* plan = (BMKTransitRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        NSLog(@"size == %ld", (long)size);
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKTransitStep *tansitStep = [plan.steps objectAtIndex:i];
                        
            if (i == 0 ) {
                RouteAnnotation *item = [[RouteAnnotation alloc] init];
                item.coordinate = plan.starting.location;
                NSLog(@"plan.starting.location:%f",plan.starting.location.latitude);
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; //添加起点标注
            } else if (i == size - 1) {
                RouteAnnotation *item = [[RouteAnnotation alloc] init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item];
            }
            RouteAnnotation *item = [[RouteAnnotation alloc] init];
            item.coordinate = tansitStep.entrace.location; //路段入口信息
            item.title = tansitStep.instruction; //路程换成说明
            item.type = 3;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += tansitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts]; //文件后缀名改为mm
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKTransitStep *transitStep = [plan.steps objectAtIndex:j];
            int k = 0;
            for (k = 0; k < transitStep.pointsCount; k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        //通过points构建BMKPolyline
        BMKPolyline *polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; //添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        //当路线起终点有歧义时通，获取建议检索起终点
        //result.routeAddrResult
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
    
    BMKTransitRouteLine* plan = (BMKTransitRouteLine*)[result.routes objectAtIndex:0];
    NSLog(@"juli is == %d公里", plan.distance / 1000);
}

//折线
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}

- (void)valueChange:(UITextField *)textField{

    _poiSearch = [[BMKPoiSearch alloc] init];
    _poiSearch.delegate = self;
    NSLog(@"搜索：%@",textField.text);
    //附近云检索
    BMKNearbySearchOption *nearBySearchOption = [[BMKNearbySearchOption alloc] init];
    nearBySearchOption.pageIndex = 0;
    nearBySearchOption.pageCapacity = 10;
    nearBySearchOption.keyword = textField.text;
    
    //检索的中心点
    nearBySearchOption.location = _locService.userLocation.location.coordinate;
    nearBySearchOption.radius = 100;
    
    BOOL flag = [_poiSearch poiSearchNearBy:nearBySearchOption];
    if (flag) {
        NSLog(@"success");
    } else {
        NSLog(@"fail");
    }
}
//代理方法
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        for (int i = 0; i < poiResult.poiInfoList.count; i++) {
            BMKPoiInfo *info = [poiResult.poiInfoList objectAtIndex:i];
            NSLog(@"地址：%@", info.name);
        }
    }
    
 
}
- (void)position:(UIButton *)button{

    _locService.delegate = self;
    _mapView.zoomLevel = 14.1; //地图等级，数字越大越清晰
    _mapView.showsUserLocation = NO;//是否显示定位小蓝点，no不显示，我们下面要自定义的(这里显示前提要遵循代理方法，不可缺少)
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    //定位
    [_locService startUserLocationService];
    
}
//地理反编码
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    CLLocationCoordinate2D carLocation = [_mapView convertPoint:self.view.center toCoordinateFromView:self.view];
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc] init];
    option.reverseGeoPoint = CLLocationCoordinate2DMake(carLocation.latitude, carLocation.longitude);
    NSLog(@"%f - %f", option.reverseGeoPoint.latitude, option.reverseGeoPoint.longitude);
    //调用发地址编码方法，让其在代理方法onGetReverseGeoCodeResult中输出
    [_geoCodeSearch reverseGeoCode:option];
    
}

//返回地理反编码
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (result) {
        NSLog(@"%@ - %@ - %@ - %@ - %@", result.addressDetail.province, result.addressDetail.city, result.addressDetail.streetName, result.address, result.businessCircle);
    } else {
        NSLog(@"找不到");
    }
}
//获取当前位置
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    _latitude = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 300, 20)];
    _latitude.textColor = [UIColor redColor];
    _latitude.text = [NSString stringWithFormat:@"%lf",userLocation.location.coordinate.latitude];
    
    _longitude = [[UILabel alloc]initWithFrame:CGRectMake(10, 150, 300, 20)];
    _longitude.textColor = [UIColor redColor];
    _longitude.text = [NSString stringWithFormat:@"%lf",userLocation.location.coordinate.longitude];
    
    _mapView.centerCoordinate = userLocation.location.coordinate;
    [_locService stopUserLocationService];
    
    [_latitude removeFromSuperview];
    [_longitude removeFromSuperview];
    
    [self.view addSubview:_latitude];
    [self.view addSubview:_longitude];
    
    _pointAnnotation.coordinate = userLocation.location.coordinate;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    BMKCoordinateRegion region;
    region.center = center;
    region.span.latitudeDelta = .01;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
    region.span.longitudeDelta = .01;//纬度范围
    [_mapView setRegion:region];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) //判断是哪个BMKPointAnnotation
    {
        static NSString *string = @"annotation";
        CustomAnnotationView *newAnnotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:string];
//        BMKPinAnnotationView *pinAnnotationView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:string];
        
        if (newAnnotationView == nil) {
            newAnnotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:string];
        }
        
//        pinAnnotationView.image = [UIImage imageNamed:@"c_07"];
        return newAnnotationView;

    }
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        return [self getRouteAnnotationView:mapView viewForAnnotation:annotation];
    }
    return nil;
}

- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageNamed:@"icon_nav_start.png"];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageNamed:@"icon_nav_end.png"];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 2:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
                view.image = [UIImage imageNamed:@"icon_nav_bus.png"];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 3:
        {   //公交或者地铁
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
                view.image = [UIImage imageNamed:@"icon_nav_rail.png"];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            //            UIImage* image = [UIImage imageNamed:@"icon_direction.png"];
            //            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
            
        }
            break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            //            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_waypoint.png"]];
            //            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    
    return view;
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    
    _mapView.delegate = self;
    _locService.delegate = self;
    _geoCodeSearch.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _locService.delegate = nil;
    _geoCodeSearch.delegate = nil;
}

@end
