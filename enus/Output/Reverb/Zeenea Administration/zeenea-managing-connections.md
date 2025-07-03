<!-- #p100003 -->


<!-- #p100009 -->
title: Managing Connections
===========================

<!-- #p100015 -->
# Managing Connections

<!-- #p100021 -->
### Prerequisites

<!-- #p100027 -->
To configure a connection between your IS and Zeenea, you must first: 

1. <!-- #p100033 -->
   Install a scanner.

2. <!-- #p100042 -->
   Install the plugin of the connector that is appropriate to your storage system.

   <!-- #p100048 -->
    :::note\[Notes\]

   - <!-- #p100054 -->
     These steps are described in the sections: Zeenea Scanners: prerequisite and setup

   - <!-- #p100066 -->
     Go to the specific documentation of each connector to identify the prerequisites and the conditions of implementation: Zeenea Connector Downloads

   <!-- #p100078 -->
    ::: 

<!-- #p100090 -->
## Creating a connection

<!-- #p100096 -->
A new connection is created by adding a new configuration file to the scanner:

- <!-- #p100102 -->
  Find your connection configuration files in the /connections folder of the scanner.

- <!-- #p100111 -->
  When the scanner starts up, it will analyze all the files in this folder and record all the valid connections on the platform.

<!-- #p100123 -->
In all connection configuration files, there are 3 systematic and mandatory parameters: 

- <!-- #p100129 -->
  name = the name that will be displayed to catalog users for this connection 

- <!-- #p100138 -->
  code = the unique identifier of the connection on the Zeenea platform. Once registered on the platform, this code must not be modified or the connection will be considered as new and the old one removed from the scanner

- <!-- #p100147 -->
  connector\_id = the type of connector to be used for the connection

<!-- #p100159 -->
The rest of the information to provide depends on the type of connector used and will be indicated in the template files. 

<!-- #p100165 -->
The name of the connection file does not matter, however it is advised to name it with the connection code.

<!-- #p100171 -->
A connection is considered valid if all of the following are true: 

- <!-- #p100177 -->
  It is syntactically correct.

- <!-- #p100186 -->
  All mandatory properties appear and are filled in.

- <!-- #p100195 -->
  The authentication information to the target system is correct.

- <!-- #p100204 -->
  The connection does not already exist on the Zeenea platform with a link to another scanner.

<!-- #p100216 -->
## Encryption of connection secrets

<!-- #p100222 -->
If you wish, you can encrypt the secrets of your connections using a tool provided by Zeenea. 

1. <!-- #p100228 -->
   Go to the scanner folder.

2. <!-- #p100237 -->
   Launch the zeenea-pwd executable. 

3. <!-- #p100246 -->
   Follow the tool's instructions, then copy the encrypted secret to the connection's configuration file on the accurate property.

4. <!-- #p100255 -->
   Managing connections from the administrator interface.

<!-- #p100267 -->
## List of connections

<!-- #p100273 -->
The connection listing page is accessible from the administration interface, under the "Connections" tab. It displays all connections within Zeenea. 

<!-- #p100279 -->
On this page, you will find active connections as well as the connections presenting an error.

<!-- #p100285 -->
```
![](C:\Users\bpandey\Documents\ePublisher Designer Projects\Zeenea\static\img\zeenea-connections-tab.png)
```

<!-- #p100291 -->
A connection is identified by catalog users by its name. For technical purposes, a connection is identified by the Zeenea platform by its unique code (displayed in square brackets on the right of its name). 

<!-- #p100297 -->
A connection can only be linked to one scanner at a time. It will be linked to the first one to register it and will be ignored by the following ones.

<!-- #p100303 -->
## Configuration of a connection

<!-- #p100309 -->
It is possible to view the detailed information of a connection, as defined at the scanner level, by clicking on "Settings" from the action menu of each connection. However, the secrets of the connection are not accessible from this interface and are kept by the scanner only.

<!-- #p100315 -->
```
![](C:\Users\bpandey\Documents\ePublisher Designer Projects\Zeenea\static\img\zeenea-connection-configuration.png)
```

<!-- #p100321 -->
You can also manage the connection options: 

- <!-- #p100333 -->
  **Data Profiling**: Allows you to activate the calculation of statistical profiles for the connection's Dataset Fields. It is not available on all connectors. Please note that activating this option may have an impact on your host's billing. For more information on Data Profiling, see Data Profiling.

