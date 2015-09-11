//
//  Listener.h
//  Dino
//
//  Created by Lucy  on 9/10/15.
//  Copyright (c) 2015 Lucy. All rights reserved.
//

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
