//
//  DetailViewController.m
//  AePubReader
//
//  Created by Federico Frappi on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EPubViewController.h"
#import "ChapterListViewController.h"
#import "SearchResultsViewController.h"
#import "SearchResult.h"
#import "UIWebView+SearchWebView.h"
#import "Chapter.h"

#import "FontView.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchAchorVC.h"

@interface EPubViewController()


- (void) gotoNextSpine;
- (void) gotoPrevSpine;
- (void) gotoNextPage;
- (void) gotoPrevPage;

- (int) getGlobalPageCount;

- (void) gotoPageInCurrentSpine: (int)pageIndex;
- (void) updatePagination;

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex;

-(void)loadConfHTML;
-(void)saveConfHTML;

@end

@implementation EPubViewController

@synthesize loadedEpub, toolbar, webView; 
@synthesize chapterListButton;
@synthesize currentPageLabel, pageSlider, searching;
@synthesize currentSearchResult;
@synthesize fontListButton,currentFontText;
@synthesize paginating;

#pragma mark -

- (void) loadEpub:(NSURL*) epubURL{
			[self loadConfHTML];
    pagesInCurrentSpineCount = 0;
    totalPagesCount = 0;
	searching = NO;
    epubLoaded = NO;
    self.loadedEpub = [[EPub alloc] initWithEPubPath:[epubURL path]];
    epubLoaded = YES;
    NSLog(@"loadEpub");

	[self updatePagination];
}

- (void) chapterDidFinishLoad:(Chapter *)chapter{
    totalPagesCount+=chapter.pageCount;

	if(chapter.chapterIndex + 1 < [loadedEpub.spineArray count]){
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] setDelegate:self];
		//[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize];
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize fontFamily:currentFontText];
		[currentPageLabel setText:[NSString stringWithFormat:@"?/%d", totalPagesCount]];
	} else {
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
		paginating = NO;
		NSLog(@"Pagination Ended!");
	}
}

- (int) getGlobalPageCount{
	int pageCount = 0;
	for(int i=0; i<currentSpineIndex; i++){
		pageCount+= [[loadedEpub.spineArray objectAtIndex:i] pageCount]; 
	}
	pageCount+=currentPageInSpineIndex+1;
	return pageCount;
}

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex {
	[self loadSpine:spineIndex atPageIndex:pageIndex highlightSearchResult:nil];
}

- (void) gotoLoadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult{
	
	int dir = 0;
	
	if (spineIndex < currentSpineIndex) {
		//right
		dir = -1;
	}else if (spineIndex > currentSpineIndex) {
		// left
		dir = 1;
	}else {
		if (pageIndex < currentPageInSpineIndex) {
			//right
			dir = -1;
		}else if (pageIndex > currentPageInSpineIndex) {
			//left
			dir = 1;
		}
	}
	
	if (dir == 1) {
		CATransition *transition = [CATransition animation];
		[transition setDelegate:self];
		[transition setDuration:0.5f];
		[transition setType:@"pageCurl"];
		[transition setSubtype:@"fromRight"];
		[self.view.layer addAnimation:transition forKey:@"CurlAnim"];
	}else if (dir == -1) {
		CATransition *transition = [CATransition animation];
		[transition setDelegate:self];
		[transition setDuration:0.5f];
		[transition setType:@"pageUnCurl"];
		[transition setSubtype:@"fromRight"];
		[self.view.layer addAnimation:transition forKey:@"UnCurlAnim"];
	}
	
	[self loadSpine:spineIndex atPageIndex:pageIndex highlightSearchResult:theResult];
	
}

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult{
	
	webView.hidden = YES;
	
	self.currentSearchResult = theResult;

	[chaptersPopover dismissPopoverAnimated:YES];
	[searchResultsPopover dismissPopoverAnimated:YES];
	
	NSURL* url = [NSURL fileURLWithPath:[[loadedEpub.spineArray objectAtIndex:spineIndex] spinePath]];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	currentPageInSpineIndex = pageIndex;
	currentSpineIndex = spineIndex;
	if(!paginating){
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];	
	}
}

- (void) gotoPageInCurrentSpine:(int)pageIndex{
	if(pageIndex>=pagesInCurrentSpineCount){
		pageIndex = pagesInCurrentSpineCount - 1;
		currentPageInSpineIndex = pagesInCurrentSpineCount - 1;	
	}
	
	float pageOffset = pageIndex*webView.bounds.size.width;

	NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
	NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
	
	[webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
	[webView stringByEvaluatingJavaScriptFromString:goTo];
	
	if(!paginating){
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];	
	}
	
	webView.hidden = NO;
	[self saveConfHTML];
	
	NSLog(@"aqui uno");
}

