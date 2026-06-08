using System;
using System.Drawing;
using System.Drawing.Printing;
using System.IO;

class Program {
    static Image img;
    
    static void Main() {
        string file = @"Z:\Obsidian_Vault\ComfyUI_Output\digital_feeling_trio_final.png";
        
        Console.WriteLine("=== EPSON L3150 Print ===");
        Console.WriteLine("File: " + file);
        
        if (!File.Exists(file)) { 
            Console.WriteLine("ERROR: File not found!");
            Environment.Exit(1);
        }
        
        // Find printer - try multiple matching strategies
        string targetPrinter = null;
        foreach (string p in PrinterSettings.InstalledPrinters) {
            if (p.IndexOf("L3150") >= 0 && p.IndexOf("EPSON") >= 0) {
                targetPrinter = p;
                break;
            }
        }
        
        if (targetPrinter == null) {
            foreach (string p in PrinterSettings.InstalledPrinters) {
                if (p.IndexOf("L3150") >= 0 || p.IndexOf("EPSON98") >= 0) {
                    targetPrinter = p;
                    break;
                }
            }
        }
        
        if (targetPrinter == null) {
            Console.WriteLine("\nERROR: No EPSON L3150 printer found!");
            Console.WriteLine("Available printers:");
            foreach (var p in PrinterSettings.InstalledPrinters)
                Console.WriteLine("  - '" + p + "'");
            Environment.Exit(1);
        }
        
        Console.WriteLine("\nUsing: " + targetPrinter);
        
        // Load image
        img = Image.FromFile(file);
        Console.WriteLine("Image size: " + img.Width + "x" + img.Height + " px");
        
        var doc = new PrintDocument();
        doc.PrinterSettings.PrinterName = targetPrinter;
        
        Console.WriteLine("Printer valid: " + doc.PrinterSettings.IsValid);
        
        // Set up print event  
        doc.PrintPage += OnPrintPage;
        
        try {
            Console.WriteLine("\nSubmitting to Windows Spooler (PNG -> PCL via driver)...");
            doc.Print();
            
            Console.WriteLine("\nSUCCESS! Print job submitted to " + targetPrinter);
            Console.WriteLine("(Windows spooler handles format conversion)");
            
        } catch (Exception ex) {
            Console.WriteLine("\nERROR: " + ex.Message);
            Console.WriteLine("Type: " + ex.GetType().Name);
            if (ex.InnerException != null)
                Console.WriteLine("Inner: " + ex.InnerException.Message);
        } finally {
            img.Dispose();
        }
    }
    
    static void OnPrintPage(object sender, PrintPageEventArgs e) {
        if (img == null) return;
        
        double rx = e.MarginBounds.Width / (double)img.Width;
        double ry = e.MarginBounds.Height / (double)img.Height;
        double scale = Math.Min(rx, ry);
        
        int nw = (int)(img.Width * scale);
        int nh = (int)(img.Height * scale);
        int cx = e.MarginBounds.X + ((e.MarginBounds.Width - nw) / 2);
        int cy = e.MarginBounds.Y + ((e.MarginBounds.Height - nh) / 2);
        
        var bg = new SolidBrush(Color.White);
        e.Graphics.FillRectangle(bg, e.PageBounds);
        bg.Dispose();
        
        var destRect = new Rectangle(cx, cy, nw, nh);
        e.Graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBilinear;
        e.Graphics.DrawImage(img, destRect);
    }
}
