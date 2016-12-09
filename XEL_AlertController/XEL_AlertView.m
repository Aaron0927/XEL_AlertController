//
//  XEL_AlertViewController.m
//  XEL_AlertController
//
//  Created by leijin on 16/12/1.
//  Copyright © 2016年 xel. All rights reserved.
//

#import "XEL_AlertView.h"

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB(r, g, b) RGBA(r, g, b, 1.0)

@interface XEL_CollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *verticalView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) CGRect frame;

@end

@implementation XEL_CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        
        
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.contentView.frame.size.height)];
        [self.contentView addSubview:_titleLabel];
        
    }
    _titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.contentView.frame.size.height);
    [_titleLabel setText:title];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
}

- (void)setCount:(NSInteger)count {
    _count = count;
    if (count == 2) {
        //添加分割线
        if (!_verticalView) {
            _verticalView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, 1, self.contentView.frame.size.height)];
        }
        
        _verticalView.tag = 200;
        _verticalView.frame = CGRectMake(self.frame.size.width, 0, 1,  self.contentView.frame.size.height);
        _verticalView.backgroundColor = RGB(220, 220, 220);
        [self.contentView addSubview:_verticalView];
    } else {
        //添加下划线
        if (!_bottomView) {
            _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.contentView.frame.size.width, 1)];
        }
        _bottomView.frame = CGRectMake(0, self.frame.size.height, self.contentView.frame.size.width, 1);
        _bottomView.tag = 300;
        _bottomView.backgroundColor = RGB(220, 220, 220);
        [self.contentView addSubview:_bottomView];
    }
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
    
}

@end

@interface XEL_AlertView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, readwrite) NSArray <XEL_AlertAction *> *actions;
@property (nonatomic, strong) XEL_AlertAction *cancelAction;

@property (nonatomic, readwrite) XEL_AlertControllerStyle preferredStyle;

//action sheet
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UIScrollView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *verticalView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
//
@property (nonatomic, assign) CGFloat headerViewHeight;
@end

//cell 的默认高度
static CGFloat kCellHeight = 50;
//取消与其他按钮的距离
static CGFloat kCancelPadding = 10;
//其他按钮的距离
static CGFloat kDefaultPadding = 1;
//titleLabel的边距
static CGFloat kTitleLabelPddding = 10;

//alert view 的最大高度比例
static CGFloat kMaxHeightRatio = 0.9;
//alert view 宽度比例
static CGFloat kMaxWidthRatio = 0.7;
//当


@implementation XEL_AlertView


- (void)xel_addTextFieldWithConfigutationHanler:(void (^)(UITextField *))configurationHandler {
    
}

- (void)xel_addAction:(XEL_AlertAction *)action {
    
    if (action.style == XEL_AlertActionStyleCancel) {
        self.cancelAction = action;
        return;
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.actions];
    [tempArray addObject:action];
    self.actions = [tempArray copy];
}