- (void) gotoNextSpine {
	if(!paginating){
		if(currentSpineIndex+1<[loadedEpub.spineArray count]){
			[self loadSpine:++currentSpineIndex atPageIndex:0];
			CATransition *transition = [CATransition animation];
			[transition setDelegate:self];
			[transition setDuration:0.5f];
			[transition setType:@"pageCurl"];
			[transition setSubtype:@"fromRight"];
			[self.view.layer addAnimation:transition forKey:@"CurlAnim"];
		}	
	}
}

- (void) gotoPrevSpine {
	if(!paginating){
		if(currentSpineIndex-1>=0){
			NSLog(@"re");
			[self loadSpine:--currentSpineIndex atPageIndex:0];
		}	
	}
}

- (void) gotoNextPage {
	if(!paginating){
		if(currentPageInSpineIndex+1<pagesInCurrentSpineCount){
			[self gotoPageInCurrentSpine:++currentPageInSpineIndex];
			CATransition *transition = [CATransition animation];
			[transition setDelegate:self];
			[transition setDuration:0.5f];
			[transition setType:@"pageCurl"];
			[transition setSubtype:@"fromRight"];
			[self.view.layer addAnimation:transition forKey:@"CurlAnim"];
		} else {
			[self gotoNextSpine];
		}		
	}
}

- (void) gotoPrevPage {
	if (!paginating) {
		if(currentPageInSpineIndex-1>=0){ NSLog(@"uno");
			CATransition *transition = [CATransition animation];
			[transition setDelegate:self];
			[transition setDuration:0.5f];
			[transition setType:@"pageUnCurl"];
			[transition setSubtype:@"fromRight"];
			[self.view.layer addAnimation:transition forKey:@"UnCurlAnim"];
			[self gotoPageInCurrentSpine:--currentPageInSpineIndex];
			
		} else {
			if(currentSpineIndex!=0){ NSLog(@"dos");
				CATransition *transition = [CATransition animation];
				[transition setDelegate:self];
				[transition setDuration:0.5f];
				[transition setType:@"pageUnCurl"];
				[transition setSubtype:@"fromRight"];
				[self.view.layer addAnimation:transition forKey:@"UnCurlAnim"];
				int targetPage = [[loadedEpub.spineArray objectAtIndex:(currentSpineIndex-1)] pageCount];
				[self loadSpine:--currentSpineIndex atPageIndex:targetPage-1];
			}
		}
	}
}

-(void)changeFontSize:(int)fontSize{
	currentTextSize = fontSize;
	[self updatePagination];
	[self saveConfHTML];
}

