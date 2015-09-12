//
//  ViewController.h
//  Dino
//
//  Created by Lucy  on 9/7/15.
//  Copyright (c) 2015 Lucy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSTextField *Accuracy;
@property (weak) IBOutlet NSTextField *Score;
@property (weak) IBOutlet NSScrollView *Notes;
@property (weak) IBOutlet NSScrollView *Intervals;
@property (weak) IBOutlet NSTextField *NoteName;
@property (weak) IBOutlet NSColorWell *Pitch;

- (IBAction)Listen:(id)sender;


@end

