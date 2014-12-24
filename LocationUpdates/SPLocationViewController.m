//
//  ViewController.m
//  LocationUpdates
//
//  Created by Suhit on 22/12/14.
//  Copyright (c) 2014 com.suhit. All rights reserved.
//

#import "SPLocationViewController.h"
#import "LocationManager.h"
#import "WebServicesManager.h"

static NSString* const kUsernameTextFieldKey = @"UserName";
static NSString* const kUsername = @"John Doe";
static NSString* const kBackgroundSessionConfiguration = @"com.suhit.locationUpdates";

@interface SPLocationViewController () <LocationManagerUpdatesDelagte>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *locationCoordinatesLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationUpdatesLabel;

@property (strong, nonatomic) LocationManager *locationManager;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startTimeDate;
@end

@implementation SPLocationViewController

#pragma mark - ViewController Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kUsernameTextFieldKey]) {
        [[NSUserDefaults standardUserDefaults] setObject:kUsername forKey:kUsernameTextFieldKey];
    }
    self.nameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kUsernameTextFieldKey];
    
    _locationManager = [[LocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)startTimer {
    
    self.startTimeDate = [NSDate date];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(updateLastSubmitTimeData:)
                                            userInfo:nil
                                             repeats:YES];
    
}

- (void)updateLastSubmitTimeData:(NSTimer *)timer {
   
    NSInteger secondsSinceStart = (NSInteger)[[NSDate date] timeIntervalSinceDate:self.startTimeDate];
    
    //NSInteger seconds = secondsSinceStart % 60;
    NSInteger minutes = (secondsSinceStart / 60) % 60;
    NSInteger hours = secondsSinceStart / (60 * 60);
    
    if (hours > 0) {
         self.locationUpdatesLabel.text=[NSString stringWithFormat:@"Last Submited %d minutes ago",hours * 60+minutes];
    }
    else {
        self.locationUpdatesLabel.text=[NSString stringWithFormat:@"last Submited %d minutes ago",minutes];
    }
}


#pragma mark -  LocationManager delegate

- (void)updateCoordinatesWithLattitudeAndLongitude:(NSString *)coordinates {
    self.locationCoordinatesLabel.text = coordinates;
}


#pragma mark - Submit Action
/**
 *  Submit Location Coordinates to the server
 *
 *  @param sender Submit Button Object
 */
- (IBAction)submitLocationUpdate:(id)sender {
    
   NSString *dataString = [self.nameTextField.text stringByAppendingFormat:@"is now at %@",self.locationUpdatesLabel.text];
    
    WebServicesManager *manager =  [[WebServicesManager alloc] init];
    [manager submitUserLocationData:dataString success:^(id responseData) {
        [self.timer invalidate];
        [self startTimer];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Application EnterBackgroundNotification

- (void)appEnteredBackground:(NSNotification *)notification {
    
   
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        
        NSLog(@"Background Refresh Permission Denied");
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        
        NSLog(@"Background Refresh Permission Restricted");
        
    } else {
        
        NSLog(@"Application Entered Background : Send Location Data To the Server");
        NSURLSessionConfiguration *configuration = nil;
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBackgroundSessionConfiguration];
        }
        else {
        configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:kBackgroundSessionConfiguration];
        }
        configuration.allowsCellularAccess = YES;
        
        WebServicesManager *manager = [[WebServicesManager alloc] initWithSessionConfiguration:configuration];
        [manager submitUserLocationData:self.locationUpdatesLabel.text success:^(id responseData) {
            
        } failure:^(NSError *error) {
            
        }];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    textField.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    textField.backgroundColor = [UIColor lightGrayColor];
    if ([textField.text length] && ![textField.text isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kUsernameTextFieldKey];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Username cannot be empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
