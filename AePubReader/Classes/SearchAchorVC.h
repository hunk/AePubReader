//
//  SearchAchorVC.h
//  AePubReader
//
//  Created by Edgar Garcia on 15/04/12.
//  Copyright (c) 2012 Blend. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPubViewController.h"

@interface SearchAchorVC : UIViewController<UIWebViewDelegate>{

	EPubViewController* epubViewController;
	NSString* currentQuery;
	int currentChapterIndex;
}

@property (nonatomic, assign) EPubViewController* epubViewController;
@property (nonatomic, retain) NSString* currentQuery;

- (void) searchString:(NSString*)query atChapterIndex:(int)chapterIndex;

@end
