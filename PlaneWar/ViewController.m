//
//  ViewController.m
//  PlaneWar
//
//  Created by tam on 2018/11/19.
//  Copyright © 2018年 abner. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSInteger bulletTag_down;           //移动中的子弹
    NSInteger bulletTag_wait;           //可用的子弹
    NSInteger enemyPlaneTag_down;       //下落中的敌机
    NSInteger enemyPlaneTag_wait;       //可用的敌机
}

@property(nonatomic,strong) UIButton * startButton;
@property(nonatomic,strong) UIImageView * bgImageView1;
@property(nonatomic,strong) UIImageView * bgImageView2;
@property(nonatomic,strong) UIImageView * planeImageView;
@property(nonatomic,strong) NSArray * bulletArray;
@property(nonatomic,strong) NSArray * enemyPlaneArray;

@property(nonatomic,strong) NSTimer * moveBgImageViewTimer;
@property(nonatomic,strong) NSTimer * collisionBoomTimer;
@property(nonatomic,strong) NSTimer * moveEnemyPlaneTimer;
@property(nonatomic,strong) NSTimer * findEnemyPlaneTimer;
@property(nonatomic,strong) NSTimer * moveBulletTimer;
@property(nonatomic,strong) NSTimer * fineBulletTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bulletTag_down = 221;
    bulletTag_wait = 222;
    enemyPlaneTag_down = 119;
    enemyPlaneTag_wait = 120;
    
    [self creatViewControllerView];
}
-(void)startButtonClick{
    self.startButton.hidden = YES;
    self.planeImageView.hidden = NO;
    [self startWar];
}
-(void)startWar{
    //背景开始移动
    self.moveBgImageViewTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                 target:self
                                                               selector:@selector(bgImgViewMove)
                                                               userInfo:nil
                                                                repeats:YES];
    //负责寻找可用子弹
    self.fineBulletTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                            target:self
                                                          selector:@selector(findMyBullet)
                                                          userInfo:nil
                                                           repeats:YES];
    //负责子弹的移动
    self.moveBulletTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                            target:self
                                                          selector:@selector(myBulletMove)
                                                          userInfo:nil
                                                           repeats:YES];
    //定时寻找可以下落的敌机
    self.findEnemyPlaneTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                target:self
                                                              selector:@selector(findEnemyPlane)
                                                              userInfo:nil
                                                               repeats:YES];
    //定时器让敌机下落
    self.moveEnemyPlaneTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                                target:self
                                                              selector:@selector(enemyPlaneDown)
                                                              userInfo:nil
                                                               repeats:YES];
    //爆炸动画
    self.collisionBoomTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                               target:self
                                                             selector:@selector(collisionBoom)
                                                             userInfo:nil
                                                              repeats:YES];
}
-(void)stopWar{
    
    [self.moveBgImageViewTimer invalidate];
    self.moveBgImageViewTimer = nil;
    
    [self.fineBulletTimer invalidate];
    self.fineBulletTimer = nil;
    
    [self.moveBulletTimer invalidate];
    self.moveBulletTimer = nil;
    
    [self.findEnemyPlaneTimer invalidate];
    self.findEnemyPlaneTimer = nil;
    
    [self.moveEnemyPlaneTimer invalidate];
    self.moveEnemyPlaneTimer = nil;
    
    [self.collisionBoomTimer invalidate];
    self.collisionBoomTimer = nil;
    
    for (UIImageView * bulletImageView in self.bulletArray) {
        if (bulletImageView.tag == bulletTag_down){
            [bulletImageView removeFromSuperview];
            bulletImageView.tag = bulletTag_wait;
        }
    }
    
    for (UIImageView * enemyPlaneImageView in self.enemyPlaneArray){
        if (enemyPlaneImageView.tag == enemyPlaneTag_down){
            [enemyPlaneImageView removeFromSuperview];
            enemyPlaneImageView.tag = enemyPlaneTag_wait;
        }
    }
    
    CGFloat time = 0.5;
    CGFloat repeatCount = 3;
    CGFloat afterDelay = time * repeatCount;
    [self.planeImageView.layer addAnimation:[self opacityForever_Animation:time repeatCount:repeatCount] forKey:nil];
    [self performSelector:@selector(startAgain) withObject:nil afterDelay:afterDelay];
}
-(void)startAgain{
    self.planeImageView.hidden = YES;
    self.startButton.hidden = NO;
    self.planeImageView.bounds = CGRectMake(0, 0, 40, 40);
    self.planeImageView.center = CGPointMake(self.view.frame.size.width*0.5, self.view.frame.size.height*0.5);
}
-(CABasicAnimation *)opacityForever_Animation:(float)time repeatCount:(int)repeatCount{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.duration = time;
    animation.repeatCount = repeatCount;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];///没有的话是均匀的动画。
    return animation;
}

