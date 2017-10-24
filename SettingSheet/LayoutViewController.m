//
//  LayoutViewController.m
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/17.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import "LayoutViewController.h"
#import "EditIconView.h"
#import "DBConnecter.h"
#import "LayoutData.h"

@interface LayoutViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mVenueNameField;
@property (weak, nonatomic) IBOutlet UITextField *mLiveDayField;
@property (nonatomic, strong) UIDatePicker *mDatePicker;
@property (nonatomic, strong) NSDateFormatter *mDateFormatter;


//ベース(スタンプの下敷き)となる画像
@property (weak, nonatomic) IBOutlet UIImageView *mShowImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *mInstrumentScroll;
//ボタンimgの格納Arr
@property (nonatomic, strong) NSMutableArray *mIconImgArr;
//ボタンの格納Arr
@property (nonatomic, strong) NSMutableArray *mIconBtnArr;
//貼り付け中のicon画像
@property (nonatomic, strong) UIImageView *mCurrentIconView;
//貼り付ける画像の保管用
@property (nonatomic, strong) UIImage *mSelectIcon;
//貼り付けたスタンプの判別用tag
@property (nonatomic, assign) NSInteger mIconTag;

//iconの添付エリア格納用プロパティ
@property (nonatomic, assign) NSInteger mShowImageViewWidth;
@property (nonatomic, assign) NSInteger mShowImageViewHeight;
//iconのサイズ格納用プロパティ
@property (nonatomic, assign) NSInteger mAdjustmentWidth;
@property (nonatomic, assign) NSInteger mAdjustmentHeight;

//変形処理用
@property (nonatomic, strong) EditIconView *mEditIconView;
//現在選ばれているiconのTagを管理
@property (nonatomic, assign) NSInteger mEditIcon;

@end

