//
//  ViewController.m
//  NavigationBarExtension
//
//  Created by YenHenChia on 2016/7/14.
//  Copyright © 2016年 YenHenChia. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UINavigationBar *navigationBar;

@property (nonatomic, strong) UIView *playerView;

@property (nonatomic, strong) UITableView *dataSourceList;

@property (nonatomic, assign) CGFloat preOffsetY;

@property (nonatomic, assign) CGFloat currOffsetY;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat navBarHeight;

@property (nonatomic, assign) CGFloat playerHeight;

@property (nonatomic, assign) CGFloat extensionHeight;

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, assign) BOOL isEndDragged;

@property (nonatomic, assign) BOOL isAnimation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.preOffsetY = self.currOffsetY = 0.0f;
    
    self.isShow = YES;
    
    self.isEndDragged = YES;
    
    self.isAnimation = NO;
    
    self.width = self.view.frame.size.width;
    self.height = self.view.frame.size.height;
    self.navBarHeight = 44;
    self.playerHeight = _width * 9 / 16;
    self.extensionHeight = _width * 9 / 16;

    self.dataSourceList = [[UITableView alloc] initWithFrame:CGRectMake(0, _navBarHeight + 20, _width, _height - _navBarHeight - 20) style:UITableViewStylePlain];
    [self.dataSourceList setContentInset:UIEdgeInsetsMake(_playerHeight, 0, 0, 0)];
    self.dataSourceList.delegate = self;
    self.dataSourceList.dataSource = self;
    [self.view addSubview:self.dataSourceList];
    
    self.playerView = [[UIView alloc] initWithFrame:CGRectMake(0, _navBarHeight + 20, _width, _playerHeight)];
    [self.playerView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.playerView];
    
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, _width, _navBarHeight + 20)];
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
    
    return 20;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
    cell.textLabel.text = [NSString stringWithFormat:@"cell%ld", indexPath.row];
    return cell;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    self.isEndDragged = NO;
}
-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    self.isEndDragged = YES;
    
    if (!decelerate) {
        
        if (_extensionHeight < 0) {
            
            self.playerView.frame = CGRectMake(0, _navBarHeight - _playerHeight, _width, _playerHeight);
            
//            self.dataSourceList.frame = CGRectMake(0, _navBarHeight + 20, _width, _height - _navBarHeight - 20);
            
            self.extensionHeight = 0;
            
            self.isShow = NO;
        }
        else if(_extensionHeight > _playerHeight) {
            
            ViewController *__weak selfObj = self;
            
            if (_isAnimation == NO) {
                
                _isAnimation = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        
                        self.playerView.frame = CGRectMake(0, _navBarHeight + 20, _width, _playerHeight);
                        
//                        self.dataSourceList.frame = CGRectMake(0, _navBarHeight + 20 + _playerHeight, _width, _height - _navBarHeight - 20 - _playerHeight);
                        
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

    CGFloat offsetY = scrollView.contentOffset.y +  _playerHeight;
    
    float scrollViewTopY = offsetY + scrollView.bounds.size.height - scrollView.contentInset.bottom;
    float scrollViewHeight = scrollView.contentSize.height + _playerHeight;
    
    self.currOffsetY = offsetY;
    
    CGFloat delta = self.currOffsetY - self.preOffsetY;

    NSLog(@"delta = %f", delta);
//
//    NSLog(@"scrollViewTopY = %f", scrollViewTopY);
//    
//    NSLog(@"scrollViewHeight = %f", scrollViewHeight);
//    
//    NSLog(@"offsetY = %f", offsetY);
    
    if (scrollViewTopY >= scrollViewHeight && offsetY > _playerHeight) {
        

        ViewController *__weak selfObj = self;
        
        if (_isAnimation == NO && _isShow == YES) {
            
            _isAnimation = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:0.1 animations:^{
                    
                    self.playerView.frame = CGRectMake(0, _navBarHeight - _playerHeight, _width, _playerHeight);
                    
//                    self.dataSourceList.frame = CGRectMake(0, _navBarHeight + 20, _width, _height - _navBarHeight - 20);
                    
                } completion:^(BOOL finished) {
                    
                    selfObj.isAnimation = NO;
                    selfObj.isShow = NO;
                }];
            });
        }
    }
    else if(offsetY <= 0) {
        
        self.playerView.frame = CGRectMake(0, _navBarHeight + 20, _width, _playerHeight);
        
        /*
        ViewController *__weak selfObj = self;
        
        if (_isAnimation == NO && _isShow == NO) {
            
            _isAnimation = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:0.1 animations:^{
                    
                    self.playerView.frame = CGRectMake(0, _navBarHeight + 20, _width, _playerHeight);
                    
//                    self.dataSourceList.frame = CGRectMake(0, _navBarHeight + 20 + _playerHeight, _width, _height - _navBarHeight - 20 - _playerHeight);
                    
                } completion:^(BOOL finished) {
                    
                    selfObj.isAnimation = NO;
                    selfObj.isShow = YES;
                }];
            });
        }
         */
    }
    else {
        
        if(delta < 0 && _isShow == NO) {
            
            ViewController *__weak selfObj = self;
            
            if (_isAnimation == NO) {
                
                _isAnimation = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        
                        self.playerView.frame = CGRectMake(0, _navBarHeight + 20, _width, _playerHeight);
                        
//                        self.dataSourceList.frame = CGRectMake(0, _navBarHeight + 20 + _playerHeight, _width, _height - _navBarHeight - 20 - _playerHeight);
                        
                    } completion:^(BOOL finished) {
                        
                        selfObj.isAnimation = NO;
                        
                        self.extensionHeight = _playerHeight;
                        
                        self.isShow = YES;
                    }];
                });
            }
        }
        else if (_extensionHeight > 0 || _isEndDragged == NO) {
            
            if (delta > 0) {
                
                CGRect playerRect = self.playerView.frame;
                playerRect.origin.y -= delta;
                
                self.playerView.frame = playerRect;
                
                self.extensionHeight -= delta;

            }
            else {
                
                if (self.extensionHeight < _playerHeight) {
                
                    CGRect playerRect = self.playerView.frame;
                    playerRect.origin.y -= delta;
                    
                    self.playerView.frame = playerRect;
                    
                    self.extensionHeight -= delta;
                }
            }
        }
    }

    self.preOffsetY = self.currOffsetY;
}

@end
