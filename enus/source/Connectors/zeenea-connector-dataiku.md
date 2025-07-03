# Adding a Dataiku Connection

<!-- #p100021 -->
## Prerequisites

- <!-- #p100030 -->
  A user with sufficient [permissions](#p100138 "title: Dataiku") is required to establish a connection with Dataiku.

- <!-- #p100039 -->
  Zeenea traffic flows towards the data source must be open. 

<!-- #p100054 -->
> **Note:** The Dataiku connector can be downloaded here: [Zeenea Connector Downloads](zeenea-connectors-list.md# "title: Zeenea Connector Downloads").

<!-- #p100060 -->
## Supported Versions

<!-- #p100066 -->
The Dataiku connector is compatible with the software SaaS version. 

<!-- #p100072 -->
## Installing the Plugin

<!-- #p100081 -->
The Dataiku plugin can be downloaded here: [Zeenea Connector Downloads](zeenea-connectors-list.md# "title: Zeenea Connector Downloads").

<!-- #p100090 -->
For more information on how to install a plugin, please refer to the following article: [Installing and Configuring Connectors as a Plugin](zeenea-connectors-install-as-plugin.md# "title: Installing and Configuring Connectors as a Plugin").

<!-- #p100096 -->
## Declaring the Connection

<!-- #p100105 -->
Creating and configuring connectors is done through a dedicated configuration file located in the `/connections` folder of the relevant scanner.

<!-- #p100114 -->
Read more: [Managing Connections](../Zeenea_Administration/zeenea-managing-connections.md)

<!-- #p100120 -->
In order to establish a connection with a Dataiku instance, specifying the following parameters in the dedicated file is required:

<!-- #p100126 -->
| Parameter | Expected value |
|---|---|
| `name` | The name that will be displayed to catalog users for this connection. |
| `code` | The unique identifier of the connection on the Zeenea platform. Once registered on the platform, this code must not be modified or the connection will be considered as new and the old one removed from the scanner. |
| `connector_id` | The type of connector to be used for the connection. Here, the value must be `dataiku` and this value must not be modified. |
| `connection.url` | Dataiku instance URL (example: `https://url.eu-west-3.app.dataiku.io`) |
| `connection.username` | Secret token generated from the Dataiku application |
| `tls.truststore.path` | The Trust Store file path. This file must be provided in case TLS encryption is activated (protocol https) and when certificates of servers are delivered by a specific authority. It must contain the certification chain. |
| `tls.truststore.password` | Password of the trust store file |
| `tls.truststore.type` | Type of the trust store file (`PKCS12` or `JKS`). Default value is discovered from the file extension. |
| `proxy.scheme` | Depending on the proxy, `http` or `https` |
| `proxy.hostname` | Proxy address |
| `proxy.port` | Proxy port. |
| `proxy.username` | Proxy username |
| `proxy.password` | Proxy account password |

<!-- #p100138 -->
## User Permissions

<!-- #p100144 -->
In order to collect metadata, the running user's permissions must allow them to access and read datasets that need cataloging. 

<!-- #p100150 -->
Here, the user must have read access to Dataiku projects that need cataloging.

<!-- #p100156 -->
## Data Extraction

<!-- #p100162 -->
To extract information, the connector runs the following REST requests on the API:

- <!-- #p100174 -->
  **GET**: `/public/api/projects/`: To get the project list.

- <!-- #p100189 -->
  **GET** `/public/api/projects/{project name}/datasets/`: To get dataset from the project.

- <!-- #p100204 -->
  **GET** `/public/api/projects/{project name}/datasets/{dataset name}/`: To get metadata dataset.

<!-- #p100216 -->
## Collected Metadata

<!-- #p100222 -->
### Inventory

<!-- #p100228 -->
Will collect the list of datasets accessible by the user.  

<!-- #p100234 -->
### Dataset

- <!-- #p100243 -->
  **Name**

- <!-- #p100255 -->
  **Source Description**

- <!-- #p100267 -->
  **Technical Data**:

  - <!-- #p100273 -->
    Type

  - <!-- #p100282 -->
    Format Type

  - <!-- #p100291 -->
    Project Key

  - <!-- #p100300 -->
    Updated At

  - <!-- #p100309 -->
    Updated By

<!-- #p100327 -->
### Field

<!-- #p100333 -->
Dataset field. 

- <!-- #p100342 -->
  **Name**

- <!-- #p100354 -->
  **Source Description**

- <!-- #p100366 -->
  **Type**

- <!-- #p100381 -->
  **Can be null**: Not supported. Default value `false`. 

- <!-- #p100396 -->
  **Multivalued**: Not supported. Default value `false`.

- <!-- #p100411 -->
  **Primary Key**: Not supported. Default value `false`.

- <!-- #p100423 -->
  **Technical Data**:

  - <!-- #p100429 -->
    Technical Name

  - <!-- #p100438 -->
    Native type

<!-- #p100456 -->
## Unique Identifier Keys

<!-- #p100462 -->
A key is associated with each item of the catalog. When the object comes from an external system, the key is built and provided by the connector.

<!-- #p100471 -->
Read more: [Identification Keys](../Stewardship/zeenea-identification-keys.md)

<!-- #p100477 -->
| Object | Identifier Key | Description |
|---|---|---|
| Dataset | code/project/dataset name | - **code**: Unique identifier of the connection noted in the configuration file<br>- **project**: Dataiku project name<br>- **dataset name** |
| Field | code/project/dataset name/field name | - **code**: Unique identifier of the connection noted in the configuration file<br>- **project**: Dataiku project name<br>- **dataset name**<br>- **field name** |

