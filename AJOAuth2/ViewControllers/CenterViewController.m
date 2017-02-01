//
//  CenterViewController.m
//

#import "CenterViewController.h"
#import "UIViewController+LGSideMenuController.h"
#import "MCLocalization.h"

@interface CenterViewController ()

@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation CenterViewController

#pragma mark View-Life Cycle

- (id)init {
    self = [super init];
    if (self) {
        // Center Navigation title
        self.title = [MCLocalization stringForKey:@"center_navigation_title"];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[MCLocalization stringForKey:@"BACK_BAR_BUTTON_ITEM_TITLE"] style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backBarButtonItem;
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        // Background Image
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageRoot"]];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.view addSubview:self.imageView];
        
        // Left Bar Button Item image
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(showLeftView)];
    }
    
    return self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.imageView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
}

#pragma mark - LGSlider

- (void)showLeftView {
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
    [self.sideMenuController.leftViewController viewWillAppear:YES];
}

@end