@implementation LayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIToolbar *toolBar = [Util makeToolBar:self];
    self.mVenueNameField.inputAccessoryView = toolBar;
    
    //mLiveFieldの値の編集
    self.mLiveDayField.inputAccessoryView = toolBar;
    self.mDatePicker = [[UIDatePicker alloc]init];
    [self.mDatePicker setDatePickerMode:UIDatePickerModeDate];
    self.mDateFormatter = [[NSDateFormatter alloc] init];
    [self.mDateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.mLiveDayField.inputView = self.mDatePicker;

    
    //楽器iconの画像データを格納
    NSArray *instrumentPngArr = [[NSArray alloc]initWithObjects:
                                 @"click_here.png",
                                 @"criate.png",
                                 @"checd_on.png",
                                 @"click_here.png",
                                 @"criate.png",
                                 @"checd_on.png",
                                 @"click_here.png",
                                 @"criate.png",
                                 @"checd_on.png",
                                 @"click_here.png",
                                 @"criate.png",
                                 @"checd_on.png",
                                 @"click_here.png",
                                 @"criate.png",
                                 @"checd_on.png",
                                 @"click_here.png",
                                 @"criate.png",
                                 @"checd_on.png",
                                 @"click_here.png",
                                 @"criate.png",
                                 @"checd_on.png",
                                 nil];
    
    self.mIconImgArr = [[NSMutableArray alloc]init];
    self.mIconBtnArr = [[NSMutableArray alloc]init];
    
    //初期値
    NSInteger widthMargin = 22;
    NSInteger heightMargin = 20;
    //iconのタグ
    self.mIconTag = 1;
    
    //mShowImageViewの設定
    self.mShowImageView.layer.borderWidth = 2.0f;
    self.mShowImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.mShowImageView.multipleTouchEnabled = YES;
    self.mShowImageView.tag = 1000;
    
    NSInteger iconCount = [instrumentPngArr count];
    //行数の切り上げ計算
    NSInteger lineCount = ceil(iconCount /5);
    
    NSInteger scrollContentHeight = heightMargin + lineCount * 60;
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.mInstrumentScroll.frame.size.width, scrollContentHeight)];
    [self.mInstrumentScroll addSubview:contentView];
    self.mInstrumentScroll.contentSize = contentView.bounds.size;
    self.mInstrumentScroll.bounces = YES;
    
    //添付位置管理用カウンター
    NSInteger sideCount = 0;
    NSInteger verticalCount = 0;
    
    //iConをボタンにして格納
    for (int i = 0; [instrumentPngArr count] > i; i++) {
        UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *btnImg = [UIImage imageNamed:[instrumentPngArr objectAtIndex:i]];
        [iconBtn setImage:btnImg forState:UIControlStateNormal];
        [iconBtn addTarget:self action:@selector(iconBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        iconBtn.tag = i;
        
        //ボタンサイズ
        NSInteger orighX = widthMargin + 60 * sideCount;
        NSInteger originY = heightMargin + 60 * verticalCount;
        
        //添付位置の設定(横5 * 縦nで配置)
        iconBtn.frame = CGRectMake(orighX, originY, 50, 50);
        
        //横に5つ並んだら改行
        if (sideCount == 5) {
            sideCount = 0;
            verticalCount ++;
        }else{
            sideCount++;
        }
        
        [self.mIconImgArr addObject:btnImg];
        [self.mIconBtnArr addObject:iconBtn];
        
        [contentView addSubview:iconBtn];
    }
    
    //iconの初期値を設定
    self.mAdjustmentWidth = 50;
    self.mAdjustmentHeight = 50;
    
    //複数の指でタッチしても、[touches count]は「1」のままとなってしまうため、multipleTouchEnabledをYESにする。
    self.view.multipleTouchEnabled = YES;
    
    //iconの添付エリアの値を格納
    self.mShowImageViewWidth = self.mShowImageView.frame.size.width;
    self.mShowImageViewHeight = self.mShowImageView.frame.size.height;

    //icon画像は最初はセットしない
    self.mSelectIcon = nil;
    
}

//- (void)closeKeyboard:(id)sender{
//    NSString *dateStr = [self.mDateFormatter stringFromDate:self.mDatePicker.date];
//    self.mLiveDayField.text = dateStr;
//    
//    [self.mVenueNameField resignFirstResponder];
//    [self.mLiveDayField resignFirstResponder];
//}

- (IBAction)iconBtnAction :(id)sender{
    UIButton *selectBtn = sender;
    UIImage *selectIcon = selectBtn.currentImage;
    self.mSelectIcon = selectIcon;
}

//画面に指が触れた時
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    //タッチされた座標を取得(全体windowに対するpoint)
    CGPoint point = [touch locationInView:self.mShowImageView];
    
    //iconを新たに添付された場合は添付処理(Tagの1000番はself.mShowImageViewのTag)
    if (touch.view.tag == 1000 && self.mSelectIcon != nil) {

        //指定した範囲内でだけスタンプを添付できる
        if (CGRectContainsPoint(CGRectMake(0,0,self.mShowImageViewWidth,self.mShowImageViewHeight),point)) {
            //タッチされたエリアのtagが1000(土台のview)だったらスタンプを追加
            self.mCurrentIconView = [[UIImageView alloc]initWithFrame:CGRectMake(point.x - self.mAdjustmentWidth / 2, point.y - self.mAdjustmentHeight / 2, self.mAdjustmentWidth, self.mAdjustmentHeight)];
            
            //選択した画像を指定
            self.mCurrentIconView.image = self.mSelectIcon;
            //iconのタッチ判定を有効にする
            //userInteractionEnabledは親ViewもYESでないと反応しない
            self.mCurrentIconView.userInteractionEnabled = YES;
            self.mCurrentIconView.tag = self.mIconTag;
            //タグの値を増やす
            self.mIconTag++;
            
            //拡大/縮小/回転flagをNOに
            self.mEditIconView.mTransformFlg = NO;
            [self.mShowImageView addSubview:self.mCurrentIconView];
        }
    }
    
    //iconの編集時の処理(Tagの1000番はself.mShowImageViewのTag)
    if (touch.view.tag != 0 && touch.view.tag != 1000) {
        NSLog(@"Tag == %ld",touch.view.tag);
        
            //選択されたicon以外のiconのEditIconViewを削除する
            [self transformAllOff];
            //選択されたiconにのみEditIconViewをadd
            UIImageView *selectIconView = [self.mShowImageView viewWithTag:touch.view.tag];
            selectIconView.multipleTouchEnabled = YES;
            self.mEditIconView = [[EditIconView alloc]initWithEditIconView:selectIconView];
            //拡大/縮小/回転flagをYESに
            self.mEditIconView.mTransformFlg = YES;
            
            self.mEditIcon = touch.view.tag;
        
    }
    
    //Tagが0は添付済みのアイコン
    if (touch.view.tag == 1000) {
        [self transformAllOff];
    }
}

