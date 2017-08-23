//
//  MyTabBarController.m
//  Seedling
//
//  Created by whkj on 16/6/3.
//  Copyright © 2016年 whkj. All rights reserved.
//

#import "MyTabBarController.h"

#import "ZTTabBar.h"

@interface MyTabBarController ()<ZTTabBarDelegate>

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViewControllers];
    //修改tabbar的背景颜色
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 48.5)];
   // backView.backgroundColor = RGBA(246, 246, 246, 1);
    backView.backgroundColor = [UIColor whiteColor];
    [self.tabBar insertSubview:backView atIndex:0];
    self.tabBar.opaque = YES;
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    // backView.backgroundColor = RGBA(246, 246, 246, 1);
    lineLabel.backgroundColor = [sezhiClass colorWithHexString:@"#d9d9d9"];
    [backView insertSubview:lineLabel atIndex:0];
   
    
    self.tabBar.clipsToBounds = YES;
  
    ZTTabBar *tabBar = [[ZTTabBar alloc] init];
    tabBar.delegate = self;
    // KVC：如果要修系统的某些属性，但被设为readOnly，就是用KVC，即setValue：forKey：。
    [self setValue:tabBar forKey:@"tabBar"];
  

}

- (void)setupViewControllers {
    
    NSString *path    = [[NSBundle mainBundle] pathForResource:@"RootTabBarC_Init" ofType:@"plist"];
    NSArray *navInfos = [NSArray arrayWithContentsOfFile:path];
      UINavigationController *Question_and_answerNav = [self vcToNav:[LYHomeViewController class] withTitle:@"约会吧" withImageName:navInfos[0][@"image"] withHeightImageName:navInfos[0][@"selectedImage"]];
    UINavigationController *FoundNav = [self vcToNav:[DialogueViewController class] withTitle:@"在线" withImageName:navInfos[1][@"image"] withHeightImageName:navInfos[1][@"selectedImage"]];
  
    UINavigationController *CustomersNav = [self vcToNav:[FriendsCirleViewController class] withTitle:@"消息" withImageName:navInfos[3][@"image"] withHeightImageName:navInfos[3][@"selectedImage"]];
//        UINavigationController *CustomersNav = [self vcToNav:[BookKeepingViewController class] withTitle:@"消息" withImageName:@"customers2" withHeightImageName:@"customers"];
     UINavigationController *personageNav = [self vcToNav:[LYMeViewController class] withTitle:@"我" withImageName:navInfos[4][@"image"] withHeightImageName:navInfos[4][@"selectedImage"]];
   
    self.viewControllers = @[Question_and_answerNav,CustomersNav,FoundNav,personageNav];
}

///**
// *  添加一个子控制器a
// *
// *  @param childVc       子控制器
// *  @param title         标题
// *  @param image         图片
// *  @param selectedImage 选中的图片
// */
//- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
//{
//    // 设置子控制器的文字(可以设置tabBar和navigationBar的文字)
//    childVc.title = title;
//    
//    // 设置子控制器的tabBarItem图片
//    childVc.tabBarItem.image = [UIImage imageNamed:image];
//    // 禁用图片渲染
//    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    
//    // 设置文字的样式
//    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : RGBA(78, 78, 78, 1)} forState:UIControlStateNormal];
//    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor redColor]} forState:UIControlStateSelected];
//    //    childVc.view.backgroundColor = RandomColor; // 这句代码会自动加载主页，消息，发现，我四个控制器的view，但是view要在我们用的时候去提前加载
//    
//    // 为子控制器包装导航控制器
//    UINavigationController *navigationVc = [[UINavigationController alloc] initWithRootViewController:childVc];
//    // 添加子控制器
//    [self addChildViewController:navigationVc];
//    
//}
- (UINavigationController *)vcToNav:(Class)class withTitle:(NSString *)title withImageName:(NSString *)imageName withHeightImageName:(NSString *)heightImageName {
    UIViewController *vc = [class new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    //让图片保持原本的颜色
    UIImage *heightImage = [[UIImage imageNamed:heightImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
      UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:heightImage];
    
    //修改tabbar的字体颜色
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[sezhiClass colorWithHexString:@"#34bf65"]} forState:UIControlStateSelected];
      [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[sezhiClass colorWithHexString:@"#888888"]} forState:UIControlStateNormal];
    nav.tabBarItem = item;
    nav.tabBarController.view.backgroundColor = [UIColor whiteColor];
    return nav;
}

#pragma ZTTabBarDelegate
/**
 *  加号按钮点击
 */

- (void)tabBarDidClickPlusButton:(ZTTabBar *)tabBar
{
       
    //点击加号按钮 进入添加界面
    SendAppointViewController *vc = [[SendAppointViewController alloc] init];
    UINavigationController *NAV = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:NAV animated:YES completion:nil];

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
