//
//  SMAboutViewController.m
//  sosmessage
//
//  Created by Arnaud K. on 26/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SMAboutViewController.h"

@interface SMAboutViewController() <MFMailComposeViewControllerDelegate>

@end

@implementation SMAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.ourMessage.font = MESSAGE_FONT;
}

- (void)viewDidUnload
{
    [self setOurMessage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_ourMessage release];
    [super dealloc];
}

- (IBAction)backPressed:(id)sender {
    [self dismissModalViewControllerAnimated:true];
}

- (IBAction)otherAppsPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: SM_ABOUT]];
}

- (IBAction)mailPressed:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
    [mailController setToRecipients:@[SM_EMAIL]];
    [mailController setDefinesPresentationContext:YES];
    mailController.mailComposeDelegate = self;
    [self presentModalViewController:mailController animated:YES];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:YES];
}

- (IBAction)twitterPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: SM_TWITTER]];
}
@end