+ (instancetype)xel_alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(XEL_AlertControllerStyle)preferredStyle {
    
    return [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(XEL_AlertControllerStyle)preferredStyle {
    self = [super init];
    if (self) {
        
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)];
        hideTap.delegate = self;
        [self addGestureRecognizer:hideTap];
        
        self.preferredStyle = preferredStyle;
        self.title = title;
        self.message = message;
        
        //添加视图旋转的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFrame) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)changeFrame {
    
    CGRect frame = [UIScreen mainScreen].bounds;
    self.frame = frame;
    //修改子视图frame
    CGRect alertViewFrame = self.alertView.frame;
    if (self.preferredStyle == XEL_AlertControllerStyleActionSheet) {
        alertViewFrame.size.width = frame.size.width;
        alertViewFrame.size.height = MIN([self headerViewHeight] + [self tableViewHeight], self.frame.size.height * kMaxHeightRatio);
        alertViewFrame.origin.y = frame.size.height - alertViewFrame.size.height;
    } else {
        alertViewFrame.size.width = MIN(frame.size.width * kMaxWidthRatio, alertViewFrame.size.width);
        alertViewFrame.size.height = MIN([self headerViewHeight] + [self collectionViewHeight], self.frame.size.height * kMaxHeightRatio);
    }
    
    self.alertView.frame = alertViewFrame;
    if (self.preferredStyle == XEL_AlertControllerStyleAlert) {
        self.alertView.center = self.center;
    }
    
    CGRect headerViewFrame = self.headerView.frame;
    if (self.preferredStyle == XEL_AlertControllerStyleActionSheet) {
        headerViewFrame.size.width = frame.size.width;
        CGFloat height = self.alertView.frame.size.height - [self tableViewHeight];
        headerViewFrame.size.height = MIN([self headerViewHeight], height);
    } else if (self.preferredStyle == XEL_AlertControllerStyleAlert) {
        headerViewFrame.size.width = self.alertView.frame.size.width;
        CGFloat height = self.alertView.frame.size.height - [self collectionViewHeight];
        headerViewFrame.size.height = MIN([self headerViewHeight], height);
    }
    self.headerView.frame = headerViewFrame;
    
    if (self.titleLabel) {
        CGRect titleLabelFrame = self.titleLabel.frame;
        CGFloat width = self.headerView.frame.size.width - 2 * kTitleLabelPddding;
        CGSize size = [self stringSizeWithString:_title width:width font:self.titleLabel.font];
        titleLabelFrame.size.width = width;
        titleLabelFrame.size.height = size.height + 2 *kTitleLabelPddding;
        self.titleLabel.frame = titleLabelFrame;
    }
    if (self.messageLabel) {
        CGRect messageLabelFrame = self.messageLabel.frame;
        CGFloat width = self.headerView.frame.size.width - 2 * kTitleLabelPddding;
        CGSize size = [self stringSizeWithString:_message width:width font:self.messageLabel.font];
        messageLabelFrame.size.width = width;
        messageLabelFrame.size.height = size.height + 2 *kTitleLabelPddding;
        CGFloat y = 0;
        if (self.title) {
            y = CGRectGetMaxY(self.titleLabel.frame);
        }
        messageLabelFrame.origin.y = y;
        self.messageLabel.frame = messageLabelFrame;
    }
    self.headerView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.messageLabel.frame));
    
    if (self.preferredStyle == XEL_AlertControllerStyleActionSheet) {
        CGRect tableViewFrame = self.tableView.frame;
        tableViewFrame.size.width = frame.size.width;
        CGFloat height1 = self.alertView.frame.size.height - self.headerView.frame.size.height;
        tableViewFrame.size.height = MIN([self tableViewHeight], height1);
        tableViewFrame.origin.y = CGRectGetHeight(self.headerView.frame);
        self.tableView.frame = tableViewFrame;
    } else if (self.preferredStyle == XEL_AlertControllerStyleAlert) {
        CGRect collectionViewFrame = self.collectionView.frame;
        collectionViewFrame.size.width = self.alertView.frame.size.width;
        CGFloat height = self.alertView.frame.size.height - self.headerView.frame.size.height;
        collectionViewFrame.size.height = height;
        collectionViewFrame.origin.y = CGRectGetHeight(self.headerView.frame);
        self.collectionView.frame = collectionViewFrame;
        [self.collectionView reloadData];
    }
    
}


- (void)showInView:(UIView *)view {
    
    [view addSubview:self];
    [self sortActions];
    
    if (self.preferredStyle == XEL_AlertControllerStyleActionSheet) {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            self.alpha = 0.5;
            CGRect frame = self.alertView.frame;
            frame.origin.y -= frame.size.height;
            
            self.alertView.frame = frame;
            
            
        } completion:^(BOOL finished) {
            
            [self addSubview:self.alertView];
            
            [self.alertView addSubview:self.headerView];
            [self.alertView addSubview:self.tableView];
            
        }];
    } else if (self.preferredStyle == XEL_AlertControllerStyleAlert) {
        
        if (self.titleLabel) {
            CGRect frame = self.titleLabel.frame;
            frame.size.width = self.alertView.frame.size.width - 2 * kTitleLabelPddding;
            self.titleLabel.frame = frame;
            
        }
        if (self.messageLabel) {
            CGRect frame = self.messageLabel.frame;
            frame.size.width = self.alertView.frame.size.width - 2 * kTitleLabelPddding;
            self.messageLabel.frame = frame;
        }
        
        [UIView animateWithDuration:0.15 animations:^{
            
            self.alpha = 0.5;
            self.alertView.center = self.center;
        } completion:^(BOOL finished) {
            
            [self addSubview:self.alertView];
            [self.alertView addSubview:self.headerView];
            [self.alertView addSubview:self.collectionView];
            NSLog(@"frame:%@", NSStringFromCGRect(self.collectionView.frame));
        }];
    }
    
}

