//
//  SettingSheetEditCell.h
//  SettingSheet
//
//  Created by 一木 英希 on 2017/02/05.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingSheetEditCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mCellCheckImg;
@property (weak, nonatomic) IBOutlet UILabel *mCellEditMainLbl;
@property (weak, nonatomic) IBOutlet UILabel *mCellEditSubLbl;
@property (weak, nonatomic) IBOutlet UIButton *mCellDeleteBtn;

@end
