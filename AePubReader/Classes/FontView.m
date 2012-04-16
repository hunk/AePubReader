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
@synthesize fontSize;

-(void)resetButtons {
	NSArray *buttons = [NSArray arrayWithObjects: fontNameBt1, fontNameBt2, fontNameBt3, fontNameBt4, nil];
	
	for(UIButton *bt in buttons) {
	
		
		[bt setTitleColor:[UIColor colorWithRed:0.196 green:0.310 blue:0.522 alpha:1.000] forState:UIControlStateNormal];
		
		if([bt.titleLabel.text isEqualToString:self.fontName]) {
			[bt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		}
	}
	
	[fontSizeA setEnabled:YES];
	[fontSizea setEnabled:YES];
	[fontSizeA setAlpha:1];
	[fontSizea setAlpha:1];
	if (fontSize == 200) {
		[fontSizeA setEnabled:NO];
		[fontSizeA setAlpha:.5];
	}
	if (fontSize == 50) {
		[fontSizea setEnabled:NO];
		[fontSizea setAlpha:.5];
	}

}

-(IBAction)fontSizeAction:(id)s {
	
	if (self.epubViewController.paginating) {
		return;
	}
	
	if([s tag] == 0){
		if(fontSize-25>=50){
			fontSize-=25;
			[self.epubViewController changeFontSize:fontSize];
		}
	}else{
		if(fontSize+25<=200){
			fontSize+=25;
			[self.epubViewController changeFontSize:fontSize];
		}	
	}
	
	[self resetButtons];
}


-(IBAction)fontNameAction:(id)sender{

	if (self.epubViewController.paginating) {
		return;
	}
	//if(!paginating){
	
	UIButton *bt = (UIButton*)sender;
	
	self.fontName = bt.titleLabel.text;
	[self resetButtons];
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
