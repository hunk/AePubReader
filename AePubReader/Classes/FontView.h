//
//  FontView.h
//  AePubReader
//
//  Created by Edgar Garcia on 14/04/12.
//  Copyright (c) 2012 Blend. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPubViewController.h"

@interface FontView : UIViewController{

	IBOutlet UIButton *fontNameBt1;
	IBOutlet UIButton *fontNameBt2;
	IBOutlet UIButton *fontNameBt3;
	IBOutlet UIButton *fontNameBt4;
	
	NSString *fontName;
	
	EPubViewController* epubViewController;
}

@property (nonatomic,retain) IBOutlet NSString *fontName;
@property(nonatomic, assign) EPubViewController* epubViewController;

-(IBAction)fontNameAction:(id)sender;

-(void)resetButtonsTextColors;

@end
