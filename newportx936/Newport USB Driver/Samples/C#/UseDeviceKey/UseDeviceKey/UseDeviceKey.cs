////////////////////////////////////////////////////////////////////////////////
// This C# sample code demonstrates how to write code in the .NET development 
// environment that interacts with the .NET interface (UsbDllWrap.dll) which 
// wraps around the native USB driver (UsbDll.dll).
////////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections;
using System.Linq;
using System.Text;
using Newport.USBComm;

namespace UseDeviceKey
{
    /// <summary>
    /// This class shows how to communicate with an instrument by using the 
    /// USB address as the unique identifier of each instrument.
    /// </summary>
    class UseDeviceKey
    {
        // Call the USB constructor with true passed in 
        // so that logging is turned on for this sample
        static USB m_USB = new USB (true);

        /// <summary>
        /// This method is the entry point for the application.
        /// </summary>
        /// <param name="args">The command line arguments.</param>
        static void Main (string[] args)
        {
            Console.WriteLine ("About to open devices.\n");

            // Open all devices on the USB bus
            bool bOpen = m_USB.OpenDevices (0, true);

            // If the devices were not opened successfully
            if (!bOpen)
            {
                Console.WriteLine ("\n***** Error:  Could not open the devices. *****\n\n");
                Console.WriteLine ("Check the log file for details.\n");
            }
            else
            {
                // Display the device table
                DisplayDeviceTable ();

                // Get the device keys
                string[] strDeviceKeyList;
                int nDeviceCount = m_USB.GetDeviceKeys (out strDeviceKeyList);

				// If there are no open instruments
                if (nDeviceCount == 0)
                {
                    Console.WriteLine ("No devices discovered.\n\n");

                    // Make sure that the system is properly shut down
                    m_USB.CloseDevices ();
                    return;
                }

                // Select a device key from the list
                string strDeviceKey = strDeviceKeyList[0];

                // Display the command to be sent to the device
                Console.WriteLine ("\nSend Command = '*IDN?'\n");

                // Send the command to the device
                int nStatus = m_USB.Write (strDeviceKey, "*IDN?");

			    // If there was a Write error
                if (nStatus != 0)
                {
                    Console.WriteLine ("\n***** Error:  Device Write Error Code = {0}. *****\n\n", nStatus);
                }
                else
                {
                    StringBuilder sbResponse = new StringBuilder (64);

                    // Read the command response from the device
                    nStatus = m_USB.Read (strDeviceKey, sbResponse);

                    // If there was a Read error
                    if (nStatus != 0)
                    {
                        Console.WriteLine ("\n***** Error:  Device Read Error Code = {0}. *****\n\n", nStatus);
                    }
                    else
                    {
                        // Display the data that was read from the device
                        Console.WriteLine ("Response = '{0}'\n\n", sbResponse);
                    }
                }

                // Close all devices on the USB bus
                m_USB.CloseDevices ();
                Console.WriteLine ("Devices closed.\n");
            }
        }

        /// <summary>
        /// This method displays the device table.
        /// </summary>
        static void DisplayDeviceTable ()
        {
            // Get the device table
            Hashtable htDeviceTable = m_USB.GetDeviceTable ();
            Console.WriteLine ("Device Count = {0}\n", htDeviceTable.Count);

            foreach (DictionaryEntry de in htDeviceTable)
            {
                Console.WriteLine ("\nDevice Key = {0} \nDevice ID = {1}\n",
                    de.Key, htDeviceTable[de.Key]);
            }
        }
    }
}
