//
//  LeftViewController.m
//

#import "LeftViewController.h"
#import "LeftViewCell.h"
#import "UIViewController+LGSideMenuController.h"
#import "CenterViewController.h"
#import "HomeViewController.h"
#import "MCLocalization.h"
#import "Constants.h"
#import "AFOAuth2Manager.h"
#import "ProfileViewController.h"

@interface LeftViewController ()

@property (strong, nonatomic) NSArray *titlesArray;
@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UILabel *usernameLabel;

@end

@implementation LeftViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        /*
         self.titlesArray = @[@"Open Right View",
                             @"",
                             @"Change Root VC",
                             @"",
                             @"Profile",
                             @"News",
                             @"Articles",
                             @"Video",
                             @"Music"];

        self.view.backgroundColor = [UIColor clearColor];
        [self.tableView registerClass:[LeftViewCell class] forCellReuseIdentifier:@"cell"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 44.0, 0.0);
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.backgroundColor = [UIColor clearColor];
        */
        
        // Forcefully stop to call table data source and delegates
        self.tableView.dataSource = nil;
        self.tableView.delegate = nil;
        
        self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 44.0, 0.0);
        self.view.backgroundColor = self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.scrollEnabled = NO;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Table header view
    self.tableView.tableHeaderView = [self getTableHeaderView];
    
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:SERVICE_PROVIDER_IDENTIFIER];
    NSLog(@"%@",credential.description);

    // TODO: (id)[NSNull null] not working
    if ([credential.accessToken isKindOfClass:[NSNull class]] || (NSNull *)credential.accessToken == [NSNull null] || credential.accessToken == nil){
        NSLog(@"WTF!!!!!");
    }

    if (credential.accessToken == nil) {
        _usernameLabel.text = [MCLocalization stringForKey:@"PERSONALIZED_TITLE_PLACEHOLDER"];
        _emailLabel.text = [MCLocalization stringForKey:@"PERSONALIZED_SUB_TITLE_PLACEHOLDER"];
    }else {
        [self me];
    }
    
    // Tap gesture added to TableHeaderView
    [self.tableView.tableHeaderView addGestureRecognizer:[self tableHeaderViewRecognizer]];
}

- (UIView *)getTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    
    // image
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 50, 50)];
    imgView.image = [UIImage imageNamed:@"circle-user"];
    [headerView addSubview:imgView];
    
    // title
    _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 240 , 30)];
    _usernameLabel.text = [MCLocalization stringForKey:@"PERSONALIZED_TITLE_PLACEHOLDER"];
    _usernameLabel.textColor = [UIColor whiteColor];
    _usernameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [headerView addSubview:_usernameLabel];
    
    // Sub-title
    _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 20, 240 , 30)];
    _emailLabel.text = [MCLocalization stringForKey:@"PERSONALIZED_SUB_TITLE_PLACEHOLDER"];
    _emailLabel.textColor = [UIColor whiteColor];
    _emailLabel.font = [UIFont systemFontOfSize:11.0f];
    [headerView addSubview:_emailLabel];
    
    // Separator line
    UIView *colorLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 55, 280, 0.5)];
    colorLineView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    [headerView addSubview:colorLineView];
    
    return headerView;
}

- (UITapGestureRecognizer *)tableHeaderViewRecognizer {
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.numberOfTapsRequired = 1;
    
    return singleTapRecognizer;
}

- (void)me {
    AFHTTPSessionManager *manager =
    [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URI]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:[AFOAuthCredential retrieveCredentialWithIdentifier:SERVICE_PROVIDER_IDENTIFIER]];
    [manager GET:GET_USERS_API_NAME
      parameters:@{}
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"Success: %@", responseObject);
             NSArray *jsonArray = (NSArray *)responseObject;
             if (!jsonArray)
             return;
             if ([jsonArray isKindOfClass:[NSArray class]] == NO)
             NSAssert(NO, @"Expected an Array, got %@", NSStringFromClass([jsonArray class]));
             
             _usernameLabel.text = [jsonArray objectAtIndex:0][@"username"];
             _emailLabel.text = [jsonArray objectAtIndex:0][@"email"];
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Failure: %@", error);
         }];
}

#pragma mark - UITapGestureRecognizer

- (void)gestureHandler:(UIGestureRecognizer *)gestureRecognizer {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:SERVICE_PROVIDER_IDENTIFIER];
    NSLog(@"%@",credential.description);
    UIViewController *rightSideVC = nil;

    if (credential.accessToken == nil) {
        rightSideVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:[NSBundle mainBundle]];
    }else {
        rightSideVC = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];
    }
    UINavigationController *navigationController = (UINavigationController *)self.sideMenuController.rootViewController;
    [navigationController pushViewController:rightSideVC animated:YES];
    [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
}

#pragma mark - UIStatusBar

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    cell.textLabel.text = self.titlesArray[indexPath.row];
   // cell.separatorView.hidden = (indexPath.row <= 3 || indexPath.row == self.titlesArray.count-1);
    //cell.userInteractionEnabled = (indexPath.row != 1 && indexPath.row != 3);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  44.0; //(indexPath.row == 1 || indexPath.row == 3) ? 22.0 :
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
//    
//    if (indexPath.row == 0) {
//        if ([mainViewController isLeftViewAlwaysVisibleForCurrentOrientation]) {
//            [mainViewController showRightViewAnimated:YES completionHandler:nil];
//        }
//        else {
//            [mainViewController hideLeftViewAnimated:YES completionHandler:^(void) {
//                [mainViewController showRightViewAnimated:YES completionHandler:nil];
//            }];
//        }
//    }
//    else if (indexPath.row == 2) {
//        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
//        UIViewController *viewController;
//
//        if ([navigationController.viewControllers.firstObject isKindOfClass:[ViewController class]]) {
//           // viewController = [OtherViewController new];
//        }
//        else {
//            viewController = [ViewController new];
//        }
//
//        [navigationController setViewControllers:@[viewController]];
//
//        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
//    }
//    else {
    
        // New controller
        UIViewController *viewController = [UIViewController new];
        viewController.view.backgroundColor = [UIColor whiteColor];
        viewController.title = self.titlesArray[indexPath.row];
    
        UINavigationController *navigationController = (UINavigationController *)self.sideMenuController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
    //}
}

@end
