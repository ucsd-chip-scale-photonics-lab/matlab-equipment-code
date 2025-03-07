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

namespace UseEventHandling
{
    /// <summary>
    /// This class shows how to communicate with an instrument by using event  
    /// handling with the device key as the unique identifier of each instrument.
    /// </summary>
    class UseEventHandling
    {
        /// <summary>
        /// Define the delegate for the Device State Changed event.
        /// </summary>
        private delegate void DeviceStateChangedDelegate (string deviceKey, USB.eDeviceState state);

        // Call the USB constructor with true passed in 
        // so that logging is turned on for this sample
        static USB m_USB = new USB (true);

        /// <summary>
        /// This method is the entry point for the application.
        /// </summary>
        /// <param name="args">The command line arguments.</param>
        static void Main (string[] args)
        {
            Console.WriteLine ("About to initialize event handling.\n");

            UseEventHandling useEvents = new UseEventHandling ();
            m_USB.EventInit (0);

            Console.WriteLine ("\nPress the Enter key to exit, or attach / detach devices.\n\n");
            Console.ReadLine ();

            // Get the device keys
            string[] strDeviceKeyList;
            int nDeviceCount = m_USB.GetDeviceKeys (out strDeviceKeyList);

            // If there is at lease one instrument that is open
            if (nDeviceCount > 0)
            {
                // Select a device key from the list
                string strDeviceKey = strDeviceKeyList[0];

                // Display the command to be sent to the device
                Console.WriteLine ("\nSend Command = '*IDN?'\n");

                // Send the command to the device
                int nStatus = m_USB.Write (strDeviceKey, "*IDN?");

                // If there was a Write error
                if (nStatus != 0)
                {
                    Console.WriteLine ("\n***** Error:  Device Write Error Code = {0}. *****\n\n", 
                        nStatus);
                }
                else
                {
                    StringBuilder sbResponse = new StringBuilder (64);

                    // Read the command response from the device
                    nStatus = m_USB.Read (strDeviceKey, sbResponse);

                    // If there was a Read error
                    if (nStatus != 0)
                    {
                        Console.WriteLine ("\n***** Error:  Device Read Error Code = {0}. *****\n\n", 
                            nStatus);
                    }
                    else
                    {
                        // Display the data that was read from the device
                        Console.WriteLine ("Response = '{0}'\n\n", sbResponse);
                    }
                }
            }

            // Display the device table
            DisplayDeviceTable ();

            // Close all devices on the USB bus
            m_USB.CloseDevices ();
            Console.WriteLine ("Devices closed.\n");
        }

        /// <summary>
        /// Constructor.
        /// </summary>
        internal UseEventHandling ()
        {
            // Listen for the Device State Changed event
            m_USB.DeviceStateChanged += new USB.DeviceStateChangedDelegate (OnDeviceStateChanged);
        }

        /// <summary>
        /// This method handles the Device State Changed event.  It invokes the device state changed 
        /// method on the proper thread to handle the details of the event.
        /// </summary>
        /// <param name="deviceKey">The device key.</param>
        /// <param name="state">The state that the device was changed to (0 = detached, 1 = attached).</param>
        private void OnDeviceStateChanged (string deviceKey, USB.eDeviceState state)
        {
            // If a new device was attached
            if (state == USB.eDeviceState.Attached)
            {
                Console.WriteLine ("Device Attached:  Key = {0}", deviceKey);
            }
            // If a device was detached
            else if (state == USB.eDeviceState.Detached)
            {
                Console.WriteLine ("Device Detached:  Key = {0}", deviceKey);
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
