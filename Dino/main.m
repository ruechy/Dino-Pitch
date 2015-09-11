//
//  main.m
//  Dino
//
//  Created by Lucy  on 9/7/15.
//  Copyright (c) 2015 Lucy. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/* main.c - chromatic guitar tuner
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <signal.h>
#include "libfft.h"
#include <portaudio.h>

/* -- some basic parameters -- */
#define SAMPLE_RATE (8000)
#define FFT_SIZE (8192)
#define FFT_EXP_SIZE (13)
#define NUM_SECONDS (20)
#define LOW_PASS_FILTER_PARAM (330)
#define SCORETOTAL (100)
#define NUMNOTES (12)
#define CENTS_SHARP_MULTIPLIER (1200)
#define ACCURACY_THRESHOLD (10.0)
#define MINIMUM (1000000000.0)
#define MISS_THRESHOLD (.5)
#define NUMOCTAVES (8)
#define OCTAVE_ONE_START (31.7855) //halfway between B0 and C1
#define OCTAVE_EIGHT_END (8137.075) //halway between B8 and C9

/* -- functions declared and used here -- */

void waitForStart();

void outputPitch(char* nearestNoteName, int nearestNoteDelta, float centsSharp);
//int listen(PaError * errp, PaStream * stream, float * data, float * mem1, float * mem2, float * a,
//           float * b, float * window, float * datai, float * freqTable, float * notePitchTable,
//           char ** noteNameTable, void * fft, float * score, int * numAccuratep);
void printResults(int numAccurate, float score, int numInputs);
void updateInfo(float * scorep, int * numAccuratep, int noteIndex, int prevNoteIndex, float centsSharp, float freq);
bool printIntervals();
bool printNotes();

static bool running = true;
static int playedNotes[NUMNOTES * NUMOCTAVES];
static int missedNotes[NUMNOTES * NUMOCTAVES];
static int playedIntervals[NUMNOTES * NUMOCTAVES][NUMNOTES * NUMOCTAVES];
static int missedIntervals[NUMNOTES * NUMOCTAVES][NUMNOTES * NUMOCTAVES];
static char * NOTES[] = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" };

//Listens to the microphone input and outputs the nearest pitch; returns number of inputs recorded
int listenToInput(PaError * errp, PaStream * stream, float * data, float * mem1, float * mem2, float * a,
           float * b, float * window, float * datai, float * freqTable, float * notePitchTable,
           char ** noteNameTable, void * fft, float * scorep, int * numAccuratep){
    
    int prevNoteIndex = -1; //Initialize the previous note index to -1 so it is not accessed on the first iteration
    int numInputs = 0; //number of inputs recorded
    while( running ) {
        numInputs++;
        // read some data
        *errp = Pa_ReadStream( stream, data, FFT_SIZE );
        for( int j=0; j<FFT_SIZE; ++j ) {
            data[j] = processSecondOrderFilter( data[j], mem1, a, b );
            data[j] = processSecondOrderFilter( data[j], mem2, a, b );
        }
        applyWindow( window, data, FFT_SIZE );
        
        // do the fft
        for( int j=0; j<FFT_SIZE; ++j )
            datai[j] = 0;
        applyfft( fft, data, datai, false );
        
        float maxVal = -1;
        int maxIndex = -1;
        for( int j=0; j<FFT_SIZE/2; ++j ) {
            float v = data[j] * data[j] + datai[j] * datai[j] ;
            if( v > maxVal ) {
                maxVal = v;
                maxIndex = j;
            }
        }
        float freq = freqTable[maxIndex];
        //find the nearest note:
        int nearestNoteDelta = 0;
        while( true ) {
            if( nearestNoteDelta < maxIndex && noteNameTable[maxIndex-nearestNoteDelta] != NULL ) {
                nearestNoteDelta = -nearestNoteDelta;
                break;
            } else if( nearestNoteDelta + maxIndex < FFT_SIZE && noteNameTable[maxIndex+nearestNoteDelta] != NULL ) {
                break;
            }
            ++(nearestNoteDelta);
        }
        char * nearestNoteName = noteNameTable[maxIndex+nearestNoteDelta];
        float nearestNotePitch = notePitchTable[maxIndex+nearestNoteDelta];
        float centsSharp = CENTS_SHARP_MULTIPLIER * log( freq / nearestNotePitch ) / log( 2.0 );
        updateInfo(scorep, numAccuratep, (maxIndex+nearestNoteDelta) % NUMNOTES, prevNoteIndex, centsSharp, freq);
        outputPitch(nearestNoteName, nearestNoteDelta, centsSharp);
        prevNoteIndex = (maxIndex+nearestNoteDelta) % NUMNOTES;
    }
    return numInputs;
}


/* -- main function -- */
int main( int argc, char **argv ) {
    NSApplicationMain(argc, argv);
    PaStreamParameters inputParameters;
    float a[2], b[3], mem1[4], mem2[4];
    float data[FFT_SIZE], datai[FFT_SIZE], window[FFT_SIZE], freqTable[FFT_SIZE], notePitchTable[FFT_SIZE];
    char * noteNameTable[FFT_SIZE];
    void * fft = NULL;
    PaStream *stream = NULL;
    PaError err = 0;
    int numAccurate = 0;
    float score = 0.;
    initNotesPlayedArrays();

    

   
    waitForStart();
    int numInputs = listenToInput(&err, stream, data, mem1, mem2, a, b, window, datai, freqTable, notePitchTable,
                           noteNameTable, fft, &score, &numAccurate);
    
    err = Pa_StopStream( stream );
    if( err != paNoError ) goto error;
    
    printResults(numAccurate, score, numInputs);
    
    // cleanup
    destroyfft( fft );
    Pa_Terminate();
    return 0;
error:

    return 1;
}

