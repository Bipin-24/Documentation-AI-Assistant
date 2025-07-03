<!-- #p100003 -->
# Troubleshooting Scanners and Connections

<!-- #p100009 -->
This topic describes the procedure to follow in case of a problem with the Zeenea scanner or the configuration of the connection.

<!-- #p100015 -->
This procedure is intended for users who have access to the machines on which the scanning processes are hosted.

<!-- #p100021 -->
If you do not find in the answers to common issues, you can report your incident by opening a ticket and contacting the operator of Zeenea. We will be able to refer to the latter for additional information.

<!-- #p100027 -->
## Unresolved Issue Procedure

<!-- #p100033 -->
Here is the recommended procedure when a problem is encountered:

1. <!-- #p100048 -->
   If your scanner version is not the latest version available, please upgrade it in order to validate if the issue is already fixed or not. The upgrade procedure is described in [Managing Scanners](zeenea-managing-scanners.md# "Managing Scanners").

2. <!-- #p100057 -->
   If it appears that the problem is related to the user interface, collecting information at this level will be useful for understanding and therefore solving the problem.

   - <!-- #p100063 -->
     It is important to collect the traces of exchanges between the browser and Zeenea services. Any JavaScript errors should be logged.

   - <!-- #p100072 -->
     By activating the Network Developer tool, the requests exchanged between the interface and the service will be visible and if one of them is in error, it will be faster to understand the problem. In this case, retrieving the information from both the request made and the response received will provide useful information.

3. <!-- #p100087 -->
   It is important to collect the server-side traces recorded in the logs. Zeenea's configuration includes by default a log named scanner. log in the logs/directory. Errors related to the incident may therefore be found there. If the incident cannot be reproduced, it is important to keep the lines relating to the time it occurred.

   - <!-- #p100093 -->
     Keep the content of the log so you can communicate it to the Zeenea support.

   - <!-- #p100102 -->
     If the problem is reproducible, isolate the possible errors that would appear during the reproduction procedure.

4. <!-- #p100117 -->
   It is not necessary, except on request of Zeenea support, to modify the levels of the traces in the logs. Errors will be logged by default. More detailed information will only be necessary in certain cases and in a very targeted manner: Zeenea support will then specify how to proceed.

5. <!-- #p100126 -->
   Open a ticket by attaching the technical elements collected and specifying the issue encountered.

<!-- #p100138 -->
## Common Errors and Solutions

<!-- #p100144 -->
#### 1. The connection I just added does not appear in my Administration interface or is indicated "in error" in the Administration interface.

<!-- #p100150 -->
Check the scanner's logs to view the list of connections it found and scanned, and any errors in the configuration files of connections that were ignored. 

<!-- #p100156 -->
#### 2. I’m unable to download the scanner using the curl command

<!-- #p100162 -->
Make sure that the following placeholders: 

- <!-- #p100171 -->
  `$APISECRET`

- <!-- #p100183 -->
  `$hostname` 

<!-- #p100195 -->
have been replaced by their actual values in the command:

<!-- #p100204 -->
   `curl -L -H "X-API-SECRET: $APISECRET" "https://$hostname/studio/api-v1/agent/get-agent" -o scanner.tar.gz`

<!-- #p100210 -->
Make sure to also check that you’re not using a proxy. 

<!-- #p100216 -->
#### 3. The server certificate is not recognized

<!-- #p100222 -->
If the scanner fails to connect to Zeenea with the error message: 

<!-- #p100231 -->
   `Error: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target`

<!-- #p100237 -->
then it is possible that the proxy is listening for the network and is generating a fake Zeenea certificate, using an internal CA. This certificate will not be recognized by Java. 

<!-- #p100243 -->
 Confirm this is happening with the following command: 

<!-- #p100252 -->
`keytool -printcert -sslserver [hostname].zeenea.app`

<!-- #p100258 -->
Below is the expected result: 

<!-- #p100264 -->
```
Certificate #0
====================================
Owner : CN=*.zeenea.app
Issuer : CN=Amazon, OU=Server CA 1B, O=Amazon, C=US
Serial Number : 7e4ffeaa2bee20ebe662390d3bdfd1f
Valid from Sun May 31 02:00:00 CEST 2020 to Wed Jun 30 14:00:00 CEST 2021
Certificate fingerprints:
         SHA 1: 9A:74:DD:9F:B2:B7:F0:E7:27:E8:B7:84:FD:F9:25:37:82:A0:41:FF
         SHA 256: 25:3C:36:3D:9A:F1:C6:C6:D6:0D:93:0B:A0:05:C9:72:AC:CA:76:92:91:B7:01:6E:76:37:C0:92:C8:AE:6B:BB
Signature algorithm name: SHA256withRSA
Subject public key algorithm: Clé RSA 2048 bits
Version: 3
```

<!-- #p100279 -->
If the issuer is an internal CA, you’ll need to retrieve the certification chain from the CA and manually add it to the `conf/` folder (`PKCS12` or `JKS`). You’ll then have to manually edit the conf/application.conf file, and especially the following part: 

<!-- #p100285 -->
```
################# TLS SPECIFIC TRUSTSTORE ##############

play.ws.ssl {
  trustManager = {
      stores = [
        # Specific truststore
        {
            path = "/path/to/zeenea/conf/truststore.p12"
            # type should be either PKCS12 or JKS (PEM format is not supported)
            type = "PKCS12"
            password = "changeit"
        }
        # Default trust store
        # This block keep compatibility this classic CA and should be unchanged (event the password)
        {
            path = ${java.home}/lib/security/cacerts
            password = "changeit"
        }
      ]
  }
```

<!-- #p100291 -->
#### 4. The scanner is duplicated

<!-- #p100297 -->
Kill both instances of the scanner, and restart it. 

<!-- #p100303 -->
It is highly recommended to launch the scanner using a systemd service to avoid duplicates. 

<!-- #p100309 -->
#### 2. java.lang.UnsatisfiedLinkError \[...\] failed to map segment from shared object: Operation not permitted

<!-- #p100315 -->
The user the scanner is executed with doesn't have the right to execute from the default /tmp folder.

<!-- #p100324 -->
You have to redefine this default folder using a specific Java property: `java.io.tmpdir`

<!-- #p100330 -->
Add this parameter to your ExecStart command from your systemd init file:

<!-- #p100336 -->
```
ExecStart=[...] -Djava.io.tmpdir=/a/path/to/another/folder/
This folder should be owned by the user the scanner starts with.
```

