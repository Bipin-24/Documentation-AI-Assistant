# Adding an Athena Connection

<!-- #p100021 -->
## Prerequisites

- <!-- #p100030 -->
  A user with sufficient [permissions](#p100549 "title: AWS Athena") is required to establish a connection with Athena. 

- <!-- #p100039 -->
  Zeenea traffic flows towards the data source must be open. 

<!-- #p100054 -->
> **Note**: A link to the configuration template can be found here: [Zeenea Connector Downloads](zeenea-connectors-list.md# "title: Zeenea Connector Downloads").

<!-- #p100060 -->
## Supported Versions

<!-- #p100066 -->
The Athena connector is compatible with the web version of the service. 

<!-- #p100072 -->
## Installing the Plugin

<!-- #p100081 -->
The AWS plugin can be downloaded here: [Zeenea Connector Downloads](zeenea-connectors-list.md# "title: Zeenea Connector Downloads").

<!-- #p100090 -->
For more information on how to install a plugin, please refer to the following article: [Installing and Configuring Connectors as a Plugin](zeenea-connectors-install-as-plugin.md# "title: Installing and Configuring Connectors as a Plugin").

<!-- #p100096 -->
## Declaring the Connection

<!-- #p100105 -->
Creating and configuring connectors is done through a dedicated configuration file located in the `/connections` folder of the relevant scanner.

<!-- #p100114 -->
Read more: [Managing Connections](../Zeenea_Administration/zeenea-managing-connections.md)

<!-- #p100120 -->
In order to establish a connection with an Athena instance, specifying the following parameters in the dedicated file is required:

<!-- multiline -->
| Parameter | Expected Value |
| --------- | -------------- |
| `name` | The name that will be displayed to catalog users for this connection. |
| `code` | Unique identifier of the connection on the Zeenea platform. Once registered on the platform, this code must not be modified or the connection will be considered as new and the old one removed from the scanner. |
| `connector_id` | The type of connector to be used for the connection. Here, the value must be `aws-athena` and this value must not be modified. |
| `connection.aws.profile` | AWS profile |
| `connection.aws.access_key_id` | AWS key identifier |
| `connection.aws.access_key_secret` | AWS secret access key |
| `connection.aws.region` | AWS region |
| `connection.fetch_page_size` | (Advanced) define the size of batch of items loaded by each request in inventory |
| `tls.truststore.path` | The Trust Store file path. This file must be provided in case TLS encryption is activated (protocol https) and when certificates of servers are delivered by a specific authority. It must contain the certification chain. |
| `tls.truststore.password` | Password of the trust store file |
| `tls.truststore.type` | Type of the trust store file (`PKCS12` or `JKS`). Default value is discovered from the file extension. |
| `proxy.scheme` | Depending on the proxy, `http` or `https` |
| `proxy.hostname` | Proxy address |
| `proxy.port` | Proxy port |
| `proxy.username` | Proxy username |
| `proxy.password`| Proxy account password |

<!-- #p100549 -->
## User Permissions

<!-- #p100555 -->
In order to collect metadata, the running user's permissions must allow them to access and read databases that need cataloging. 

<!-- #p100561 -->
Here, the user must have followings access:

- <!-- #p100567 -->
  athena:GetDataCatalog

- <!-- #p100576 -->
  athena:ListDatabases

- <!-- #p100585 -->
  athena:GetDatabase

- <!-- #p100594 -->
  athena:ListTableMetadata

- <!-- #p100603 -->
  athena:GetTableMetadata

<!-- #p100615 -->
## Data Extraction

<!-- #p100621 -->
To extract information, the connector runs requests through the AWS SDK:

- <!-- #p100627 -->
  AmazonAthena.ListDataCatalogs

- <!-- #p100636 -->
  AmazonAthena.ListDatabases

- <!-- #p100645 -->
  AmazonAthena.ListTableMetadata

- <!-- #p100654 -->
  AmazonAthena.GetTableMetadata

<!-- #p100666 -->
## Collected Metadata

<!-- #p100672 -->
### Inventory

<!-- #p100678 -->
Will collect the list of tables and views accessible by the user.  

<!-- #p100684 -->
### Dataset

<!-- #p100690 -->
A dataset can be a table or a view. 

- <!-- #p100699 -->
  **Name**

- <!-- #p100711 -->
  **Source Description**

- <!-- #p100723 -->
  **Technical Data**: 

  - <!-- #p100729 -->
    Creation Date

  - <!-- #p100738 -->
    Location

  - <!-- #p100747 -->
    Table Type

  - <!-- #p100756 -->
    Format

  - <!-- #p100765 -->
    Partitioned By

<!-- #p100783 -->
### Field

<!-- #p100789 -->
Dataset field. 

- <!-- #p100798 -->
  **Name**

- <!-- #p100810 -->
  **Source Description**

- <!-- #p100822 -->
  **Type**

- <!-- #p100834 -->
  **Can be null**: Depending on field settings

- <!-- #p100849 -->
  **Multivalued**: Not supported. Default value `false`.

- <!-- #p100861 -->
  **Primary key**: Depending on the "Primary Key" field attribute

- <!-- #p100873 -->
  **Technical Data**: 

  - <!-- #p100879 -->
    Technical Name

  - <!-- #p100888 -->
    Native type

<!-- #p100906 -->
## Unique Identifier Keys

<!-- #p100912 -->
A key is associated with each item of the catalog. When the object comes from an external system, the key is built and provided by the connector.

<!-- #p100921 -->
More information about unique identification keys in this documentation: [Identification Keys](../Stewardship/zeenea-identification-keys.md).

<!-- #p100927 -->
| Object  | Identifier Key | Description     |
| :------ | :------------- | :-------------- |
| Dataset | code/region/catalog/schema/dataset name  | - **code**: Unique identifier of the connection noted in the configuration file<br>- **region**: AWS region<br>- **catalog**: Object catalog<br>- **schema**: Object schema<br>- **dataset name**: Table or view name |
| Field   | code/region/catalog/schema/dataset name/field name | - **code**: Unique identifier of the connection noted in the configuration file<br>- **region**: AWS region<br>- **catalog**: Object catalog<br>- **schema**: Object schema<br>- **dataset name**: Table or view name<br>- **field name** |