//全てのEditIconViewを削除する
- (void) transformAllOff{
    //self.mShowImageViewにaddsubViewされた全てのself.mCurrentIconView
    for (UIImageView *currentIconView in self.mShowImageView.subviews) {
        //self.mCurrentIconViewにaddsubViewされた全てのEditIconView
        for (EditIconView *editIconView in [currentIconView subviews]) {
            [editIconView removeFromSuperview];
        }
    }
}

//画面に指が触れた状態で指を移動させた時
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

    //タッチされた座標を取得
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.mShowImageView];
    
    if (self.mSelectIcon != nil) {
        
        //iconを新たに添付された場合は移動処理(Tagの1000番はself.mShowImageViewのTag)
        if (touch.view.tag == 1000) {
            if (CGRectContainsPoint(CGRectMake(self.mAdjustmentWidth / 2,self.mAdjustmentHeight / 2,self.mShowImageViewWidth - self.mAdjustmentWidth,self.mShowImageViewHeight - self.mAdjustmentHeight),point)) {
                
                //スタンプの位置を変更する
                self.mCurrentIconView.frame = CGRectMake(point.x - self.mAdjustmentWidth / 2, point.y - self.mAdjustmentHeight / 2, self.mAdjustmentWidth, self.mAdjustmentHeight);
            }
        }
    }
    
    NSArray *touchesArr = [touches allObjects];
    //拡大/縮小/回転flagがYESであり、2本指でタップされた場合
    if (self.mEditIconView.mTransformFlg == YES && [touches count] == 2){
        //iconの編集時の処理
        //2本指でタッチされた場合(拡大/縮小/回転)それぞれの動きを検知して処理
        UITouch *touch1 = touchesArr[0];
        UITouch *touch2 = touchesArr[1];
        
        //指1本目のタッチした座標
        CGPoint point1 = [touch1 previousLocationInView:self.mShowImageView];
        CGPoint pointLocation1 = [touch1 locationInView:self.mShowImageView];
        
        //指2本目のタッチした座標
        CGPoint point2 = [touch2 previousLocationInView:self.mShowImageView];
        CGPoint pointLocation2 = [touch2 locationInView:self.mShowImageView];
        
        //2本の指の距離
        CGFloat distance = sqrtf(powf(point2.x - point1.x, 2) + powf(point2.y - point1.y, 2));
        CGFloat distanceLocation = sqrtf(powf(pointLocation2.x - pointLocation1.x, 2) + powf(pointLocation2.y - pointLocation1.y, 2));
        
        //スケールのincrement
        self.mEditIconView.mScale *= distanceLocation / distance;
        [self.mEditIconView setScale:self.mEditIconView.mScale];
        
        //角度のincrement
        CGFloat angleIncrement = angleBetweenLinesInRadians([touch1 previousLocationInView:self.mShowImageView], [touch2 previousLocationInView:self.mShowImageView], [touch1 locationInView:self.mShowImageView], [touch2 locationInView:self.mShowImageView]);
        
        self.mEditIconView.mAngle += angleIncrement;
        [self.mEditIconView setAngle:self.mEditIconView.mAngle];
    }
}

//拡大/縮小/回転関数
static inline CGFloat angleBetweenLinesInRadians(CGPoint line1Start, CGPoint line1End, CGPoint line2Start, CGPoint line2End) {
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;
    
    CGFloat line1Slope = (line1End.y - line1Start.y) / (line1End.x - line1Start.x);
    CGFloat line2Slope = (line2End.y - line2Start.y) / (line2End.x - line2Start.x);
    
    CGFloat degs = acosf(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
    
    return (line2Slope > line1Slope) ? degs : -degs;
}

//画面から指が離れた時
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //スタンプを確定する(スタンプモード終了)
    self.mSelectIcon = nil;
}

//画面タッチがキャンセルされた時
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //スタンプを確定する(スタンプモード終了)
}