- (void)hideView {
    
    if (self.preferredStyle == XEL_AlertControllerStyleActionSheet) {
        [UIView animateWithDuration:0.15 animations:^{
            
            self.alpha = 0;
            CGRect frame = self.alertView.frame;
            frame.origin.y += [self headerViewHeight] + [self tableViewHeight];
            self.alertView.frame = frame;
            
        } completion:^(BOOL finished) {
            [self.headerView removeFromSuperview];
            [self.tableView removeFromSuperview];
            [self.alertView removeFromSuperview];
            [self removeFromSuperview];
        }];
    } else if (self.preferredStyle == XEL_AlertControllerStyleAlert) {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self.headerView removeFromSuperview];
            [self.alertView removeFromSuperview];
            [self removeFromSuperview];
        }];
    }
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.actions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alertCell"];
    XEL_AlertAction *action = self.actions[indexPath.section];
    cell.textLabel.text = action.title;
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
    [cell.textLabel setTintColor:[UIColor blackColor]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0;
    } else if (section == self.actions.count - 1) {
        if ([self hasCancelAction]) {
            return kCancelPadding;
        } else {
            return kDefaultPadding;
        }
    }
    return kDefaultPadding;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XEL_AlertAction *action = self.actions[indexPath.section];
    
    if (action.handle) {
        action.handle(action);
    }
    
    [self hideView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.actions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XEL_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    XEL_AlertAction *action = self.actions[indexPath.row];
    cell.frame = CGRectMake(0, 0, collectionView.frame.size.width / 2, collectionView.frame.size.height);
    cell.title = action.title;
    cell.count = self.actions.count;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.actions.count == 2) {
        
        return CGSizeMake(self.alertView.frame.size.width / 2, kCellHeight);
    }
    return CGSizeMake(self.alertView.frame.size.width, kCellHeight);
}


#pragma mark - setter getter

- (void)setTitle:(NSString *)title {
    _title = title;
    
    if (title) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = title;
        UIFont *font = [UIFont systemFontOfSize:17];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setNumberOfLines:0];
        [titleLabel setFont:font];
        CGFloat width = self.frame.size.width - 2 * kTitleLabelPddding;
        CGSize size = [self stringSizeWithString:title width:width font:font];
        
        titleLabel.frame = CGRectMake(kTitleLabelPddding, 0, width, size.height + 2 * kTitleLabelPddding);
        
        self.titleLabel = titleLabel;
        
        self.headerViewHeight += titleLabel.frame.size.height;
    }
    
}


- (void)setMessage:(NSString *)message {
    _message = message;
    
    if (message) {
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.text = message;
        UIFont *font = [UIFont systemFontOfSize:15];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setFont:font];
        [messageLabel setNumberOfLines:0];
        CGFloat width = self.frame.size.width - 2 * kTitleLabelPddding;
        CGSize size = [self stringSizeWithString:message width:width font:font];
        
        CGFloat y = 0;
        if (self.title) {
            y = CGRectGetMaxY(self.titleLabel.frame);
        }
        
        messageLabel.frame = CGRectMake(kTitleLabelPddding, y + 1, width, size.height + 2 * kTitleLabelPddding);
        
        self.messageLabel = messageLabel;

        self.headerViewHeight += messageLabel.frame.size.height;
    }
    
}


- (UIView *)alertView {
    if (!_alertView) {
        
        if (self.preferredStyle == XEL_AlertControllerStyleActionSheet) {
            _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, MIN([self headerViewHeight] + [self tableViewHeight] + 1, self.frame.size.height * kMaxHeightRatio))];
            
        } else if (self.preferredStyle == XEL_AlertControllerStyleAlert) {
            _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width * kMaxWidthRatio, MIN([self headerViewHeight] + [self collectionViewHeight], self.frame.size.height * kMaxHeightRatio))];
            
        }
        _alertView.backgroundColor = RGB(220, 220, 220);
        
    }
    return _alertView;
}

