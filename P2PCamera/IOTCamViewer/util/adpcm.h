//
//  adpcm.h
//  IOTCamViewer
//
//  Created by 百堅 蕭 on 12/4/27.
//  Copyright (c) 2012年 Throughtek Co., Ltd. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */
    
    void ResetADPCMEncoder();
    void ResetADPCMDecoder();
    void EncodeADPCM(unsigned char *pRaw, int nLenRaw, unsigned char *pBufEncoded);
    void DecodeADPCM(char *in, int inLen, char *out, int outLen);
    
    
#ifdef __cplusplus
}
#endif /* __cplusplus */