//
//  SearchAchorVC.m
//  AePubReader
//
//  Created by Edgar Garcia on 15/04/12.
//  Copyright (c) 2012 Blend. All rights reserved.
//

#import "SearchAchorVC.h"
#import "UIWebView+SearchWebView.h"

@interface SearchAchorVC ()
	
- (void) searchString:(NSString *)query inChapterAtIndex:(int)index;

@end

@implementation SearchAchorVC

@synthesize epubViewController, currentQuery;

- (void) searchString:(NSString*)query atChapterIndex:(int)chapterIndex{

    self.currentQuery=query;
	currentChapterIndex = chapterIndex;
    
    [self searchString:query inChapterAtIndex:currentChapterIndex];    
}

- (void) searchString:(NSString *)query inChapterAtIndex:(int)index{
    
    currentChapterIndex = index;
    
    Chapter* chapter = [epubViewController.loadedEpub.spineArray objectAtIndex:index];
	UIWebView* webView = [[UIWebView alloc] initWithFrame:chapter.windowSize];
	[webView setDelegate:self];
	NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:chapter.spinePath]];
	[webView loadRequest:urlRequest];   

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@", error);
	[webView release];
}

- (void) webViewDidFinishLoad:(UIWebView*)webView{
    NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
	
	NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
	"if (mySheet.addRule) {"
    "mySheet.addRule(selector, newRule);"								// For Internet Explorer
	"} else {"
    "ruleIndex = mySheet.cssRules.length;"
    "mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
    "}"
	"}";
	
	//    NSLog(@"w:%f h:%f", webView.bounds.size.width, webView.bounds.size.height);
	
	NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %fpx; -webkit-column-gap: 0px; -webkit-column-width: %fpx;')", webView.frame.size.height, webView.frame.size.width];
	NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
	NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')",[[epubViewController.loadedEpub.spineArray objectAtIndex:currentChapterIndex] fontPercentSize]];
    
	NSString *setFontFamilyRule = [NSString stringWithFormat:@"addCSSRule('body', 'font-family:\"%@\" !important;')", epubViewController.currentFontText];
	
	NSString *setImageRule = [NSString stringWithFormat:@"addCSSRule('img', 'max-width: %fpx; height:auto;')", webView.frame.size.width *0.75];
	
	[webView stringByEvaluatingJavaScriptFromString:varMySheet];
	
	[webView stringByEvaluatingJavaScriptFromString:addCSSRule];
    
	[webView stringByEvaluatingJavaScriptFromString:insertRule1];
	
	[webView stringByEvaluatingJavaScriptFromString:insertRule2];
	
    [webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
	
	[webView stringByEvaluatingJavaScriptFromString:setFontFamilyRule];
	
	[webView stringByEvaluatingJavaScriptFromString:setImageRule];
    
    [webView searchAchor:currentQuery];
    
    NSString* foundHit = [webView stringByEvaluatingJavaScriptFromString:@"results"];
    
	if (foundHit) {
		//found!!
		int y = [foundHit intValue];
		int page = y/webView.bounds.size.height;
		[epubViewController gotoLoadSpine:currentChapterIndex atPageIndex:page highlightSearchResult:nil];

	}else {
		[epubViewController gotoLoadSpine:currentChapterIndex atPageIndex:0 highlightSearchResult:nil];
	}
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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
