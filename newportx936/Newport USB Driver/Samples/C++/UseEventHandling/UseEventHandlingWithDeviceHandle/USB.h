#pragma once
#include "NewpDll.h"
#include <string>
#include <vector>
#include <map>

using namespace std;

// This structure contains the information for a single device.
typedef struct tagDevInfo
{
	int nID;
	string strDescription;
}
DevInfo;


// This class interfaces with UsbDll.dll and provides the basic
// functionality for USB communication.
class USB
{
public:
	USB (void);
	~USB (void);

	bool OpenDevices (int nProductID = 0);
	bool OpenDevices (int nProductID, bool bUsingDeviceKey);
	void CloseDevices ();
	int Read (string strDeviceKey, char* lpBuffer, int nLength, unsigned long* lBytesRead);
	int Read (int nDeviceID, char* lpBuffer, int nLength, unsigned long* lBytesRead);
	int ReadBinary (string strDeviceKey, char* lpBuffer, int nLength, unsigned long* lBytesRead);
	int ReadBinary (int nDeviceID, char* lpBuffer, int nLength, unsigned long* lBytesRead);
	int Write (string strDeviceKey, char* lpBuffer);
	int Write (int nDeviceID, char* lpBuffer);
	int Write (string strDeviceKey, string strBuffer);
	int Write (int nDeviceID, string strBuffer);
	void StringToChar (char* lpDest, string strSrc);
	map <string, int> GetDeviceTable ();
	vector <DevInfo> GetDevInfoList ();
	void FillDevInfoList (char* lpDevInfo);
	bool CreateDeviceKey (int handle, string& strDeviceKey);
	void ParseDeviceKey (char* lpID, string& strDeviceKey);

	enum
	{
		// The maximum buffer length for a USB I/O transfer.
		m_knMaxBufferLength = 64
	};

private:
	// The device information list.
	vector <DevInfo> m_DevInfoList;
	// The device table.
	map <string, int> m_mapDeviceTable;
	// The devices open flag.
	bool m_bOpen;
};
