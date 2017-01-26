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
#import "Helper.h"
#import "User.h"

@interface LeftViewController ()

@property (strong, nonatomic) NSArray *titlesArray;
@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UILabel *usernameLabel;

@end

@implementation LeftViewController

#pragma mark View-Life Cycle

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
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
    
    if (![PREFS objectForKey:USER_INFORMATION]) {
        _usernameLabel.text = [MCLocalization stringForKey:@"PERSONALIZED_TITLE_PLACEHOLDER"];
        _emailLabel.text = [MCLocalization stringForKey:@"PERSONALIZED_SUB_TITLE_PLACEHOLDER"];
    }else {
        NSData *myObject = [PREFS objectForKey:USER_INFORMATION];
        User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
        
        // Username
        _usernameLabel.text = user.userName;
        
        // Email Address
        _emailLabel.text = user.emailAddress;
    }
    
    // Tap gesture added to TableHeaderView
    [self.tableView.tableHeaderView addGestureRecognizer:[self tableHeaderViewRecognizer]];
}

#pragma mark UITableview header

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
    UIView *colorLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 280, 0.5)];
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

#pragma mark - UITapGestureRecognizer

- (void)gestureHandler:(UIGestureRecognizer *)gestureRecognizer {
    UIViewController *rightSideVC = nil;
    
    if (![PREFS objectForKey:USER_INFORMATION]) {
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

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // New controller
    UIViewController *viewController = [UIViewController new];
    viewController.view.backgroundColor = [UIColor whiteColor];
    viewController.title = self.titlesArray[indexPath.row];
    
    UINavigationController *navigationController = (UINavigationController *)self.sideMenuController.rootViewController;
    [navigationController pushViewController:viewController animated:YES];
    [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
}

@end
