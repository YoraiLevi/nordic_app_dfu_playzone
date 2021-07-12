# Warn not admin
# Recieve Path to SDK
# Make sure ../../ exists
# Make symlink
Get-ChildItem .\nRF5SDK160098a08e2\ -Directory | forEach {New-Item -Name $_.Name -Target $_.FullName -Type SymbolicLink}