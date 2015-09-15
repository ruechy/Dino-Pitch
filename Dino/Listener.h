//
//  Listener.h
//  A Listener takes in microphone input and analyzes its frequency to determine the pitch it is closest to.
//  It passes the information it gathers about the frequency (the closest pitch, how off it is from the pitch, etc.)
//  to a ListenScore object. The ListenScore object also contains historical information about how often the user
//  is missing pitches and the pitches/intervals the user is missing most often. The Listener updates this information as well.
//

/* Built on top of:
 * chromatic guitar tuner
 *
 * Copyright (C) 2012 by Bjorn Roche
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted, provided
 * that the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation.  This software is provided "as is" without express or
 * implied warranty.
 *
 */

#import <Foundation/Foundation.h>
#import <portaudio.h>
#import "ListenScore.h"
#define FFT_SIZE (8192)

@interface Listener : NSObject {
    PaStreamParameters inputParameters;
    float a[2], b[3], mem1[4], mem2[4];
    float data[FFT_SIZE], datai[FFT_SIZE], window[FFT_SIZE], freqTable[FFT_SIZE], notePitchTable[FFT_SIZE];
    char * noteNameTable[FFT_SIZE];
    void * fft;
    PaStream *stream;
    PaError err;
}

@property (strong, nonatomic) ListenScore * info;
- (Listener*)init;
- (ListenScore *)getInput;


@end
