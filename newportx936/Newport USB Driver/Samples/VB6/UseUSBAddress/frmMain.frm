VERSION 5.00
Begin VB.Form frmMain 
   Caption         =   "Use USB Address"
   ClientHeight    =   3090
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4680
   LinkTopic       =   "Form2"
   ScaleHeight     =   3090
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox txtOutput 
      Height          =   2895
      Left            =   120
      MultiLine       =   -1  'True
      TabIndex        =   0
      Text            =   "frmMain.frx":0000
      Top             =   120
      Width           =   4455
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'********************************************************************************
'* This VB6 sample demonstrates how to write code in the native development
'* invironment that interacts with the USB driver (usbdll.dll).
'********************************************************************************
Option Explicit

'Global variable for the USB object
Dim g_oUSB As USB
'Global variable to hold the entire output to be displayed in the text box control
Dim g_strOutput As String
'Global variable to hold carriage return and linefeed characters
Dim g_strCRLF As String

'********************************************************************************
'* This is the main function.  It gets called at initialization time when the
'* main form is loaded.  It opens all devices on the USB bus, retrieves the
'* device information from the USB driver, performs a write, a read, and then
'* closes all devices.
'********************************************************************************
Private Sub Form_Load()
    Dim lStatus As Long
    Set g_oUSB = New USB

    g_strCRLF = Chr(13) & Chr(10)
    g_strOutput = "About to open devices." & g_strCRLF
    Me.txtOutput.Text = g_strOutput

    'Open all devices on the USB bus
    lStatus = g_oUSB.OpenDevices()

    'If the devices were not opened successfully
    If lStatus <> 0 Then
        Call HandleOpenError(lStatus)
    Else
        'Initialize the device information list
        Dim oDevInfoList As Collection
        Set oDevInfoList = g_oUSB.DevInfoList

        'Display the device information list
        Call DisplayDeviceInfo(oDevInfoList)

        'Select the first device in the list
        Dim oDevInfo As devInfo
        Set oDevInfo = oDevInfoList.Item(1)

        'Get the USB address of the selected device
        Dim nDeviceID As Integer
        nDeviceID = oDevInfo.ID

        'Display the command to be sent to the device
        g_strOutput = g_strOutput & g_strCRLF & "Send Command = " & Chr(39) & "*IDN?" & Chr(39) & g_strCRLF
        Me.txtOutput.Text = g_strOutput

        'Send the command to the device
        lStatus = g_oUSB.WriteAscii(nDeviceID, "*IDN?")

        'If there was a Write error
        If (lStatus <> 0) Then
            g_strOutput = g_strOutput & g_strCRLF & "***** Error:  Device Write Error Code = " & Str(lStatus) & ". *****" & g_strCRLF & g_strCRLF
            Me.txtOutput.Text = g_strOutput
        Else
            Dim nkMaxBufferLength As Integer
            Dim strBuffer As String
            Dim nBytesRead As Integer

            nkMaxBufferLength = 64
            strBuffer = Space(nkMaxBufferLength)
            
            'Read the command response from the device
            lStatus = g_oUSB.ReadAscii(nDeviceID, strBuffer, nkMaxBufferLength, nBytesRead)
            
            'If there was a Read error
            If (lStatus <> 0) Then
                g_strOutput = g_strOutput & g_strCRLF & "***** Error:  Device Read Error Code = " & Str(lStatus) & ". *****" & g_strCRLF & g_strCRLF
                Me.txtOutput.Text = g_strOutput
            Else
                'Display the data that was read from the device
                g_strOutput = g_strOutput & "Response = " & Chr(39) & strBuffer & Chr(39) & g_strCRLF & g_strCRLF
                Me.txtOutput.Text = g_strOutput
            End If
        End If

        'Close all devices on the USB bus
        lStatus = g_oUSB.CloseDevices()
        g_strOutput = g_strOutput & "Devices closed." & g_strCRLF
        Me.txtOutput.Text = g_strOutput
    End If

End Sub

'********************************************************************************
'* This function displays error information based upon the error code that is
'* returned from the USB driver when the devices are not successfully opened.
'* Input:
'*    lOpenStatus:  The I/O status of the open operation.
'********************************************************************************
Sub HandleOpenError(ByVal lOpenStatus As Long)

    ' If there was a timeout error
    If lOpenStatus = -2 Then
        g_strOutput = g_strOutput & g_strCRLF & "***** Error:  Device Timeout. *****" & g_strCRLF & g_strCRLF
        g_strOutput = g_strOutput & "Please make sure that the device is powered on, " & g_strCRLF
        g_strOutput = g_strOutput & "connected to the PC, and that the drivers are properly installed." & g_strCRLF & g_strCRLF
    Else
        'If there was a duplicate address error
        If lOpenStatus = 1 Then
            Dim lStatus As Long
            g_strOutput = g_strOutput & g_strCRLF & "***** Error:  Duplicate USB address. *****" & g_strCRLF & g_strCRLF

            'Initialize the device information list
            Dim oDevInfoList As Collection
            Set oDevInfoList = g_oUSB.DevInfoList

            'Display the device information list
            Call DisplayDeviceInfo(oDevInfoList)

            'Close all devices on the USB bus
            lStatus = g_oUSB.CloseDevices()
        Else
            g_strOutput = g_strOutput & "***** Error:  Device Open Error Code = " & lOpenStatus & ". *****" & g_strCRLF & g_strCRLF
        End If
    End If

    Me.txtOutput.Text = g_strOutput
End Sub

'********************************************************************************
'* This function displays the device information that is returned from the USB
'* driver after all devices have been opened.
'* Input:
'*    devInfoList:  The device information list.
'********************************************************************************
Sub DisplayDeviceInfo(ByRef DevInfoList As Collection)
    g_strOutput = g_strOutput & "Device Count = " & DevInfoList.Count & g_strCRLF

    Dim devInfo As devInfo
    For Each devInfo In DevInfoList
        g_strOutput = g_strOutput & g_strCRLF & "Device ID (USB Address) = " & devInfo.ID & g_strCRLF & "Description = " & Chr(39) & devInfo.Description & Chr(39) & g_strCRLF
    Next

    Me.txtOutput.Text = g_strOutput
End Sub

