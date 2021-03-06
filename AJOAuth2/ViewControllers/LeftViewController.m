//
//  LeftViewController.m
//

#import "LeftViewController.h"
#import "LeftViewCell.h"
#import "CenterViewController.h"
#import "HomeViewController.h"
#import "MCLocalization.h"
#import "ProfileViewController.h"
#import "Helper.h"
#import "User.h"
#import <LGSideMenuController/UIViewController+LGSideMenuController.h>
#import "ChangeLanguageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LeftViewController ()

@property (strong, nonatomic) NSArray *titlesArray;
@property (strong, nonatomic) UILabel *emailLabel;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UIImageView *avatarImageView;

@end

@implementation LeftViewController

#pragma mark View-Life Cycle

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        [self.tableView registerClass:[LeftViewCell class] forCellReuseIdentifier:@"cell"];
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
    // Tap gesture added to TableHeaderView
    [self.tableView.tableHeaderView addGestureRecognizer:[self tableHeaderViewRecognizer]];
    
    // Left title array on cell
    self.titlesArray = @[@"", [MCLocalization stringForKey:@"settings_title"]];
    
    if (![PREFS objectForKey:USER_INFO]) {
        _usernameLabel.text = [MCLocalization stringForKey:@"personalized_title_placeholder"];
        _emailLabel.text = [MCLocalization stringForKey:@"personalized_subtitle_placeholder"];
        _avatarImageView.image = PLACEHOLDER_IMAGE;
    } else {
        User *user = [Helper getUserPrefs];
        
        // Username
        _usernameLabel.text = user.userName;
        
        // Email Address
        _emailLabel.text = user.emailAddress;
        
        // Avatar ImageView        
        [_avatarImageView setShowActivityIndicatorView:YES];
        [_avatarImageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        NSURL *avatarImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOST_URL, user.avatarImageURLString]];
        [_avatarImageView sd_setImageWithURL:avatarImageUrl placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageRefreshCached];
    }
    
    [self.tableView reloadData];
}

#pragma mark UITableview header

- (UIView *)getTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    
    // avatar imageview
    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    _avatarImageView.layer.cornerRadius = _avatarImageView.frame.size.width/2;
    _avatarImageView.layer.masksToBounds = YES;
    [headerView addSubview:_avatarImageView];
    
    // title
    _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 240 , 30)];
    _usernameLabel.text = [MCLocalization stringForKey:@"personalized_title_placeholder"];
    _usernameLabel.textColor = [UIColor whiteColor];
    _usernameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [headerView addSubview:_usernameLabel];
    
    // Sub-title
    _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, 240 , 30)];
    _emailLabel.text = [MCLocalization stringForKey:@"personalized_subtitle_placeholder"];
    _emailLabel.textColor = [UIColor whiteColor];
    _emailLabel.font = [UIFont systemFontOfSize:11.0f];
    [headerView addSubview:_emailLabel];
    
    // Separator line
    UIView *colorLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 280, 0.5)];
    colorLineView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    [headerView addSubview:colorLineView];
    
    return headerView;
}

#pragma mark - UITapGestureRecognizer

- (UITapGestureRecognizer *)tableHeaderViewRecognizer {
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.numberOfTapsRequired = 1;
    
    return singleTapRecognizer;
}

- (void)gestureHandler:(UIGestureRecognizer *)gestureRecognizer {
    UIViewController *rightSideVC = nil;
    
    if (![PREFS objectForKey:USER_INFO]) {
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
    cell.separatorView.hidden = (indexPath.row == 0);
    cell.userInteractionEnabled = (indexPath.row == self.titlesArray.count - 1);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row == self.titlesArray.count - 1) ? 22.0 : 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.titlesArray.count - 1) {
        UIViewController *rightSideVC = nil;
        if (![PREFS objectForKey:USER_INFO]) {
            rightSideVC = [[ChangeLanguageViewController alloc] initWithNibName:@"ChangeLanguageViewController" bundle:[NSBundle mainBundle]];
        }else {
            rightSideVC = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];
        }
        UINavigationController *navigationController = (UINavigationController *)self.sideMenuController.rootViewController;
        [navigationController pushViewController:rightSideVC animated:YES];
        [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
    }
}

@end
