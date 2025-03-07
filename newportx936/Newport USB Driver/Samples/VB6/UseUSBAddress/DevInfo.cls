VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "DevInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'********************************************************************************
'* This class defines the device information returned by the USB driver
'* (usbdll.dll).
'********************************************************************************

'The device ID.
Private m_nID As Integer
'The device description.
Private m_strDescription As String

'********************************************************************************
'* This property gets the device ID.
'********************************************************************************
Public Property Get ID() As Integer
    ID = m_nID
End Property

'********************************************************************************
'* This property sets the device ID.
'********************************************************************************
Public Property Let ID(ByVal nID As Integer)
    m_nID = nID
End Property

'********************************************************************************
'* This property gets the device description.
'********************************************************************************
Public Property Get Description() As String
    Description = m_strDescription
End Property

'********************************************************************************
'* This property sets the device description.
'********************************************************************************
Public Property Let Description(ByVal strDescription As String)
    m_strDescription = strDescription
End Property