//ベース画像のサイズで画像を切り抜く
//領域を指定して画像を切り抜く
- (UIImage *) captureImage{
    //画像領域の設定
    CGSize size = CGSizeMake(self.mShowImageView.frame.size.width, self.mShowImageView.frame.size.height);
    UIGraphicsBeginImageContext(size);
    
    //グラフィックスコンテキスト取得
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //コンテキストの位置を切り取り開始位置に合わせる
    CGPoint point = self.mShowImageView.frame.origin;
    CGAffineTransform affineMoveLeftTop = CGAffineTransformMakeTranslation(-(int)point.x, -(int)point.y);
    CGContextConcatCTM(context, affineMoveLeftTop);
    
    //Viewから切り取る
    [(CALayer *)self.view.layer renderInContext:context];
    
    //切り取った内容をUIImageとして取得
    UIImage *cnvImg = UIGraphicsGetImageFromCurrentImageContext();
    
    //コンテキストの破棄
    UIGraphicsEndImageContext();
    return cnvImg;
}

////画像をDBの保存
//- (void)saveDB{
//    //画像を取得
//    UIImage *saveImage = [self captureImage];
//    NSLog(@"%@", saveImage);
//}

//- (void)targetImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)context{
//    
//    NSString *message = [NSString string];
//    
//    if (error) {
//        message = @"保存に失敗しました。";
//    }else{
//        message = @"保存に成功しました。";
//    }
//    NSLog(@"%@",message);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelBtnAction:(id)sender {
    [Util makeCancelAlert:self];
}

- (IBAction)saveBtnAction:(id)sender {
    
    if (self.mVenueNameField.text.length == 0 || self.mLiveDayField.text.length == 0) {
        //必須入力項目未記入の場合
        UIAlertController *incompAlert = [UIAlertController alertControllerWithTitle:@"Caution!" message:@"「Venue name」 or 「Live Day」 are not yet entered.\n会場名またはライブ日時が未入力です。" preferredStyle:UIAlertControllerStyleAlert];
        [incompAlert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //アラートを閉じる
            [incompAlert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:incompAlert animated:YES completion:nil];
        
    }else{
        UIAlertController *compAlert = [UIAlertController alertControllerWithTitle:@"Layout saved!" message:@"Layout saved.\nレイアウトを保存しました。" preferredStyle:UIAlertControllerStyleAlert];
        [compAlert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UIImage *saveImg = [self captureImage];
            NSString *saveVenueName = self.mVenueNameField.text;
            NSString *saveLiveDay = self.mLiveDayField.text;
            //UIImageのNSStringへBase64エンコード
            NSData* jpgData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(saveImg, 1.0f)];
            NSString* jpg64Str = [jpgData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
            //アプリ内DBに格納
            LayoutData *layoutData = [[LayoutData alloc]init];
            layoutData.sheet_data = jpg64Str;
            layoutData.venus_name = saveVenueName;
            layoutData.live_date = saveLiveDay;
            //DBの初期化
            DBConnecter *dbConnecter = [DBConnecter sharedManager];
            [dbConnecter insertLayoutData:layoutData];
            //アラートを閉じる
            [compAlert dismissViewControllerAnimated:YES completion:nil];
            
        }]];
        [self presentViewController:compAlert animated:YES completion:nil];
    }
    
    //テストここから
//    NSMutableArray *testImageArr = [dbConnecter getSettingSheetList];
//    NSLog(@"%@",testImageArr);
//    LayoutData *testInstance = [testImageArr objectAtIndex:1];
//    NSString *testImgStr = testInstance.sheet_data;
//    //
//    NSData *ResultJpgData = [[NSData alloc] initWithBase64EncodedString:testImgStr
//                                                          options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    UIImage* image = [UIImage imageWithData:ResultJpgData];
//    
//    CGRect rect2 = [UIScreen mainScreen].bounds;
//    UIView *testView = [[UIView alloc]initWithFrame:CGRectMake(10, 100, rect2.size.width, rect2.size.height)];
//    UIImageView *testImgView = [[UIImageView alloc]initWithImage:image];
//    [testView addSubview:testImgView];
//    [self.view addSubview:testView];
    //テストここまで
}


@end
