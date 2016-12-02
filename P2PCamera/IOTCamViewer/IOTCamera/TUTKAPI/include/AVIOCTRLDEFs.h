/*
 * AVIOCTRLDEFs.h
 *	Define AVIOCTRL Message Type and Context
 *  Created on: 2011-08-12
 *  Author: TUTK
 *
 */

//Change Log:
//
//  2013-06-25 - 1> Add set and get time zone of device.
//                      Add IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ
//                          Client request device to return time zone
//	                    Add IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP
//	                        Device return to client the time zone
//	                    Add IOTYPE_USER_IPCAM_SET_TIMEZONE_REQ
//	                        Client request device to set time zone
//	                    Add IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP 
//	                        Device acknowledge the set time zone request
//
//  2013-06-05 - 1> Add customer defined message type, start from #FF000000
//                  Naming role of message type : IOTYPE_[Company_name]_[function_name]
//                      ex : IOTYPE_TUTK_TEST_REQ, IOTYPE_TUTK_TEST_RESP
//                  Naming role of data structure : [Company_name]_[data_structure_name]
//                      ex : TUTK_SMsgTestReq, TUTK_SMsgTestResp
//                  
//
//  2013-03-10 - 1> Add flow information collection mechanism.
//						Add IOTYPE_USER_IPCAM_GET_FLOWINFO_REQ
//							Device request client to collect flow information.
//						Add IOTYPE_USER_IPCAM_GET_FLOWINFO_RESP
//							Client acknowledge device that request is received.
//						Add IOTYPE_USER_IPCAM_CURRENT_FLOWINFO
//							Client send collected flow information to device.
//				 2> Add IOTYPE_USER_IPCAM_RECEIVE_FIRST_IFRAME command.
//
//	2013-02-19 - 1> Add more detail of status of SWifiAp
//				 2> Add more detail description of STimeDay
//
//	2012-10-26 - 1> SMsgAVIoctrlGetEventConfig
//						Add field: externIoOutIndex, externIoInIndex
//				 2> SMsgAVIoctrlSetEventConfig, SMsgAVIoctrlGetEventCfgResp
//						Add field: externIoOutStatus, externIoInStatus
//
//	2012-10-19 - 1> SMsgAVIoctrlGetWifiResp: -->SMsgAVIoctrlGetWifiResp2
//						Add status description
//				 2> SWifiAp:
//				 		Add status 4: selected but not connected
//				 3> WI-FI Password 32bit Change to 64bit
//				 4> ENUM_AP_ENCTYPE: Add following encryption types
//				 		AVIOTC_WIFIAPENC_WPA_PSK_TKIP		= 0x07,
//						AVIOTC_WIFIAPENC_WPA_PSK_AES		= 0x08,
//						AVIOTC_WIFIAPENC_WPA2_PSK_TKIP		= 0x09,
//						AVIOTC_WIFIAPENC_WPA2_PSK_AES		= 0x0A,
//
//				 5> IOTYPE_USER_IPCAM_SETWIFI_REQ_2:
//						Add struct SMsgAVIoctrlSetWifiReq2
//				 6> IOTYPE_USER_IPCAM_GETWIFI_RESP_2:
//						Add struct SMsgAVIoctrlGetWifiResp2

//  2012-07-18 - added: IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ, IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_RESP
//	2012-05-29 - IOTYPE_USER_IPCAM_DEVINFO_RESP: Modify firmware version
//	2012-05-24 - SAvEvent: Add result type
//

#ifndef _AVIOCTRL_DEFINE_H_
#define _AVIOCTRL_DEFINE_H_

/////////////////////////////////////////////////////////////////////////////////
/////////////////// Message Type Define//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

