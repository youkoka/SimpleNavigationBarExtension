//
//  ViewController.m
//  NavigationBarExtension
//
//  Created by YenHenChia on 2016/7/14.
//  Copyright © 2016年 YenHenChia. All rights reserved.
//

#import "ViewController.h"

#define AccelerateLimit     100

#define AnimationTime       0.2

#define DefaultDeltaTime    0.5

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UINavigationBar *navigationBar;

@property (nonatomic, strong) UIView *playerView;

@property (nonatomic, strong) UITableView *dataSourceList;

@property (nonatomic, assign) CGFloat preOffsetY;

@property (nonatomic, assign) CGFloat currOffsetY;

@property (nonatomic, assign) NSTimeInterval preScrollTime;

@property (nonatomic, assign) NSTimeInterval currScrollTime;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat navBarHeight;

@property (nonatomic, assign) CGFloat playerHeight;

@property (nonatomic, assign) CGFloat extensionHeight;

@property (nonatomic, assign) CGFloat statusBarHeight;

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, assign) BOOL isEndDragged;

@property (nonatomic, assign) BOOL isAnimation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.preOffsetY = self.currOffsetY = 0.0f;
    
    self.preScrollTime = self.currScrollTime = 0.0f;
    
    self.isShow = YES;
    
    self.isEndDragged = YES;
    
    self.isAnimation = NO;
    
    self.statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    self.width = self.view.frame.size.width;
    self.height = self.view.frame.size.height;
    self.navBarHeight = 44;
    self.playerHeight = _width * 9 / 16;
    self.extensionHeight = _width * 9 / 16;

    self.dataSourceList = [[UITableView alloc] initWithFrame:CGRectMake(0, _navBarHeight + _playerHeight + _statusBarHeight, _width, _height - _navBarHeight - _playerHeight - _statusBarHeight) style:UITableViewStylePlain];
    self.dataSourceList.delegate = self;
    self.dataSourceList.dataSource = self;
    [self.view addSubview:self.dataSourceList];
    
    self.playerView = [[UIView alloc] initWithFrame:CGRectMake(0, _navBarHeight + _statusBarHeight, _width, _playerHeight)];
    [self.playerView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.playerView];
    
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, _width, _navBarHeight + _statusBarHeight)];
    [self.navigationBar setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:self.navigationBar];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 30;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
    cell.textLabel.text = [NSString stringWithFormat:@"cell%ld", indexPath.row];
    return cell;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    self.isEndDragged = NO;
    
    self.preScrollTime = self.currScrollTime = [[NSDate date] timeIntervalSince1970];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    self.isEndDragged = YES;
    
    if (!decelerate) {
        
        if (_extensionHeight < 0) {
            
            self.playerView.frame = CGRectMake(0, _navBarHeight - _playerHeight, _width, _playerHeight);
            
            self.dataSourceList.frame = CGRectMake(0, _navBarHeight + _statusBarHeight, _width, _height - _navBarHeight - _statusBarHeight);
            
            self.extensionHeight = 0;
            
            self.isShow = NO;
        }
        else if(_extensionHeight > _playerHeight) {
            
            ViewController *__weak selfObj = self;
            
            if (_isAnimation == NO) {
                
                _isAnimation = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [UIView animateWithDuration:AnimationTime animations:^{
                        
                        self.playerView.frame = CGRectMake(0, _navBarHeight + _statusBarHeight, _width, _playerHeight);
                        
                        self.dataSourceList.frame = CGRectMake(0, _navBarHeight + _statusBarHeight + _playerHeight, _width, _height - _navBarHeight - _statusBarHeight - _playerHeight);
                        
                    } completion:^(BOOL finished) {
                        
                        selfObj.isAnimation = NO;
                        
                        self.extensionHeight = _playerHeight;
                        
                        self.isShow = YES;
                    }];
                });
            }
        }
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat offsetY = scrollView.contentOffset.y;
    
    float scrollViewTopY = offsetY + scrollView.bounds.size.height - scrollView.contentInset.bottom;
    float scrollViewHeight = scrollView.contentSize.height ;
    
    self.currOffsetY = offsetY;
    
    self.currScrollTime = [[NSDate date] timeIntervalSince1970];
    
    CGFloat deltaY = self.currOffsetY - self.preOffsetY;
    CGFloat deltaTime = self.currScrollTime - self.preScrollTime;
    
    if (deltaTime <= DefaultDeltaTime) {
        
        deltaTime = DefaultDeltaTime;
    }
    
    CGFloat acceleration = (2 * deltaY) / powf(deltaTime, 2);
    
    if (scrollViewTopY >= scrollViewHeight && offsetY > _playerHeight) {
        
        ViewController *__weak selfObj = self;
        
        if (_isAnimation == NO && _isShow == YES && _isEndDragged == YES) {
            
            _isAnimation = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:AnimationTime animations:^{
                    
                    self.playerView.frame = CGRectMake(0, _navBarHeight - _playerHeight, _width, _playerHeight);
                    
                    self.dataSourceList.frame = CGRectMake(0, _navBarHeight + _statusBarHeight, _width, _height - _navBarHeight - _statusBarHeight);
                    
                } completion:^(BOOL finished) {
                    
                    selfObj.isAnimation = NO;
                    selfObj.isShow = NO;
                }];
            });
        }
    }
    else if(offsetY <= 0) {
        
        ViewController *__weak selfObj = self;
        
        if (_isAnimation == NO && _isShow == NO) {
            
            _isAnimation = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:AnimationTime animations:^{
                    
                    self.playerView.frame = CGRectMake(0, _navBarHeight + _statusBarHeight, _width, _playerHeight);
                    
                    self.dataSourceList.frame = CGRectMake(0, _navBarHeight + _statusBarHeight + _playerHeight, _width, _height - _navBarHeight - _statusBarHeight - _playerHeight);
                    
                } completion:^(BOOL finished) {
                    
                    selfObj.isAnimation = NO;
                    
                    self.extensionHeight = _playerHeight;
                    
                    self.isShow = YES;
                }];
            });
        }
    }
    else {
        
        if(deltaY < 0 && _isShow == NO && fabs(acceleration) > AccelerateLimit) {
            
            ViewController *__weak selfObj = self;
            
            if (_isAnimation == NO) {
                
                _isAnimation = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [UIView animateWithDuration:AnimationTime animations:^{
                        
                        self.playerView.frame = CGRectMake(0, _navBarHeight + _statusBarHeight, _width, _playerHeight);
                        
                        self.dataSourceList.frame = CGRectMake(0, _navBarHeight + _statusBarHeight + _playerHeight, _width, _height - _navBarHeight - _statusBarHeight - _playerHeight);
                        
                    } completion:^(BOOL finished) {
                        
                        selfObj.isAnimation = NO;
                        
                        self.extensionHeight = _playerHeight;
                        
                        self.isShow = YES;
                    }];
                });
            }
        }
        else if (_extensionHeight > 0 || _isEndDragged == NO) {
            
            if (deltaY > 0) {
                
                CGRect playerRect = self.playerView.frame;
                playerRect.origin.y -= deltaY;
                
                self.playerView.frame = playerRect;
                
                CGRect listRect = self.dataSourceList.frame;
                listRect.origin.y -= deltaY;
                listRect.size.height += deltaY;
                
                self.dataSourceList.frame = listRect;
                
                self.extensionHeight = (self.extensionHeight - deltaY) < 0 ? 0 : self.extensionHeight - deltaY;
            }
            else {
                
                if ((self.extensionHeight < _playerHeight && _isShow == YES) || offsetY <= _playerHeight) {
                    
                    CGRect playerRect = self.playerView.frame;
                    playerRect.origin.y -= deltaY;
                    
                    if (playerRect.origin.y > _navBarHeight + _statusBarHeight) {
                        
                        playerRect.origin.y = _navBarHeight + _statusBarHeight;
                    }
                    
                    self.playerView.frame = playerRect;
                    
                    CGRect listRect = self.dataSourceList.frame;
                    
                    if (listRect.size.height >  _height - _navBarHeight - _statusBarHeight - _playerHeight) {
                    
                        listRect.origin.y -= deltaY;
                        listRect.size.height += deltaY;
                    }
                    
                    self.dataSourceList.frame = listRect;
                    
                    self.extensionHeight = (self.extensionHeight - deltaY) < 0 ? 0 : self.extensionHeight - deltaY;
                }
            }
        }
    }

    self.preOffsetY = self.currOffsetY;
    self.preScrollTime = self.currScrollTime;
}

@end
