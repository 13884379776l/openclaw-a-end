WScript.Echo "=== EPSON L3150 Print ==="
On Error Resume Next

' Set printer as default via WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")
For Each p In wmi.ExecQuery("SELECT * FROM Win32_Printer WHERE Name='L3150 Series(网络)'")
    WScript.Echo "Port: " & p.PortName
    p.SetDefaultPrinter()
Next

WScript.Sleep 1000

' Use .NET PrintDocument via COM (Windows Script Host + .NET FW)
Set dotNet = CreateObject("Microsoft.DotNet.Interactive.Documents.Document") ' This will fail, try another way

' Actually use WIA Image File for printing
On Error Clear
Set wiaPrinters = CreateObject("WIA.PrintDialog").QueryDefaultPrinters()
foundPrinter = False

For i = 1 To wiaPrinters.Count  
    Set p = wiaPrinters.Item(i)
    If InStr(UCase(p.Name), "L3150") > 0 Or InStr(UCase(p.Name), "EPSON") > 0 Then
        WScript.Echo "Found: " & p.Name
        
        Set img = CreateObject("WIA.ImageFile")  
        img.LoadFile "Z:\Obsidian_Vault\ComfyUI_Output\digital_feeling_trio_final.png"
        
        ' Print using WIA COM - this handles format conversion automatically!
        On Error Resume Next
        Set dlg = CreateObject("WIA.PrintDialog")
        dlg.PrintImage img, p
        
        If Err.Number = 0 Then
            WScript.Echo "SUCCESS! WIA Print via: " & p.Name
            foundPrinter = True
        Else  
            WScript.Echo "WIA failed: " & Err.Description
            Err.Clear
        End If
        Exit For
    End If
Next

If Not foundPrinter Then
    WScript.Echo "No EPSON/L3150 printer found via WIA"
    
    ' Try .NET PrintDocument directly via COM interop  
    On Error Resume Next
    Set net = CreateObject("System.Drawing.Printing.PrintDocument")
    If Err.Number = 0 Then
        WScript.Echo ".NET Framework available"
        
        ' Can't set events from VBScript easily, so use cmd print fallback
        Set wmi2 = GetObject("winmgmts:\\.\root\cimv2")  
        For Each p In wmi2.ExecQuery("SELECT * FROM Win32_Printer WHERE Name='L3150 Series(网络)'")
            port = p.PortName
            WScript.Echo "Trying: print /d:" & chr(34) & port & chr(34)
            
            ' Use Windows.print subsystem via the PrintUI
            ret = Shell("cmd /c start print_file """ & port & """", 0)
        Next
    End If
End If

' Restore default printer  
WScript.Sleep 2000
For Each p In wmi.ExecQuery("SELECT * FROM Win32_Printer WHERE Default=True")
    p.SetDefaultPrinter()
Next