// AVIOCTRL Message Type
typedef enum 
{
	IOTYPE_USER_IPCAM_START 					= 0x01FF,
	IOTYPE_USER_IPCAM_STOP	 					= 0x02FF,
	IOTYPE_USER_IPCAM_AUDIOSTART 				= 0x0300,
	IOTYPE_USER_IPCAM_AUDIOSTOP 				= 0x0301,

	IOTYPE_USER_IPCAM_SPEAKERSTART 				= 0x0350,
	IOTYPE_USER_IPCAM_SPEAKERSTOP 				= 0x0351,

	IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ			= 0x0320,
	IOTYPE_USER_IPCAM_SETSTREAMCTRL_RESP		= 0x0321,
	IOTYPE_USER_IPCAM_GETSTREAMCTRL_REQ			= 0x0322,
	IOTYPE_USER_IPCAM_GETSTREAMCTRL_RESP		= 0x0323,

	IOTYPE_USER_IPCAM_SETMOTIONDETECT_REQ		= 0x0324,
	IOTYPE_USER_IPCAM_SETMOTIONDETECT_RESP		= 0x0325,
	IOTYPE_USER_IPCAM_GETMOTIONDETECT_REQ		= 0x0326,
	IOTYPE_USER_IPCAM_GETMOTIONDETECT_RESP		= 0x0327,
	
	IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ		= 0x0328,	// Get Support Stream
	IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_RESP		= 0x0329,	

	IOTYPE_USER_IPCAM_DEVINFO_REQ				= 0x0330,
	IOTYPE_USER_IPCAM_DEVINFO_RESP				= 0x0331,

	IOTYPE_USER_IPCAM_SETPASSWORD_REQ			= 0x0332,
	IOTYPE_USER_IPCAM_SETPASSWORD_RESP			= 0x0333,

	IOTYPE_USER_IPCAM_LISTWIFIAP_REQ			= 0x0340,
	IOTYPE_USER_IPCAM_LISTWIFIAP_RESP			= 0x0341,
	IOTYPE_USER_IPCAM_SETWIFI_REQ				= 0x0342,
	IOTYPE_USER_IPCAM_SETWIFI_RESP				= 0x0343,
	IOTYPE_USER_IPCAM_GETWIFI_REQ				= 0x0344,
	IOTYPE_USER_IPCAM_GETWIFI_RESP				= 0x0345,
	IOTYPE_USER_IPCAM_SETWIFI_REQ_2				= 0x0346,
	IOTYPE_USER_IPCAM_GETWIFI_RESP_2			= 0x0347,

	IOTYPE_USER_IPCAM_SETRECORD_REQ				= 0x0310,
	IOTYPE_USER_IPCAM_SETRECORD_RESP			= 0x0311,
	IOTYPE_USER_IPCAM_GETRECORD_REQ				= 0x0312,
	IOTYPE_USER_IPCAM_GETRECORD_RESP			= 0x0313,

	IOTYPE_USER_IPCAM_SETRCD_DURATION_REQ		= 0x0314,
	IOTYPE_USER_IPCAM_SETRCD_DURATION_RESP  	= 0x0315,
	IOTYPE_USER_IPCAM_GETRCD_DURATION_REQ		= 0x0316,
	IOTYPE_USER_IPCAM_GETRCD_DURATION_RESP  	= 0x0317,

	IOTYPE_USER_IPCAM_LISTEVENT_REQ				= 0x0318,
	IOTYPE_USER_IPCAM_LISTEVENT_RESP			= 0x0319,
	
	IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL 		= 0x031A,
	IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL_RESP 	= 0x031B,
	
	IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ		= 0x032A,
	IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_RESP	= 0x032B,

	IOTYPE_USER_IPCAM_GET_EVENTCONFIG_REQ		= 0x0400,	// Get Event Config Msg Request
	IOTYPE_USER_IPCAM_GET_EVENTCONFIG_RESP		= 0x0401,	// Get Event Config Msg Response
	IOTYPE_USER_IPCAM_SET_EVENTCONFIG_REQ		= 0x0402,	// Set Event Config Msg req
	IOTYPE_USER_IPCAM_SET_EVENTCONFIG_RESP		= 0x0403,	// Set Event Config Msg resp

	IOTYPE_USER_IPCAM_SET_ENVIRONMENT_REQ		= 0x0360,
	IOTYPE_USER_IPCAM_SET_ENVIRONMENT_RESP		= 0x0361,
	IOTYPE_USER_IPCAM_GET_ENVIRONMENT_REQ		= 0x0362,
	IOTYPE_USER_IPCAM_GET_ENVIRONMENT_RESP		= 0x0363,
	
	IOTYPE_USER_IPCAM_SET_VIDEOMODE_REQ			= 0x0370,	// Set Video Flip Mode
	IOTYPE_USER_IPCAM_SET_VIDEOMODE_RESP		= 0x0371,
	IOTYPE_USER_IPCAM_GET_VIDEOMODE_REQ			= 0x0372,	// Get Video Flip Mode
	IOTYPE_USER_IPCAM_GET_VIDEOMODE_RESP		= 0x0373,
	
	IOTYPE_USER_IPCAM_FORMATEXTSTORAGE_REQ		= 0x0380,	// Format external storage
	IOTYPE_USER_IPCAM_FORMATEXTSTORAGE_RESP		= 0x0381,	
	
	IOTYPE_USER_IPCAM_PTZ_COMMAND				= 0x1001,	// P2P PTZ Command Msg

	IOTYPE_USER_IPCAM_EVENT_REPORT				= 0x1FFF,	// Device Event Report Msg
	IOTYPE_USER_IPCAM_RECEIVE_FIRST_IFRAME		= 0x1002,	// Send from client, used to talk to device that
															// client had received the first I frame
	
	IOTYPE_USER_IPCAM_GET_FLOWINFO_REQ			= 0x0390,
	IOTYPE_USER_IPCAM_GET_FLOWINFO_RESP			= 0x0391,
	IOTYPE_USER_IPCAM_CURRENT_FLOWINFO			= 0x0392,
	
	IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ          = 0x3A0,
	IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP         = 0x3A1,
	IOTYPE_USER_IPCAM_SET_TIMEZONE_REQ          = 0x3B0,
	IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP         = 0x3B1,
	
	//Customer defined message type, start from 0xFF00:0000
	//Naming role : IOTYPE_[Company_name]_[function_name]
	//EX:
	//IOTYPE_TUTK_TEST_REQ						=0xFF000001,
	//IOTYPE_TUTK_TEST_RESP						=0xFF000002,
    
    
    //================================iBaby start================================//
	IOTYPE_USER_IPCAM_GET_OSD_REQ                       = 0x2201,
	IOTYPE_USER_IPCAM_GET_OSD_RESP                      = 0x2202,
	IOTYPE_USER_IPCAM_SET_OSD_REQ                       = 0x2203,
	IOTYPE_USER_IPCAM_SET_OSD_RESP                      = 0x2204,
	
	IOTYPE_USER_IPCAM_GET_MD_REQ                        = 0x2205,
	IOTYPE_USER_IPCAM_GET_MD_RESP                       = 0x2206,
	IOTYPE_USER_IPCAM_SET_MD_REQ                        = 0x2207,
	IOTYPE_USER_IPCAM_SET_MD_RESP                       = 0x2208,
	
	IOTYPE_USER_IPCAM_GET_ALARMLINK_REQ                 = 0x2209,
	IOTYPE_USER_IPCAM_GET_ALARMLINK_RESP                = 0x220A,
	IOTYPE_USER_IPCAM_SET_ALARMLINK_REQ                 = 0x220B,
	IOTYPE_USER_IPCAM_SET_ALARMLINK_RESP                = 0x220C,
	
	IOTYPE_USER_IPCAM_GET_AUDIOALARM_REQ                = 0x220D,
	IOTYPE_USER_IPCAM_GET_AUDIOALARM_RESP               = 0x220E,
    //IOTYPE_USER_IPCAM_GET_AUDIOALARM_RESP			= 0x2300,
    
	IOTYPE_USER_IPCAM_SET_AUDIOALARM_REQ                = 0x220F,
	IOTYPE_USER_IPCAM_SET_AUDIOALARM_RESP               = 0x2210,
	
	//④、录像抓拍
    IOTYPE_USER_IPCAM_GET_REC_REQ                       = 0x2211,
    IOTYPE_USER_IPCAM_GET_REC_RESP                      = 0x2212,
    IOTYPE_USER_IPCAM_SET_REC_REQ                       = 0x2213,
    IOTYPE_USER_IPCAM_SET_REC_RESP                      = 0x2214,
    IOTYPE_USER_IPCAM_GET_SNAP_REQ                      = 0x2215,
    IOTYPE_USER_IPCAM_GET_SNAP_RESP                     = 0x2216,
    IOTYPE_USER_IPCAM_SET_SNAP_REQ                      = 0x2217,
    IOTYPE_USER_IPCAM_SET_SNAP_RESP                     = 0x2218,
    
    //⑤、报警布防，定时录像，定时抓拍时刻表
    IOTYPE_USER_IPCAM_GET_SCHEDULE_REQ                  = 0x2219,
    IOTYPE_USER_IPCAM_GET_SCHEDULE_RESP                 = 0x221A,
    IOTYPE_USER_IPCAM_SET_SCHEDULE_REQ                  = 0x221B,
    IOTYPE_USER_IPCAM_SET_SCHEDULE_RESP                 = 0x221C,
    
    //⑥、音乐播放
    IOTYPE_USER_IPCAM_FLASHFILE_START                   = 0x2220,
    IOTYPE_USER_IPCAM_FLASHFILE_STOP                    = 0x2221,
    IOTYPE_USER_IPCAM_TEMPFILE_START                    = 0x2222,
    IOTYPE_USER_IPCAM_TEMPFILE_STOP                     = 0x2223,
    IOTYPE_USER_IPCAM_GET_FILEINFO_REQ                  = 0x2224,
    IOTYPE_USER_IPCAM_GET_FILEINFO_RESP                 = 0x2225,
    IOTYPE_USER_IPCAM_SET_FILEINFO_REQ                  = 0x2226,
    IOTYPE_USER_IPCAM_SET_FILEINFO_RESP                 = 0x2227,
    IOTYPE_USER_IPCAM_PLAY_MUSIC_REQ                    = 0x2228,
    IOTYPE_USER_IPCAM_PLAY_MUSIC_RESP                   = 0x2229,
    IOTYPE_USER_IPCAM_GET_PLAYLIST_REQ                  = 0x222A,
    IOTYPE_USER_IPCAM_GET_PLAYLIST_RESP                 = 0x222B,
    IOTYPE_USER_IPCAM_EDIT_PLAYLIST_REQ                 = 0x222C,
    IOTYPE_USER_IPCAM_EDIT_PLAYLIST_RESP                = 0x222D,
    
    IOTYPE_USER_IPCAM_GET_PLAYLIST_REQ_EXT              = 0x224A,
    IOTYPE_USER_IPCAM_GET_PLAYLIST_RESP_EXT             = 0x224B,
    //⑦、系统时间
    IOTYPE_USER_IPCAM_GET_SVRTIME_REQ                   = 0x2230,
    IOTYPE_USER_IPCAM_GET_SVRTIME_RESP                  = 0x2231,
    IOTYPE_USER_IPCAM_SET_SVRTIME_REQ                   = 0x2232,
    IOTYPE_USER_IPCAM_SET_SVRTIME_RESP                  = 0x2233,
    
    //⑧、升级
    IOTYPE_USER_IPCAM_UPGRADE_REQ                       = 0x22FE,
    IOTYPE_USER_IPCAM_UPGRADE_RESP                      = 0x22FF,
    
    //9 私有用户数据
    IOTYPE_USER_IPCAM_GET_USERDATA_REQ                  = 0x2244,
    IOTYPE_USER_IPCAM_GET_USERDATA_RESP                 = 0x2245,
    
//    10、删除音乐文件
    IOTYPE_USER_IPCAM_DEL_MUSIC_REQ                     = 0x2246,
    IOTYPE_USER_IPCAM_DEL_MUSIC_RESP                    = 0x2247,
    
//    11、音乐播放状态
    IOTYPE_USER_IPCAM_GET_MUSIC_STATE_REQ               = 0x2248,
    IOTYPE_USER_IPCAM_GET_MUSIC_STATE_RESP              = 0x2249,
//    12、设置音量大小
    IOTYPE_USER_IPCAM_GET_SOUND_VOLUME_REQ              = 0x224C,
    IOTYPE_USER_IPCAM_GET_SOUND_VOLUME_RESP             = 0x224D,
    
    IOTYPE_USER_IPCAM_SET_SOUND_VOLUME_REQ              = 0x224E,
    IOTYPE_USER_IPCAM_SET_SOUND_VOLUME_RESP             = 0x224F,
    
    // 13 报警录制抓拍(优先级1)
    IOTYPE_USER_IPCAM_GET_ALARMREC_STATE_REQ		= 0x2250,
    IOTYPE_USER_IPCAM_GET_ALARMREC_STATE_RESP		= 0x2251,
    IOTYPE_USER_IPCAM_SET_ALARMREC_STATE_REQ		= 0x2252,
    IOTYPE_USER_IPCAM_SET_ALARMREC_STATE_RESP		= 0x2253,
    
    // 夜视灯控制
    IOTYPE_USER_IPCAM_GET_NIGHTVISION_REQ		    = 0x2260,
    IOTYPE_USER_IPCAM_GET_NIGHTVISION_RESP		    = 0x2261,
    IOTYPE_USER_IPCAM_SET_NIGHTVISION_REQ		    = 0x2262,
    IOTYPE_USER_IPCAM_SET_NIGHTVISION_RESP		    = 0x2263,
    
    //升级状态
    IOTYPE_USER_IPCAM_UPGRADE_STATUS_REQ			= 0x2264,
    IOTYPE_USER_IPCAM_UPGRADE_STATUS_RESP		  = 0x2265,
    
    //ibaby end
	
}ENUM_AVIOCTRL_MSGTYPE;



