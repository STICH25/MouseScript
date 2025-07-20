Add-Type @"
using System;
using System.Runtime.InteropServices;
public class IdleTime {
    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }
    public static uint GetIdleTime() {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)Marshal.SizeOf(lii);
        GetLastInputInfo(ref lii);
        return ((uint)Environment.TickCount - lii.dwTime) / 1000;
    }
}
"@

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$rand = New-Object Random

while ($true) {
    Start-Sleep -Seconds 60

    $idleTime = [IdleTime]::GetIdleTime()
    if ($idleTime -gt 120) {
        $pos = [System.Windows.Forms.Cursor]::Position
        $dx = if ($rand.Next(0, 2) -eq 0) { 200 } else { -200 }
        $dy = if ($rand.Next(0, 2) -eq 0) { 200 } else { -200 }

        $newPos = New-Object System.Drawing.Point(($pos.X + $dx), ($pos.Y + $dy))
        [System.Windows.Forms.Cursor]::Position = $newPos
        Start-Sleep -Milliseconds 200
        [System.Windows.Forms.Cursor]::Position = $pos
    }
}
