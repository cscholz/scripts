Set dtmConvertedDate = CreateObject("WbemScripting.SWbemDateTime")

strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colOperatingSystems = objWMIService.ExecQuery _
    ("Select * from Win32_OperatingSystem")

For Each objOperatingSystem in colOperatingSystems
    Wscript.Echo "Boot Device: " & objOperatingSystem.BootDevice
    Wscript.Echo "Build Number: " & objOperatingSystem.BuildNumber
    Wscript.Echo "Build Type: " & objOperatingSystem.BuildType
    Wscript.Echo "Caption: " & objOperatingSystem.Caption
    Wscript.Echo "Code Set: " & objOperatingSystem.CodeSet
    Wscript.Echo "Country Code: " & objOperatingSystem.CountryCode
    Wscript.Echo "Debug: " & objOperatingSystem.Debug
    Wscript.Echo "Encryption Level: " & objOperatingSystem.EncryptionLevel
    dtmConvertedDate.Value = objOperatingSystem.InstallDate
    dtmInstallDate = dtmConvertedDate.GetVarDate
    Wscript.Echo "Install Date: " & dtmInstallDate 
    Wscript.Echo "Licensed Users: " & _
        objOperatingSystem.NumberOfLicensedUsers
    Wscript.Echo "Organization: " & objOperatingSystem.Organization
    Wscript.Echo "OS Language: " & objOperatingSystem.OSLanguage
    Wscript.Echo "OS Product Suite: " & objOperatingSystem.OSProductSuite
    Wscript.Echo "OS Type: " & objOperatingSystem.OSType
    Wscript.Echo "Primary: " & objOperatingSystem.Primary
    Wscript.Echo "Registered User: " & objOperatingSystem.RegisteredUser
    Wscript.Echo "Serial Number: " & objOperatingSystem.SerialNumber
    Wscript.Echo "Version: " & objOperatingSystem.Version
Next
