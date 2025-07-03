# Adding an AWS Glue (Data Catalog) Connection

## Prerequisites

* A user with sufficient [permissions](#user-permissions) is required to establish a connection with AWS Glue.
* Zeenea traffic flows towards the database must be open. 

The Agent's host server must have sufficient credentials to connect to AWS Glue; in this case, available authentication methods are: 

* Instance Role
* Environment Variable
* Configuration File

> **Note:** A configuration template can be downloaded here: [aws-glue.conf](https://actian.file.force.com/sfc/dist/version/download/?oid=00D300000001XnW&ids=068Nu00000GUWKh&d=%2Fa%2FNu000002lgp3%2FH18toXLWbRtA99SpfE67qxKdIhnrTJyyB7dsfnec2vQ&asPdf=false)

| Target | Protocol	| Usual Ports |
| :--- | :--- | :--- |
| AWS Glue | HTTP | 443 |

## Supported Versions

The AWS Glue connector was successfully tested with the online application. 

## Installing the Plugin

The AWS Glue plugin can be downloaded here: [Zeenea Connector Downloads](./zeenea-connectors-list.md).

For more information on how to install a plugin, please refer to the following article: [Installing and Configuring Connectors as a Plugin](./zeenea-connectors-install-as-plugin.md).

## Declaring the Connection
  
Creating and configuring connectors is done through a dedicated configuration file located in the `/connections` folder of the relevant scanner.
 
Read more: [Managing Connections](../Zeenea_Administration/zeenea-managing-connections.md)
 
In order to establish a connection with an AWS Glue instance, specifying the following parameters in the dedicated file is required:
 
| Parameter | Expected value |
|---|---|
| `name` | The name that will be displayed to catalog users for this connection. |
| `code` | The unique identifier of the connection on the Zeenea platform. Once registered on the platform, this code must not be modified or the connection will be considered as new and the old one removed from the scanner. |
| `connector_id` | The type of connector to be used for the connection. Here, the value must be `aws.glue` and this value must not be modified. |
| `connection.aws.access_key_id` | AWS Glue Access Key Identifier |
| `connection.aws.secret_access_key` | AWS Glue Secret Access Key |
| `connection.aws.region` | AWS region |
| `connection.aws.profile` | AWS Profile for authentication |
| `connection.aws.multi_account.enabled ` | Allow a single connection to retrieve data from other AWS account data catalog.<br><br>In order to connect to multiple accounts, you need to configure AWS cross access between accounts.<br><br>AWS documentation : https://docs.aws.amazon.com/glue/latest/dg/cross-account-access.html.<br><br>Default value is `false`.<br><br>*Since version 3.3.1* |
| `connection.aws.multi_account.list` | Define which account/region to connected to. It must be a list of *account*:*region* entries, separated by a space.<br><br><br>Example : `123456789012:eu-west-2 987654321098:eu-west-2`<br><br>*Since version 3.3.1* |
| `connection.fetch_page_size` | (Advanced) define the size of batch of items loaded by each request in inventory.<br><br>*Since version 1.0.3* |
| `filter` | Lets you filter based on specific characteristics. See [Rich Filters](#rich-filters) below for a comprehensive explanation.<br><br>*Since version 3.4.1* |

## User Permissions

In order to collect metadata, the running user's permissions must allow them to access and read databases that need cataloging. 

### Roles

The user must be able to run the following actions on the target bucket and the objects it contains: 

* `glue:GetTable`
* `glue:GetTables`
* `glue:GetDatabases`
 
Example for cataloging a bucket (in JSON):

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SearchTables",
      "Effect": "Allow",
      "Action": [
        "glue:GetTable",
        "glue:GetTables",
        "glue:GetDatabases"
      ],
      "Resource": "*"
    }
  ]
}
```

## Rich Filters

### Databases and Tables

Starting with version 3.4.1, the connector embeds a rich filter mechanism that enables you to extract only specific tables or databases matching the criteria.


| Criteria | Description |
| :--- | :--- |
| database | Database name |
| table | Table name |

Example:

`filter = "database in ('production', 'qa') and table ~ /(?:hr|it|market)_figures/"`

> **Note:** The `filter` attribute can contain either the raw value or a file URL to the content. (e.g., `file:///path/to/zeenea/connections/aws-glue-inventory-filter.json`)
>
> When using an side-file, filter changes are taken into account without restarting the scanner.

## Data Extraction

To extract information, the connector requests AWS Glue to get tables and metadata.

## Collected Metadata

### Inventory

Will collect the list of tables and views accessible by the user.  

### Dataset

A dataset can be a table or a view. 

* **Name**
* **Source Description**
* **Technical Data**:
  * AWS Region
  * Database Name
  * Location
  * Owner
  * CreateTime
  * UpdateTime
  * LastAccessTime
  * LastAnalyzeTime
  * TableType

### Field

Dataset field. 

* **Name**
* **Source Description**
* **Type**
* **Can be null**: Depending on field settings 
* **Multivalued**: Depending on field settings
* **Primary Key**: Not supported. Default value `false`.

## Object Identification Keys

An identification key is associated with each object in the catalog. In the case of the object being created by a connector, the connector builds it.

 Read more: [Identification Keys](../Stewardship/zeenea-identification-keys.md)

| Object | Identification Key | Description |
|---|---|---|
| Dataset | code/aws region/dataset identifier | - **code**: Unique identifier of the connection noted in the configuration file<br>- **aws region**: AWS region code<br>- **dataset identifier**: Table name<br> Database schema name<br>S3 bucket key |
| Field | code/aws region/dataset identifier/field name | - **code**: Unique identifier of the connection noted in the configuration file<br>- **aws region**: AWS region code<br>- **dataset identifier**: <br>Database schema name<br>S3 bucket key<br>- **field name** |
