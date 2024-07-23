# Invoke-AkamaiOPEN

EdgeGrid for PowerShell

> **NOTICE:** PowerShell EdgeGrid Client has been deprecated and is not supported anymore. For details on managing Akamai's product APIs via PowerShell, see the [Akamai Powershell Module](https://github.com/akamai/PowerShell) repo.

Invoke-AkamaiOPEN is a PowerShell authorization wrapper around `Invoke-RestMethod`. It adds the required EdgeGrid signature to a normal `Invoke-RestMethod` request.

## Install

Invoke-AkamaiOPEN requires PowerShell 3.0.

## Authentication

We provide authentication credentials through an API client. Requests to the API are signed with a timestamp and are executed immediately.

1. [Create authentication credentials](https://techdocs.akamai.com/developer/docs/set-up-authentication-credentials).

2. Place your credentials in an EdgeGrid resource file, `.edgerc`, under a heading of `[default]` at your local home directory or the home directory of a web-server user.

    ```
    [default]
    client_secret = C113nt53KR3TN6N90yVuAgICxIRwsObLi0E67/N8eRN=
    host = akab-h05tnam3wl42son7nktnlnnx-kbob3i3v.luna.akamaiapis.net
    access_token = akab-acc35t0k3nodujqunph3w7hzp7-gtm6ij
    client_token = akab-c113ntt0k3n4qtari252bfxxbsl-yvsdj

## Configuration

Pass the parameters and credentials for signing the requests during runtime as command line options.

Available command line options:

| Option | Description |
| ---------- | --------- |
| `-Method` | A request method. Valid values are `GET`, `POST`, `PUT`, and `DELETE`. |
| `-ClientToken` | An authentication token used in client auth. Available in Luna Portal |
| `-ClientAccessToken` | An authentication token used in client auth. Available in Luna Portal. |
| `-ClientSecret` | An authentication password used in client auth. Available in Luna Portal. |
| `-ReqURL`  | A full request URL complete with API location and parameters. Must be URL-encoded. |
| `-Body` | Should contain the `POST` or `PUT` body. The body should be structured like a JSON object. For example: <br /> <br /> `$Body = '{"country":"USA","firstName":"John","lastName":"Smith", "jobTitle":"Engineer"}'` |

## Use

To use the library, provide your authentication credentials and the appropriate endpoint information.

```bash
Invoke-AkamaiOPEN -Method GET `
-ClientToken "akab-c113ntt0k3n4qtari252bfxxbsl-yvsdj" `
-ClientAccessToken "akab-acc35t0k3nodujqunph3w7hzp7-gtm6ij" `
-ClientSecret "C113nt53KR3TN6N90yVuAgICxIRwsObLi0E67/N8eRN=" `
-ReqURL "https://akab-h05tnam3wl42son7nktnlnnx-kbob3i3v.luna.akamaiapis.net/identity-management/v3/user-profile"
```

## Reporting issues

To report an issue or make a suggestion, create a new [GitHub issue](https://github.com/akamai/AkamaiOPEN-edgegrid-powershell/issues).

## License

Copyright 2024 Akamai Technologies, Inc. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
