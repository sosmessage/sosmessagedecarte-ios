//
//  SMProposeNewMessageController.m
//  sosmessage
//
//  Created by Arnaud K. on 05/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMProposeNewMessageController.h"
#import <QuartzCore/QuartzCore.h>

@interface SMProposeNewMessageController ()<SMMessageDelegate, UIAlertViewDelegate>

@property (assign) NSInteger selectedCategory;
@property (nonatomic, retain) SMMessagesHandler* handler;

- (void)checkDoneButton;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
@end

@implementation SMProposeNewMessageController
@synthesize sendButton;
@synthesize nameTextField;
@synthesize categoryTextField;
@synthesize messageTextView;
@synthesize categoryPicker;
@synthesize scrollView;
@synthesize categories;
@synthesize selectedCategory;
@synthesize handler;

bool keyboardVisible = false;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.selectedCategory = -1;
        self.handler = [[[SMMessagesHandler alloc] initWithDelegate:self] autorelease];
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
    // Do any additional setup after loading the view from its nib.
    self.messageTextView.layer.borderColor = [[UIColor colorWithWhite:.5 alpha:1.0] CGColor];
    self.messageTextView.layer.cornerRadius = 6.0;
    self.messageTextView.layer.borderWidth = 1.5;
    self.messageTextView.clipsToBounds = true;
    
    self.scrollView.contentSize = self.scrollView.frame.size;
    
    [self checkDoneButton];
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setMessageTextView:nil];
    [self setSendButton:nil];
    [self setCategoryPicker:nil];
    [self setCategoryTextField:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)selectCategory:(id)sender {
    self.categoryPicker.hidden = false;
    [self.categoryPicker resignFirstResponder];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.categoryTextField resignFirstResponder];
    [self checkDoneButton];
}

- (IBAction)cancelPushed:(id)sender {
    NSLog(@"Cancel button pushed.");
    [self dismissModalViewControllerAnimated:true];
}

- (IBAction)sendPushed:(id)sender {
    NSLog(@"Send button pushed.");
    NSString* categoryId = [[self.categories objectAtIndex:self.selectedCategory] objectForKey:CATEGORY_ID];
    [self.handler requestProposeMessage:self.messageTextView.text author:self.nameTextField.text category:categoryId];
}

- (IBAction)showPicker:(id)sender {
    UIPickerView* pickerView = [[UIPickerView alloc] init];
    [pickerView sizeToFit];
    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = true;
    
    self.categoryTextField.inputView = pickerView;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem* doneButton = [[[UIBarButtonItem alloc] initWithTitle:@"Ok" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissKeyboard:)] autorelease];
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.categoryTextField.inputAccessoryView = keyboardDoneButtonView;
    
    [pickerView release];
    [keyboardDoneButtonView release];
}

-(void)checkDoneButton {
    self.sendButton.enabled = selectedCategory >= 0;
}

- (void)dealloc {
    [nameTextField release];
    [messageTextView release];
    [sendButton release];
    [categoryPicker release];
    [categoryTextField release];
    [scrollView release];
    [super dealloc];
}

#pragma mark - UIPickerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.categories count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString* category = [[self.categories objectAtIndex:row] objectForKey:CATEGORY_NAME];
    return [NSString stringWithFormat:@"%@", category];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedCategory = row;
    self.categoryTextField.text = [[[self.categories objectAtIndex:row] objectForKey:CATEGORY_NAME] capitalizedString];
    [self checkDoneButton];
}

#pragma mark NSMessageHandlerDelegate

- (void)startActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    hud.labelText = kmessage_propose_sending;
}

- (void)stopActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    [MBProgressHUD hideHUDForView:self.view animated:true];
}

- (void)messageHandler:(SMMessagesHandler *)messageHandler didFinish:(id)data {
    NSLog(@"Status code: %d", messageHandler.lastStatusCode);
    if (messageHandler.lastStatusCode == 200) {
        [[[UIAlertView new] initWithTitle:kmessage_propose_thanks_title message:kmessage_propose_thanks delegate:self cancelButtonTitle:nil otherButtonTitles:klabel_btn_ok, nil] show];
    }
}

#pragma mark handle keyboard resizing
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissModalViewControllerAnimated:true];
}

@end
