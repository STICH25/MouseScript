@echo off
:loop
timeout /t 60 >nul

powershell -command "& {
    Add-Type @'
        using System;
        using System.Runtime.InteropServices;
        public class IdleTime {
            [DllImport(\"user32.dll\")]
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
'@

    $idleTime = [IdleTime]::GetIdleTime()
    if ($idleTime -gt 180) {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $pos = [System.Windows.Forms.Cursor]::Position

        # Generate random X and Y direction (+80 or -80)
        $rand = New-Object System.Random
        $dx = if ($rand.Next(0, 2) -eq 0) { 80 } else { -80 }
        $dy = if ($rand.Next(0, 2) -eq 0) { 80 } else { -80 }

        # Move cursor
        $newPos = New-Object System.Drawing.Point(($pos.X + $dx), ($pos.Y + $dy))
        [System.Windows.Forms.Cursor]::Position = $newPos

        # Wait briefly and return cursor to original
        Start-Sleep -Milliseconds 200
        [System.Windows.Forms.Cursor]::Position = $pos
    }
}"
goto loop
