//
//  ListenScore.h
//  Dino
//
//  Created by Lucy  on 9/10/15.
//  Copyright (c) 2015 Lucy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUMNOTES 12
#define NUMOCTAVES 8

@interface ListenScore : NSObject {
    int playedNotes[NUMNOTES * NUMOCTAVES];
    int missedNotes[NUMNOTES * NUMOCTAVES];
    int playedIntervals[NUMNOTES * NUMOCTAVES][NUMNOTES * NUMOCTAVES];
    int missedIntervals[NUMNOTES * NUMOCTAVES][NUMNOTES * NUMOCTAVES];
}
    @property (nonatomic) int numInputs;
    @property (nonatomic) int numAccurate;
    @property (nonatomic) float score;
    @property (nonatomic) char* nearestNoteName;
    @property (nonatomic) int nearestNoteDelta;
    @property (nonatomic) float centsSharp;
    @property (nonatomic) int noteIndex;
    @property (nonatomic) int prevNoteIndex;
    @property (nonatomic) float freq;

- (ListenScore *) init;
- (int *)playedNotes;
- (int *)missedNotes;
- (int (*)[NUMNOTES*NUMOCTAVES])playedIntervals;
- (int (*)[NUMNOTES*NUMOCTAVES]) missedIntervals;
@end
