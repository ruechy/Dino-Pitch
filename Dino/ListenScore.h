//
//  ListenScore.h
//  Holds information about the frequency of the last microphone input received, its distance from the
//  closest note, and the name of the closest note. Also holds historical information about the duration of
//  the microphone input, such as the percent of pitches that have been hit accurately, and the number of times
//  a given pitch/interval has been missed.
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
