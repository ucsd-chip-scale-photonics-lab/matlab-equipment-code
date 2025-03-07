<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="9008000">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="AppendToOutput.vi" Type="VI" URL="../AppendToOutput.vi"/>
		<Item Name="DisplayDeviceTable.vi" Type="VI" URL="../DisplayDeviceTable.vi"/>
		<Item Name="Event_Callback.vi" Type="VI" URL="../Event_Callback.vi"/>
		<Item Name="Event_Register.vi" Type="VI" URL="../Event_Register.vi"/>
		<Item Name="Event_Unregister.vi" Type="VI" URL="../Event_Unregister.vi"/>
		<Item Name="GetFirstDeviceKey.vi" Type="VI" URL="../GetFirstDeviceKey.vi"/>
		<Item Name="UseEventHandling.vi" Type="VI" URL="../UseEventHandling.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="subTimeDelay.vi" Type="VI" URL="/&lt;vilib&gt;/express/express execution control/TimeDelayBlock.llb/subTimeDelay.vi"/>
			</Item>
			<Item Name="mscorlib" Type="VI" URL="mscorlib">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="UsbDllWrap.dll" Type="Document" URL="../UsbDllWrap.dll"/>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>