//Prints the names of the notes that the user missed more than a specified percentage of the time. Returns true
//if there are no frequently missed notes.
bool printNotes(){
    bool perfect = true; //no missed notes
    printf("Problem notes:\n");
    for(int i = 0; i < NUMNOTES * NUMOCTAVES; i++){
        if(playedNotes[i]){
            float missed = (float) missedNotes[i] / playedNotes[i];
            if(missed > MISS_THRESHOLD){
                //print integer instead of float; integer is precise enough for this purpose
                printf("%s%d (missed %d %% of the time)\n", NOTES[i % NUMNOTES],
                       (i / NUMOCTAVES) + 1, (int)(missed * SCORETOTAL));
                perfect = false;
            }
        }
    }
    return perfect;
}

//Prints the interval jumps that the user missed more than a specified percentage of the time. Returns true
//if there are no frequently missed intervals.
bool printIntervals(){
    bool perfect = true; //no missed intervals
    printf("Problem intervals:\n");
    for(int i = 0; i < NUMNOTES * NUMOCTAVES; i++){
        for(int j = 0; j < NUMNOTES * NUMOCTAVES; j++){
            if(playedIntervals[i][j]){
                float missed = (float) missedIntervals[i][j] / playedIntervals[i][j];
                if(missed > MISS_THRESHOLD){
                    //print integer instead of float; integer is precise enough for this purpose
                    printf("%s%d -> %s%d (missed %d %% of the time)\n", NOTES[i % NUMNOTES],
                           (i / NUMOCTAVES) + 1, NOTES[j % NUMNOTES], (j / NUMOCTAVES) + 1, (int)(missed * SCORETOTAL));
                    perfect = false;
                }
            }
        }
    }
    return perfect;
}

//Prints the pitch results of the recording:
void printResults(int numAccurate, float score, int numInputs){
    if(numInputs == 0){ //ensures no division by 0 is attempted
        printf("No inputs recorded. \n");
    } else {
        float percentAccurate = (((float) numAccurate)/numInputs) * SCORETOTAL;
        printf("Percent accurate: %d %% \n", (int)percentAccurate); //print integer instead of float; integer is precise enough for this purpose
        printf("\n");
        printf("Precision Score: %d / 100 \n", (int)(score/numInputs)); //print integer instead of float; integer is precise enough for this purpose
    }
    printf("\n");
    if(printNotes()) printf("None! Nice job! :D \n"); //if this is true, it means the user didn't frequently miss any notes
    printf("\n");
    if(printIntervals()) printf("None! Nice job! :D \n"); //if this is true, it means the user didn't frequently miss any intervals
}



//updates accuracy/score/other pitch information based on frequency input
void updateInfo(float * scorep, int * numAccuratep, int noteIndex, int prevNoteIndex, float centsSharp, float freq){
    if(freq < OCTAVE_ONE_START || freq > OCTAVE_EIGHT_END) return; //return if outside of the span of the 8 octaves
    int octave = (log(freq/OCTAVE_ONE_START)/log(2.0)) + 1; //converts from Hz to octave
    prevNoteIndex *= octave; //puts note in respective octave
    noteIndex *= octave;
    playedNotes[noteIndex]++;
    if(prevNoteIndex > 0 && prevNoteIndex != noteIndex){ //if it's not the first note or the same note
        playedIntervals[prevNoteIndex][noteIndex]++;
    }
    if(fabsf(centsSharp) < ACCURACY_THRESHOLD){
        (*numAccuratep)++; //Count it as an accurate pitch if it's "close enough" in the range of the accuracy threshold
    } else {
        missedNotes[noteIndex]++;
        if(prevNoteIndex > 0 && prevNoteIndex != noteIndex){ //if it's not the first note or the same note
            missedIntervals[prevNoteIndex][noteIndex]++;
        }
    }
    float singleInputScore = SCORETOTAL - fabsf(centsSharp);
    *scorep += singleInputScore;
    
}


//Output the pitch heard and the degree of "pitchiness"
void outputPitch(char* nearestNoteName, int nearestNoteDelta, float centsSharp){
    printf("\033[2J\033[1;1H"); //clear screen, go to top left
    fflush(stdout);
    printf( "Nearest Note: %s\n", nearestNoteName );
    if( nearestNoteDelta != 0 ) {
        if( centsSharp > 0 )
            printf( "%f cents sharp.\n", centsSharp );
        if( centsSharp < 0 )
            printf( "%f cents flat.\n", -centsSharp );
    } else {
        printf( "in tune!\n" );
    }
    printf( "\n" );
    int chars = 30;
    if( nearestNoteDelta == 0 || centsSharp >= 0 ) {
        for( int i=0; i<chars; ++i )
            printf( " " );
    } else {
        for( int i=0; i<chars+centsSharp; ++i )
            printf( " " );
        for( int i=chars+centsSharp<0?0:chars+centsSharp; i<chars; ++i )
            printf( "=" );
    }
    printf( " %2s ", nearestNoteName );
    if( nearestNoteDelta != 0 )
        for( int i=0; i<chars && i<centsSharp; ++i )
            printf( "=" );
    printf("\n");
}


//Program will not proceed until r is entered
void waitForStart(){
    char start = '\n';
    printf("Enter 'r' to start recording.\n");
    while(start != 'r'){
        start = getchar();
    }
}



//Stops the recording
void signalHandler( int signum ) { running = false; }