/////////////////////////////////////////////////////////////////////////////////
/////////////////// Type ENUM Define ////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
typedef enum
{
	AVIOCTRL_OK					= 0x00,
	AVIOCTRL_ERR				= -0x01,
	AVIOCTRL_ERR_PASSWORD		= AVIOCTRL_ERR - 0x01,
	AVIOCTRL_ERR_STREAMCTRL		= AVIOCTRL_ERR - 0x02,
	AVIOCTRL_ERR_MONTIONDETECT	= AVIOCTRL_ERR - 0x03,
	AVIOCTRL_ERR_DEVICEINFO		= AVIOCTRL_ERR - 0x04,
	AVIOCTRL_ERR_LOGIN			= AVIOCTRL_ERR - 5,
	AVIOCTRL_ERR_LISTWIFIAP		= AVIOCTRL_ERR - 6,
	AVIOCTRL_ERR_SETWIFI		= AVIOCTRL_ERR - 7,
	AVIOCTRL_ERR_GETWIFI		= AVIOCTRL_ERR - 8,
	AVIOCTRL_ERR_SETRECORD		= AVIOCTRL_ERR - 9,
	AVIOCTRL_ERR_SETRCDDURA		= AVIOCTRL_ERR - 10,
	AVIOCTRL_ERR_LISTEVENT		= AVIOCTRL_ERR - 11,
	AVIOCTRL_ERR_PLAYBACK		= AVIOCTRL_ERR - 12,

	AVIOCTRL_ERR_INVALIDCHANNEL	= AVIOCTRL_ERR - 0x20,
}ENUM_AVIOCTRL_ERROR; //APP don't use it now


// ServType, unsigned long, 32 bits, is a bit mask for function declareation
// bit value "0" means function is valid or enabled
// in contract, bit value "1" means function is invalid or disabled.
// ** for more details, see "ServiceType Definitation for AVAPIs"
// 
// Defined bits are listed below:
//----------------------------------------------
// bit		fuction
// 0		Audio in, from Device to Mobile
// 1		Audio out, from Mobile to Device 
// 2		PT function
// 3		Event List function
// 4		Play back function (require Event List function)
// 5		Wi-Fi setting function
// 6		Event Setting Function
// 7		Recording Setting function
// 8		SDCard formattable function
// 9		Video flip function
// 10		Environment mode
// 11		Multi-stream selectable
// 12		Audio out encoding format

// The original enum below is obsoleted.
typedef enum
{
	SERVTYPE_IPCAM_DWH					= 0x00,
	SERVTYPE_RAS_DWF					= 0x01,
	SERVTYPE_IOTCAM_8125				= 0x10,
	SERVTYPE_IOTCAM_8125PT				= 0x11,
	SERVTYPE_IOTCAM_8126				= 0x12,
	SERVTYPE_IOTCAM_8126PT				= 0x13,	
}ENUM_SERVICE_TYPE;

// AVIOCTRL Quality Type
typedef enum 
{
	AVIOCTRL_QUALITY_UNKNOWN			= 0x00,	
	AVIOCTRL_QUALITY_MAX				= 0x01,	// ex. 640*480, 15fps, 320kbps (or 1280x720, 5fps, 320kbps)
	AVIOCTRL_QUALITY_HIGH				= 0x02,	// ex. 640*480, 10fps, 256kbps
	AVIOCTRL_QUALITY_MIDDLE				= 0x03,	// ex. 320*240, 15fps, 256kbps
	AVIOCTRL_QUALITY_LOW				= 0x04, // ex. 320*240, 10fps, 128kbps
	AVIOCTRL_QUALITY_MIN				= 0x05,	// ex. 160*120, 10fps, 64kbps
}ENUM_QUALITY_LEVEL;


typedef enum
{
	AVIOTC_WIFIAPMODE_NULL				= 0x00,
	AVIOTC_WIFIAPMODE_MANAGED			= 0x01,
	AVIOTC_WIFIAPMODE_ADHOC				= 0x02,
}ENUM_AP_MODE;


typedef enum
{
	AVIOTC_WIFIAPENC_INVALID			= 0x00, 
	AVIOTC_WIFIAPENC_NONE				= 0x01, //
	AVIOTC_WIFIAPENC_WEP				= 0x02, //WEP, for no password
	AVIOTC_WIFIAPENC_WPA_TKIP			= 0x03, 
	AVIOTC_WIFIAPENC_WPA_AES			= 0x04, 
	AVIOTC_WIFIAPENC_WPA2_TKIP			= 0x05, 
	AVIOTC_WIFIAPENC_WPA2_AES			= 0x06,

	AVIOTC_WIFIAPENC_WPA_PSK_TKIP  = 0x07,
	AVIOTC_WIFIAPENC_WPA_PSK_AES   = 0x08,
	AVIOTC_WIFIAPENC_WPA2_PSK_TKIP = 0x09,
	AVIOTC_WIFIAPENC_WPA2_PSK_AES  = 0x0A,

}ENUM_AP_ENCTYPE;


// AVIOCTRL Event Type
typedef enum 
{
	AVIOCTRL_EVENT_ALL					= 0x00,	// all event type(general APP-->IPCamera)
	AVIOCTRL_EVENT_MOTIONDECT			= 0x01,	// motion detect start//==s==
	AVIOCTRL_EVENT_VIDEOLOST			= 0x02,	// video lost alarm
	AVIOCTRL_EVENT_IOALARM				= 0x03, // io alarmin start //---s--

	AVIOCTRL_EVENT_MOTIONPASS			= 0x04, // motion detect end  //==e==
	AVIOCTRL_EVENT_VIDEORESUME			= 0x05,	// video resume
	AVIOCTRL_EVENT_IOALARMPASS			= 0x06, // IO alarmin end   //---e--

	AVIOCTRL_EVENT_EXPT_REBOOT			= 0x10, // system exception reboot
	AVIOCTRL_EVENT_SDFAULT				= 0x11, // sd record exception
    AVIOCTRL_EVENT_AUDIO                = 0x12, // audio alarm
    AVIOCTRL_FIRMWARE_UPDATE_SUCCEED    = 0x13, // 升级固件成功通知
    AVIOCTRL_FIRMWARE_UPDATE_FAILED     = 0x14, // 升级固件成功失败
}ENUM_EVENTTYPE;

// AVIOCTRL Record Type
typedef enum
{
	AVIOTC_RECORDTYPE_OFF				= 0x00,
	AVIOTC_RECORDTYPE_FULLTIME			= 0x01,
	AVIOTC_RECORDTYPE_ALARM				= 0x02,
	AVIOTC_RECORDTYPE_MANUAL			= 0x03,
}ENUM_RECORD_TYPE;

// AVIOCTRL Play Record Command
typedef enum 
{
	AVIOCTRL_RECORD_PLAY_PAUSE			= 0x00,
	AVIOCTRL_RECORD_PLAY_STOP			= 0x01,
	AVIOCTRL_RECORD_PLAY_STEPFORWARD	= 0x02, //now, APP no use
	AVIOCTRL_RECORD_PLAY_STEPBACKWARD	= 0x03, //now, APP no use
	AVIOCTRL_RECORD_PLAY_FORWARD		= 0x04, //now, APP no use
	AVIOCTRL_RECORD_PLAY_BACKWARD		= 0x05, //now, APP no use
	AVIOCTRL_RECORD_PLAY_SEEKTIME		= 0x06, //now, APP no use
	AVIOCTRL_RECORD_PLAY_END			= 0x07,
	AVIOCTRL_RECORD_PLAY_START			= 0x10,
}ENUM_PLAYCONTROL;

// AVIOCTRL Environment Mode
typedef enum
{
	AVIOCTRL_ENVIRONMENT_INDOOR_50HZ 	= 0x00,
	AVIOCTRL_ENVIRONMENT_INDOOR_60HZ	= 0x01,
	AVIOCTRL_ENVIRONMENT_OUTDOOR		= 0x02,
	AVIOCTRL_ENVIRONMENT_NIGHT			= 0x03,	
}ENUM_ENVIRONMENT_MODE;

// AVIOCTRL Video Flip Mode
typedef enum
{
	AVIOCTRL_VIDEOMODE_NORMAL 			= 0x00,
	AVIOCTRL_VIDEOMODE_FLIP				= 0x01,
	AVIOCTRL_VIDEOMODE_MIRROR			= 0x02,
	AVIOCTRL_VIDEOMODE_FLIP_MIRROR 		= 0x03,
}ENUM_VIDEO_MODE;

