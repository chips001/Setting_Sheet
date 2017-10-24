//
//  TrackOrderCell.h
//  SettingSheet
//
//  Created by 一木 英希 on 2017/02/19.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackOrderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mCellNumberLbl;
@property (weak, nonatomic) IBOutlet UILabel *mCellSongNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *mCellFeaturesLbl;
@property (weak, nonatomic) IBOutlet UIButton *mCellDeleteBtn;

@end
