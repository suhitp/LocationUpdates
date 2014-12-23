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

@interface SPLocationViewController () <LocationManagerUpdatesDelagte>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *locationCoordinatesLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationUpdatesLabel;

@property (strong, nonatomic) LocationManager *locationManager;

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
        
    } failure:^(NSError *error) {
        
    }];
    
    
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

@end
