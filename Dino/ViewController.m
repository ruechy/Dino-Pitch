//
//  ViewController.m
//

#import "ViewController.h"
#import "Listener.h"
#import "ListenScore.h"

#define SCORETOTAL 100
#define MISS_THRESHOLD (.5)
#define MISSED_ARRAY_SIZE (5)
#define GRAPHICAL_MULTIPLIER (1.3)
#define INPUT_THRESHOLD (3) //number of inputs recorded to be eligible for a problem note/interval
static char * NOTES[] = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" };

Listener * list;
bool button;

//Initialize every index in the most missed array to -1. 
void initMostMissed(int* mostMissed){
    for(int i = 0; i < MISSED_ARRAY_SIZE; i++){
        mostMissed[i] = -1;
    }
}

@implementation ViewController

//Initializes view
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

//Prints the names of the most frequently played notes that the user missed more than a specified percentage of the time. Returns true
//if there are no frequently missed notes.
- (bool)printNotes:(ListenScore *) input {
    [self.Notes setStringValue: @""];
    bool perfect = true; //no missed notes
    int mostMissed[MISSED_ARRAY_SIZE]; //keeps track of indices of top most missed notes
    int mostMissedNPlayed[MISSED_ARRAY_SIZE]; //keeps track of how often each of the most missed notes have been played
    initMostMissed(mostMissed);
    float missed = 0.;
    for(int i = 0; i < NUMNOTES * NUMOCTAVES; i++){
        if(input.playedNotes[i] > INPUT_THRESHOLD){
            missed = (float) input.missedNotes[i] / input.playedNotes[i];
            if(missed > MISS_THRESHOLD){
                for(int j = 0; j < MISSED_ARRAY_SIZE; j++){
                    if(input.playedNotes[i] > mostMissedNPlayed[j]){
                        for(int k = MISSED_ARRAY_SIZE - 1; k > j; k--){
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
    for(int i = 0; i < MISSED_ARRAY_SIZE; i++){
        if(mostMissed[i] > 0){
            [self.Notes setStringValue:[NSString stringWithFormat:@"%s%d (%d %%)\n%@", NOTES[mostMissed[i] % NUMNOTES],(mostMissed[i] / NUMNOTES) + 1, SCORETOTAL - (int)(((float) input.missedNotes[mostMissed[i]] / input.playedNotes[mostMissed[i]]) * SCORETOTAL), self.Notes.stringValue]]; //print integer instead of float; integer is precise enough for this purpose
        }
    }
    return perfect;
}

//Prints the top most frequently played missed intervals.
- (void)printTop:(int*) mostMissedNoteOne: (int*) mostMissedNoteTwo: (ListenScore *) input{
    for(int i = 0; i < MISSED_ARRAY_SIZE; i++){
        if(mostMissedNoteOne[i] > 0){
            float missed = (float) input.missedIntervals[mostMissedNoteOne[i]][mostMissedNoteTwo[i]] / input.playedIntervals[mostMissedNoteOne[i]][mostMissedNoteTwo[i]];
            [self.Intervals setStringValue:[NSString stringWithFormat:@"%s%d -> %s%d (%d %%)\n%@", NOTES[mostMissedNoteOne[i] % NUMNOTES], (mostMissedNoteOne[i] / NUMNOTES) + 1, NOTES[mostMissedNoteTwo[i] % NUMNOTES], (mostMissedNoteTwo[i] / NUMNOTES) + 1, SCORETOTAL -(int)(missed * SCORETOTAL), self.Intervals.stringValue]];//print integer instead of float; integer is precise enough for this purpose
        }
    }
}

//Prints the most frequently played interval jumps that the user missed more than a specified percentage of the time. Returns true if there are no frequently missed intervals.
- (bool)printIntervals:(ListenScore *) input {
    [self.Intervals setStringValue: @""];
    bool perfect = true; //no missed notes
    int mostMissedNoteOne[MISSED_ARRAY_SIZE]; //keeps track of indices first notes of of top most missed intervals
    int mostMissedNoteTwo[MISSED_ARRAY_SIZE]; //keeps track of indices first notes of of top most missed intervals
    int mostMissedNPlayed[MISSED_ARRAY_SIZE]; //keeps track of how often each of the most missed notes have been played
    initMostMissed(mostMissedNoteOne);
    initMostMissed(mostMissedNoteOne);
    float missed = 0.;
    for(int i = 0; i < NUMNOTES * NUMOCTAVES; i++){
        for(int l = 0; l < NUMNOTES * NUMOCTAVES; l++){
        if(input.playedIntervals[i][l] > INPUT_THRESHOLD){
            missed = (float) input.missedIntervals[i][l] / input.playedIntervals[i][l];
            if(missed > MISS_THRESHOLD){
                for(int j = 0; j < MISSED_ARRAY_SIZE; j++){
                    if(input.playedIntervals[i][l] > mostMissedNPlayed[j]){
                        for(int k = MISSED_ARRAY_SIZE - 1; k > j; k--){
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
    [self printTop: mostMissedNoteOne: mostMissedNoteTwo: input];
    return perfect;

}

- (void)generatePitchInfo {
    int origin = self.Frequency.frame.origin.y;
    if(button){
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
            frame.origin.y = origin + (input.centsSharp * GRAPHICAL_MULTIPLIER); //Shifts the pitch bar by degree of pitchiness
            self.Frequency.frame = frame;
        }
        [self performSelector:@selector(generatePitchInfo) withObject:nil afterDelay:0.0];
    }
}

//Listens to a single microphone input and graphically updates pitch information (closest pitch, degree of pitchiness) as well as historical data (percent accuracy of all inputs received, accuracy score, and problem notes/intervals)
- (IBAction)Listen:(id)sender {
    button = !button;
    if(button){
        list = [[Listener alloc] init];
        [self generatePitchInfo];
    } 
}


@end