-(void)creatViewControllerView{
    
    self.bgImageView1.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.bgImageView1];
    self.bgImageView2.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.bgImageView2];
    
    self.planeImageView.bounds = CGRectMake(0, 0, 40, 40);
    self.planeImageView.center = CGPointMake(self.view.frame.size.width*0.5, self.view.frame.size.height*0.5);
    [self.view addSubview:self.planeImageView];
    
    self.startButton.bounds = CGRectMake(0, 0, 120, 45);
    self.startButton.center = CGPointMake(self.view.frame.size.width*0.5, self.view.frame.size.height*0.5);
    [self.view addSubview:self.startButton];
    
    self.planeImageView.hidden = YES;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //找到屏幕上任何的触摸，也就是找到touch对象
    UITouch *touch = [touches anyObject];
    //找到触摸的的点的位置
    CGPoint point = [touch locationInView:self.view];
    //让我的战机的中心点 位于手指移动的点
    self.planeImageView.center = point;
}

//====================================敌方数据准备======================================


//寻找可用的敌机
- (void)findEnemyPlane{
    //找到数组中没有在下落的敌机，把它tag值设为下落，立马下落（另一个定时器控制）
    for (int i = 0; i < self.enemyPlaneArray.count; i++) {
        UIImageView * enemyPlaneImageView = [self.enemyPlaneArray objectAtIndex:i];
        if (enemyPlaneImageView.tag == enemyPlaneTag_wait) {
            enemyPlaneImageView.tag = enemyPlaneTag_down;
            //把敌机出来的位置重置一下，保证在屏幕上边
            int pointX = arc4random() % (int)self.view.frame.size.width;
            
            if (pointX <= 40) {
                pointX = 40;
            } else if (pointX > (self.view.frame.size.width -40)) {
                pointX = self.view.frame.size.width - 40;
            }
            
            enemyPlaneImageView.frame =  CGRectMake(pointX, -40, 40, 40);
            //把敌机再添加在屏幕上，因为爆炸完把它移除了
            [self.view addSubview:enemyPlaneImageView];
            break;
        }
    }
}
//敌机下落
-(void)enemyPlaneDown{
    //需找数组中 可以下落的敌机，让其下落
    for (int i = 0; i < self.enemyPlaneArray.count; i++){
        UIImageView *enemyPlaneImageView = [self.enemyPlaneArray objectAtIndex:i];
        if (enemyPlaneImageView.tag == enemyPlaneTag_down){
            enemyPlaneImageView.frame = CGRectMake(enemyPlaneImageView.frame.origin.x, enemyPlaneImageView.frame.origin.y + 5, 40, 40);
            
            //如果敌机跑出屏幕 就让其tag改为没有在下落，并且回到屏幕上方，等待下落
            if (enemyPlaneImageView.frame.origin.y >= self.view.frame.size.height){
                int pointX = arc4random() % (int)self.view.frame.size.width;
                
                if (pointX <= 40) {
                    pointX = 40;
                } else if (pointX > (self.view.frame.size.width -40)) {
                    pointX = self.view.frame.size.width - 40;
                }
                enemyPlaneImageView.tag = enemyPlaneTag_wait;
                enemyPlaneImageView.frame = CGRectMake(pointX, -40, 40, 40);
            }
        }
    }
}
//检测碰撞 爆炸
- (void)collisionBoom {
    //找到dijiArr数组中属于UIImageView类型的对象，用diji指针接收
    for (UIImageView * diji in self.enemyPlaneArray)
    {
        if (diji.tag == enemyPlaneTag_down)
        {
            //找正在运行中的子弹
            for (int i = 0; i < self.bulletArray.count; i++)
            {
                UIImageView * myBullet = [self.bulletArray objectAtIndex:i];
                
                if (myBullet.tag == bulletTag_down){
                    if (CGRectIntersectsRect(diji.frame, myBullet.frame)){
                        [myBullet removeFromSuperview];
                        myBullet.tag = bulletTag_wait;
                        [self startBoomAnimation:diji];
                    }
                }
            }
            
            if (CGRectIntersectsRect(diji.frame, self.planeImageView.frame)){
                [self startBoomAnimation:diji];
                [self performSelector:@selector(stopWar) withObject:nil afterDelay:0.5];
            }
        }
    }
}
-(void)startBoomAnimation:(UIImageView *)imageView{
    //创建数组，用来存放帧动画的图片
    NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:0];
    //创建爆炸的imageview
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:imageView.frame];
    [self.view addSubview:imgView];
    //创建爆炸图片，存在数组
    for (int i = 1; i < 6 ; i++)
    {
        NSString *str = [NSString stringWithFormat:@"bz%d",i];
        UIImage *img = [UIImage imageNamed:str];
        [arr addObject:img];
    }
    //设置帧动画的数据源数组
    imgView.animationImages = arr;
    
    //设置循环一次的时间
    imgView.animationDuration = 0.5;
    
    //设置循环次数
    imgView.animationRepeatCount = 1;
    
    //开始帧动画
    [imgView startAnimating];
    
    //爆炸完 把子弹 和 敌机移除
    //延迟0.5秒 敌机移除
    [self performSelector:@selector(removeImageView:) withObject:imgView afterDelay:0.5];
    [imageView removeFromSuperview];
    imageView.tag = enemyPlaneTag_wait;
}
- (void)removeImageView:(UIImageView *)imageView{
    [imageView removeFromSuperview];
}
//====================================我方数据准备======================================
//寻找可以下落的子弹
- (void)findMyBullet{
    //找到屏幕上我的战机
    for (int i = 0; i < self.bulletArray.count; i++) {
        UIImageView * bulletImageView = [self.bulletArray objectAtIndex:i];
        if (bulletImageView.tag == bulletTag_wait) {
            bulletImageView.tag = bulletTag_down;
            //设置子弹出现的位置为飞机的机头位置
            bulletImageView.center = CGPointMake(self.planeImageView.center.x+2, self.planeImageView.center.y - 30);
            [self.view addSubview:bulletImageView];
            //把飞机的层次 调到子弹之上
            [self.view bringSubviewToFront:self.planeImageView];
            break;
        }
    }
}
//移动子弹
- (void)myBulletMove {
    for (int i = 0; i < self.bulletArray.count; i++){
        UIImageView *bulletImageView = [self.bulletArray objectAtIndex:i];
        if (bulletImageView.tag == bulletTag_down) {
            bulletImageView.frame = CGRectMake(bulletImageView.frame.origin.x, bulletImageView.frame.origin.y - 5, 10, 20);
            //如果子弹飞出屏幕 就把tag设为可以重用  并且从父视图移除
            if (bulletImageView.frame.origin.y <= 0){
                bulletImageView.tag = bulletTag_wait;
                [bulletImageView removeFromSuperview];
            }
        }
    }
}

