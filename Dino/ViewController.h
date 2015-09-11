//
//  ViewController.h
//  Dino
//
//  Created by Lucy  on 9/7/15.
//  Copyright (c) 2015 Lucy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (strong, nonatomic) IBOutlet NSTextField *Accuracy;
@property (strong, nonatomic) IBOutlet NSTextField *Score;
@property (strong, nonatomic) IBOutlet NSScrollView *Notes;
@property (strong, nonatomic) IBOutlet NSScrollView *Intervals;
- (IBAction)Listen:(id)sender;


@end

