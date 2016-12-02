//
//  adpcm.cpp
//  IOTCamViewer
//
//  Created by 百堅 蕭 on 12/4/27.
//  Copyright (c) 2012年 Throughtek Co., Ltd. All rights reserved.
//

#ifdef __cplus
#include <iostream>
#endif
#include "adpcm.h"

int g_nEnAudioPreSample=0;
int g_nEnAudioIndex=0;
int g_nDeAudioPreSample=0;
int g_nDeAudioIndex=0;

static int gs_index_adjust[16]= //{-1,-1,-1,-1,2,4,6,8};
{-1, -1, -1, -1,  2,
    4,  6,  8, -1, -1,
    -1, -1,  2,  4,  6,
    8 };
static int gs_step_table[89] =
{
	7,8,9,10,11,12,13,14,16,17,19,21,23,25,28,31,34,37,41,45,
	50,55,60,66,73,80,88,97,107,118,130,143,157,173,190,209,230,253,279,307,337,371,
	408,449,494,544,598,658,724,796,876,963,1060,1166,1282,1411,1552,1707,1878,2066,
	2272,2499,2749,3024,3327,3660,4026,4428,4871,5358,5894,6484,7132,7845,8630,9493,
	10442,11487,12635,13899,15289,16818,18500,20350,22385,24623,27086,29794,32767
};

void ResetADPCMEncoder()
{
    g_nEnAudioPreSample=0;
    g_nEnAudioIndex=0;
}

void EncodeADPCM(unsigned char *pRaw, int nLenRaw, unsigned char *pBufEncoded)
{
	short *pcm = (short *)pRaw;
	int cur_sample;
	int i;
	int delta;
	int sb;
	int code;
	nLenRaw >>= 1;
    
	for(i = 0; i<nLenRaw; i++)
	{
		cur_sample = pcm[i];
		delta = cur_sample - g_nEnAudioPreSample;
		if (delta < 0){
			delta = -delta;
			sb = 8;
		}else sb = 0;
        
		code = 4 * delta / gs_step_table[g_nEnAudioIndex];
		if (code>7)	code=7;
        
		delta = (gs_step_table[g_nEnAudioIndex] * code) / 4 + gs_step_table[g_nEnAudioIndex] / 8;
		if(sb) delta = -delta;
        
		g_nEnAudioPreSample += delta;
		if (g_nEnAudioPreSample > 32767) g_nEnAudioPreSample = 32767;
		else if (g_nEnAudioPreSample < -32768) g_nEnAudioPreSample = -32768;
        
		g_nEnAudioIndex += gs_index_adjust[code];
		if(g_nEnAudioIndex < 0) g_nEnAudioIndex = 0;
		else if(g_nEnAudioIndex > 88) g_nEnAudioIndex = 88;
        
		if(i & 0x01) pBufEncoded[i>>1] |= code | sb;
		else pBufEncoded[i>>1] = (code | sb) << 4;
	}
}

void ResetADPCMDecoder()
{
    g_nDeAudioPreSample=0;
    g_nDeAudioIndex=0;
}

void DecodeADPCM(char *in, int inLen, char *out, int outLen)
{
	char* pDataCompressed = in;
	int i;
	int code;
	int sb;
	int delta;
	unsigned short *pcm = (unsigned short *)out;
	int nLenData = outLen >> 1;
	
	for(i=0; i<nLenData; i++)
	{
		if(i & 0x01) code = pDataCompressed[i>>1] & 0x0f;
		else code = pDataCompressed[i>>1] >> 4;
		
		if((code & 8) != 0) sb = 1;
		else sb = 0;
		code &= 7;
		
		delta = (gs_step_table[g_nDeAudioIndex] * code) / 4 + gs_step_table[g_nDeAudioIndex] / 8;
		if(sb) delta = -delta;
		
		g_nDeAudioPreSample += delta;
		if(g_nDeAudioPreSample > 32767) g_nDeAudioPreSample = 32767;
		else if (g_nDeAudioPreSample < -32768) g_nDeAudioPreSample = -32768;
		
		pcm[i] = g_nDeAudioPreSample;
		g_nDeAudioIndex+= gs_index_adjust[code];
		if(g_nDeAudioIndex < 0) g_nDeAudioIndex = 0;
		if(g_nDeAudioIndex > 88) g_nDeAudioIndex= 88;
	}
#if 0
	LOG(@"With problem at UID:DZJTATRP98U7AMPPWFWS");
	int valpred = 0;
	int index = 0;
    //	int volset = 100;
	
	int step;
	int vpdiff;
	unsigned char buffer_step = 0;
	
	step = gs_step_table[index];
	unsigned char* R_TargetBuffer = (unsigned char*)out;
	int Source_Idx = 4;
	int Target_Idx = 0;
	inLen -= 4;
	for (inLen <<= 1; inLen > 0; inLen--) {
		unsigned char delta = (unsigned char)in[Source_Idx];
		if (buffer_step == 0) {
			delta >>= 4;
		} else {
			Source_Idx++; // set to next byte
		}
		delta &= 0x0f;
		buffer_step ^= 1;
		
		/* Step 2 - Find new index value (for later) */
		index += gs_index_adjust[delta];
		if (index < 0) {
			index = 0;
		} else if (index > 88) {
			index = 88;
		}
		
		vpdiff = step >> 3;
		if ((delta & 4) != 0)
			vpdiff += step;
		if ((delta & 2) != 0)
			vpdiff += step >> 1;
		if ((delta & 1) != 0)
			vpdiff += step >> 2;
		
		// if (sign != 0)
		if (delta > 7) {
			valpred -= vpdiff;
		} else {
			valpred += vpdiff;
		}
		/* Step 5 - clamp output value */
		if (valpred > 32767) {
			valpred = 32767;
		} else if (valpred < -32768) {
			valpred = -32768;
		}
		/* Step 6 - Update step value */
		step = gs_step_table[index];
		
		/* Step 7 - Output value */
		if (Target_Idx + 2 > outLen)
			break;
        //		if (volset != 100)
        //			valpred = valpred * volset / 100;
		int tmp = (short) valpred;
		R_TargetBuffer[Target_Idx++] = (unsigned char)(tmp & 0x0FF);
		tmp >>= 8;
		R_TargetBuffer[Target_Idx++] = (unsigned char)(tmp & 0x0FF);
	}
    //	return Target_Idx;
#endif
}