// AVIOCTRL PTZ Command Value
typedef enum 
{
	AVIOCTRL_PTZ_STOP					= 0,
	AVIOCTRL_PTZ_UP						= 1,
	AVIOCTRL_PTZ_DOWN					= 2,
	AVIOCTRL_PTZ_LEFT					= 3,
	AVIOCTRL_PTZ_LEFT_UP				= 4,
	AVIOCTRL_PTZ_LEFT_DOWN				= 5,
	AVIOCTRL_PTZ_RIGHT					= 6, 
	AVIOCTRL_PTZ_RIGHT_UP				= 7, 
	AVIOCTRL_PTZ_RIGHT_DOWN				= 8, 
	AVIOCTRL_PTZ_AUTO					= 9, 
	AVIOCTRL_PTZ_SET_POINT				= 10,
	AVIOCTRL_PTZ_CLEAR_POINT			= 11,
	AVIOCTRL_PTZ_GOTO_POINT				= 12,

	AVIOCTRL_PTZ_SET_MODE_START			= 13,
	AVIOCTRL_PTZ_SET_MODE_STOP			= 14,
	AVIOCTRL_PTZ_MODE_RUN				= 15,

	AVIOCTRL_PTZ_MENU_OPEN				= 16, 
	AVIOCTRL_PTZ_MENU_EXIT				= 17,
	AVIOCTRL_PTZ_MENU_ENTER				= 18,

	AVIOCTRL_PTZ_FLIP					= 19,
	AVIOCTRL_PTZ_START					= 20,

	AVIOCTRL_LENS_APERTURE_OPEN			= 21,
	AVIOCTRL_LENS_APERTURE_CLOSE		= 22,

	AVIOCTRL_LENS_ZOOM_IN				= 23, 
	AVIOCTRL_LENS_ZOOM_OUT				= 24,

	AVIOCTRL_LENS_FOCAL_NEAR			= 25,
	AVIOCTRL_LENS_FOCAL_FAR				= 26,

	AVIOCTRL_AUTO_PAN_SPEED				= 27,
	AVIOCTRL_AUTO_PAN_LIMIT				= 28,
	AVIOCTRL_AUTO_PAN_START				= 29,

	AVIOCTRL_PATTERN_START				= 30,
	AVIOCTRL_PATTERN_STOP				= 31,
	AVIOCTRL_PATTERN_RUN				= 32,

	AVIOCTRL_SET_AUX					= 33,
	AVIOCTRL_CLEAR_AUX					= 34,
	AVIOCTRL_MOTOR_RESET_POSITION		= 35,
}ENUM_PTZCMD;



/////////////////////////////////////////////////////////////////////////////
///////////////////////// Message Body Define ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////

/*
IOTYPE_USER_IPCAM_START 				= 0x01FF,
IOTYPE_USER_IPCAM_STOP	 				= 0x02FF,
IOTYPE_USER_IPCAM_AUDIOSTART 			= 0x0300,
IOTYPE_USER_IPCAM_AUDIOSTOP 			= 0x0301,
IOTYPE_USER_IPCAM_SPEAKERSTART 			= 0x0350,
IOTYPE_USER_IPCAM_SPEAKERSTOP 			= 0x0351,
** @struct SMsgAVIoctrlAVStream
*/
typedef struct
{
	unsigned int channel; // Camera Index
	unsigned char reserved[4];
} SMsgAVIoctrlAVStream;


/*
IOTYPE_USER_IPCAM_GETSTREAMCTRL_REQ		= 0x0322,
** @struct SMsgAVIoctrlGetStreamCtrlReq
*/
typedef struct
{
	unsigned int channel;	// Camera Index
	unsigned char reserved[4];
}SMsgAVIoctrlGetStreamCtrlReq;

/*
IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ		= 0x0320,
IOTYPE_USER_IPCAM_GETSTREAMCTRL_RESP	= 0x0323,
** @struct SMsgAVIoctrlSetStreamCtrlReq, SMsgAVIoctrlGetStreamCtrlResq
*/
typedef struct
{
	unsigned int  channel;	// Camera Index
	unsigned char quality;	//refer to ENUM_QUALITY_LEVEL
	unsigned char reserved[3];
} SMsgAVIoctrlSetStreamCtrlReq, SMsgAVIoctrlGetStreamCtrlResq;

/*
IOTYPE_USER_IPCAM_SETSTREAMCTRL_RESP	= 0x0321,
** @struct SMsgAVIoctrlSetStreamCtrlResp
*/
typedef struct
{
	int result;	// 0: success; otherwise: failed.
	unsigned char reserved[4];
}SMsgAVIoctrlSetStreamCtrlResp;


/*
IOTYPE_USER_IPCAM_GETMOTIONDETECT_REQ	= 0x0326,
** @struct SMsgAVIoctrlGetMotionDetectReq
*/
typedef struct
{
	unsigned int channel; 	// Camera Index
	unsigned char reserved[4];
}SMsgAVIoctrlGetMotionDetectReq;


/*
IOTYPE_USER_IPCAM_SETMOTIONDETECT_REQ		= 0x0324,
IOTYPE_USER_IPCAM_GETMOTIONDETECT_RESP		= 0x0327,
** @struct SMsgAVIoctrlSetMotionDetectReq, SMsgAVIoctrlGetMotionDetectResp
*/
typedef struct
{
	unsigned int channel; 		// Camera Index
	unsigned int sensitivity; 	// 0(Disabled) ~ 100(MAX):
								// index		sensitivity value
								// 0			0
								// 1			25
								// 2			50
								// 3			75
								// 4			100
}SMsgAVIoctrlSetMotionDetectReq, SMsgAVIoctrlGetMotionDetectResp;


/*
IOTYPE_USER_IPCAM_SETMOTIONDETECT_RESP	= 0x0325,
** @struct SMsgAVIoctrlSetMotionDetectResp
*/
typedef struct
{
	int result;	// 0: success; otherwise: failed.
	unsigned char reserved[4];
}SMsgAVIoctrlSetMotionDetectResp;


/*
IOTYPE_USER_IPCAM_DEVINFO_REQ			= 0x0330,
** @struct SMsgAVIoctrlDeviceInfoReq
*/
typedef struct
{
	unsigned char reserved[4];
}SMsgAVIoctrlDeviceInfoReq;


/*
IOTYPE_USER_IPCAM_DEVINFO_RESP			= 0x0331,
** @struct SMsgAVIoctrlDeviceInfo
*/
typedef struct
{
	unsigned char model[16];	// IPCam mode
	unsigned char vendor[16];	// IPCam manufacturer
	unsigned int version;		// IPCam firmware version	ex. v1.2.3.4 => 0x01020304;  v1.0.0.2 => 0x01000002
	unsigned int channel;		// Camera index
	unsigned int total;			// 0: No cards been detected or an unrecognizeable sdcard that could not be re-formatted.
								// -1: if camera detect an unrecognizable sdcard, and could be re-formatted
								// otherwise: return total space size of sdcard (MBytes)								
								
	unsigned int free;			// Free space size of sdcard (MBytes)
	unsigned char reserved[8];	// reserved
}SMsgAVIoctrlDeviceInfoResp;

/*
IOTYPE_USER_IPCAM_SETPASSWORD_REQ		= 0x0332,
** @struct SMsgAVIoctrlSetPasswdReq
*/
typedef struct
{
	char oldpasswd[32];			// The old security code
	char newpasswd[32];			// The new security code
}SMsgAVIoctrlSetPasswdReq;


/*
IOTYPE_USER_IPCAM_SETPASSWORD_RESP		= 0x0333,
** @struct SMsgAVIoctrlSetPasswdResp
*/
typedef struct
{
	int result;	// 0: success; otherwise: failed.
	unsigned char reserved[4];
}SMsgAVIoctrlSetPasswdResp;


/*
IOTYPE_USER_IPCAM_LISTWIFIAP_REQ		= 0x0340,
** @struct SMsgAVIoctrlListWifiApReq
*/
typedef struct
{
	unsigned char reserved[4];
}SMsgAVIoctrlListWifiApReq;

typedef struct
{
	char ssid[32]; 				// WiFi ssid
	char mode;	   				// refer to ENUM_AP_MODE
	char enctype;  				// refer to ENUM_AP_ENCTYPE
	char signal;   				// signal intensity 0--100%
	char status;   				// 0 : invalid ssid or disconnected
								// 1 : connected with default gateway
								// 2 : unmatched password
								// 3 : weak signal and connected
								// 4 : selected:
								//		- password matched and
								//		- disconnected or connected but not default gateway
}SWifiAp;

/*
IOTYPE_USER_IPCAM_LISTWIFIAP_RESP		= 0x0341,
** @struct SMsgAVIoctrlListWifiApResp
*/
typedef struct
{
	unsigned int number; // MAX number: 1024(IOCtrl packet size) / 36(bytes) = 28
	SWifiAp stWifiAp[1];
}SMsgAVIoctrlListWifiApResp;

/*
IOTYPE_USER_IPCAM_SETWIFI_REQ			= 0x0342,
** @struct SMsgAVIoctrlSetWifiReq
*/
typedef struct
{
	unsigned char ssid[32];			//WiFi ssid
	unsigned char password[32];		//if exist, WiFi password
	unsigned char mode;				//refer to ENUM_AP_MODE
	unsigned char enctype;			//refer to ENUM_AP_ENCTYPE
	unsigned char reserved[10];
}SMsgAVIoctrlSetWifiReq;

