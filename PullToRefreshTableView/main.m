//
//  main.m
//  PullToRefresh
//
//  Created by Leah Culver on 7/25/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainAppDelegate.h"

int main(int argc, char *argv[]) {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([MainAppDelegate class]));
    [pool release];
    return retVal;
}
