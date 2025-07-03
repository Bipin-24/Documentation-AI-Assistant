# Adding a DynamoDB Connection

<!-- #p100021 -->
## Prerequisites

- <!-- #p100030 -->
  A user with sufficient [permissions](#p100138 "title: AWS DynamoDB") is required to establish a connection with DynamoDB.

- <!-- #p100039 -->
  Zeenea traffic flows towards the data source must be open. 

<!-- #p100054 -->
> **Note**: A link to the configuration template is available from this page: [Zeenea Connector Downloads](zeenea-connectors-list.md# "title: Zeenea Connector Downloads").

<!-- #p100060 -->
## Supported Versions

<!-- #p100066 -->
The DynamoDB connector was developed and tested with the web version of the product. 

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
In order to establish a connection with a DynamoDB instance, specifying the following parameters in the dedicated file is required:

<!-- #p100126 -->
| Parameter | Expected value |
|---|---|
| `name` | The name that will be displayed to catalog users for this connection. |
| `code` | The unique identifier of the connection on the Zeenea platform. Once registered on the platform, this code must not be modified or the connection will be considered as new and the old one removed from the scanner. |
| `connector_id` | The type of connector to be used for the connection. Here, the value must be `aws-dynamodb` and this value must not be modified. |
| **Optional, can be determined from the EC2 configuration** | |
| `connection.aws.url` | Database DynamoDB address |
| `connection.aws.profile` | AWS profile |
| `connection.aws.access_key_id` | AWS key identifier |
| `connection.aws.secret_access_key` | AWS secret access key |
| `connection.aws.region` | AWS region |
| `connection.fetch_page_size` | (Advanced) define the size of batch of items loaded by each request in inventory |
| **Sampling** | |
| `schema_analysis.enable` | Enable data sample in order to complete dataset fields. Default value is `false`. |
| `schema_analysis.sample_size` | Number of items retrieve for data sample. Default value is `1000`. |
| **Certificate & Proxy** | |
| `tls.truststore.path` | The Trust Store file path. This file must be provided in case TLS encryption is activated (protocol https) and when certificates of servers are delivered by a specific authority. It must contain the certification chain. |
| `tls.truststore.password` | Password of the trust store file |
| `tls.truststore.type` | Type of the trust store file. (`PKCS12` or `JKS`). Default value is discovered from the file extension. |
| `proxy.scheme` | Depending on the proxy, `http` or `https` |
| `proxy.hostname` | Proxy address |
| `proxy.port` | Proxy port |
| `proxy.username` | Proxy username |
| `proxy.password` | Proxy account password |

<!-- #p100138 -->
## User Permissions

<!-- #p100144 -->
In order to collect metadata, the running user's permissions must allow them to access and read databases that need cataloging. 

<!-- #p100150 -->
Here, the user must have the followings access rights:

- <!-- #p100159 -->
  `dynamodb:ListTables`

- <!-- #p100171 -->
  `dynamodb:DescribeTable`

<!-- #p100183 -->
If you want to determine the table's value pattern by means of sampling, the following additional access right is required:

- <!-- #p100192 -->
  `dynamodb:PartiQLSelect`

<!-- #p100204 -->
## Data Extraction

<!-- #p100210 -->
To extract information, the connector runs requests on the API:

- <!-- #p100219 -->
  `listTables`

- <!-- #p100231 -->
  `describeTable`

- <!-- #p100243 -->
  `executeStatement(Statement='select * from [table_name]', Limit=[sample_size])` (only with the sampling feature)

<!-- #p100255 -->
## Collected Metadata

<!-- #p100261 -->
### Inventory

<!-- #p100267 -->
Will collect the list of tables accessible by the user. 

<!-- #p100273 -->
### Dataset

<!-- #p100279 -->
A dataset is a DynamoDB table. 

- <!-- #p100288 -->
  **Name**

- <!-- #p100300 -->
  **Source Description**

- <!-- #p100312 -->
  **Technical Data**:

  - <!-- #p100318 -->
    AWS Region

  - <!-- #p100327 -->
    Creation Date

  - <!-- #p100336 -->
    Items Count

  - <!-- #p100345 -->
    Table Size

<!-- #p100363 -->
### Field

<!-- #p100369 -->
Dataset field. 

- <!-- #p100378 -->
  **Name**

- <!-- #p100390 -->
  **Source Description**

- <!-- #p100402 -->
  **Type**

- <!-- #p100414 -->
  **Can be null**: Depending on the field settings 

- <!-- #p100429 -->
  **Multivalued**: Not supported. Default value `false`.

- <!-- #p100441 -->
  **Primary Key**: Depending on the "Primary Key" field attribute

- <!-- #p100453 -->
  **Technical Data**:

  - <!-- #p100459 -->
    Technical Name

  - <!-- #p100468 -->
    Native type: Field native type

  - <!-- #p100477 -->
    Field Kind

<!-- #p100495 -->
## Unique Identification Keys

<!-- #p100501 -->
A key is associated with each item of the catalog. When the object comes from an external system, the key is built and provided by the connector.

<!-- #p100510 -->
Read more: [Identification Keys](../Stewardship/zeenea-identification-keys.md)

<!-- #p100516 -->
| Object | Identifier Key | Description |
|---|---|---|
| Dataset | code/region/dataset name | - **code**: Unique identifier of the connection noted in the configuration file<br>- **region**: AWS object region<br>- **dataset name**: Table name |
| Field | code/region/dataset name/field name | - **code**: Unique identifier of the connection noted in the configuration file<br>- **region**: AWS object region<br>- **dataset name**: Table name<br>- **field name** |