//IOTYPE_USER_IPCAM_SETWIFI_REQ_2		= 0x0346,
typedef struct
{
	unsigned char ssid[32];		// WiFi ssid
	unsigned char password[64];	// if exist, WiFi password
	unsigned char mode;			// refer to ENUM_AP_MODE
	unsigned char enctype;		// refer to ENUM_AP_ENCTYPE
	unsigned char reserved[10];
}SMsgAVIoctrlSetWifiReq2;

/*
IOTYPE_USER_IPCAM_SETWIFI_RESP			= 0x0343,
** @struct SMsgAVIoctrlSetWifiResp
*/
typedef struct
{
	int result; //0: wifi connected; 1: failed to connect
	unsigned char reserved[4];
}SMsgAVIoctrlSetWifiResp;

/*
IOTYPE_USER_IPCAM_GETWIFI_REQ			= 0x0344,
** @struct SMsgAVIoctrlGetWifiReq
*/
typedef struct
{
	unsigned char reserved[4];
}SMsgAVIoctrlGetWifiReq;

/*
IOTYPE_USER_IPCAM_GETWIFI_RESP			= 0x0345,
** @struct SMsgAVIoctrlGetWifiResp //if no wifi connected, members of SMsgAVIoctrlGetWifiResp are all 0
*/
typedef struct
{
	unsigned char ssid[32];		// WiFi ssid
	unsigned char password[32]; // WiFi password if not empty
	unsigned char mode;			// refer to ENUM_AP_MODE
	unsigned char enctype;		// refer to ENUM_AP_ENCTYPE
	unsigned char signal;		// signal intensity 0--100%
	unsigned char status;		// refer to "status" of SWifiAp
}SMsgAVIoctrlGetWifiResp;

//changed: WI-FI Password 32bit Change to 64bit 
//IOTYPE_USER_IPCAM_GETWIFI_RESP_2    = 0x0347,
typedef struct
{
 unsigned char ssid[32];	 // WiFi ssid
 unsigned char password[64]; // WiFi password if not empty
 unsigned char mode;	// refer to ENUM_AP_MODE
 unsigned char enctype; // refer to ENUM_AP_ENCTYPE
 unsigned char signal;  // signal intensity 0--100%
 unsigned char status;  // refer to "status" of SWifiAp
}SMsgAVIoctrlGetWifiResp2;

/*
IOTYPE_USER_IPCAM_GETRECORD_REQ			= 0x0312,
** @struct SMsgAVIoctrlGetRecordReq
*/
typedef struct
{
	unsigned int channel; // Camera Index
	unsigned char reserved[4];
}SMsgAVIoctrlGetRecordReq;

/*
IOTYPE_USER_IPCAM_SETRECORD_REQ			= 0x0310,
IOTYPE_USER_IPCAM_GETRECORD_RESP		= 0x0313,
** @struct SMsgAVIoctrlSetRecordReq, SMsgAVIoctrlGetRecordResq
*/
typedef struct
{
	unsigned int channel;		// Camera Index
	unsigned int recordType;	// Refer to ENUM_RECORD_TYPE
	unsigned char reserved[4];
}SMsgAVIoctrlSetRecordReq, SMsgAVIoctrlGetRecordResq;

/*
IOTYPE_USER_IPCAM_SETRECORD_RESP		= 0x0311,
** @struct SMsgAVIoctrlSetRecordResp
*/
typedef struct
{
	int result;	// 0: success; otherwise: failed.
	unsigned char reserved[4];
}SMsgAVIoctrlSetRecordResp;


/*
IOTYPE_USER_IPCAM_GETRCD_DURATION_REQ	= 0x0316,
** @struct SMsgAVIoctrlGetRcdDurationReq
*/
typedef struct
{
	unsigned int channel; // Camera Index
	unsigned char reserved[4];
}SMsgAVIoctrlGetRcdDurationReq;

/*
IOTYPE_USER_IPCAM_SETRCD_DURATION_REQ	= 0x0314,
IOTYPE_USER_IPCAM_GETRCD_DURATION_RESP  = 0x0317,
** @struct SMsgAVIoctrlSetRcdDurationReq, SMsgAVIoctrlGetRcdDurationResp
*/
typedef struct
{
	unsigned int channel; 		// Camera Index
	unsigned int presecond; 	// pre-recording (sec)
	unsigned int durasecond;	// recording (sec)
}SMsgAVIoctrlSetRcdDurationReq, SMsgAVIoctrlGetRcdDurationResp;


/*
IOTYPE_USER_IPCAM_SETRCD_DURATION_RESP  = 0x0315,
** @struct SMsgAVIoctrlSetRcdDurationResp
*/
typedef struct
{
	int result;	// 0: success; otherwise: failed.
	unsigned char reserved[4];
}SMsgAVIoctrlSetRcdDurationResp;


typedef struct
{
	unsigned short year;	// The number of year.
	unsigned char month;	// The number of months since January, in the range 1 to 12.
	unsigned char day;		// The day of the month, in the range 1 to 31.
	unsigned char wday;		// The number of days since Sunday, in the range 0 to 6. (Sunday = 0, Monday = 1, ...)
	unsigned char hour;     // The number of hours past midnight, in the range 0 to 23.
	unsigned char minute;   // The number of minutes after the hour, in the range 0 to 59.
	unsigned char second;   // The number of seconds after the minute, in the range 0 to 59.
}STimeDay;

/*
IOTYPE_USER_IPCAM_LISTEVENT_REQ			= 0x0318,
** @struct SMsgAVIoctrlListEventReq
*/
typedef struct
{
	unsigned int channel; 		// Camera Index
	STimeDay stStartTime; 		// Search event from ...
	STimeDay stEndTime;	  		// ... to (search event)
	unsigned char event;  		// event type, refer to ENUM_EVENTTYPE
	unsigned char status; 		// 0x00: Recording file exists, Event unreaded
								// 0x01: Recording file exists, Event readed
								// 0x02: No Recording file in the event
	unsigned char reserved[2];
}SMsgAVIoctrlListEventReq;


typedef struct
{
	STimeDay stTime;
	unsigned char event;
	unsigned char status;	// 0x00: Recording file exists, Event unreaded
							// 0x01: Recording file exists, Event readed
							// 0x02: No Recording file in the event
	unsigned char reserved[2];
}SAvEvent;
	
/*
IOTYPE_USER_IPCAM_LISTEVENT_RESP		= 0x0319,
** @struct SMsgAVIoctrlListEventResp
*/
typedef struct
{
	unsigned int  channel;		// Camera Index
	unsigned int  total;		// Total event amount in this search session
	unsigned char index;		// package index, 0,1,2...; 
								// because avSendIOCtrl() send package up to 1024 bytes one time, you may want split search results to serveral package to send.
	unsigned char endflag;		// end flag; endFlag = 1 means this package is the last one.
	unsigned char count;		// how much events in this package
	unsigned char reserved[1];
	SAvEvent stEvent[1];		// The first memory address of the events in this package
}SMsgAVIoctrlListEventResp;

	
/*
IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL 	= 0x031A,
** @struct SMsgAVIoctrlPlayRecord
*/
typedef struct
{
	unsigned int channel;	// Camera Index
	unsigned int command;	// play record command. refer to ENUM_PLAYCONTROL
	unsigned int Param;		// command param, that the user defined
	STimeDay stTimeDay;		// Event time from ListEvent
	unsigned char reserved[4];
} SMsgAVIoctrlPlayRecord;

/*
IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL_RESP 	= 0x031B,
** @struct SMsgAVIoctrlPlayRecordResp
*/
typedef struct
{
	unsigned int command;	// Play record command. refer to ENUM_PLAYCONTROL
	unsigned int result; 	// Depends on command
							// when is AVIOCTRL_RECORD_PLAY_START:
							//	result>=0   real channel no used by device for playback
							//	result <0	error
							//			-1	playback error
							//			-2	exceed max allow client amount
	unsigned char reserved[4];
} SMsgAVIoctrlPlayRecordResp; // only for play record start command


/*
IOTYPE_USER_IPCAM_PTZ_COMMAND	= 0x1001,	// P2P Ptz Command Msg 
** @struct SMsgAVIoctrlPtzCmd
*/
typedef struct
{
	unsigned char control;	// PTZ control command, refer to ENUM_PTZCMD
	unsigned char speed;	// PTZ control speed
	unsigned char point;	// no use in APP so far. preset position, for RS485 PT
	unsigned char limit;	// no use in APP so far. 
	unsigned char aux;		// no use in APP so far. auxiliary switch, for RS485 PT
	unsigned char channel;	// camera index
	unsigned char reserve[2];
} SMsgAVIoctrlPtzCmd;

/*
IOTYPE_USER_IPCAM_EVENT_REPORT	= 0x1FFF,	// Device Event Report Msg 
*/
/** @struct SMsgAVIoctrlEvent
 */