- (UIScrollView *)headerView {
    if (!_headerView) {
        
        CGFloat height = 0;
        if (self.preferredStyle == XEL_AlertControllerStyleActionSheet) {
            height = self.alertView.frame.size.height - [self tableViewHeight];
        } else if (self.preferredStyle == XEL_AlertControllerStyleAlert) {
            height = self.alertView.frame.size.height - [self collectionViewHeight];
        }
        _headerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.alertView.frame.size.width, MIN([self headerViewHeight], height))];
        if (height < [self headerViewHeight]) {
            _headerView.scrollEnabled = YES;
            
        } else {
            _headerView.scrollEnabled = NO;
        }
        [_headerView addSubview:self.titleLabel];
        [_headerView addSubview:self.messageLabel];
        _headerView.contentSize = CGSizeMake(0, [self headerViewHeight]);
        _headerView.backgroundColor = [UIColor whiteColor];
        //添加分割线
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, MIN([self headerViewHeight], height) - 1, self.frame.size.width, 1)];
        separatorView.backgroundColor = RGB(220, 220, 220);
        [_headerView addSubview:separatorView];
        if (self.messageLabel) {
            UIView *titleSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, _titleLabel.frame.size.height, self.frame.size.width, 1)];
            titleSeparatorView.backgroundColor = RGB(220, 220, 220);
            [_headerView addSubview:titleSeparatorView];
        }
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        
        CGFloat height = self.alertView.frame.size.height - self.headerView.frame.size.height;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.frame), self.alertView.frame.size.width, MIN([self tableViewHeight], height)) style:UITableViewStylePlain];
        if (height < [self tableViewHeight]) {
            _tableView.scrollEnabled = YES;
        } else {
            _tableView.scrollEnabled = NO;
        }
        _tableView.backgroundColor = RGB(220, 220, 220);
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"alertCell"];
        _tableView.rowHeight = kCellHeight;
        
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CGFloat height = self.alertView.frame.size.height - self.headerView.frame.size.height;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 0;
        //layout.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.frame), self.alertView.frame.size.width, height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[XEL_CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
//        _collectionView.layer.borderColor = [UIColor redColor].CGColor;
//        _collectionView.layer.borderWidth = 1.f;
    }
    return _collectionView;
}

#pragma mark - view height
- (CGFloat)tableViewHeight {
    CGFloat height = 0;
    if (self.actions.count == 1) {
        height = kCellHeight;
    } else if (self.actions.count == 2) {
        if ([self hasCancelAction]) {
            height = self.actions.count * kCellHeight + kCancelPadding;
        } else {
            height = self.actions.count * kCellHeight;
        }
        
    } else {
        height = self.actions.count * kCellHeight + (self.actions.count - 2) * kDefaultPadding + kCancelPadding;
    }
    
    return height;
}

- (CGFloat)collectionViewHeight {
    CGFloat height = 0;
    if (self.actions.count < 3 && self.actions.count > 0) {
        height = kCellHeight;
    } else {
        height = kCellHeight * self.actions.count;
    }
    return height;
}


#pragma mark - private --

- (BOOL)hasCancelAction {
    //判断是否含有取消action
    for (XEL_AlertAction *action in self.actions) {
        if (action.style == XEL_AlertActionStyleCancel) {
            return YES;
        }
    }
    return NO;
}

- (void)sortActions {
    if (self.cancelAction) {
        
        if (self.preferredStyle == XEL_AlertControllerStyleActionSheet) {
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.actions];
            [tempArray addObject:self.cancelAction];
            self.actions = [tempArray copy];
        } else if (self.preferredStyle == XEL_AlertControllerStyleAlert) {
            if (self.actions.count > 1) {
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.actions];
                [tempArray addObject:self.cancelAction];
                self.actions = [tempArray copy];
            } else {
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.actions];
                [tempArray insertObject:self.cancelAction atIndex:0];
                self.actions = [tempArray copy];
            }
        }
    }
}

- (CGSize)stringSizeWithString:(NSString *)string width:(CGFloat)width font:(UIFont *)font {
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil].size;
    
    return size;
}

#pragma mark - gesture delegate
//屏蔽cell上的点击
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    NSLog(@"touchView:%@", touch.view);
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

@end


@interface XEL_AlertAction ()

@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) XEL_AlertActionStyle style;


@end

@implementation XEL_AlertAction

+ (instancetype)xel_actionWithTitle:(NSString *)title style:(XEL_AlertActionStyle)style handler:(void (^)(XEL_AlertAction *))handler {
    return [[self alloc] initWithTitle:title style:style handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title style:(XEL_AlertActionStyle)style handler:(void (^)(XEL_AlertAction *))handler {
    self = [super init];
    if (self) {
        self.title  = title;
        self.style  = style;
        self.handle = handler;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return nil;
}

@end

