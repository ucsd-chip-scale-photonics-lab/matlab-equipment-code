VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "USB"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'********************************************************************************
'* This native VB6 wrapper class provides support for interacting with the USB
'* driver (usbdll.dll).
'********************************************************************************

'Declare the public interface functions from the USB driver
Private Declare Function newp_usb_init_system Lib "usbdll" () As Long
Private Declare Function newp_usb_uninit_system Lib "usbdll" () As Long
Private Declare Function newp_usb_get_device_info Lib "usbdll" (ByVal strDevInfo As String) As Long
Private Declare Function newp_usb_get_ascii Lib "usbdll" (ByVal nDeviceID As Integer, ByVal strBuffer As String, ByVal nLength As Integer, ByRef nBytesRead As Integer) As Long
Private Declare Function newp_usb_send_ascii Lib "usbdll" (ByVal nDeviceID As Integer, ByVal strBuffer As String, ByVal nLength As Integer) As Long

'The device information list.
Private m_DevInfoList As New Collection

'********************************************************************************
'* This method performs initialization for the class.
'********************************************************************************
Private Sub Class_Initialize()
End Sub

'********************************************************************************
'* This property gets the device information list.
'********************************************************************************
Public Property Get DevInfoList() As Collection
    Set DevInfoList = m_DevInfoList
End Property

'********************************************************************************
'* This method opens all devices on the USB bus.
'********************************************************************************
Public Function OpenDevices() As Long
    Dim lOpenStatus As Long
    Dim lStatus As Long

    'Open all devices on the USB bus
    lOpenStatus = newp_usb_init_system()

    If (lOpenStatus = 0 Or lOpenStatus = 1) Then
        Dim strDevInfo As String
        strDevInfo = Space$(1024)

        'Retrieve the device information
        lStatus = newp_usb_get_device_info(strDevInfo)

        If (lStatus = 0) Then
            'Initialize the device information list
            Call FillDevInfoList(strDevInfo)
        End If
    End If

    If (lOpenStatus <> 0) Then
        OpenDevices = lOpenStatus
    Else
        OpenDevices = lStatus
    End If
End Function

'********************************************************************************
'* This method closes all open devices on the USB bus.
'********************************************************************************
Public Function CloseDevices() As Long
    CloseDevices = newp_usb_uninit_system()
End Function

'********************************************************************************
'* This method reads the response data from the specified device.
'* Input:
'*    nDeviceID:    The USB address of the device.  The valid range is from 0 - 31.
'*    strBuffer:    The character buffer used to hold the response data.
'*    nLength:      The length of the character buffer.
'* Output:
'*    nBytesRead:   The number of bytes read.
'* Returns:
'*    Zero for success, non-zero for failure.
'********************************************************************************
Public Function ReadAscii(ByVal nDeviceID As Integer, ByRef strBuffer As String, ByVal nLength As Integer, ByRef nBytesRead) As Long
    Dim lStatus As Long
    lStatus = newp_usb_get_ascii(nDeviceID, strBuffer, nLength, nBytesRead)
    
    'If there was no Read error and at least two characters were read
    If (lStatus = 0 And nBytesRead >= 2) Then
        If (Mid(strBuffer, nBytesRead - 1, 1) = Chr(13)) Then
            'Strip off the carriage return and linefeed characters
            strBuffer = Left(strBuffer, nBytesRead - 2)
        Else
            'Strip off the linefeed character
            strBuffer = Left(strBuffer, nBytesRead - 1)
        End If
    End If

    ReadAscii = lStatus
End Function

'********************************************************************************
'* This method sends the passed in command string to the specified device.
'* Input:
'*    nDeviceID:    The USB address of the device.  The valid range is from 0 - 31.
'*    strBuffer:    The character buffer used to hold the response data.
'* Returns:
'*    Zero for success, non-zero for failure.
'********************************************************************************
Public Function WriteAscii(ByVal nDeviceID As Integer, ByVal strBuffer As String) As Long
    WriteAscii = newp_usb_send_ascii(nDeviceID, strBuffer, Len(strBuffer))
End Function

'********************************************************************************
'* This method fills / initializes the device information list.
'* Input:
'*    devInfoList:  The character buffer used to hold the device information.
'********************************************************************************
Private Sub FillDevInfoList(ByRef DevInfoList As String)
    Dim arrDevInfo As Variant
    Dim arrFields As Variant

    arrDevInfo = Split(DevInfoList, ";")
    
    For i = 0 To UBound(arrDevInfo) - 1
        arrFields = Split(arrDevInfo(i), ",")
        Set devInfo = New devInfo
        devInfo.ID = CInt(arrFields(0))
        devInfo.Description = arrFields(1)
        m_DevInfoList.Add devInfo
    Next i
End Sub

