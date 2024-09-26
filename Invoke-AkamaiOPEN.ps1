#Requires -Version 3.0
<#
.SYNOPSIS
EdgeGrid Powershell
.DESCRIPTION
Authorization wrapper around Invoke-RestMethod for use with Akamai's OPEN API initiative.
.PARAMETER Method
A request method. Valid values are GET, POST, PUT, and DELETE.
.PARAMETER ClientToken
Authentication token used in client auth.
.PARAMETER ClientAccessToken
Authentication token used in client auth.
.PARAMETER ClientSecret
Authentication password used in client auth.
.PARAMETER ReqURL
A full request URL complete with API location and parameters. Must be URL encoded.
.PARAMETER Body
The POST or PUT body in JSON format. For example: -Body '{"country":"USA", "firstName":"John", "lastName":"Smith", "jobTitle":"Engineer"}'
.EXAMPLE
Invoke-AkamaiOPEN -Method GET -ClientToken {your-client-token} -ClientAccessToken {your-access-token} -ClientSecret {your-client-secret} -ReqURL "https://{your-host}.akamaiapis.net/identity-management/v3/user-profile"
.LINK
https://techdocs.akamai.com
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("GET", "PUT", "POST", "DELETE")]
    [string]$Method,
    [Parameter(Mandatory=$true)][string]$ClientToken,
    [Parameter(Mandatory=$true)][string]$ClientAccessToken,
    [Parameter(Mandatory=$true)][string]$ClientSecret,
    [Parameter(Mandatory=$true)][string]$ReqURL,
    [Parameter(Mandatory=$false)][string]$Body,
    [Parameter(Mandatory=$false)][string]$MaxBody = 131072
    )

#Function to generate HMAC SHA256 Base64
Function Crypto ($secret, $message)
{
  [byte[]] $keyByte = [System.Text.Encoding]::ASCII.GetBytes($secret)
  [byte[]] $messageBytes = [System.Text.Encoding]::ASCII.GetBytes($message)
  $hmac = new-object System.Security.Cryptography.HMACSHA256((,$keyByte))
  [byte[]] $hashmessage = $hmac.ComputeHash($messageBytes)
  $Crypt = [System.Convert]::ToBase64String($hashmessage)

  return $Crypt
}

#ReqURL Verification
If (($ReqURL -as [System.URI]).AbsoluteURI -eq $null -or $ReqURL -notmatch "akamaiapis.net")
{
  throw "Error: Ivalid Request URI"
}

#Sanitize Method param
$Method = $Method.ToUpper()

#Split $ReqURL for inclusion in SignatureData
$ReqArray = $ReqURL -split "(.*\/{2})(.*?)(\/)(.*)"

#Timestamp for request signing
$TimeStamp = [DateTime]::UtcNow.ToString("yyyyMMddTHH:mm:sszz00")

#GUID for request signing
$Nonce = [GUID]::NewGuid()

#Build data string for signature generation
$SignatureData = $Method + "`thttps`t"
$SignatureData += $ReqArray[2] + "`t" + $ReqArray[3] + $ReqArray[4]

#Add body to signature. Truncate if body is greater than max-body (Akamai default is 131072). PUT Medthod does not require adding to signature.

if ($Body -and $Method -eq "POST")
{
  $Body_SHA256 = [System.Security.Cryptography.SHA256]::Create()
  if($Body.Length -gt $MaxBody){
    $Post_Hash = [System.Convert]::ToBase64String($Body_SHA256.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($Body.Substring(0,$MaxBody))))
  }
  else{
    $Post_Hash = [System.Convert]::ToBase64String($Body_SHA256.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($Body)))
  }

  $SignatureData += "`t`t" + $Post_Hash + "`t"
}
else
{
  $SignatureData += "`t`t`t"
}

$SignatureData += "EG1-HMAC-SHA256 "
$SignatureData += "client_token=" + $ClientToken + ";"
$SignatureData += "access_token=" + $ClientAccessToken + ";"
$SignatureData += "timestamp=" + $TimeStamp  + ";"
$SignatureData += "nonce=" + $Nonce + ";"

#Generate SigningKey
$SigningKey = Crypto -secret $ClientSecret -message $TimeStamp

#Generate Auth Signature
$Signature = Crypto -secret $SigningKey -message $SignatureData

#Create AuthHeader
$AuthorizationHeader = "EG1-HMAC-SHA256 "
$AuthorizationHeader += "client_token=" + $ClientToken + ";"
$AuthorizationHeader += "access_token=" + $ClientAccessToken + ";"
$AuthorizationHeader += "timestamp=" + $TimeStamp + ";"
$AuthorizationHeader += "nonce=" + $Nonce + ";"
$AuthorizationHeader += "signature=" + $Signature

#Create IDictionary to hold request headers
$Headers = @{}

#Add Auth header
$Headers.Add('Authorization',$AuthorizationHeader)

#Add additional headers if POSTing or PUTing
If ($Body)
{
  # turn off the "Expect: 100 Continue" header
  # as it's not supported on the Akamai side.
  [System.Net.ServicePointManager]::Expect100Continue = $false
}

#Check for valid Methods and required switches
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
if ($Method -eq "PUT" -or $Method -eq "POST") {
  try {
    if ($Body) {
      Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -Body $Body -ContentType 'application/json'
    }
    else {
      Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json'
    }
  }
  catch {
    $_.Exception.Response
  }
}
else {
  try {
    #Invoke API call with GET or DELETE and return
    Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers
  }
  catch {
    $_.Exception.Response
  }
}
