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
    self.btnBack.titleLabel.font = BARS_FONT;
    self.btnOtherApp.titleLabel.font = BARS_FONT;
    self.lblAbout.font = BARS_FONT;
}

- (void)viewDidUnload
{
    [self setOurMessage:nil];
    [self setLblAbout:nil];
    [self setBtnBack:nil];
    [self setBtnOtherApp:nil];
    [self setLblAketomic:nil];
    [self setBtnAketomic:nil];
    [self setLblLkemen:nil];
    [self setBtnLkemen:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Resize lkemen / aketomic btns
    [self moveButton:self.btnAketomic besideLabel:self.lblAketomic];
    [self moveButton:self.btnLkemen besideLabel:self.lblLkemen];
}

-(void)moveButton:(UIButton *)btn besideLabel:(UILabel *)label {
    CGSize strSize = [label.text sizeWithFont:label.font];
    btn.center = CGPointMake(label.center.x + (strSize.width / 2) - (btn.frame.size.width / 2), label.center.y);
    NSLog(@"lbl: %.2f:%.2f Btn: %.2f:%.2f", label.center.x, label.center.y, btn.center.x, btn.center.y);
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
    [_lblAbout release];
    [_btnBack release];
    [_btnOtherApp release];
    [_lblAketomic release];
    [_btnAketomic release];
    [_lblLkemen release];
    [_btnLkemen release];
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

- (IBAction)facebookPressed:(id)sender {
    NSURL *facebookURL = [NSURL URLWithString: SM_FACEBOOK_ID];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SM_FACEBOOK_URL]];
    }
}

- (IBAction)aketomicTwitterPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: AKETOMIC_TWITTER]];
}

- (IBAction)liseTwitterPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: LISE_TWITTER]];
}

@end