typedef struct
{
	STimeDay stTime;
	unsigned long time; 	// UTC Time
	unsigned int  channel; 	// Camera Index
	unsigned int  event; 	// Event Type
	unsigned char reserved[4];
} SMsgAVIoctrlEvent;



#if 0

/* 	IOTYPE_USER_IPCAM_GET_EVENTCONFIG_REQ	= 0x0400,	// Get Event Config Msg Request 
 */
/** @struct SMsgAVIoctrlGetEventConfig
 */
typedef struct
{
	unsigned int	channel; 		  //Camera Index
	unsigned char   externIoOutIndex; //extern out index: bit0->io0 bit1->io1 ... bit7->io7;=1: get this io value or not get
    unsigned char   externIoInIndex;  //extern in index: bit0->io0 bit1->io1 ... bit7->io7; =1: get this io value or not get
	char reserved[2];
} SMsgAVIoctrlGetEventConfig;
 
/*
	IOTYPE_USER_IPCAM_GET_EVENTCONFIG_RESP	= 0x0401,	// Get Event Config Msg Response 
	IOTYPE_USER_IPCAM_SET_EVENTCONFIG_REQ	= 0x0402,	// Set Event Config Msg req 
*/
/* @struct SMsgAVIoctrlSetEventConfig
 * @struct SMsgAVIoctrlGetEventCfgResp
 */
typedef struct
{
	unsigned int    channel;        // Camera Index
	unsigned char   mail;           // enable send email
	unsigned char   ftp;            // enable ftp upload photo
	unsigned char   externIoOutStatus;   // enable extern io output //bit0->io0 bit1->io1 ... bit7->io7; 1:on; 0:off
	unsigned char   p2pPushMsg;			 // enable p2p push msg
	unsigned char   externIoInStatus;    // enable extern io input  //bit0->io0 bit1->io1 ... bit7->io7; 1:on; 0:off
	char            reserved[3];
}SMsgAVIoctrlSetEventConfig, SMsgAVIoctrlGetEventCfgResp;

/*
	IOTYPE_USER_IPCAM_SET_EVENTCONFIG_RESP	= 0x0403,	// Set Event Config Msg resp 
*/
/** @struct SMsgAVIoctrlSetEventCfgResp
 */
typedef struct
{
	unsigned int channel; 	// Camera Index
	unsigned int result;	// 0: success; otherwise: failed.
}SMsgAVIoctrlSetEventCfgResp;

#endif


/*
IOTYPE_USER_IPCAM_SET_ENVIRONMENT_REQ		= 0x0360,
** @struct SMsgAVIoctrlSetEnvironmentReq
*/
typedef struct
{
	unsigned int channel;		// Camera Index
	unsigned char mode;			// refer to ENUM_ENVIRONMENT_MODE
	unsigned char reserved[3];
}SMsgAVIoctrlSetEnvironmentReq;


/*
IOTYPE_USER_IPCAM_SET_ENVIRONMENT_RESP		= 0x0361,
** @struct SMsgAVIoctrlSetEnvironmentResp
*/
typedef struct
{
	unsigned int channel; 		// Camera Index
	unsigned char result;		// 0: success; otherwise: failed.
	unsigned char reserved[3];
}SMsgAVIoctrlSetEnvironmentResp;


/*
IOTYPE_USER_IPCAM_GET_ENVIRONMENT_REQ		= 0x0362,
** @struct SMsgAVIoctrlGetEnvironmentReq
*/
typedef struct
{
	unsigned int channel; 	// Camera Index
	unsigned char reserved[4];
}SMsgAVIoctrlGetEnvironmentReq;

/*
IOTYPE_USER_IPCAM_GET_ENVIRONMENT_RESP		= 0x0363,
** @struct SMsgAVIoctrlGetEnvironmentResp
*/
typedef struct
{
	unsigned int channel; 		// Camera Index
	unsigned char mode;			// refer to ENUM_ENVIRONMENT_MODE
	unsigned char reserved[3];
}SMsgAVIoctrlGetEnvironmentResp;


/*
IOTYPE_USER_IPCAM_SET_VIDEOMODE_REQ			= 0x0370,
** @struct SMsgAVIoctrlSetVideoModeReq
*/
typedef struct
{
	unsigned int channel;	// Camera Index
	unsigned char mode;		// refer to ENUM_VIDEO_MODE
	unsigned char reserved[3];
}SMsgAVIoctrlSetVideoModeReq;


/*
IOTYPE_USER_IPCAM_SET_VIDEOMODE_RESP		= 0x0371,
** @struct SMsgAVIoctrlSetVideoModeResp
*/
typedef struct
{
	unsigned int channel; 	// Camera Index
	unsigned char result;	// 0: success; otherwise: failed.
	unsigned char reserved[3];
}SMsgAVIoctrlSetVideoModeResp;


/*
IOTYPE_USER_IPCAM_GET_VIDEOMODE_REQ			= 0x0372,
** @struct SMsgAVIoctrlGetVideoModeReq
*/
typedef struct
{
	unsigned int channel; 	// Camera Index
	unsigned char reserved[4];
}SMsgAVIoctrlGetVideoModeReq;


/*
IOTYPE_USER_IPCAM_GET_VIDEOMODE_RESP		= 0x0373,
** @struct SMsgAVIoctrlGetVideoModeResp
*/
typedef struct
{
	unsigned int  channel; 	// Camera Index
	unsigned char mode;		// refer to ENUM_VIDEO_MODE
	unsigned char reserved[3];
}SMsgAVIoctrlGetVideoModeResp;


/*
/IOTYPE_USER_IPCAM_FORMATEXTSTORAGE_REQ			= 0x0380,
** @struct SMsgAVIoctrlFormatExtStorageReq
*/
typedef struct
{
	unsigned int storage; 	// Storage index (ex. sdcard slot = 0, internal flash = 1, ...)
	unsigned char reserved[4];
}SMsgAVIoctrlFormatExtStorageReq;


/*
IOTYPE_USER_IPCAM_FORMATEXTSTORAGE_REQ		= 0x0381,
** @struct SMsgAVIoctrlFormatExtStorageResp
*/
typedef struct
{
	unsigned int  storage; 	// Storage index
	unsigned char result;	// 0: success;
							// -1: format command is not supported.
							// otherwise: failed.
	unsigned char reserved[3];
}SMsgAVIoctrlFormatExtStorageResp;


typedef struct
{
	unsigned short index;		// the stream index of camera
	unsigned short channel;		// the channel index used in AVAPIs, that is ChID in avServStart2(...,ChID)
	char reserved[4];
}SStreamDef;


/*	IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ			= 0x0328,
 */
typedef struct
{
	unsigned char reserved[4];
}SMsgAVIoctrlGetSupportStreamReq;


/*	IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_RESP			= 0x0329,
 */
typedef struct
{
	unsigned int number; 		// the quanity of supported audio&video stream or video stream
	SStreamDef streams[1];
}SMsgAVIoctrlGetSupportStreamResp;


/* IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ			= 0x032A, //used to speak. but once camera is connected by App, send this at once.
 */
typedef struct
{
	unsigned int channel;		// camera index
	char reserved[4];
}SMsgAVIoctrlGetAudioOutFormatReq;

/* IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_RESP			= 0x032B,
 */
typedef struct
{
	unsigned int channel;		// camera index
	int format;					// refer to ENUM_CODECID in AVFRAMEINFO.h
	char reserved[4];
}SMsgAVIoctrlGetAudioOutFormatResp;

/* IOTYPE_USER_IPCAM_RECEIVE_FIRST_IFRAME			= 0x1002,
 */
typedef struct
{
	unsigned int channel;		// camera index
	char reserved[4];
}SMsgAVIoctrlReceiveFirstIFrame;

/* IOTYPE_USER_IPCAM_GET_FLOWINFO_REQ              = 0x390
 */
typedef struct
{
	unsigned int channel;			// camera index
	unsigned int collect_interval;	// seconds of interval to collect flow information
									// send 0 indicates stop collecting.
}SMsgAVIoctrlGetFlowInfoReq;

/* IOTYPE_USER_IPCAM_GET_FLOWINFO_RESP            = 0x391
 */
typedef struct
{
	unsigned int channel;			// camera index
	unsigned int collect_interval;	// seconds of interval client will collect flow information
}SMsgAVIoctrlGetFlowInfoResp;

/* IOTYPE_USER_IPCAM_CURRENT_FLOWINFO              = 0x392
 */
typedef struct
{
	unsigned int channel;						// camera index
	unsigned int total_frame_count;				// Total frame count in the specified interval
	unsigned int lost_incomplete_frame_count;	// Total lost and incomplete frame count in the specified interval
	unsigned int total_expected_frame_size;		// Total expected frame size from avRecvFrameData2()
	unsigned int total_actual_frame_size;		// Total actual frame size from avRecvFrameData2()
	unsigned int timestamp_ms;					// Timestamp in millisecond of this report.
	char reserved[8];
}SMsgAVIoctrlCurrentFlowInfo;

/* IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ               = 0x3A0
 * IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP              = 0x3A1
 * IOTYPE_USER_IPCAM_SET_TIMEZONE_REQ               = 0x3B0
 * IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP              = 0x3B1
 */
typedef struct
{
	int cbSize;							// the following package size in bytes, should be sizeof(SMsgAVIoctrlTimeZone)
	int nIsSupportTimeZone;				// device is support TimeZone or not, 1: Supported, 0: Unsupported.
	int nGMTDiff;						// the difference between GMT in hours
	char szTimeZoneString[256];			// the timezone description string in multi-bytes char format
}SMsgAVIoctrlTimeZone;

//================================iBaby================================//

//--------------------------------OSD----------------------------------//
/* IOTYPE_USER_IPCAM_GET_OSD_REQ				= 0x2201,   */
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetOSDReq;

/* IOTYPE_USER_IPCAM_GET_OSD_RESP			  = 0x2202,   */
/* IOTYPE_USER_IPCAM_SET_OSD_REQ				= 0x2203,   */
typedef struct
{
    char sName[64];	/* OSD name */
    unsigned char blEnTime;	/* time osd: 0:show, 1:hide */
    unsigned char blEnName;	/* name osd: 0:show, 1:hide */
    unsigned char reserved1[2];
    unsigned char reserved2[8];
} SMsgAVIoctrlGetOSDResp, SMsgAVIoctrlSetOSDReq;

/* IOTYPE_USER_IPCAM_SET_OSD_RESP			  = 0x2204,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlSetOSDResp;


//--------------------------------MD----------------------------------//
/* IOTYPE_USER_IPCAM_GET_MD_REQ				  = 0x2205,   */
typedef struct
{
	unsigned int  u32Area; /* 1~4 */
	unsigned char reserved[8];
}SMsgAVIoctrlGetMDReq;

/* IOTYPE_USER_IPCAM_GET_MD_RESP			  = 0x2206,   */
/* IOTYPE_USER_IPCAM_SET_MD_REQ				  = 0x2207,   */
typedef struct
{
	unsigned int u32Area; /* 1~4 */
	unsigned int u32Sensitivity;  /* 1~99 */
	unsigned int u32X;
	unsigned int u32Y;
	unsigned int u32Width;
	unsigned int u32Height;
	unsigned char blEnable; /* 0:enable, 1:disable */
	unsigned char reserved1[3];
	unsigned char reserved2[4];
} SMsgAVIoctrlGetMDResp, SMsgAVIoctrlSetMDReq;

/* IOTYPE_USER_IPCAM_SET_MD_RESP			  = 0x2208,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlSetMDResp;


//--------------------------------ALARM LINK----------------------------------//
/* IOTYPE_USER_IPCAM_GET_ALARMLINK_REQ			= 0x2209,   */
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetAlarmLinkReq;

/* IOTYPE_USER_IPCAM_GET_ALARMLINK_RESP			= 0x220A,   */
/* IOTYPE_USER_IPCAM_SET_ALARMLINK_REQ			= 0x220B,   */
typedef struct
{
	unsigned int  u32Interval; /* 30~60, default:30 */
	unsigned char reserved[8];
} SMsgAVIoctrlGetAlarmLinkResp, SMsgAVIoctrlSetAlarmLinkReq;

/* IOTYPE_USER_IPCAM_SET_ALARMLINK_RESP			= 0x220C,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlSetAlarmLinkResp;


//--------------------------------AUDIO ALARM----------------------------------//
/* IOTYPE_USER_IPCAM_GET_AUDIOALARM_REQ			= 0x220D,   */
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetAudioAlarmReq;

/* IOTYPE_USER_IPCAM_GET_AUDIOALARM_RESP		= 0x220E,   */
/* IOTYPE_USER_IPCAM_SET_AUDIOALARM_REQ			= 0x220F,   */
typedef struct
{
	unsigned int  u32Enable;// 0:disable, 1:enable
	unsigned int  u32Value; //µ•ŒªŒ™1, 1-100
	unsigned char reserved[8];
} SMsgAVIoctrlGetAudioAlarmResp, SMsgAVIoctrlSetAudioAlarmReq;

/* IOTYPE_USER_IPCAM_SET_AUDIOALARM_RESP		= 0x2210,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlSetAudioAlarmResp;


//④、录像抓拍
/* IOTYPE_USER_IPCAM_GET_REC_REQ		        = 0x2211,   */
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetRecReq;

/* IOTYPE_USER_IPCAM_GET_REC_RESP		        = 0x2212,   */
/* IOTYPE_USER_IPCAM_SET_REC_REQ		        = 0x2213,   */
typedef struct
{
	unsigned int  u32RecChn;    /* 11, 12, 13*/
	unsigned int  u32PlanRecEnable; /* 0:disable, 1:enable */
	unsigned int  u32PlanRecLen; //定时录像文件时长
	unsigned int  u32AlarmRecEnable; /* 0:disable, 1:enable */
	unsigned int  u32AlarmRecLen; //报警录像文件时长,预报警录像+报警录像,5+10=15秒.
	unsigned char reserved[8];
} SMsgAVIoctrlGetRecResp, SMsgAVIoctrlSetRecReq;

/* IOTYPE_USER_IPCAM_SET_REC_RESP		        = 0x2214,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlSetRecResp;

/* IOTYPE_USER_IPCAM_GET_SNAP_REQ		        = 0x2215,   */
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetSnapReq;

/* IOTYPE_USER_IPCAM_GET_SNAP_RESP		        = 0x2216,   */
/* IOTYPE_USER_IPCAM_SET_SNAP_REQ		        = 0x2217,   */
typedef struct
{
	unsigned int  u32SnapEnable;  /* 0:disable, 1:enable */
	unsigned int  u32SnapChn;      /* 11, 12, 13*/
	unsigned int  u32SnapInterval; /* 5s ~ 24*60*60s  */
	unsigned int  u32SnapCount; /* 1-3 */
	unsigned char reserved[8];
} SMsgAVIoctrlGetSnapResp, SMsgAVIoctrlSetSnapReq;

/* IOTYPE_USER_IPCAM_SET_SNAP_RESP		        = 0x2218,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlSetSnapResp;

//⑤、报警布防，定时录像，定时抓拍时刻表
/* IOTYPE_USER_IPCAM_GET_SCHEDULE_REQ			= 0x2219,   */
typedef enum
{
    AVIOTC_SCHEDULETYPE_ALARM		= 0x00,
	AVIOTC_SCHEDULETYPE_PLAN		= 0x01,
	AVIOTC_SCHEDULETYPE_SNAP		= 0x02,
	AVIOTC_SCHEDULETYPE_BUTT
}ENUM_SCHEDULE_TYPE;

typedef struct
{
	unsigned int  u32Type; //refer to ENUM_SCHEDULE_TYPE
	unsigned char reserved[8];
}SMsgAVIoctrlGetScheduleReq;

/* IOTYPE_USER_IPCAM_GET_SCHEDULE_RESP		= 0x221A,   */
/* IOTYPE_USER_IPCAM_SET_SCHEDULE_REQ			= 0x221B,   */
typedef struct
{
	unsigned int  u32ScheduleType;		//refer to ENUM_SCHEDULE_TYPE
	char          sDayData[7][48+1];	//P:yes, N:no
	unsigned char reserved1[1];
	unsigned char reserved2[8];
} SMsgAVIoctrlGetScheduleResp, SMsgAVIoctrlSetScheduleReq;
/*
 备注：sDayData参数包括整周7天的数据，每天以48个字符来表示,即一天24小时的录像配置字符串(每天24小时将细分为半小时为一个时间段,用字符P或者N表示是否开启录像,P表示开启,N表示关闭),时间从零点零分开始计算。
 */
/* IOTYPE_USER_IPCAM_SET_SCHEDULE_RESP		= 0x221C,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlSetScheduleResp;


//⑥、音乐播放
/* IOTYPE_USER_IPCAM_FLASHFILE_START		= 0x2220,   */
/* IOTYPE_USER_IPCAM_FLASHFILE_STOP		 = 0x2221,   */
/* IOTYPE_USER_IPCAM_TEMPFILE_START		= 0x2222,   */
/* IOTYPE_USER_IPCAM_TEMPFILE_STOP		    = 0x2223,   */
typedef struct
{
	unsigned int channel; //transport channel
	unsigned int filetype; //0:flash, 1:temp
	unsigned int fileindex; //save index, use for flash type
	char         szFileName[32];//save name, use for flash type
	unsigned char reserved[8];
} SMsgAVIoctrlFileTransport;

/* IOTYPE_USER_IPCAM_GET_FILEINFO_REQ			    = 0x2224,   */
typedef struct
{
	unsigned int  index;
	unsigned char reserved[8];
}SMsgAVIoctrlGetFileInfoReq;

