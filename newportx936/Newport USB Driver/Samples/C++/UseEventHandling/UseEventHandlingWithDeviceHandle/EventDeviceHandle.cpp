////////////////////////////////////////////////////////////////////////////////
// This C++ sample demonstrates how to write code in the native development
// environment that interacts with the USB driver (usbdll.dll).
////////////////////////////////////////////////////////////////////////////////
#include "stdio.h"
#include "USB.h"
#include "EventDeviceHandle.h"

// The USB communication object.
USB g_Usb;

////////////////////////////////////////////////////////////////////////////////
// This is the main function.  It initializes event handling for the USB driver, 
// waits for the user to press the Enter key, and then closes all devices.
////////////////////////////////////////////////////////////////////////////////
void main ()
{
	// Turn on logging for this sample
	newp_usb_SetLogging (true);

	// Initialize event handling
	printf ("About to initialize event handling.\n");
	newp_usb_event_init (0, (DeviceStateChanged) &DeviceStateChangedCB);

	printf ("\nPress the Enter key to exit, or attach / detach devices.\n\n");
	char line[80];
	fgets (line, sizeof(line), stdin);

	// Close all devices on the USB bus
	newp_usb_uninit_system ();
	printf ("Devices closed.\n");
}

////////////////////////////////////////////////////////////////////////////////
// This function is the callback function that is invoked by the USB driver 
// when an event occurs.
// Input:
//    handle :  The device handle that was assigned by the USB driver.
//    nState :  The device state (0 = detached, 1 = attached).
////////////////////////////////////////////////////////////////////////////////
void __stdcall DeviceStateChangedCB (int handle, int nState)
{
    // If the device has been attached
	if (nState == 1)
	{
		GetDeviceID (handle);
	}
	else
	{
		printf ("Detached Device Handle = %d\n\n", handle);
	}
}

////////////////////////////////////////////////////////////////////////////////
// This function performs a USB write and a USB Read using the specified device 
// handle.  It sends the "*IDN?" query and displays the results.
// Input:
//    handle :  The device handle that was assigned by the USB driver.
////////////////////////////////////////////////////////////////////////////////
void GetDeviceID (int handle)
{
	int nStatus = g_Usb.Write (handle, (string) "*IDN?");

	// If there was a Write error
	if (nStatus != 0)
	{
		printf ("\n***** Error:  Device Write Error Code = %d. *****\n\n", nStatus);
	}
	else
	{
		char szBuffer[g_Usb.m_knMaxBufferLength];
		unsigned long lBytesRead = 0;

		// Read the command response from the device
		nStatus = g_Usb.Read (handle, szBuffer, g_Usb.m_knMaxBufferLength, &lBytesRead);

		// If there was a Read error
		if (nStatus != 0)
		{
			printf ("\n***** Error:  Device Read Error Code = %d. *****\n\n", nStatus);
		}
		else
		{
			// Display the data that was read from the device
			printf ("Attached Device = '%s', Handle = %d\n\n", szBuffer, handle);
		}
	}
}