- <!-- #p100348 -->
  **Data Sampling**: Enables data sampling for all the connection's imported Datasets. This option is not available for all connectors. For more information on Data Sampling, see Data Sampling.

- <!-- #p100360 -->
  **Automatic import**: This option allows you to automatically import all new Items for a connection, without having to select them manually from the Studio. Beware of using an appropriate filter configuration at the connection level to avoid importing unwanted Objects.

<!-- #p100372 -->
Activating any of these options does not automatically trigger the execution of the functionality. You must then launch execution from the actions menu (see below) or wait for a job scheduled in the Scanner.

<!-- #p100378 -->
## Manually launching scanner jobs

<!-- #p100384 -->
From the actions menu, you have the possibility to trigger certain actions of the scanner, without waiting for a scheduled batch execution: 

- <!-- #p100393 -->
  **Run inventory**: launches a new inventory of the connection and detects potential new Objects to import, or orphaned Objects (deleted from the source connection)

- <!-- #p100405 -->
  **Update Imported Items**: launches an update of the source documentation of the connection's Objects and updates the schema of the already imported datasets (new Fields or orphaned Fields)

- <!-- #p100417 -->
  **Run automatic import**: launches a new inventory, followed by an automatic import of the potential new Objects detected (action only available if the option is activated)

- <!-- #p100429 -->
  **Synchronize**: updates the list of Objects in the connection in the catalog, as well as their source documentation (action only available on some connection types)

- <!-- #p100441 -->
  **Run Data Profiling**: launches a new calculation of the statistical profiles of the connection's Fields (action available only if the option is activated)

- <!-- #p100453 -->
  **Run Data Sampling**: Starts retrieval of sample data from the connection

<!-- #p100465 -->
## Connection statuses

- <!-- #p100474 -->
  **Valid connection**: A connection that is considered valid allows the automatic update of the Items imported into the catalog as well as the import of new ones.

- <!-- #p100486 -->
  **Connection in error**: Connections in error are distinguished from others by a red text in the connection cell. A connection in error:

  - <!-- #p100492 -->
    Can no longer update the items imported into the catalog,

  - <!-- #p100501 -->
    Can no longer be used by Zeenea Studio users to import new Items.

  - <!-- #p100510 -->
    Remain available for reading in the catalog for all users along with the Items already imported. 

<!-- #p100528 -->
Reasons for a connection in error include the following: 

- <!-- #p100534 -->
  The configuration file is no longer present in the scanner.

- <!-- #p100543 -->
  The configuration file has a syntax error (missing mandatory parameter or badly written property name).

- <!-- #p100552 -->
  The authentication settings to the target system provided in the configuration file are incorrect.

<!-- #p100564 -->
To find out the exact nature of the error, check the scanner logs.

<!-- #p100570 -->
## Deleting a connection

<!-- #p100576 -->
In order to delete a connection from the Catalog, you must follow the next two steps: first, delete the connection from the scanner folder and then go to the administration interface and delete the connection.

<!-- #p100582 -->
### From the scanner

<!-- #p100588 -->
To delete a connection from a scanner : 

1. <!-- #p100597 -->
   Go to the `/connections` folder of the scanner, 

2. <!-- #p100606 -->
   Delete the configuration file corresponding to the connection you want to delete.

3. <!-- #p100615 -->
   Restart the scanner. 

   <!-- #p100621 -->
    :::note\[IMPORTANT\]  Deleting the configuration file from the scanner does not delete the items imported into the catalog. Users will still be able to access the items imported from this connection, but these items will no longer be updated automatically and it will no longer be possible to import new ones into the catalog.  ::: 

<!-- #p100633 -->
### From the administration interface

<!-- #p100639 -->
It is temporarily not possible to remove an old connection from the Administration menu. It will remain visible in the list, however it will be greyed out in the import menu.

<!-- #p100645 -->
## Relocating a connection

<!-- #p100651 -->
To relocate a connection to another scanner: 

1. <!-- #p100657 -->
   Delete it from its original scanner first. (See the section above "Delete a connection from the scanner".)

2. <!-- #p100666 -->
   Move the configuration file to the new scanner.

3. <!-- #p100675 -->
   Restart the scanner.

4. <!-- #p100684 -->
   Check in the detailed view of the destination scanner that the connection has been relocated. 

   <!-- #p100690 -->
    :::note  Operations on the scanners are only taken into account by the Zeenea platform every 10 seconds. It may take a few seconds for changes to appear on the interface.  :::

