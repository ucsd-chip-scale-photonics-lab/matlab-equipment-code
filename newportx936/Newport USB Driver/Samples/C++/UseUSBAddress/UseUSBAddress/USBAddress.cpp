////////////////////////////////////////////////////////////////////////////////
// This C++ sample demonstrates how to write code in the native development
// environment that interacts with the USB driver (usbdll.dll).
////////////////////////////////////////////////////////////////////////////////
#include "stdio.h"
#include "USB.h"
#include "USBAddress.h"

////////////////////////////////////////////////////////////////////////////////
// This is the main function.  It opens all devices on the USB bus, retrieves 
// the device information from the USB driver, performs a write, a read, and 
// then closes all devices.
////////////////////////////////////////////////////////////////////////////////
void main ()
{
	// Turn on logging for this sample
	newp_usb_SetLogging (true);
	printf ("About to open devices.\n");

	// Open all devices on the USB bus
	long lOpenStatus = newp_usb_init_system ();

	// If the devices were not opened successfully
	if (lOpenStatus != 0)
	{
		// Display error information
		HandleOpenError (lOpenStatus);
	}
	else
	{
		char szDevInfo[1024];

		// If all device information can be retrieved
		if (newp_usb_get_device_info (szDevInfo) == 0)
		{
			USB usb;

			// Initialize the device information list
			usb.FillDevInfoList (szDevInfo);
			vector <DevInfo> devInfoList = usb.GetDevInfoList ();

			// Display the device information list
			DisplayDeviceInfo (devInfoList);

			// If there are no open instruments
			if (devInfoList.size () == 0)
			{
				printf ("No devices discovered.\n\n");

				// Make sure that the system is properly shut down
				newp_usb_uninit_system ();
				return;
			}

			// Select the first device in the list
			DevInfo devInfo = devInfoList.front ();

			// Get the USB address of the selected device
			int nDeviceID = devInfo.nID;

			// Display the command to be sent to the device
			printf ("\nSend Command = '*IDN?'\n");

			// Send the command to the device
			int nStatus = usb.Write (nDeviceID, (string) "*IDN?");

			// If there was a Write error
			if (nStatus != 0)
			{
				printf ("\n***** Error:  Device Write Error Code = %d. *****\n\n", nStatus);
			}
			else
			{
				char szBuffer[usb.m_knMaxBufferLength];
				unsigned long lBytesRead = 0;

				// Read the command response from the device
				nStatus = usb.Read (nDeviceID, szBuffer, usb.m_knMaxBufferLength, &lBytesRead);

				// If there was a Read error
				if (nStatus != 0)
				{
					printf ("\n***** Error:  Device Read Error Code = %d. *****\n\n", nStatus);
				}
				else
				{
					// Display the data that was read from the device
					printf ("Response = '%s'\n\n", szBuffer);
				}
			}
		}

		// Close all devices on the USB bus
		newp_usb_uninit_system ();
		printf ("Devices closed.\n");
	}
}

////////////////////////////////////////////////////////////////////////////////
// This function displays error information based upon the error code that is 
// returned from the USB driver when the devices are not successfully opened.
// Input:
//    lOpenStatus:	The I/O status of the open operation. 
////////////////////////////////////////////////////////////////////////////////
void HandleOpenError (long lOpenStatus)
{
	// If there was a timeout error
	if (lOpenStatus == -2)
	{
		printf ("\n***** Error:  Device Timeout. *****\n\n");
		printf ("Please make sure that the device is powered on, \n");
		printf ("connected to the PC, and that the drivers are properly installed.\n\n");
	}
	// If there was a duplicate address error
	else if (lOpenStatus == 1)
	{
		char szDevInfo[1024];

		// If all device information can be retrieved
		if (newp_usb_get_device_info (szDevInfo) == 0)
		{
			USB usb;

			// Initialize the device information list
			usb.FillDevInfoList (szDevInfo);
			vector <DevInfo> devInfoList = usb.GetDevInfoList ();
			DisplayDeviceInfo (devInfoList);
		}

		// Close all devices on the USB bus
		newp_usb_uninit_system ();
		printf ("\n***** Error:  Duplicate USB address. *****\n\n");
	}
	else
	{
		printf ("\n***** Error:  Device Open Error Code = %d. *****\n\n", lOpenStatus);
	}
}

////////////////////////////////////////////////////////////////////////////////
// This function displays the device information that is returned from the
// USB driver after all devices have been opened.
// Input:
//    devInfoList:	The device information list. 
////////////////////////////////////////////////////////////////////////////////
void DisplayDeviceInfo (vector <DevInfo> devInfoList)
{
	vector <DevInfo> :: const_iterator it;
	printf ("Device Count = %d\n", devInfoList.size ());

	for (it = devInfoList.begin (); it != devInfoList.end (); it++)
	{
		printf ("\nDevice ID (USB Address) = %d \nDescription = '%s'\n", 
			it->nID, it->strDescription.c_str ());
	}
}
