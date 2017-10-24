//
//  ArtistViewController.h
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/17.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "ListView.h"

@interface ArtistViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate, UtilDelegate>

//遷移前のListViewを格納
@property (nonatomic, strong) ListView *mArtistListView;


@end
