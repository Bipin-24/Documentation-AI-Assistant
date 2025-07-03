# Adding a MongoDB Connection

<!-- #p100021 -->
## Prerequisites

- <!-- #p100030 -->
  To connect to a MongoDB cluster, a user with sufficient [permissions](#p100255 "title: MongoDB") is required.

- <!-- #p100039 -->
  The traffic flows from Zeenea towards the MongoDB cluster must be open.

<!-- #p100054 -->
> **Note:** A link to the configuration template can be found here: [Zeenea Connector Downloads](zeenea-connectors-list.md# "title: Zeenea Connector Downloads").

<!-- #p100060 -->
## Supported Versions

<!-- #p100069 -->
Since scanner version 26.9, the MongoDB plugin can be downloaded here: [Zeenea Connector Downloads](zeenea-connectors-list.md# "title: Zeenea Connector Downloads")

<!-- #p100075 -->
## Installing the Plugin

<!-- #p100081 -->
Since scanner version 26.9, the MongoDB plugin can be downloaded here: Connectors: download links

<!-- #p100090 -->
For more information on how to install a plugin, please refer to the following article: [Installing and Configuring Connectors as a Plugin](zeenea-connectors-install-as-plugin.md# "title: Installing and Configuring Connectors as a Plugin").

<!-- #p100096 -->
## Declaring the Connection

<!-- #p100105 -->
Creating and configuring connectors is done through a dedicated configuration file located in the `/connections` folder of the relevant scanner. The scanner frequently checks for any change and resynchronises automatically.

<!-- #p100114 -->
Read more: [Managing Connections](../Zeenea_Administration/zeenea-managing-connections.md)

<!-- #p100120 -->
In order to establish a connection to a MongoDB cluster, specifying the following parameters in the dedicated file is required:

<!-- #p100126 -->
| Parameter | Expected value |
|---|---|
| `name` | The name that will be displayed to catalog users for this connection |
| `code` | The unique identifier of the connection on the Zeenea platform. Once registered on the platform, this code must not be modified or the connection will be considered as new and the old one removed from the scanner. |
| `connector_id` | The type of connector to be used for the connection. Here, the value must be `Mongodb` and this value must not be modified. |
| `connection.url` | MongoDB connection address.<br><br>Example: `mongodb://mongodb.zeenea.local:27017/admin?authSource=admin` |
| `connection.username` | Username |
| `connection.password` | User password |
| `tls.trust_store.type` | One of two values: `pkcs12` or `jks` |
| `tls.trust_store.path` | Path to the trust store containing the trust certificates. It must contain the certificate chain that generated the MongoDB Cluster Nodes certificates. |
| `tls.trust_store.password` | Password of the Trust Store containing the Trust Certificates |
| `schema_analysis.strategy` | One of two values: `Map Reduce` or `Sample` |
| `schema_analysis.sample.size` | In case mode `Sample` is selected, this will limit the size of the sample. Default value is `1000`. |
| `inventory.databases` | (Optional) List of databases to be inventoried separated by spaces |

<!-- #p100138 -->
## Data Extraction

<!-- #p100144 -->
The MongoDB connector allows you to select between two modes for metadata extraction. Choosing one of these modes is necessary, as MongoDB does not use schemas. 

<!-- #p100150 -->
### MapReduce Mode

<!-- #p100156 -->
This mode uses the MongoDB MapReduce feature, which lists all fields (even those that are only used once). It is very resource consuming, and may result in a timeout failure if it takes too long. 

<!-- #p100162 -->
The MapReduce feature runs JavaScript on the database; this code is coming in from the agent. The code is constant, and is not subjected to any action or data from the user. 

<!-- #p100171 -->
The script engine mustn't be disabled (option `--noscripting`).

<!-- #p100177 -->
No actual data is extracted from the database.

<!-- #p100183 -->
### Sample Mode

<!-- #p100189 -->
This mode uses a sampling request. Because the request is probabilistic, rare fields can't be detected. 

<!-- #p100195 -->
The sample size is defined in the connector. 

<!-- #p100204 -->
There is no risk of a timeout failure, and no JavaScript code is ran on the MongoDB server; thus, this mode is compatible with the `--noscripting` option. 

<!-- #p100210 -->
Some data is read by the agent but it is never saved or sent, and is "forgotten" as soon as the information has been extracted.

<!-- #p100216 -->
## Choosing the Right Mode

<!-- #p100222 -->
The MapReduce mode was built first, however, after being faced with speed issues and timeout failures on large collections, the Sample mode was introduced. 

<!-- #p100228 -->
The MapReduce mode is most useful when the collection size is reasonably large and when it contains rare fields. 

<!-- #p100234 -->
Unfortunately, we do not know which resources are consumed, because this mode is dependent on multiple variables: server performance, collection size, number of fields, etc... 

<!-- #p100240 -->
The Sample mode is usually recommended, however it may not detect rare fields. More accurately, a rare field may appear temporarily when a schema is being updated, and disappear at the next update. This has not been observed or reported, but, statistically, it is a possibility. 

<!-- #p100249 -->
**We recommend trying the Sample mode first, as it is faster and lighter. If it is not applicable to your configuration, switching to the MapReduce mode remains possible.**

<!-- #p100255 -->
## User Permissions

<!-- #p100261 -->
In order to collect metadata, the running user must be able to list and read databases that need to be cataloged.

<!-- #p100270 -->
In case of limited rights to list databases **before version 4**, it is possible to use the inventory.databases parameter to select only the desired databases.

<!-- #p100276 -->
### Integrated Roles

<!-- #p100282 -->
The readAnyDatabase integrated role is enough to catalog the entire system. 

<!-- #p100288 -->
The read integrated role, when assigned to a database, allows the user to catalog that base's collections.

<!-- #p100294 -->
In the following example, the Zeenea account can catalog the sales and stock bases:

<!-- #p100300 -->
```
db.grantRolesToUser('zeenea', [
    { role: 'read', db: 'sales' },
    { role: 'read', db: 'stock' }
]);
```

<!-- #p100306 -->
### Zeenea Role

<!-- #p100312 -->
You may regroup permissions into one specific role for Zeenea:

<!-- #p100318 -->
```
db.createRole({
    role: "zeeneaRole",
    privileges: [],
    roles: [
        { role: 'read', db: 'sales' },
        { role: 'read', db: 'stock' }
    ]});

db.grantRolesToUser('zeenea', 'zeeneaRole');
```

<!-- #p100324 -->
## Collected Metadata

<!-- #p100330 -->
### Inventory

<!-- #p100336 -->
The inventory collects all databases and collections accessible by the user. 

<!-- #p100342 -->
### Datasets

<!-- #p100348 -->
Here, datasets are MongoDB collections.

- <!-- #p100357 -->
  **Name**: collection name

- <!-- #p100369 -->
  **Source Description**: not supported

- <!-- #p100381 -->
  **Technical Data**:

  - <!-- #p100387 -->
    Database: Database name

  - <!-- #p100396 -->
    Collection: Collection name

<!-- #p100414 -->
### Field

<!-- #p100420 -->
Table fields. 

- <!-- #p100432 -->
  **Name**: Field path in the JSON file, where items are separated by a period (e.g., `client.name`)

- <!-- #p100444 -->
  **Source Description**: Not supported

- <!-- #p100459 -->
  **Native type**: Field native type. If there are more than one native types, they are separated with a pipe (`|`).

- <!-- #p100474 -->
  **Nullable**: constant, `TRUE`

- <!-- #p100489 -->
  **Multivalued**: `TRUE` if the field contains a list

- <!-- #p100501 -->
  **Technical Data**:

  - <!-- #p100507 -->
    Technical Name: Field technical name

  - <!-- #p100516 -->
    Native type: Field native type

<!-- #p100534 -->
## Object Identification Keys

<!-- #p100540 -->
An identification key is associated with each object in the catalog. In the case of the object being created by a connector, the connector builds it.

<!-- #p100549 -->
More information about unique identification keys in this documentation: [Identification Keys](../Stewardship/zeenea-identification-keys.md).

<!-- #p100555 -->
| Object | Identification Key | Description |
|---|---|---|
| Dataset | code/database name/dataset name | - **code**: Unique identifier of the connection noted in the configuration file<br>- **database name**<br>- **dataset name** |
| Field | code/database name/dataset name/field name | - **code**: Unique identifier of the connection noted in the configuration file<br>- **database name**<br>- **dataset name**<br>- **field name** |

