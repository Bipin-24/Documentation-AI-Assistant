# Adding an SAP BO Connection

<!-- #p100021 -->
## Prerequisites

- <!-- #p100030 -->
  A user with sufficient [permissions](#p100138 "title: SAP BO") is required to connect to SAP BO.

- <!-- #p100039 -->
  Zeenea traffic flows towards the database must be opened. 

<!-- #p100054 -->
> **Note:** A template of the configuration file can be downloaded here: [sap-bo.conf](https://actian.file.force.com/sfc/dist/version/download/?oid=00D300000001XnW&amp;ids=068Nu00000GUbsA&amp;d=%2Fa%2FNu000002lg13%2FjreF1E.n796hrp2hMHF2Sx439bB2NS79B2n35_HIsak&amp;asPdf=false).

<!-- #p100060 -->
## Supported Versions

<!-- #p100066 -->
The SAP BO connector is compatible with all recent versions in which the Rest API is exposed (necessary for the connector to access and harvest metadata). 

<!-- #p100072 -->
## Installing the Plugin

<!-- #p100081 -->
The SAP BO connector can be downloaded here: [Zeenea Connector Downloads](zeenea-connectors-list.md# "title: Zeenea Connector Downloads")

<!-- #p100090 -->
For more information on how to install a plugin, please refer to the following article: [Installing and Configuring Connectors as a Plugin](zeenea-connectors-install-as-plugin.md# "title: Installing and Configuring Connectors as a Plugin").

<!-- #p100096 -->
## Declaring the Connection

<!-- #p100105 -->
Creating and configuring connectors is done through a dedicated configuration file located in the `/connections` folder of the relevant scanner. The scanner frequently checks for any change and resynchronises automatically.

<!-- #p100114 -->
Read more: [Managing Connections](../Zeenea_Administration/zeenea-managing-connections.md)

<!-- #p100120 -->
The following parameters are required in order to establish a connection with SAP BO. 

<!-- #p100126 -->
| Parameter | Expected value |
|---|---|
| `name` | The name that will be displayed to catalog users for this connection. |
| `code` | The unique identifier of the connection on the Zeenea platform. Once registered on the platform, this code must not be modified or the connection will be considered as new and the old one removed from the scanner. |
| `connector_id` | The connector type to use for the connection. Here, the value must be `sap-bo` and this value must not be modified. |
| `connection.url` | URL towards the SAP BO REST API (e.g., `http://:6405`).<br>This URL can be obtained from the Central Management Console (CMC) |
| `connection.username` | User’s technical identifier |
| `connection.password` | User password |
| `connection.auth_type` | Authentication type (`secEnterprise`, `secLDAP`, `secWinAD`, `secSAPR3`). Default value `secEnterprise`. |
| `tls.truststore.path` | The Trust Store file path. This file must be provided in case TLS encryption is activated (HTTPS protocol) and when the server's certificates have been delivered by a specific Certification Authority. The file must contain the certification chain. |
| `tls.truststore.password` | Trust Store password |
| `tls.truststore.type` | Trust Store type. Possible options are `pkcs12` or `jks`. |
| `proxy.scheme` | Depending on the proxy, `http` or `https` |
| `proxy.hostname` | Proxy address |
| `proxy.port` | Proxy port |
| `proxy.username` | Proxy username |
| `proxy.password` | Proxy user password |

<!-- #p100138 -->
## User Permissions

<!-- #p100144 -->
In order for the connector to harvest metadata, the running user associated with it must be able to list and read objects that need to be cataloged. 

<!-- #p100150 -->
## Metadata Extraction

<!-- #p100156 -->
To harvest metadata, the connector will run the following API queries:

- <!-- #p100168 -->
  **GET &amp; POST** `/biprws/logon/long` : authentication query

- <!-- #p100180 -->
  `/universes`

- <!-- #p100192 -->
  `/universes/$param`

- <!-- #p100204 -->
  `/documents`

- <!-- #p100216 -->
  `/documents/$param`

- <!-- #p100228 -->
  `/documents/$param/dataproviders`

- <!-- #p100240 -->
  `/documents/$param/dataproviders/$param` to harvest all assets (visualizations, datasets, fields)

<!-- #p100252 -->
## Collected Metadata

<!-- #p100258 -->
### Inventory

<!-- #p100264 -->
The inventory lists all visualizations (Webi Documents) the running user has access to. 

<!-- #p100270 -->
### Visualization

<!-- #p100276 -->
A visualization is a Webi Document.

- <!-- #p100285 -->
  **Name**

- <!-- #p100297 -->
  **Source Description**

- <!-- #p100309 -->
  **Technical Data**:

  - <!-- #p100315 -->
    SAP ID

  - <!-- #p100324 -->
    UUID

<!-- #p100342 -->
### Datasets

<!-- #p100348 -->
A dataset is a Data Provider or an SAP Universe.

- <!-- #p100357 -->
  **Name**

- <!-- #p100369 -->
  **Source Description**

- <!-- #p100381 -->
  **Technical Data**:

  - <!-- #p100387 -->
    SAP Identifier

  - <!-- #p100396 -->
    RowNumber (Data Provider)

  - <!-- #p100405 -->
    Universe type (SAP Universe)

<!-- #p100423 -->
### Fields

<!-- #p100429 -->
One field per table (dataset) column.

