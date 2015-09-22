//
//  ListenScore.h
//  Holds information about the frequency of the last microphone input received, its distance from the
//  closest note, and the name of the closest note. Also holds historical information about the duration of
//  the microphone input, such as the percent of pitches that have been hit accurately, and the number of times
//  a given pitch/interval has been missed.
//

#import <Foundation/Foundation.h>

#define NUMNOTES 12 //number of notes in an octave
#define NUMOCTAVES 8 //number of octaves that are being listened for

@interface ListenScore : NSObject {
    //in the arrays below, the 0th index is C1 and every preceding index represents a half step up from C1

    int playedNotes[NUMNOTES * NUMOCTAVES]; //Keeps track of number of each note that has been heard in the input
    int missedNotes[NUMNOTES * NUMOCTAVES]; //Keeps track of number of each note that has been heard in the input with an inaccurate pitch
    
    //in the arrays below, if the array is represented by [x][y], x is the first note in the interval and y is the second
    int playedIntervals[NUMNOTES * NUMOCTAVES][NUMNOTES * NUMOCTAVES]; //Keeps track of number of each interval that has been heard in the input
    int missedIntervals[NUMNOTES * NUMOCTAVES][NUMNOTES * NUMOCTAVES]; //Keeps track of number of each interval that has been heard in the input with an inaccurate pitch
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


//Getters for played/missed arrays
- (int *)playedNotes;
- (int *)missedNotes;
- (int (*)[NUMNOTES*NUMOCTAVES])playedIntervals;
- (int (*)[NUMNOTES*NUMOCTAVES]) missedIntervals;
@end
