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
#define MISS_THRESHOLD (.5)
static char * NOTES[] = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" };

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

//Prints the names of the notes that the user missed more than a specified percentage of the time. Returns true
//if there are no frequently missed notes.
- (bool)printNotes:(ListenScore *) input {
    bool perfect = true; //no missed notes
    for(int i = 0; i < NUMNOTES * NUMOCTAVES; i++){
        if(input.playedNotes[i]){
            float missed = (float) input.missedNotes[i] / input.playedNotes[i];
            if(missed > MISS_THRESHOLD){
                //print integer instead of float; integer is precise enough for this purpose
                [self.Notes setStringValue:[NSString stringWithFormat:@"%s%d (%d %%)\n", NOTES[i % NUMNOTES],(i / NUMOCTAVES) + 1, (int)(missed * SCORETOTAL)]];
                perfect = false;
            }
        }
    }
    return perfect;
}

//Prints the interval jumps that the user missed more than a specified percentage of the time. Returns true
//if there are no frequently missed intervals.
- (bool)printIntervals:(ListenScore *) input {
    bool perfect = true; //no missed intervals
    for(int i = 0; i < NUMNOTES * NUMOCTAVES; i++){
        for(int j = 0; j < NUMNOTES * NUMOCTAVES; j++){
            if(input.playedIntervals[i][j]){
                float missed = (float) input.missedIntervals[i][j] / input.playedIntervals[i][j];
                if(missed > MISS_THRESHOLD){
                    //print integer instead of float; integer is precise enough for this purpose
                    [self.Intervals setStringValue:[NSString stringWithFormat:@"%s%d -> %s%d (%d %%)\n", NOTES[i % NUMNOTES], (i / NUMOCTAVES) + 1, NOTES[j % NUMNOTES], (j / NUMOCTAVES) + 1, (int)(missed * SCORETOTAL)]];
                    perfect = false;
                }
            }
        }
        }
    return perfect;
}

- (IBAction)Listen:(id)sender {
    int origin = self.Frequency.frame.origin.y;
    while(true){
    ListenScore * input;
    input = [list getInput];
    if(input.numInputs != 0){
        float percentAccurate = (((float) input.numAccurate)/input.numInputs) * SCORETOTAL;
        [self.Accuracy setStringValue:[NSString stringWithFormat:@"%i %%", (int)percentAccurate]]; //print integer instead of float; integer is precise enough for this purpose
        [self.Score setStringValue:[NSString stringWithFormat:@"%i / 100", (int)(input.score/input.numInputs)]]; //print integer instead of float; integer is precise enough for this purpose
        [self.NoteName setStringValue: [NSString stringWithFormat:@"%s", input.nearestNoteName]];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
        if([self printNotes: input]) [self.Notes setStringValue:@"None! Nice job! :D"];//if this is true, it means the user didn't frequently miss any notes
        if([self printIntervals: input]) [self.Intervals setStringValue:@"None! Nice job! :D"]; //if this is true, it means the user didn't frequently miss any intervals
        CGRect frame = self.Frequency.frame;
        frame.origin.y = origin + (input.centsSharp * 1.3);
        self.Frequency.frame = frame;
    }
    
}
    
    //set intervals at end
}


@end
