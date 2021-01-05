Add-Type -AssemblyName "System.Windows.Forms"
$data = New-Object Windows.Forms.DataObject
$rtf = Get-Content -Path beta_reprex.rtf
$data.SetData([Windows.Forms.DataFormats]::Rtf, $rtf)
[Windows.Forms.Clipboard]::SetDataObject($data)
