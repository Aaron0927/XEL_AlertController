//
//  XEL_AlertViewController.m
//  XEL_AlertController
//
//  Created by leijin on 16/12/1.
//  Copyright © 2016年 xel. All rights reserved.
//

#import "XEL_AlertView.h"



@interface XEL_AlertView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, readwrite) NSArray <XEL_AlertAction *> *actions;
@property (nonatomic, strong) XEL_AlertAction *cancelAction;


//action sheet
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UIScrollView *headerView;
@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
//
@property (nonatomic, assign) CGFloat headerViewHeight;
@end

//cell 的默认高度
static CGFloat kCellHeight = 44;
//取消与其他按钮的距离
static CGFloat kCancelPadding = 10;
//其他按钮的距离
static CGFloat kDefaultPadding = 2;
//titleLabel的边距
static CGFloat kTitleLabelPddding = 10;

//alert view 的最大高度比例
static CGFloat kMaxRatio = 0.9;
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
        
        self.title = title;
        self.message = message;
        
        //添加视图旋转的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFrame) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)changeFrame {
    
    CGRect frame = [UIScreen mainScreen].bounds;
    NSLog(@"%@", NSStringFromCGRect(frame));
    self.frame = frame;
    //修改子视图frame
    CGRect alertViewFrame = self.alertView.frame;
    alertViewFrame.size.width = frame.size.width;
    alertViewFrame.size.height = MIN([self headerViewHeight] + [self tableViewHeight], self.frame.size.height * kMaxRatio);
    alertViewFrame.origin.y = frame.size.height - alertViewFrame.size.height;
    self.alertView.frame = alertViewFrame;
    
    CGRect headerViewFrame = self.headerView.frame;
    headerViewFrame.size.width = frame.size.width;
    CGFloat height = self.alertView.frame.size.height - [self tableViewHeight];
    headerViewFrame.size.height = MIN([self headerViewHeight], height);
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
    
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.width = frame.size.width;
    CGFloat height1 = self.alertView.frame.size.height - self.headerView.frame.size.height;
    tableViewFrame.size.height = MIN([self tableViewHeight], height1);
    tableViewFrame.origin.y = CGRectGetHeight(self.headerView.frame);
    self.tableView.frame = tableViewFrame;
    
}

- (void)layoutSubviews {
    NSLog(@"layoutSubViews");
}

- (void)showInView:(UIView *)view {
    
    [view addSubview:self];
    [self sortActions];
    
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
}

- (void)hideView {
    
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
        self.headerViewHeight = titleLabel.frame.size.height;
        
        self.titleLabel = titleLabel;
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
        
        self.headerViewHeight += (size.height + 2 * kTitleLabelPddding);
        
        CGFloat y = 0;
        if (self.title) {
            y = CGRectGetMaxY(self.titleLabel.frame);
        }
        
        messageLabel.frame = CGRectMake(kTitleLabelPddding, y, width, size.height + 2 * kTitleLabelPddding);
        self.messageLabel = messageLabel;
        messageLabel.layer.borderColor = [UIColor redColor].CGColor;
        messageLabel.layer.borderWidth = 1.f;
    }
    
}


- (UIView *)alertView {
    if (!_alertView) {
        
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, MIN([self headerViewHeight] + [self tableViewHeight], self.frame.size.height * kMaxRatio))];
        
        _alertView.backgroundColor = [UIColor lightGrayColor];
        
    }
    return _alertView;
}

- (UIScrollView *)headerView {
    if (!_headerView) {
        
        CGFloat height = self.alertView.frame.size.height - [self tableViewHeight];
        if (height < [self headerViewHeight]) {
            _headerView.scrollEnabled = YES;
            
        } else {
            _headerView.scrollEnabled = NO;
        }
        _headerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.alertView.frame.size.width, MIN([self headerViewHeight], height))];
        [_headerView addSubview:self.titleLabel];
        [_headerView addSubview:self.messageLabel];
        _headerView.contentSize = CGSizeMake(0, [self headerViewHeight]);
        _headerView.layer.borderColor = [UIColor greenColor].CGColor;
        _headerView.layer.borderWidth = 1.f;
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
        _tableView.backgroundColor = [UIColor darkGrayColor];
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"alertCell"];
        _tableView.rowHeight = kCellHeight;
        
    }
    return _tableView;
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
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.actions];
    [tempArray addObject:self.cancelAction];
    self.actions = [tempArray copy];
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