- (IBAction) doneClicked:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction) slidingStarted:(id)sender{
    int targetPage = ((pageSlider.value/(float)100)*(float)totalPagesCount);
    if (targetPage==0) {
        targetPage++;
    }
	[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d", targetPage, totalPagesCount]];
}

- (IBAction) slidingEnded:(id)sender{
	int targetPage = (int)((pageSlider.value/(float)100)*(float)totalPagesCount);
    if (targetPage==0) {
        targetPage++;
    }
	int pageSum = 0;
	int chapterIndex = 0;
	int pageIndex = 0;
	for(chapterIndex=0; chapterIndex<[loadedEpub.spineArray count]; chapterIndex++){
		pageSum+=[[loadedEpub.spineArray objectAtIndex:chapterIndex] pageCount];
//		NSLog(@"Chapter %d, targetPage: %d, pageSum: %d, pageIndex: %d", chapterIndex, targetPage, pageSum, (pageSum-targetPage));
		if(pageSum>=targetPage){
			pageIndex = [[loadedEpub.spineArray objectAtIndex:chapterIndex] pageCount] - 1 - pageSum + targetPage;
			break;
		}
	}
	//[self loadSpine:chapterIndex atPageIndex:pageIndex];
	[self gotoLoadSpine:chapterIndex atPageIndex:pageIndex highlightSearchResult:nil];
}

- (IBAction) showChapterIndex:(id)sender{
	if(chaptersPopover==nil){
		ChapterListViewController* chapterListView = [[ChapterListViewController alloc] initWithNibName:@"ChapterListViewController" bundle:[NSBundle mainBundle]];
		[chapterListView setEpubViewController:self];
		chaptersPopover = [[UIPopoverController alloc] initWithContentViewController:chapterListView];
		[chaptersPopover setPopoverContentSize:CGSizeMake(400, 600)];
		[chapterListView release];
	}
	if ([chaptersPopover isPopoverVisible]) {
		[chaptersPopover dismissPopoverAnimated:YES];
	}else{
		[chaptersPopover presentPopoverFromBarButtonItem:chapterListButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];		
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		
        //path to called chapter
        NSURL *url = [request  URL];
		
		NSString *newChapterURL = [url path];
		NSString *achor = [url fragment];

		if (achor) {

			int indexNewChapter = -1;
			NSString *path;
		
			for (int i=0; i<loadedEpub.spineArray.count & indexNewChapter == -1; i++) {
			
				path = ((Chapter*)[loadedEpub.spineArray objectAtIndex:i]).spinePath;
			
				if([path isEqualToString:newChapterURL]){
					indexNewChapter = i;
				}
			}

			SearchAchorVC *svc = [[SearchAchorVC alloc] init];
			svc.epubViewController = self;
			[svc searchString:url.fragment atChapterIndex:indexNewChapter];
		
			return NO;
		}
    }
	
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView{
	
	NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
	
	NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
	"if (mySheet.addRule) {"
	"mySheet.addRule(selector, newRule);"								// For Internet Explorer
	"} else {"
	"ruleIndex = mySheet.cssRules.length;"
	"mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
	"}"
	"}";
	
	NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %fpx; -webkit-column-gap: 0px; -webkit-column-width: %fpx;')", webView.frame.size.height, webView.frame.size.width];
	NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
	NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')", currentTextSize];
	NSString *setFontFamilyRule = [NSString stringWithFormat:@"addCSSRule('body', 'font-family:\"%@\" !important;')", currentFontText];
	NSString *setHighlightColorRule = [NSString stringWithFormat:@"addCSSRule('highlight', 'background-color: yellow;')"];
	
	NSString *setImageRule = [NSString stringWithFormat:@"addCSSRule('img', 'max-width: %fpx; height:auto;')", self.webView.frame.size.width *0.75];

	
	[webView stringByEvaluatingJavaScriptFromString:varMySheet];
	
	[webView stringByEvaluatingJavaScriptFromString:addCSSRule];
		
	[webView stringByEvaluatingJavaScriptFromString:insertRule1];
	
	[webView stringByEvaluatingJavaScriptFromString:insertRule2];
	
	[webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
	
	[webView stringByEvaluatingJavaScriptFromString:setFontFamilyRule];
	
	[webView stringByEvaluatingJavaScriptFromString:setHighlightColorRule];
	
	[webView stringByEvaluatingJavaScriptFromString:setImageRule];
	
	if(currentSearchResult!=nil){
	//	NSLog(@"Highlighting %@", currentSearchResult.originatingQuery);
        [webView highlightAllOccurencesOfString:currentSearchResult.originatingQuery];
	}
	
	
	int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
	
	[webView stringByEvaluatingJavaScriptFromString:insertRule1];
	
	totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
	
	if (webView.scrollView.contentSize.height != webView.frame.size.height) {
		[self loadSpine:currentSpineIndex atPageIndex:currentPageInSpineIndex];
	}else {
	
		pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);
		[self gotoPageInCurrentSpine:currentPageInSpineIndex];
	}
}

- (void) updatePagination{
	if(epubLoaded){
        if(!paginating){
            NSLog(@"Pagination Started!");
            paginating = YES;
            totalPagesCount=0;
            [self loadSpine:currentSpineIndex atPageIndex:currentPageInSpineIndex];
            [[loadedEpub.spineArray objectAtIndex:0] setDelegate:self];
            //[[loadedEpub.spineArray objectAtIndex:0] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize];
			[[loadedEpub.spineArray objectAtIndex:0] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize fontFamily:currentFontText];
            [currentPageLabel setText:@"?/?"];
        }
	}
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	if(searchResultsPopover==nil){
		searchResultsPopover = [[UIPopoverController alloc] initWithContentViewController:searchResViewController];
		[searchResultsPopover setPopoverContentSize:CGSizeMake(400, 600)];
	}
	if (![searchResultsPopover isPopoverVisible]) {
		[searchResultsPopover presentPopoverFromRect:searchBar.bounds inView:searchBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
//	NSLog(@"Searching for %@", [searchBar text]);
	if(!searching){
		searching = YES;
		[searchResViewController searchString:[searchBar text]];
        [searchBar resignFirstResponder];
	}
}

- (IBAction) fontClicked:(id)sender{

	if (fontPopover == nil) {
		
		if (fontView == nil) {
			fontView = [[FontView alloc] initWithNibName:@"FontView" bundle:nil];
			[fontView setEpubViewController:self];
		}
		
		fontPopover = [[UIPopoverController alloc] initWithContentViewController:fontView];
		[fontPopover setPopoverContentSize:CGSizeMake(200, 300)];
	}
	
	if (![fontPopover isPopoverVisible]) {
	
		[fontView setFontName:currentFontText];
		[fontView setFontSize:currentTextSize];
		[fontView resetButtons];
		
		[fontPopover presentPopoverFromBarButtonItem:fontListButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

-(void)changeFont:(NSString*)fontName{
	
	currentFontText = fontName;
	[self updatePagination];
	[self saveConfHTML];

	NSLog(@"la actual fuente %@",currentFontText);
}

-(void)saveConfHTML{
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setInteger:currentTextSize forKey:@"fontSize"];
	[defs setObject:currentFontText forKey:@"fontName"];
	[defs setInteger:currentSpineIndex forKey:@"currentSpineIndex"];
	[defs setInteger:currentPageInSpineIndex forKey:@"currentPageInSpineIndex"];
	[defs synchronize];
}

-(void)loadConfHTML{
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	
	int fSize = [defs integerForKey:@"fontSize"];
	
	if(fSize) {
		currentTextSize = fSize;
	}
	
	NSString *fName = [defs stringForKey:@"fontName"];
	
	if (fName) {
		currentFontText = fName;
	}
	
	int cSpineIndex = [defs integerForKey:@"currentSpineIndex"];
	
	if(cSpineIndex) {
		currentSpineIndex = cSpineIndex;
	}
	
	int cPageInSpineIndex = [defs integerForKey:@"currentPageInSpineIndex"];
	
	if(cPageInSpineIndex) {
		currentPageInSpineIndex = cPageInSpineIndex;
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	float x = [((UITouch*)[touches anyObject]) locationInView:self.view].x;
	
	if(x < 150){
		//touch to the left
		[self gotoPrevPage];
	}else {
		//touch to the right
		[self gotoNextPage];
	}
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"shouldAutorotate");
    [self updatePagination];
	return YES;
}

#pragma mark -
#pragma mark View lifecycle

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[webView setDelegate:self];
	
	webView.opaque = NO;
		
	UIScrollView* sv = nil;
	for (UIView* v in  webView.subviews) {
		if([v isKindOfClass:[UIScrollView class]]){
			sv = (UIScrollView*) v;
			sv.scrollEnabled = NO;
			sv.bounces = NO;
		}
	}
	currentTextSize = 100;
	currentFontText = @"Times New Roman";
	currentSpineIndex = 0;
    currentPageInSpineIndex = 0;
	
	
	UISwipeGestureRecognizer* rightSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextPage)] autorelease];
	[rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	
	UISwipeGestureRecognizer* leftSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPrevPage)] autorelease];
	[leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
	
	[webView addGestureRecognizer:rightSwipeRecognizer];
	[webView addGestureRecognizer:leftSwipeRecognizer];
	
	[pageSlider setThumbImage:[UIImage imageNamed:@"slider_ball.png"] forState:UIControlStateNormal];
	[pageSlider setMinimumTrackImage:[[UIImage imageNamed:@"orangeSlide.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
	[pageSlider setMaximumTrackImage:[[UIImage imageNamed:@"yellowSlide.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
    
	searchResViewController = [[SearchResultsViewController alloc] initWithNibName:@"SearchResultsViewController" bundle:[NSBundle mainBundle]];
	searchResViewController.epubViewController = self;
}

- (void)viewDidUnload {
	self.toolbar = nil;
	self.webView = nil;
	self.chapterListButton = nil;
	self.pageSlider = nil;
	self.currentPageLabel = nil;	
}


#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)dealloc {
    self.toolbar = nil;
	self.webView = nil;
	self.chapterListButton = nil;
	self.pageSlider = nil;
	self.currentPageLabel = nil;
	[loadedEpub release];
	[chaptersPopover release];
	[searchResultsPopover release];
	[searchResViewController release];
	[currentSearchResult release];
    [super dealloc];
}

@end
