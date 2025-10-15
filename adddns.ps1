# Define variables
$dnsServerName = "dnsservername" # Replace with your DNS server name or IP address
$forwardZone = "domain"     # Your Forward Lookup Zone
$csvFilePath = "C:\filelocation\xxx.csv"  # Path to the CSV file

# Import the DNS Server module if it's not already loaded
if (-not (Get-Module -Name DNSServer)) {
    Import-Module DNSServer
}

# Read the CSV file
$dnsRecords = Import-Csv -Path $csvFilePath

foreach ($record in $dnsRecords) {
    # Create A record
    try {
        Write-Output "Creating A Record for $($record.HostName)"
        Add-DnsServerResourceRecordA -Name $record.HostName `
                                     -ZoneName $forwardZone `
                                     -IPv4Address $record.IPAddress `
                                     -ComputerName $dnsServerName

        # Create PTR record
        try {
            Write-Output "Creating PTR Record for $($record.IPAddress)"
            Add-DnsServerResourceRecordPtr     -Name $record.name `
                                               -ZoneName $record.reversezone `
                                               -PtrDomainName $record.PtrDomainName
                                               
                                               
        } catch {
            Write-Warning "Failed to create PTR record for $($record.IPAddress): $_"
        }
    } catch {
        Write-Warning "Failed to create A Record for $($record.HostName): $_"
    }
}

Write-Output "DNS records creation process completed."
