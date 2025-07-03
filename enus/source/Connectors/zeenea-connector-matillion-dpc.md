# Adding a Matillion DPC Connection

## Prerequisites

* A user with sufficient [permissions](#user-permissions) is required to establish a connection with Matillion DPC.

> **Note:** The configuration template can be downloaded here: [matillion-dpc.conf](https://github.com/zeenea/connector-conf-templates/blob/main/templates/matillion-dpc.conf)

## Supported Versions

The Matillion DPC module is compatible with the online version of the product. 

## Installing the Plugin

The Matillion DPC plugin can be downloaded here: [Zeenea Connector Downloads](./zeenea-connectors-list.md)

For more information on how to install a plugin, please refer to the following article: [Installing and Configuring Connectors as a Plugin](./zeenea-connectors-install-as-plugin.md).

## Declaring the Connection

Creating and configuring connectors is done through a dedicated configuration file located in the `/connections` folder of the relevant scanner. The scanner frequently checks for any change and resynchronises automatically.

Read more: [Managing Connections](../Zeenea_Administration/zeenea-managing-connections.md)

In order to establish a connection with a Matillion DPC instance, the following parameters in the dedicated file are required:

### Changes in version 4.1.0

| Parameter | Expected value |
|---|---|
| `name` | The name that will be displayed to catalog users for this connection. |
| `code` | The unique identifier of the connection on the Zeenea platform. Once registered on the platform, this code must not be modified or the connection will be considered as new and the old one removed from the scanner. |
| `connector_id` | The type of connector to be used for the connection. Here, the value must be `matillion-dpc` and this value must not be modified. |
| `connection.path` | The root path of matillions files |
| `default.warehouse` | Replace the default value [Environment Default] for the parameters "warehouse" for every components |
| `default.database` | Replace the default value [Environment Default] for the parameters "database" for every components |
| `default.schema` | Replace the default value [Environment Default] for the parameters "schema" for every components |

## User Permissions

In order to collect metadata, the running user's permissions must allow them to access and read folders and files that need cataloging.

## Data Extraction

The Matillion DPC connector feeds Zeenea Database with Data Processes. Like other Data Process connectors, it has a single job "synchronize" that discovers all items of interest and creates or updates their documentation in the catalog. Matillion items of interest are Jobs. So, for each Jobs in Matillion DPC, a Data Process should be created in Zeenea.

## Synchronization

This connector will harvest all transformation processes identified in the Matillion DPC instance, and automatically represent them in Zeenea.

## Lineage

The Matillion DPC connector is able to retrieve the lineage with:

* Matillion DPC for **Redshift**
* Matillion DPC for **Snowflake**
* Matillion DPC for **Oracle**
* Matillion DPC for **PostgreSQL**

## Collected Metadata

### Data Process

A data process is a Matillion transformation. 

* **Name**
* **Source Description**
* **Input**: Input datasets
* **Output**: Output datasets
* **Technical Data**:
  * YAML job definition
  * Warehouse
  * Database
  * Schema

## Unique Identifier Keys
 
A key is associated with each item of the catalog. When the object comes from an external system, the key is built and provided by the connector.
 
More information about unique identification keys in this documentation: [Identification Keys](../Stewardship/zeenea-identification-keys.md).
  
| Object | Identifier Key | Description |
|---|---|---|
| Data process | code/name | - **code**: Unique identifier of the connection noted in the configuration file<br/>- **name**: job name |