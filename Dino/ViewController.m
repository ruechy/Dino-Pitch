//
//  ViewController.m
//  Dino
//
//  Created by Lucy  on 9/7/15.
//  Copyright (c) 2015 Lucy. All rights reserved.
//

#import "ViewController.h"
#import "Listener.h"
#import "ListenScore.h"

#define SCORETOTAL 100

Listener * list;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    list = [[Listener alloc] init];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}


- (IBAction)Listen:(id)sender {
    while(true){
    ListenScore * input;
    input = [list getInput];
    if(input.numInputs != 0){
        float percentAccurate = (((float) input.numAccurate)/input.numInputs) * SCORETOTAL;
        [self.Accuracy setStringValue:[NSString stringWithFormat:@"%i %%", (int)percentAccurate]]; //print integer instead of float; integer is precise enough for this purpose
        [self.Score setStringValue:[NSString stringWithFormat:@"%i / 100", (int)(input.score/input.numInputs)]]; //print integer instead of float; integer is precise enough for this purpose
        [self.NoteName setStringValue: [NSString stringWithFormat:@"%s", input.nearestNoteName]];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
    }
    }
    
    //set intervals at end
}


@end
