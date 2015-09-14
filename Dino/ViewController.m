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

//Initialize every index in the most missed array to -1. 
void initMostMissed(int* mostMissed){
    for(int i = 0; i < 5; i++){
        mostMissed[i] = -1;
    }
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    list = [[Listener alloc] init];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

//Prints the names of the notes that the user missed more than a specified percentage of the time. Returns true
//if there are no frequently missed notes.
- (bool)printNotes:(ListenScore *) input {
    [self.Notes setStringValue: @""];
    bool perfect = true; //no missed notes
    int mostMissed[5]; //keeps track of indices of top 5 most missed notes
    int mostMissedNPlayed[5]; //keeps track of how often each of the most missed notes have been played
    initMostMissed(mostMissed);
    float missed = 0.;
    for(int i = 0; i < NUMNOTES * NUMOCTAVES; i++){
        if(input.playedNotes[i] > 5){
            missed = (float) input.missedNotes[i] / input.playedNotes[i];
            if(missed > MISS_THRESHOLD){
                for(int j = 0; j < 5; j++){
                    if(input.playedNotes[i] > mostMissedNPlayed[j]){
                        for(int k = 4; k > j; k--){
                            mostMissed[k] = mostMissed[k-1];
                            mostMissedNPlayed[k] = input.playedNotes[k-1];
                        }
                        mostMissed[j] = i;
                        mostMissedNPlayed[j] = input.playedNotes[i];
                        break;
                    }
                }
                perfect = false;
            }
        }
    }
    for(int i = 0; i < 5; i++){
        if(mostMissed[i] > 0){
            [self.Notes setStringValue:[NSString stringWithFormat:@"%s%d (%d %%)\n%@", NOTES[mostMissed[i] / NUMNOTES],(mostMissed[i] / NUMOCTAVES) + 1, SCORETOTAL - (int)(((float) input.missedNotes[mostMissed[i]] / input.playedNotes[mostMissed[i]]) * SCORETOTAL), self.Notes.stringValue]]; //print integer instead of float; integer is precise enough for this purpose
        }
    }
    return perfect;
}


- (void)printTopFive:(int*) mostMissedNoteOne: (int*) mostMissedNoteTwo: (ListenScore *) input{
    for(int i = 0; i < 5; i++){
        if(mostMissedNoteOne[i] > 0){
            float missed = (float) input.missedIntervals[mostMissedNoteOne[i]][mostMissedNoteTwo[i]] / input.playedIntervals[mostMissedNoteOne[i]][mostMissedNoteTwo[i]];
            [self.Intervals setStringValue:[NSString stringWithFormat:@"%s%d -> %s%d (%d %%)\n%@", NOTES[mostMissedNoteOne[i] / NUMNOTES], (mostMissedNoteOne[i] / NUMOCTAVES) + 1, NOTES[mostMissedNoteTwo[i] / NUMNOTES], (mostMissedNoteTwo[i] / NUMOCTAVES) + 1, SCORETOTAL -(int)(missed * SCORETOTAL), self.Intervals.stringValue]];//print integer instead of float; integer is precise enough for this purpose
        }
    }
}

//Prints the interval jumps that the user missed more than a specified percentage of the time. Returns true
//if there are no frequently missed intervals.
- (bool)printIntervals:(ListenScore *) input {
    [self.Intervals setStringValue: @""];
    bool perfect = true; //no missed notes
    int mostMissedNoteOne[5]; //keeps track of indices first notes of of top 5 most missed intervals
    int mostMissedNoteTwo[5]; //keeps track of indices first notes of of top 5 most missed intervals
    int mostMissedNPlayed[5]; //keeps track of how often each of the most missed notes have been played
    initMostMissed(mostMissedNoteOne);
    initMostMissed(mostMissedNoteOne);
    float missed = 0.;
    for(int i = 0; i < NUMNOTES * NUMOCTAVES; i++){
        for(int l = 0; l < NUMNOTES * NUMOCTAVES; l++){
        if(input.playedIntervals[i][l] > 5){
            missed = (float) input.missedIntervals[i][l] / input.playedIntervals[i][l];
            if(missed > MISS_THRESHOLD){
                for(int j = 0; j < 5; j++){
                    if(input.playedIntervals[i][l] > mostMissedNPlayed[j]){
                        for(int k = 4; k > j; k--){
                            mostMissedNoteOne[k] = mostMissedNoteOne[k-1];
                            mostMissedNoteTwo[k] = mostMissedNoteTwo[k-1];
                            mostMissedNPlayed[k] = mostMissedNPlayed[k-1];
                        }
                        mostMissedNoteOne[j] = i;
                        mostMissedNoteTwo[j] = l;
                        mostMissedNPlayed[j] = input.playedIntervals[i][l];
                        break;
                    }
                }
                perfect = false;
            }
        }
        }
    }
    [self printTopFive: mostMissedNoteOne: mostMissedNoteTwo: input];
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
