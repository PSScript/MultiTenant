   $Forest = "pshell.site"
$Container = "Tenants"
  $tenant1 = "TenantA"  ; $Domain1 = "o365.pro"  ; $OnMSFT1 = "M365EDU471782.onmicrosoft.com" ; $routing1 = "M365EDU471782.mail.onmicrosoft.com"
  $tenant2 = "TenantB"  ; $Domain2 = "jan.red"   ; $OnMSFT2 = "cvgdnsabr.onmicrosoft.com"     ; $routing2 = "cvgdnsabr.mail.onmicrosoft.com"
  $tenant3 = "TenantC"  ; $Domain3 = "jahube.de" ; $OnMSFT3 = "M365EDU471782.onmicrosoft.com" ; $routing3 = "M365EDU471782.mail.onmicrosoft.com"

  cvgdnsabr.onmicrosoft.com

New-ADOrganizationalUnit -Name $Container
New-ADOrganizationalUnit -Name $tenant1 -Path "OU=$Container,DC=pshell,DC=site"
New-ADOrganizationalUnit -Name $tenant2 -Path "OU=$Container,DC=pshell,DC=site"
New-ADOrganizationalUnit -Name $tenant3 -Path "OU=$Container,DC=pshell,DC=site"

Set-ADForest -Identity $Forest -UPNSuffixes @{add="$Domain1"}
Set-ADForest -Identity $Forest -UPNSuffixes @{add="$Domain2"}
Set-ADForest -Identity $Forest -UPNSuffixes @{add="$Domain3"}

New-AcceptedDomain -Name $tenant1 -DomainName $Domain1 -DomainType:Authoritative
New-AcceptedDomain -Name $tenant2 -DomainName $Domain2 -DomainType:Authoritative
New-AcceptedDomain -Name $tenant3 -DomainName $Domain3 -DomainType:Authoritative

New-GlobalAddressList -Name "$tenant1 – GAL" -ConditionalCustomAttribute1 $tenant1 -IncludedRecipients MailboxUsers -RecipientContainer "$Forest/$Container/$tenant1"

New-AddressList -Name "$tenant1 – All Rooms" -RecipientFilter "(CustomAttribute1 -eq 'TenantA') -and (RecipientTypeDetails -eq 'RoomMailbox')" -RecipientContainer "$Forest/$Container/$tenant1"

New-AddressList -Name "$tenant1 – All Users" -RecipientFilter "(CustomAttribute1 -eq 'TenantA') -and (ObjectClass -eq 'User')" -RecipientContainer "$Forest/$Container/$tenant1"

New-AddressList -Name "$tenant1 – All Contacts" -RecipientFilter "(CustomAttribute1 -eq 'TenantA') -and (ObjectClass -eq 'Contact')" -RecipientContainer "$Forest/$Container/$tenant1"

New-AddressList -Name "$tenant1 – All Groups" -RecipientFilter "(CustomAttribute1 -eq 'TenantA') -and (ObjectClass -eq 'Group')" -RecipientContainer "$Forest/$Container/$tenant1"

# New-OfflineAddressBook -Name "$tenant1" -AddressLists "$tenant1 – GAL"
New-OfflineAddressBook -Name "Offline Addressbook $tenant1" -AddressLists "$tenant1 – GAL","$tenant1 – All Rooms","$tenant1 – All Users","$tenant1 – All Contacts","$tenant1 – All Groups"

#New-EmailAddressPolicy -Name "$tenant1 – EAP" -RecipientContainer "$Forest/$Container/$tenant1" -IncludedRecipients "AllRecipients" -ConditionalCustomAttribute1 $tenant1 -EnabledEmailAddressTemplates 'SMTP:%g.%s@o365.pro','smtp:%m@pshell.site','smtp:%m@M365EDU471782.onmicrosoft.com','smtp:%m@M365EDU471782.mail.onmicrosoft.com' -EnabledPrimarySMTPAddressTemplate 'SMTP:%g.%s@o365.pro'

New-AddressBookPolicy -Name "$tenant1" -AddressLists "$tenant1 – All Users", "$tenant1 – All Contacts", "$tenant1 – All Groups" -GlobalAddressList "$tenant1 – GAL" -OfflineAddressBook "Offline Addressbook $tenant1" -RoomList "$tenant1 – All Rooms"


New-Mailbox -Name 'TenantA Conference Room 1' -Alias 'TenantA_conf1' -OrganizationalUnit "$Forest/$Container/$tenant1" -UserPrincipalName 'confroom1@o365.pro' -SamAccountName 'TenantA_conf1' -FirstName 'Conference' -LastName 'Room 1' -AddressBookPolicy $tenant1 -Room
 
Set-Mailbox 'TenantA_conf1' -CustomAttribute1 $tenant1
 
Set-CalendarProcessing -Identity 'TenantA_conf1' -AutomateProcessing AutoAccept -DeleteComments $true -AddOrganizerToSubject $true -AllowConflicts $false

$c = Get-Credential
 
New-Mailbox -Name 'First Last' -Alias "$($tenant1 + "_FirstLast")" -OrganizationalUnit "$Forest/$Container/$tenant1" -UserPrincipalName 'First.Last@o365.pro' -SamAccountName "$($tenant1 + "_FirstLast")" -FirstName 'First' -LastName 'Last' -Password $c.password -ResetPasswordOnNextLogon $false -AddressBookPolicy "$tenant1"
 
Set-Mailbox 'First.Last@o365.pro' -CustomAttribute1 "$tenant1"