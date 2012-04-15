//
//  FontView.m
//  AePubReader
//
//  Created by Edgar Garcia on 14/04/12.
//  Copyright (c) 2012 Blend. All rights reserved.
//

#import "FontView.h"

@interface FontView ()

@end

@implementation FontView

@synthesize fontName;
@synthesize epubViewController;

-(void)resetButtonsTextColors {
	NSArray *buttons = [NSArray arrayWithObjects: fontNameBt1, fontNameBt2, fontNameBt3, fontNameBt4, nil];
	
	for(UIButton *bt in buttons) {
		if([bt.titleLabel.text isEqualToString:self.fontName]) {
            bt.alpha = 1;
		}
		else {
			bt.alpha = .5;
		}
	}
	
	NSLog(@"la actual fuente es %@",self.fontName);
}


-(IBAction)fontNameAction:(id)sender{

	UIButton *bt = (UIButton*)sender;
	NSLog(@"selecciono %@",bt.titleLabel.text);
	
	self.fontName = bt.titleLabel.text;
	[self resetButtonsTextColors];
	[self.epubViewController changeFont:self.fontName];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
