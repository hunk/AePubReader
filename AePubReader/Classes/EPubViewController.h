//
//  DetailViewController.h
//  AePubReader
//
//  Created by Federico Frappi on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZipArchive.h"
#import "EPub.h"
#import "Chapter.h"

@class SearchResultsViewController;
@class SearchResult;
@class FontView;

@interface EPubViewController : UIViewController <UIWebViewDelegate, ChapterDelegate, UISearchBarDelegate> {
    
    UIToolbar *toolbar;
        
	UIWebView *webView;
    
    UIBarButtonItem* chapterListButton;
    
    UISlider* pageSlider;
    UILabel* currentPageLabel;
			
	EPub* loadedEpub;
	int currentSpineIndex;
	int currentPageInSpineIndex;
	int pagesInCurrentSpineCount;
	int currentTextSize;
	int totalPagesCount;
	
	NSString *currentFontText;
    
    BOOL epubLoaded;
    BOOL paginating;
    BOOL searching;
    
    UIPopoverController* chaptersPopover;
    UIPopoverController* searchResultsPopover;
	UIPopoverController *fontPopover;

    SearchResultsViewController* searchResViewController;
    SearchResult* currentSearchResult;
	FontView *fontView;
	
	UIBarButtonItem* fontListButton;
}

- (IBAction) showChapterIndex:(id)sender;
- (IBAction) fontClicked:(id)sender;
- (IBAction) slidingStarted:(id)sender;
- (IBAction) slidingEnded:(id)sender;
- (IBAction) doneClicked:(id)sender;

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult;

- (void) gotoLoadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult;

- (void) loadEpub:(NSURL*) epubURL;

-(void)loadConfHTML;
-(void)saveConfHTML;
-(void)changeFont:(NSString*)fontName;
-(void)changeFontSize:(int)fontSize;

@property (nonatomic, retain) EPub* loadedEpub;

@property (nonatomic, retain) SearchResult* currentSearchResult;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *chapterListButton;

@property (nonatomic, retain) IBOutlet UISlider *pageSlider;
@property (nonatomic, retain) IBOutlet UILabel *currentPageLabel;

@property BOOL searching;
@property BOOL paginating;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *fontListButton;

@property (nonatomic,retain) NSString *currentFontText;

@end