/* IOTYPE_USER_IPCAM_GET_FILEINFO_RESP		    = 0x2225,   */
/* IOTYPE_USER_IPCAM_SET_FILEINFO_REQ			= 0x2226,   */
#define MAX_FILE_NUM  4
typedef struct
{
	unsigned int  index; //save index
	unsigned int  u32FileSize; // only for get
	char          szFileName[32];
	unsigned char reserved[8];
}SMsgAVIoctrlGetFileInfoResp, SMsgAVIoctrlSetFileInfoReq;



/* IOTYPE_USER_IPCAM_SET_FILEINFO_RESP		    = 0x2227,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlSetFileInfoResp;

/* IOTYPE_USER_IPCAM_PLAY_MUSIC_REQ			      = 0x2228,   */
typedef enum
{
	AVIOTC_PLAYMODE_STOP		=0X00,   //停止
	AVIOTC_PLAYMODE_SINGLE		= 0x01,   //单曲播放
	AVIOTC_PLAYMODE_LIST		= 0x02,   //列表播放，预留
}ENUM_PLAY_MODE;

typedef struct
{
	unsigned int index; //file index
    unsigned char musicurl[512];
	unsigned int mode; // refer to ENUM_PLAY_MODE
	unsigned int loop;	 // 循环播放 0: no, 1:yes
	unsigned char reserved[8];
}SMsgAVIoctrlPlayMusicReq;


/* IOTYPE_USER_IPCAM_PLAY_MUSIC_RESP		      = 0x2229,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlPlayMusicResp;

/* IOTYPE_USER_IPCAM_GET_PLAYLIST_REQ			  = 0x222A,   */
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetPlayListReq;

/* IOTYPE_USER_IPCAM_GET_PLAYLIST_RESP		    = 0x222B,   */
/* IOTYPE_USER_IPCAM_EDIT_PLAYLIST_REQ			= 0x222C,   */
typedef struct
{
	unsigned int  playlist[MAX_FILE_NUM]; //the file index in flash
	unsigned char reserved[8];
}SMsgAVIoctrlGetPlayListResp, SMsgAVIoctrlEditPlayListReq;

//typedef struct
//{
//	SMsgAVIoctrlSetFileInfoReq  playlist[MAX_FILE_NUM];
//	unsigned char reserved[8];
//}SMsgAVIoctrlGetPlayListRespExt, SMsgAVIoctrlEditPlayListReqExt;

typedef struct
{
	SMsgAVIoctrlGetFileInfoResp  FileInfoList[4];
	unsigned char reserved[8];
}SMsgAVIoctrlGetPlayListRespExt;

/* IOTYPE_USER_IPCAM_EDIT_PLAYLIST_RESP		  = 0x222D,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlEditPlayListResp;


//⑦、系统时间
/* IOTYPE_USER_IPCAM_GET_SVRTIME_REQ			= 0x2230,   */
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetSvrTimeReq;

/* IOTYPE_USER_IPCAM_GET_SVRTIME_RESP		    = 0x2231,   */
/* IOTYPE_USER_IPCAM_SET_SVRTIME_REQ			= 0x2232,   */
typedef struct
{
	char     szTime[32]; //such as "2013.04.27.10.55.08"
	char     szTimeZone[32]; //请查看附录A时区表
	unsigned int u32DstMode;
	unsigned char reserved[8];
}SMsgAVIoctrlGetSvrTimeResp, SMsgAVIoctrlSetSvrTimeReq;
/* IOTYPE_USER_IPCAM_SET_SVRTIME_RESP		  = 0x2233,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlSetSvrTimeResp;


//⑧、升级
/* IOTYPE_USER_IPCAM_UPGRADE_REQ			= 0x22FE,   */
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlUpgradeReq;

/* IOTYPE_USER_IPCAM_UPGRADE_RESP		  = 0x22FF,   */
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[8];
}SMsgAVIoctrlUpgradeResp;

//9、私有用户数据
/* IOTYPE_USER_IPCAM_GET_USERDATA_REQ		    = 0x2244 */
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetUserdataReq;

/* IOTYPE_USER_IPCAM_GET_USERDATA_RESP		    = 0x2245 */
typedef struct
{
	unsigned int u32Len;	//数据长度
	unsigned char szUserdata[128];		//数据
	unsigned char reserved[8];
}SMsgAVIoctrlGetUserdataResp;


//10、删除音乐文件
//IOTYPE_USER_IPCAM_DEL_MUSIC_REQ		    = 0x2246,
typedef struct
{
	unsigned int index; //file index 1~4
    unsigned char reserved[8];
}SMsgAVIoctrlDelMusicReq;




//IOTYPE_USER_IPCAM_DEL_MUSIC_RESP		    = 0x2247,

typedef struct
{
	unsigned int result; //0 success ,other failed
	unsigned char reserved[8];
}SMsgAVIoctrlDelMusicResp;


//11、音乐播放状态
//IOTYPE_USER_IPCAM_GET_MUSIC_STATE_REQ		    = 0x2248,
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetMusicStateReq;


//IOTYPE_USER_IPCAM_GET_MUSIC_STATE_RESP		    = 0x2249,
typedef struct
{
	unsigned int index; //file index 1~4 0:no music is playing
    unsigned int mode; // 1:downloading  2:error 3:play 4:stop, 5. pause //ENUM_PLAY_MODE
    int content; // only play and pause should read this value. seconds
	unsigned char reserved[4];
}SMsgAVIoctrlGetMusicStateResp;

//IOTYPE_USER_IPCAM_GET_SOUND_VOLUME_REQ			= 0x224C,
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetSoundReq;
//IOTYPE_USER_IPCAM_SET_SOUND_VOLUME_RESP		= 0x224F,
typedef struct
{
	unsigned int  result;	// 0: success; otherwise: failed.
	unsigned char reserved[4];
}SMsgAVIoctrlSetSoundResp;

//IOTYPE_USER_IPCAM_GET_SOUND_VOLUME_RESP		= 0x224D,
//IOTYPE_USER_IPCAM_SET_SOUND_VOLUME_REQ			= 0x224E,
typedef struct
{
	unsigned int SoundIn; //1-100
	unsigned int SoundOut; //1-100
	unsigned char reserved[8];
}SMsgAVIoctrlGetSoundResp,SMsgAVIoctrlSetSoundReq;

//IOTYPE_USER_IPCAM_GET_ALARMREC_STATE_REQ		= 0x2250,
typedef struct
{
	unsigned char reserved[8];
} SMsgAVIoctrlGetAlarmRecStateReq;

//IOTYPE_USER_IPCAM_GET_ ALARMREC_STATE_RESP		= 0x2251,
typedef struct
{
	unsigned int state; //0: 即不拍照也不录像, 1: 拍照，2: 录像, 默认值为: 1
	unsigned char reserved[8];
}SMsgAVIoctrlGetAlarmRecStateResp;

//IOTYPE_USER_IPCAM_SET_ ALARMREC_STATE_REQ		= 0x2252,
typedef struct
{
	unsigned int state; //0: 即不拍照也不录像, 1: 拍照，2: 录像, 默认值为: 1
	unsigned char reserved[8];
}SMsgAVIoctrlSetAlarmRecStateReq;

//IOTYPE_USER_IPCAM_SET_ ALARMREC_STATE _RESP		= 0x2253,
typedef struct
{
	unsigned int result; //0 success, others :fail
	unsigned char reserved[8];
}SMsgAVIoctrlSetAlarmRecStateResp;

//12. 夜视灯控制

//IOTYPE_USER_IPCAM_GET_NIGHTVISION_REQ		    = 0x2260,
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlGetNightVisionReq;


//IOTYPE_USER_IPCAM_GET_NIGHTVISION_RESP		    = 0x2261,
typedef struct
{
	unsigned int state; //  0  auto, 1,常开，2 关闭
	unsigned char reserved[8];
}SMsgAVIoctrlGetNightVisionResp;

//IOTYPE_USER_IPCAM_SET_NIGHTVISION_REQ		    = 0x2262
typedef struct
{
	unsigned int state; //   0  auto, 1,常开，2 关闭
	unsigned char reserved[8];
} SMsgAVIoctrlSetNightVisionReq;

//IOTYPE_USER_IPCAM_SET_NIGHTVISION_RESP		    = 0x2263
typedef struct
{
	unsigned int result; //  0 success others fail
	unsigned char reserved[8];
}SMsgAVIoctrlSetNightVisionResp;

//升级状态
/* IOTYPE_USER_IPCAM_UPGRADE_STATUS_REQ			= 0x2264,   */
typedef struct
{
	unsigned char reserved[8];
}SMsgAVIoctrlUpgradeStatusReq;


/* IOTYPE_USER_IPCAM_UPGRADE_STATUS_RESP		  = 0x2265,   */
typedef struct
{
	int needUpdate; //0:不需要升级1:需要升级
	char oldVersion[12];
	char newVersion[12];
	unsigned char reserved[8];
}SMsgAVIoctrlUpgradeStatusResp;
// end ibaby

#endif

