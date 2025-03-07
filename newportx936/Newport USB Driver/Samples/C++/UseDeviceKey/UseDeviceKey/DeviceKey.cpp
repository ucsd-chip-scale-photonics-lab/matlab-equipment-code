////////////////////////////////////////////////////////////////////////////////
// This C++ sample demonstrates how to write code in the native development
// environment that interacts with the USB driver (usbdll.dll).
////////////////////////////////////////////////////////////////////////////////
#include "stdio.h"
#include "USB.h"
#include "DeviceKey.h"

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
	USB usb;

	// If the devices were not opened successfully
	if (!usb.OpenDevices (0, true))
	{
		printf ("\n***** Error:  Could not open the devices. *****\n\n");
		printf ("Please make sure that the devices are powered on, \n");
		printf ("connected to the PC, and that the drivers are properly installed.\n\n");
	}
	else
	{
		// Get the device table
		map <string, int> deviceTable = usb.GetDeviceTable ();

		// Display the device table
		DisplayDeviceTable (deviceTable);

		// If there are no open instruments
		if (deviceTable.size () == 0)
		{
			printf ("No devices discovered.\n\n");

			// Make sure that the system is properly shut down
			newp_usb_uninit_system ();
			return;
		}

		// Select the first device in the list
		map <string, int> :: const_iterator it;
		it = deviceTable.begin ();
		string strDeviceKey = it->first.c_str ();

		// Display the command to be sent to the device
		printf ("\nSend Command = '*IDN?'\n");

		// Send the command to the device
		int nStatus = usb.Write (strDeviceKey, (string) "*IDN?");

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
			nStatus = usb.Read (strDeviceKey, szBuffer, usb.m_knMaxBufferLength, &lBytesRead);

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

		// Close all devices on the USB bus
		newp_usb_uninit_system ();
		printf ("Devices closed.\n");
	}
}

////////////////////////////////////////////////////////////////////////////////
// This function displays the device table that is returned from the
// USB driver after all devices have been opened.
// Input:
//    deviceTable:	The device table. 
////////////////////////////////////////////////////////////////////////////////
void DisplayDeviceTable (map <string, int> deviceTable)
{
	map <string, int> :: const_iterator it;
	printf ("Device Count = %d\n", deviceTable.size ());

	// Iterate through the map
	for (it = deviceTable.begin (); it != deviceTable.end (); it++)
	{
		printf ("\nDevice Key = %s \nDevice ID = %d\n", 
			it->first.c_str (), it->second);
	}
}
