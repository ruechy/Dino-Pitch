//
//  ListenScore.m
//  Dino
//
//  Created by Lucy  on 9/10/15.
//  Copyright (c) 2015 Lucy. All rights reserved.
//

#import "ListenScore.h"

//Initializes the number of each note/interval played/missed to 0
void initNotesPlayedArrays(int * playedNotes, int * missedNotes, int playedIntervals[NUMNOTES * NUMOCTAVES][NUMNOTES * NUMOCTAVES] , int missedIntervals[NUMNOTES * NUMOCTAVES][NUMNOTES * NUMOCTAVES]){
    for(int i = 0; i < NUMNOTES; i++){
        playedNotes[i] = 0;
        missedNotes[i] = 0;
        for(int j = 0; j < NUMNOTES; j++){
            playedIntervals[i][j] = 0;
            missedIntervals[i][j] = 0;
        }
    }
}

@implementation ListenScore
- (ListenScore *)init {
    self = [super init];
    if (self) {
        initNotesPlayedArrays(self.playedNotes, self.missedNotes, self.playedIntervals, self.missedIntervals);
    }
    return self;
}
- (int *)missedNotes {
    return missedNotes;
}
- (int *)playedNotes {
    return playedNotes;
}
- (int (*)[NUMNOTES*NUMOCTAVES])playedIntervals {
    return playedIntervals;
}
- (int (*)[NUMNOTES*NUMOCTAVES])missedIntervals {
    return missedIntervals;
}

@end
