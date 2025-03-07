<?xml version='1.0'?>
<Project Type="Project" LVVersion="8008005">
   <Item Name="My Computer" Type="My Computer">
      <Property Name="CCSymbols" Type="Str">OS,Win;CPU,x86;</Property>
      <Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
      <Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
      <Property Name="server.tcp.enabled" Type="Bool">false</Property>
      <Property Name="server.tcp.port" Type="Int">0</Property>
      <Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
      <Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
      <Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
      <Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
      <Property Name="specify.custom.address" Type="Bool">false</Property>
      <Item Name="Device VIs" Type="Folder">
         <Item Name="DeviceQuery.vi" Type="VI" URL="Device VIs/DeviceQuery.vi"/>
         <Item Name="DeviceRead.vi" Type="VI" URL="Device VIs/DeviceRead.vi"/>
         <Item Name="DeviceWrite.vi" Type="VI" URL="Device VIs/DeviceWrite.vi"/>
         <Item Name="GetAllDeviceKeys.vi" Type="VI" URL="Device VIs/GetAllDeviceKeys.vi"/>
         <Item Name="GetFirstDeviceKey.vi" Type="VI" URL="Device VIs/GetFirstDeviceKey.vi"/>
         <Item Name="USBInit.vi" Type="VI" URL="Device VIs/USBInit.vi"/>
         <Item Name="USBShutdown.vi" Type="VI" URL="Device VIs/USBShutdown.vi"/>
      </Item>
      <Item Name="AppendToOutput.vi" Type="VI" URL="AppendToOutput.vi"/>
      <Item Name="UseDeviceKey (with Device VIs).vi" Type="VI" URL="UseDeviceKey (with Device VIs).vi"/>
      <Item Name="Dependencies" Type="Dependencies"/>
      <Item Name="Build Specifications" Type="Build"/>
   </Item>
</Project>
