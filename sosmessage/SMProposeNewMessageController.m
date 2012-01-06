//
//  SMProposeNewMessageController.m
//  sosmessage
//
//  Created by Arnaud K. on 05/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMProposeNewMessageController.h"
#import <QuartzCore/QuartzCore.h>

@interface SMProposeNewMessageController ()<SMMessageDelegate>
@property (assign) NSInteger selectedCategory;
@property (nonatomic, retain) SMMessagesHandler* handler;

-(void)checkDoneButton;
@end

@implementation SMProposeNewMessageController
@synthesize sendButton;
@synthesize nameTextField;
@synthesize categoryTextField;
@synthesize messageTextView;
@synthesize categoryPicker;
@synthesize categories;
@synthesize selectedCategory;
@synthesize handler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.selectedCategory = -1;
        self.handler = [[SMMessagesHandler alloc] initWithDelegate:self];
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
    
    [self checkDoneButton];
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setMessageTextView:nil];
    [self setSendButton:nil];
    [self setCategoryPicker:nil];
    [self setCategoryTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return [NSString stringWithFormat:@"%@%@", category.prepositionWithSpace, category];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedCategory = row;
    self.categoryTextField.text = [[[self.categories objectAtIndex:row] objectForKey:CATEGORY_NAME] capitalizedString];
    [self checkDoneButton];
}

#pragma mark NSMessageHandlerDelegate

- (void)startActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
}

- (void)stopActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    [MBProgressHUD hideHUDForView:self.view animated:true];
}

- (void)messageHandler:(SMMessagesHandler *)messageHandler didFinish:(id)data {
    [self dismissModalViewControllerAnimated:true];    
}

@end
