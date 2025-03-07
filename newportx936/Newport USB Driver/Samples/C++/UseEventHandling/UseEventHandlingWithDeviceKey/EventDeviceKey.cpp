////////////////////////////////////////////////////////////////////////////////
// This C++ sample demonstrates how to write code in the native development
// environment that interacts with the USB driver (usbdll.dll).
////////////////////////////////////////////////////////////////////////////////
#include "stdio.h"
#include "USB.h"
#include "EventDeviceKey.h"

// The USB communication object.
USB g_Usb;
// The device table.
map <string, int> g_mapDeviceTable;

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

	// If there is at lease one instrument that is open
	if (g_mapDeviceTable.size () > 0)
	{
		// Select the first device in the list
		map <string, int> :: const_iterator it;
		it = g_mapDeviceTable.begin ();
		string strDeviceKey = it->first.c_str ();

		// Display the command to be sent to the device
		printf ("\nSend Command = '*IDN?'\n");

		// Send the command to the device
		int nStatus = g_Usb.Write (strDeviceKey, (string) "*IDN?");

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
			nStatus = g_Usb.Read (strDeviceKey, szBuffer, g_Usb.m_knMaxBufferLength, &lBytesRead);

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

	// Display the attached devices
	DisplayAttachedDevices ();

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
	char szDeviceKey[64];

    // If the device has been attached
	if (nState == 1)
	{
		string strDeviceKey;
		g_Usb.CreateDeviceKey (handle, strDeviceKey);
		printf ("Attached Device = '%s', Handle = %d\n\n", strDeviceKey.c_str (), handle);

        // Inform the USB driver to add the device key to the list of attached devices
		g_Usb.StringToChar (szDeviceKey, strDeviceKey);
        newp_usb_event_assign_key (szDeviceKey, handle);

		// Add the device key to the device table
		g_mapDeviceTable[strDeviceKey] = handle;
	}
	else
	{
        // If the device key can be retrieved from the USB driver
        if (newp_usb_event_get_key_from_handle (handle, szDeviceKey) == 0)
		{
            // If the device key can be removed from the list of attached devices
            if (newp_usb_event_remove_key (szDeviceKey) == 0)
            {
				printf ("Detached Device = '%s', Handle = %d\n\n", szDeviceKey, handle);

				// Remove the device key from the device table
				map <string, int> :: const_iterator it;
				it = g_mapDeviceTable.find (szDeviceKey);

				// If the device key was found then remove it
				if (it != g_mapDeviceTable.end ())
				{
					g_mapDeviceTable.erase (it->first);
				}
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
// This function displays the device key and handle of the currently attached
// devices.
////////////////////////////////////////////////////////////////////////////////
void DisplayAttachedDevices ()
{
	const int kn_MaxDevices = 32;
	char* pKeys[kn_MaxDevices];
	int nHandles[kn_MaxDevices];

	// Initialize the list of device keys
	for (int i = 0; i < kn_MaxDevices; i++)
	{
		pKeys[i] = new char (0);
	}

	// Get the list of attached devices
    newp_usb_event_get_attached_devices (pKeys, nHandles);

	for (int i = 0; i < kn_MaxDevices; i++)
	{
		// If the rest of the list is empty then exit this for-loop
		if (strlen (pKeys[i]) == 0)
		{
			break;
		}

		printf ("Attached Device #%d = '%s', Handle = %d\n\n", i + 1, pKeys[i], nHandles[i]);
	}
}