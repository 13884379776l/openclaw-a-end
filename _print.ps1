Add-Type -TypeDefinition "using System;using System.Drawing;using System.Drawing.Printing;public class PH:ICloneable{public Image Img{get;set;}public bool Printed=false;public void OnPrintPage(object s,PrintPageEventArgs e){if(Img==null)return;double rx=e.MarginBounds.Width/(double)Img.Width;double ry=e.MarginBounds.Height/(double)Img.Height;double sc=Math.Min(rx,ry);int nw=(int)(Img.Width*sc),nh=(int)(Img.Height*sc),cx=e.MarginBounds.X+((e.MarginBounds.Width-nw)/2),cy=e.MarginBounds.Y+((e.MarginBounds.Height-nh)/2);var bg=new SolidBrush(Color.White);e.Graphics.FillRectangle(bg,e.PageBounds);bg.Dispose();e.Graphics.InterpolationMode=System.Drawing.Drawing2D.InterpolationMode.HighQualityBilinear;e.Graphics.DrawImage(Img,cx,cy,nw,nh);Printed=true;}public object Clone(){return this;}}"

$f="Z:\Obsidian_Vault\ComfyUI_Output\digital_feeling_trio_final.png"
$pri="L3150 Series(网络)"

if(!(Test-Path $f)){Write-Error "Not found";exit 1}

$wmi=Get-WmiObject Win32_Printer|?{$_.Name -eq $pri}
$old=Get-WmiObject Win32_Printer|?{$_.Default-eq $true}
$wmi.SetDefaultPrinter()>$null;Start-Sleep 1

$h=New-Object PH
$h.Img=[System.Drawing.Image]::FromFile($f)
Write-Host "Image: $($h.Img.Width)x$($h.Img.Height)" -ForegroundColor Gray

$d=New-Object System.Drawing.Printing.PrintDocument
$act=[System.Action[System.Object,System.Drawing.Printing.PrintPageEventArgs]]::Create(([System.Func[System.Object,System.Drawing.Printing.PrintPageEventArgs,System.Void]][methodinfo]$h.GetType().GetMethod("OnPrintPage")).CreateDelegate([System.Action[System.Object,System.Drawing.Printing.PrintPageEventArgs]]))
$d.add_PrintPage($act)>$null

Write-Host "Submitting..." -ForegroundColor Cyan
try{$d.Print()>$null;Write-Host "SUCCESS! Submitted" -ForegroundColor Green}catch{Write-Error $_;exit 1}finally{$h.Img.Dispose();Start-Sleep 3;$old.SetDefaultPrinter()>$null}
Write-Host "=== Done ===" -ForegroundColor Gray
