//
//  EditIconView.h
//  SettingSheet
//
//  Created by 一木 英希 on 2017/03/23.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutViewController.h"

@interface EditIconView : UIView

@property (weak, nonatomic) IBOutlet UILabel *mSizeAdjustmentLbl;
@property (weak, nonatomic) IBOutlet UIButton *mIconDeleteBtn;
//添付された編集するIconを格納
@property (nonatomic, strong) UIImageView *mSelectIconView;
//添付エリアを格納
@property (nonatomic, strong) UIImageView *mShowImageView;

//スケール変形用
@property (nonatomic) CGFloat mScale;
//角度変形用
@property (nonatomic) CGFloat mAngle;
//変形を行うか否かのflag
@property (nonatomic, assign) BOOL mTransformFlg;

//初期化メソッド
- (id)initWithEditIconView:(UIImageView *)selectIconView;

- (void)setScale:(CGFloat)scale;
- (void)setAngle:(CGFloat)angle;

@end
