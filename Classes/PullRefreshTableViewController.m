//
//  PullRefreshTableViewController.m
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Modified by Grantland Chew 12/5/11.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "PullRefreshTableViewController.h"

#define REFRESH_HEADER_HEIGHT 52.0f


@interface PullRefreshTableViewController (Private)

- (void)setupStrings;

/**
 * @abstract Add Pull To Refresh Views
 */
- (void)addPullToRefreshHeader;

/**
 * @abstract Layout Pull To Refresh Views
 */
- (void)layoutPullToRefreshHeader;

/**
 * @abstract Reference to the UIScrollView
 */
- (UIScrollView*)scrollView;

@end


@implementation PullRefreshTableViewController

@synthesize textPull=textPull_,
         textRelease=textRelease_,
         textLoading=textLoading_,
   refreshHeaderView=refreshHeaderView_,
        refreshLabel=refreshLabel_,
        refreshArrow=refreshArrow_,
      refreshSpinner=refreshSpinner_;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addPullToRefreshHeader];
    [self layoutPullToRefreshHeader];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Pull To Refresh
////////////////////////////////////////////////////////////////////////////////////////////////////

- (UIScrollView*)scrollView
{
    return self.tableView;
}

// Call in init or something
- (void)addPullToRefreshHeader
{
    [self setupStrings];
    [self scrollView].delegate = self;

    refreshHeaderView_ = [[UIView alloc] initWithFrame:CGRectZero];
    refreshHeaderView_.backgroundColor = [UIColor clearColor];

    refreshLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    refreshLabel_.backgroundColor = [UIColor clearColor];
    refreshLabel_.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel_.textAlignment = UITextAlignmentCenter;

    refreshArrow_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow_.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                     (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                     27, 44);

    refreshSpinner_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner_.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner_.hidesWhenStopped = YES;

    [refreshHeaderView_ addSubview:refreshLabel_];
    [refreshHeaderView_ addSubview:refreshArrow_];
    [refreshHeaderView_ addSubview:refreshSpinner_];
    [[self scrollView] addSubview:refreshHeaderView_];
}

// Call in layoutSubViews
- (void)layoutPullToRefreshHeader
{
    int width = [self scrollView].frame.size.width;
    refreshHeaderView_.frame = CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, width, REFRESH_HEADER_HEIGHT);
    refreshLabel_.frame = CGRectMake(0, 0, width, REFRESH_HEADER_HEIGHT);
}

- (void)setupStrings
{
    textPull_ = [[NSString alloc] initWithString:@"Pull down to refresh..."];
    textRelease_ = [[NSString alloc] initWithString:@"Release to refresh..."];
    textLoading_ = [[NSString alloc] initWithString:@"Loading..."];
}

- (void)refresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

- (void)startLoading {
    isLoading_ = YES;

    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self scrollView].contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshLabel_.text = textLoading_;
    refreshArrow_.hidden = YES;
    [refreshSpinner_ startAnimating];
    [UIView commitAnimations];

    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading_ = NO;

    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    [self scrollView].contentInset = UIEdgeInsetsZero;
    [refreshArrow_ layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshLabel_.text = textPull_;
    refreshArrow_.hidden = NO;
    [refreshSpinner_ stopAnimating];
}

- (void)ptrScrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading_) return;
    isDragging_ = YES;
}

- (void)ptrScrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading_) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            [self scrollView].contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            [self scrollView].contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging_ && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshLabel_.text = textRelease_;
            [refreshArrow_ layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            refreshLabel_.text = textPull_;
            [refreshArrow_ layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
}

- (void)ptrScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading_) return;
    isDragging_ = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)ptrDealloc
{
    [refreshHeaderView_ release];
    [refreshLabel_ release];
    [refreshArrow_ release];
    [refreshSpinner_ release];
    [textPull_ release];
    [textRelease_ release];
    [textLoading_ release];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate callbacks
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self ptrScrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self ptrScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self ptrScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)dealloc {
    [self ptrDealloc];
    [super dealloc];
}

@end
