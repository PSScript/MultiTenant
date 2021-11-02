#
# creates "WindowsAzureACS-$tenant" + "evoSTS-$tenant"
#
# Oauth
# source https://docs.microsoft.com/de-de/exchange/configure-oauth-authentication-between-exchange-and-exchange-online-organizations-exchange-2013-help
# ref    https://techcommunity.microsoft.com/t5/exchange-team-blog/september-2020-hybrid-configuration-wizard-update/ba-p/1687698

$domains = "domain1.com","domain2.com"
$tenant = "TENANT" # without onmicrosoft
$OnPremHost = "mail.domain.com"
$autodiscoverOnPrem = "autodiscover.domain.com"

# primary domain first in array
#$domains = $tenant.domains.split(",")
#$tenantServiceDomain = "$($tenant.tenant).mail.onmicrosoft.com"
$ServiceDomain = "$tenant.mail.onmicrosoft.com"

# Exch on premise:
New-AuthServer -Name "WindowsAzureACS-$tenant" -AuthMetadataUrl "https://accounts.accesscontrol.windows.net/$($domains[0])/metadata/json/1"

New-AuthServer -Name "evoSTS-$tenant" -Type AzureAD -AuthMetadataUrl "https://login.windows.net/$($domains[0])/federationmetadata/2007-06/federationmetadata.xml"

set-authserver "WindowsAzureACS-$tenant" -domainname $domains
set-authserver "evoSTS-$tenant" -domainname $domains

get-authserver | fl *domain*

New-IntraOrganizationConnector -name "ExchangeHybridOnPremisesToOnline $tenant" -DiscoveryEndpoint https://outlook.office365.com/autodiscover/autodiscover.svc -TargetAddressDomains $ServiceDomain

Get-PartnerApplication |  ?{$_.ApplicationIdentifier -eq "00000002-0000-0ff1-ce00-000000000000" -and $_.Realm -eq ""} | Set-PartnerApplication -Enabled $true

Connect-MsolService
$CertFile = "$env:SYSTEMDRIVE\OAuthConfig\OAuthCert.cer"
$objFSO = New-Object -ComObject Scripting.FileSystemObject
$CertFile = $objFSO.GetAbsolutePathName($CertFile)
$cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate
$cer.Import($CertFile)
$binCert = $cer.GetRawCertData()
$credValue = [System.Convert]::ToBase64String($binCert)
$ServiceName = "00000002-0000-0ff1-ce00-000000000000"
$p = Get-MsolServicePrincipal -ServicePrincipalName $ServiceName
New-MsolServicePrincipalCredential -AppPrincipalId $p.AppPrincipalId -Type asymmetric -Usage Verify -Value $credValue

#######################################################################################################################

CLOUD

# ExO:
Connect-ExchangeOnline

New-IntraOrganizationConnector -name ExchangeHybridOnlineToOnPremises -DiscoveryEndpoint https://$OnPremHost/autodiscover/autodiscover.svc -TargetAddressDomains $domains

# MSOL:
Install-Module MSOnline
Connect-MsolService

$ServiceName = "00000002-0000-0ff1-ce00-000000000000";
$x = Get-MsolServicePrincipal -AppPrincipalId $ServiceName;
$x.ServicePrincipalnames.Add("$OnPremHost");
$x.ServicePrincipalnames.Add("$autodiscoverOnPrem");


Set-MSOLServicePrincipal -AppPrincipalId $ServiceName -ServicePrincipalNames $x.ServicePrincipalNames;

Get-MsolServicePrincipal -AppPrincipalId 00000002-0000-0ff1-ce00-000000000000 | select -ExpandProperty ServicePrincipalNames


$CertFile = "$env:SYSTEMDRIVE\OAuthConfig\OAuthCert.cer"
$objFSO = New-Object -ComObject Scripting.FileSystemObject
$CertFile = $objFSO.GetAbsolutePathName($CertFile)
$cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate
$cer.Import($CertFile)
$binCert = $cer.GetRawCertData()
$credValue = [System.Convert]::ToBase64String($binCert)
$ServiceName = "00000002-0000-0ff1-ce00-000000000000"
$p = Get-MsolServicePrincipal -ServicePrincipalName $ServiceName

New-MsolServicePrincipalCredential -AppPrincipalId $p.AppPrincipalId -Type asymmetric -Usage Verify -Value $credValue

New-MigrationEndpoint -Name Hybrid1 -ExchangeRemoteMove -RemoteServer MRSServer.contoso.com -Credentials (Get-Credential Contoso.com\Administrator)

New-MigrationEndpoint -Name Hybrid1 -ExchangeRemoteMove -RemoteServer pshell.site -Credentials (Get-Credential pshell.site\Administrator)





New-sendconnector  "Outbound to $tenant1" -addresspace "SMTP:$tenant1.mail.onmicrosoft.com;1" -CloudServicesMailEnabled $true

New-sendconnector  "Outbound to $tenant2" -addresspace "SMTP:$tenant2.mail.onmicrosoft.com;1" -CloudServicesMailEnabled $true

New-sendconnector  "Outbound to $tenant3" -addresspace "SMTP:$tenant3.mail.onmicrosoft.com;1" -CloudServicesMailEnabled $true

smtp:cvgdnsabr.mail.onmicrosoft.com;1

 Outbound to Office 365 - 549bfa0d-2ba7-4f47-8f51-55605049304d

 New-sendconnector  "Outbound to Office 365 - 549bfa0d-2ba7-4f47-8f51-55605049304d" -addresspace "smtp:cvgdnsabr.mail.onmicrosoft.com;1" -RequireTLS $true -CloudServicesMailEnabled $true

 TlsAuthLevel DomainValidation





$Param = @{   RequireTLS = $true
           AddressSpaces = "smtp:$tenant1.mail.onmicrosoft.com;1"
CloudServicesMailEnabled = $true }


New-sendconnector  "Outbound to $tenant1" @Param


Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services

$TLSCert = Get-ExchangeCertificate <Thumbrint from above>

$TLSCertName = "<I>$($TLSCert.Issuer)<S>$($TLSCert.Subject)"

Set-SendConnector "Outbound to $tenant1" -RequireTLS $true -TlsSettings CertificateValidation -TlsCertificateName $TLSCertName


Set-SendConnector "Outbound to $tenant1" -RequireTLS $true -TlsSettings -RequireTLS $true -TLSAuthLevel Domainvalidation -TlsDomain Domain.TLD


Set-SendConnector "Outbound to Office 365 - 549bfa0d-2ba7-4f47-8f51-55605049304d" -RequireTLS $true -TlsSettings CertificateValidation -TlsCertificateName $TLSCertName  

Set-SendConnector "Outbound to Office 365 - 549bfa0d-2ba7-4f47-8f51-55605049304d" -RequireTLS $true -TlsSettings DomainValidation