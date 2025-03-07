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

namespace FilterByProductID
{
    /// <summary>
    /// This class shows how to communicate with an instrument by using the 
    /// USB address as the unique identifier of each instrument.
    /// </summary>
    class FilterByProductID
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

            // Open all devices on the USB bus with the specified product ID
            // NOTE:  A product ID of zero will open all devices on the USB bus, 
            // and a product ID of CEC7 will open all power meters on the USB bus.
            bool bOpen = m_USB.OpenDevices (0xCEC7);

            // If the devices were not opened successfully
            if (!bOpen)
            {
                Console.WriteLine ("\n***** Error:  Could not open the devices. *****\n\n");
                Console.WriteLine ("Check the log file for details.\n");
            }
            else
            {
                // Get the device information list
                ArrayList alDevInfoList = m_USB.GetDevInfoList ();

                // Display the device information list
                DisplayDeviceInfo ();

                // If there are no open instruments
                if (alDevInfoList.Count == 0)
                {
                    Console.WriteLine ("No devices discovered.\n\n");

                    // Make sure that the system is properly shut down
                    m_USB.CloseDevices ();
                    return;
                }

                // Get the USB address of the first device in the list
                int nDeviceID = ((DevInfo) alDevInfoList[0]).ID;

                // Display the command to be sent to the device
                Console.WriteLine ("\nSend Command = '*IDN?'\n");

                // Send the command to the device
                int nStatus = m_USB.Write (nDeviceID, "*IDN?");

			    // If there was a Write error
                if (nStatus != 0)
                {
                    Console.WriteLine ("\n***** Error:  Device Write Error Code = {0}. *****\n\n", nStatus);
                }
                else
                {
                    StringBuilder sbResponse = new StringBuilder (64);

                    // Read the command response from the device
                    nStatus = m_USB.Read (nDeviceID, sbResponse);

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
        /// This method displays the device information list.
        /// </summary>
        static void DisplayDeviceInfo ()
        {
            // Get the device information list
            ArrayList alDevInfoList = m_USB.GetDevInfoList ();
            Console.WriteLine ("Device Count = {0}\n", alDevInfoList.Count);

            for (int i = 0; i < alDevInfoList.Count; i++)
            {
                Console.WriteLine ("\nDevice ID (USB Address) = {0} \nDescription = '{1}'\n", 
                    ((DevInfo) alDevInfoList[i]).ID, ((DevInfo) alDevInfoList[i]).Description);
            }
        }
    }
}
