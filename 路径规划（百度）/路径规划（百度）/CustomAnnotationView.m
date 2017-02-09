//
//  CustomAnnotationView.m
//  路径规划（百度）
//
//  Created by 云媒 on 16/11/17.
//  Copyright © 2016年 YunMei. All rights reserved.
//

#import "CustomAnnotationView.h"

@implementation CustomAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.centerOffset = CGPointMake(0, 0);
        //定义改标注总的大小
        self.frame = CGRectMake(0, 0, 20, 25);
        
        _bgImageView = [[UIImageView alloc] initWithFrame:self.frame];
        _bgImageView.image = [UIImage imageNamed:@"c_07"];
        [self addSubview:_bgImageView];
//        self.image = [UIImage imageNamed:@"c_07"];
        UIImageView *paoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        paoView.image =[UIImage imageNamed:@"c_03"];
//        self.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:paoView];
    }
    return self;
}

@end