//====================================背景======================================
- (void)bgImgViewMove {
    
    self.bgImageView1.frame = CGRectMake(0, self.bgImageView1.frame.origin.y + 5, self.view.frame.size.width, self.view.frame.size.height);
    self.bgImageView2.frame = CGRectMake(0, self.bgImageView2.frame.origin.y + 5, self.view.frame.size.width, self.view.frame.size.height);
    
    if (self.bgImageView1.frame.origin.y >= (self.view.frame.size.height -5)) {
        self.bgImageView1.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }
    if (self.bgImageView2.frame.origin.y >= (self.view.frame.size.height -5)) {
        self.bgImageView2.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }
}



-(NSArray *)bulletArray{
    if (!_bulletArray) {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        for (int i = 0; i < 20; i++){
            //创建我的子弹，初始位置为战机的位置
            UIImageView * myBullet = [[UIImageView alloc] init];
            myBullet.center =CGPointMake(self.planeImageView.center.x, self.planeImageView.center.y - self.planeImageView.bounds.size.height/2 - self.planeImageView.frame.size.height/2 - 10);
            myBullet.bounds = CGRectMake(0, 0, 10, 20);
            myBullet.image = [UIImage imageNamed:@"zidan"];
            myBullet.tag = bulletTag_wait;
            [array  addObject:myBullet];
        }
        _bulletArray = [NSArray arrayWithArray:array];
    }
    return _bulletArray;
}
-(NSArray *)enemyPlaneArray{
    if (!_enemyPlaneArray) {
        NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < 10; i++) {
            int pointX = arc4random() % (int)self.view.frame.size.width;
            
            if (pointX <= 40) {
                pointX = 40;
            } else if (pointX > (self.view.frame.size.width -40)) {
                pointX = self.view.frame.size.width - 40;
            }
            
            UIImageView * diji = [[UIImageView alloc] initWithFrame:CGRectMake(pointX, -40, 40, 40)];
            diji.image = [UIImage imageNamed:@"diji"];
            diji.tag = enemyPlaneTag_wait;
            [array addObject:diji];
        }
        _enemyPlaneArray = [NSArray arrayWithArray:array];
    }
    return _enemyPlaneArray;
}
-(UIImageView *)planeImageView{
    if (!_planeImageView) {
        _planeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _planeImageView.userInteractionEnabled = YES;
        _planeImageView.image = [UIImage imageNamed:@"plane1"];
        
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < 2; i++) {
            //拼接图片名称
            NSString *str = [NSString stringWithFormat:@"plane%d",i + 1];
            UIImage *img = [UIImage imageNamed:str];
            [arr addObject:img];
        }
        _planeImageView.animationImages = arr;
        _planeImageView.animationDuration = 0.5;
        _planeImageView.animationRepeatCount = 0;
        [_planeImageView startAnimating];
    }
    return _planeImageView;
}
-(UIImageView *)bgImageView1{
    if (!_bgImageView1) {
        _bgImageView1 = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bgImageView1.image = [UIImage imageNamed:@"bg"];
        _bgImageView1.userInteractionEnabled = YES;
    }
    return _bgImageView1;
}
-(UIImageView *)bgImageView2{
    if (!_bgImageView2) {
        _bgImageView2 = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bgImageView2.image = [UIImage imageNamed:@"bg"];
        _bgImageView2.userInteractionEnabled = YES;
    }
    return _bgImageView2;
}
-(UIButton *)startButton{
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _startButton.layer.cornerRadius = 12;
        _startButton.layer.borderWidth = 2;
        _startButton.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        _startButton.layer.masksToBounds = YES;
        [_startButton setTitle:@"开始游戏" forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(startButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}
@end
