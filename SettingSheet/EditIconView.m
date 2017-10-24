//
//  EditIconView.m
//  SettingSheet
//
//  Created by 一木 英希 on 2017/03/23.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import "EditIconView.h"

@implementation EditIconView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UINib *nib = [UINib nibWithNibName:@"EditIconView" bundle:nil];
        self = [nib instantiateWithOwner:nil options:nil][0];
        
        //初期化
        self.mScale = 1.0;
        self.mAngle = 0.0;
        self.mTransformFlg = YES;

    }
    return self;
}

//初期化メソッド
- (id)initWithEditIconView:(UIImageView *)selectIconView{
    self = [super init];
    if (self != nil) {
        self.multipleTouchEnabled = YES;
        
        self.mSelectIconView = selectIconView;
        self.mSelectIconView.multipleTouchEnabled = YES;
        self.userInteractionEnabled = YES;
        
        [self.mSelectIconView addSubview:self];
    }
    return self;
}

- (IBAction)iconDeleteBtnAction:(id)sender {
    NSLog(@"ICON削除");
    if (self.mSelectIconView != nil) {
        NSLog(@"deleteIcon=%ld",self.mSelectIconView.tag);
        [self.mSelectIconView removeFromSuperview];
    }
}

//拡大縮小の範囲設定
- (void)setScale:(CGFloat)scale{
    //変形フラグがNOの場合は拡大縮小を行わない
    if (!self.mTransformFlg) {
        return;
    }
    //Minimum スケール
    if (scale < 0.5) {
        scale = 0.5;
    }
    //Max スケール
    if (scale > 1.5) {
        scale = 1.5;
    }
    self.mScale = scale;
    [self doTransform];
}

//回転の範囲設定
- (void)setAngle:(CGFloat)angle{
    //変形フラグがNOの場合は回転を行わない
    if (!self.mTransformFlg) {
        return;
    }
    self.mAngle = angle;
    [self doTransform];
}

//変形処理
- (void)doTransform{
    //拡大縮小処理
    CGAffineTransform pinchTransform = CGAffineTransformMakeScale(self.mScale, self.mScale);
    //回転処理
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(self.mAngle);
    self.mSelectIconView.transform = CGAffineTransformConcat(pinchTransform, rotationTransform);
}

@end
