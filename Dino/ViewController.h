//
//  ViewController.h
//  Provides a graphical display for information gathered about pitches played into the microphone.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSTextField *Accuracy;
@property (weak) IBOutlet NSTextField *Score;
@property (weak) IBOutlet NSTextField *Notes;
@property (weak) IBOutlet NSTextField *Intervals;
@property (weak) IBOutlet NSButton *Frequency;
@property (weak) IBOutlet NSTextField *NoteName;
@property (weak) IBOutlet NSColorWell *Pitch;

- (IBAction)Listen:(id)sender;


@end

