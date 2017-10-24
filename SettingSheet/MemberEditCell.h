//
//  MemberEditCell.h
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/23.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberEditCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mCellCheckImg;
@property (weak, nonatomic) IBOutlet UILabel *mCellNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *mCellInstrumentLbl;
@property (weak, nonatomic) IBOutlet UIButton *mCellDeleteBtn;

@end
