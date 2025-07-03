<!-- #p100003 -->
# Managing Scanners

<!-- #p100009 -->
## Adding a Scanner

<!-- #p100024 -->
Scanners are added and set up outside of the Zeenea interface. Please see [Zeenea Scanner Setup](zeenea-scanner-setup.md# "Zeenea Scanner Setup") for more information.

<!-- #p100030 -->
## Deleting a Scanner

<!-- #p100036 -->
Scanners cannot be deleted. They will however be tagged as “Inactive” in the Scanners list. 

<!-- #p100042 -->
## Moving a Scanner

<!-- #p100048 -->
You can move a scanner simply by moving its installation folder. The scanner will then be automatically updated on the Zeenea platform, without any added manual intervention on your end. 

<!-- #p100054 -->
This process can be used both for moving a scanner in the same host, or changing the host entirely.   

<!-- #p100060 -->
## Renaming a Scanner

<!-- #p100066 -->
It is possible to rename a scanner, but it will need to be set up again. 

<!-- #p100072 -->
When renaming a scanner, if there are connections attached to it, you will need to follow a following procedure: 

1. <!-- #p100078 -->
   Stop the scanner.

2. <!-- #p100090 -->
   Move the `connections` folder into a temporary location.

3. <!-- #p100099 -->
   Restart the scanner: all connections will automatically be updated on the platform and temporarily disabled.

4. <!-- #p100111 -->
   Rename the scanner (by changing the scanner identifier in the `agent-identifier` file).

5. <!-- #p100123 -->
   Move the `connections` folder back to its original location.

6. <!-- #p100132 -->
   Restart the scanner: the scanner is added to the administration platform and all attached connections are enabled again.

7. <!-- #p100144 -->
   If there are no connections, you can rename it by changing the identifier in the `agent-identifier` file.

<!-- #p100156 -->
## Scanners list

<!-- #p100162 -->
The Scanners list in the Administration interface allows you to: 

- <!-- #p100168 -->
  view active scanners

- <!-- #p100177 -->
  view inactive scanners

- <!-- #p100186 -->
  download the scanner executable file

<!-- #p100198 -->
## Identifying a scanner

<!-- #p100204 -->
Scanners are identified by a unique ID and the name of the machine hosting them, which allows you to accurately locate them inside your Information System.  

<!-- #p100210 -->
## Scanner detailed view

<!-- #p100216 -->
By clicking on the "eye" icon next to a Scanner, you’ll be able to access more detailed information, as well as the list of connections attached to it. 

<!-- #p100222 -->
## Scanner states

- <!-- #p100231 -->
  **Active Scanner**: A scanner is considered “Active” when it runs a successful verification every 10 seconds, even when it doesn’t contain any connection.

- <!-- #p100243 -->
  **Inactive Scanner**: A scanner is considered “Inactive” when it hasn’t run a verification for 3 days. Inactive scanners are hidden by default, and can viewed by toggling the “Include Inactive Scanners” box.

- <!-- #p100255 -->
  **Action required**: If one (or more) connection managed by a scanner encounters an error, the message “A connection linked to this scanner needs your attention” is displayed. The user can then access the list of connections linked to the scanner and quickly identify which one needs correcting. 

<!-- #p100267 -->
## Updating a Scanner

<!-- #p100273 -->
Unlike Zeenea Studio and Zeenea Explorer, the scanner must be updated manually.

<!-- #p100282 -->
**Zeenea Support team may ask you to upgrade your scanner if you are facing an issue to validate if it is already fixed in the most recent version available.**

<!-- #p100288 -->
### Installation procedure:

1. <!-- #p100294 -->
   Stop the current scanner

2. <!-- #p100303 -->
   Download the new version available at: https://\[yourenvironment\].zeenea.app/admin/settings/scanners. (If you need a specific version of the scanner, it will be provided by Zeenea support.)

3. <!-- #p100315 -->
   Copy the file `agent-identifier` from the root directory of the current scanner and paste it into the root directory of the new scanner.

4. <!-- #p100333 -->
   Copy the file `application.conf` from the `conf` directory of the current scanner and paste it into the `conf` directory of the new scanner.

5. <!-- #p100348 -->
   Copy the connections configuration files from the `connections` directory of the current scanner and paste them in the `connections` directory of the new scanner.

6. <!-- #p100360 -->
   Go to the Connectors List and the copy up-to-date version of the plugins you use (without unzipping them) into the `plugins` directory of the new scanner.

7. <!-- #p100369 -->
   Start the new scanner. It should be visible on the Zeenea administration page and the connections must be correctly associated and ready to use again.

<!-- #p100381 -->
## Windows Environment (Scanner as a Windows Service)

<!-- #p100393 -->
Each time you decide to upgrade your Scanner, being defined as a Windows Service, you'll have to copy these files files from the previous scanner installation to the newly one: `prunmgr.exe` and `prunsrv.exe`.

<!-- #p100402 -->
Then, you'll need to execute `./bin/zeenea-service.bat` script which will update paths in the current service configuration and will relaunch the process.

