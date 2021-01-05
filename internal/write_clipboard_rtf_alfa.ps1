Add-Type -AssemblyName System.Windows.Forms
$rtf = Get-Content -Path alfa_reprex.rtf
[Windows.Forms.Clipboard]::SetText($rtf, [System.Windows.Forms.TextDataFormat]::Rtf)
