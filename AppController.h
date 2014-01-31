//
//  AppController.h
//  Shoot Ball into Ring
//
//  Created by Randall Maas on 2014-1-25
//  Copyright 2014 Randall Maas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AppController : NSObject 
{
	IBOutlet NSWindow	*visWindow;
	IBOutlet QCView				*visView;
    NSTimer* timer;
}

- (void) applicationWillFinishLaunching:(NSNotification*)notification;
@end
