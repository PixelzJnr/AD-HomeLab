# Active Directory User Creation Script
# Author: Frank Ewasy Odoom Jnr (Pixelz)
# Description: Creates an OU, domain users, and assigns admin privileges
# Domain: lab.local

Import-Module ActiveDirectory

# Variables
$domain = "DC=lab,DC=local"
$ouName = "SOC-Lab-Users"
$ouPath = "OU=$ouName,$domain"
$password = ConvertTo-SecureString "Password@123!" -AsPlainText -Force

# Create Organisational Unit
Write-Host "Creating Organisational Unit: $ouName" -ForegroundColor Cyan
New-ADOrganizationalUnit -Name $ouName -Path $domain

# Create standard users
$users = @(
    @{Name="John Smith"; First="John"; Last="Smith"; Sam="jsmith"},
    @{Name="Jane Doe"; First="Jane"; Last="Doe"; Sam="jdoe"}
)

foreach ($user in $users) {
    Write-Host "Creating user: $($user.Name)" -ForegroundColor Green
    New-ADUser `
        -Name $user.Name `
        -GivenName $user.First `
        -Surname $user.Last `
        -SamAccountName $user.Sam `
        -UserPrincipalName "$($user.Sam)@lab.local" `
        -Path $ouPath `
        -AccountPassword $password `
        -Enabled $true
}

# Create admin user
Write-Host "Creating admin user: adminuser" -ForegroundColor Yellow
New-ADUser `
    -Name "Admin User" `
    -GivenName "Admin" `
    -Surname "User" `
    -SamAccountName "adminuser" `
    -UserPrincipalName "adminuser@lab.local" `
    -Path $ouPath `
    -AccountPassword $password `
    -Enabled $true

# Add admin user to Domain Admins
Write-Host "Adding adminuser to Domain Admins" -ForegroundColor Yellow
Add-ADGroupMember -Identity "Domain Admins" -Members "adminuser"

# Verify
Write-Host "`nUsers created successfully:" -ForegroundColor Cyan
Get-ADUser -Filter * -SearchBase $ouPath | Select-Object Name, SamAccountName, Enabled

Write-Host "`nDomain Admins members:" -ForegroundColor Cyan
Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name, SamAccountName