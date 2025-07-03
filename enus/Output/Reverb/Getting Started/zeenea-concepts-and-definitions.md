<!-- #p100003 -->
# Concepts and Definitions

<!-- #p100009 -->
This list highlights select Zeenea-specific terms you might encounter in the documentation. It focuses on terms with unique meanings within Zeenea.

<!-- #p100015 -->
Many definitions on the list provide links to articles and core reference materials, offering deeper insights into the concepts and practical applications of the associated keyword.

<!-- #p100021 -->
Use the search feature in your browser to quickly find the term or phrase that you are looking for. Search is usually activated with CTRL+F or ⌘ + F.

<!-- #p100027 -->
## Category

<!-- #p100033 -->
The "Category" item type is a concept that facilitates the organization of datasets in Zeenea.

<!-- #p100039 -->
It will allow you to create groupings of datasets according to your organization and your domains.

<!-- #p100045 -->
This Item Type is deprecated.

<!-- #p100051 -->
Its characteristics:

- <!-- #p100057 -->
  A dataset may or may not belong to a Category. 

- <!-- #p100066 -->
  A category can be created without associated datasets.

- <!-- #p100075 -->
  The search by Category is proposed in the search engine. 

<!-- #p100087 -->
The elements of a Category item are the following:

- <!-- #p100093 -->
  Name

- <!-- #p100102 -->
  Description

- <!-- #p100111 -->
  Associated datasets

- <!-- #p100120 -->
  Properties

- <!-- #p100129 -->
  Contacts

<!-- #p100141 -->
## Connection

<!-- #p100147 -->
A Connection represents a system to which Zeenea is connected. It allows the scanner to retrieve metadata from your information source with which you are connected and incorporate them into Zeenea. 

<!-- #p100153 -->
Connections are therefore associated with specific solutions (Oracle, Teradata, HDFS, Amazon S3, Table, Power BI...) through Zeenea connectors.

<!-- #p100159 -->
## Custom item

<!-- #p100165 -->
Custom items allow you to document entirely new concepts, without being limited by native or default Item Types in Zeenea. They offer ideal support for modeling abstract concepts, complementary to the metadata structurally proposed by Zeenea.

<!-- #p100171 -->
Each new custom item type can be used on each of the templates, as a single or multi-valued property, to create relationships with all of Zeenea's asset types.

<!-- #p100177 -->
## Dataset

<!-- #p100183 -->
 A dataset is a physical representation of an existing set of data from a database. 

<!-- #p100189 -->
It can be a table in a database, a collection in a NoSQL storage, a file or a set of files in a file system, etc. 

<!-- #p100195 -->
Elements of a "dataset" item:

<!-- #p100201 -->
In the detailed pages of this item, you can find a set of information, such as: 

- <!-- #p100207 -->
  a title (a logical name and the technical name) 

- <!-- #p100216 -->
  the source of import

- <!-- #p100225 -->
  the date of its last update with the source in Zeenea

- <!-- #p100234 -->
  a description added from Zeenea Studio

- <!-- #p100243 -->
  a description imported from the source

- <!-- #p100252 -->
  associated business terms

- <!-- #p100261 -->
  the schema of the dataset and its fields

- <!-- #p100270 -->
  its lineage (through data process items)

- <!-- #p100279 -->
  its data model (graph and list of all links in the datasource)

- <!-- #p100288 -->
  associated contacts

- <!-- #p100297 -->
  properties filled in by the associated contacts

<!-- #p100309 -->
## Data Process

<!-- #p100315 -->
A Data Process is an item in Zeenea generally used to materialize a program or pipeline taking one or more sets of data as input and producing one or more other sets of data as output.

<!-- #p100321 -->
This item thus makes it possible to materialize these relations between datasets and therefore to build the "horizontal" lineage of the data.

<!-- #p100327 -->
Data Processes can also be used to represent logical data flows between custom items.

<!-- #p100333 -->
In the detailed pages of this item, you can find a set of information, such as: 

- <!-- #p100339 -->
  Technical name

- <!-- #p100348 -->
  Name 

- <!-- #p100357 -->
  Description 

- <!-- #p100366 -->
  Properties 

- <!-- #p100375 -->
  Contacts

- <!-- #p100384 -->
  Input Datasets

- <!-- #p100393 -->
  Outputs Datasets

<!-- #p100405 -->
## Field

<!-- #p100411 -->
The structure of a dataset is described in its schema. This structure contains the enumeration, if known, of the Fields, which typically correspond to the columns of a table in a database. 

<!-- #p100417 -->
Fields are the technical items with the finest granularity in Zeenea.

<!-- #p100423 -->
Fields are accompanied by metadata:

- <!-- #p100429 -->
  Technical name

- <!-- #p100438 -->
  Logical name

- <!-- #p100447 -->
  Type

- <!-- #p100456 -->
  Characteristics specific to the storage system (nullable, primary key...)

- <!-- #p100465 -->
  Description proposed by the Data Steward

- <!-- #p100474 -->
  Description from Data source (read-only)

- <!-- #p100483 -->
  Link to glossary item(s)

- <!-- #p100492 -->
  Properties

- <!-- #p100501 -->
  Contacts

<!-- #p100513 -->
## Glossary Item

<!-- #p100519 -->
A business glossary is used to document and store a specific company's business concepts and terminology, as well as to detail relationships between these items. 

<!-- #p100525 -->
A glossary sheds some light on: 

- <!-- #p100531 -->
  The way a business term is defined

- <!-- #p100540 -->
  Who is responsible for a business term definition

- <!-- #p100549 -->
  How is a KPI calculated?

<!-- #p100561 -->
Setting up a glossary in Zeenea will help bring value to your data by: 

- <!-- #p100567 -->
  Bringing a common understanding of your company’s concepts and terminology

- <!-- #p100576 -->
  Reducing the risk of misuse, especially due to a misunderstanding of the data

- <!-- #p100585 -->
  Maximizing research capabilities and easing access to documented company data

<!-- #p100597 -->
Other advantages of a glossary are: 

- <!-- #p100603 -->
  Clearly communicating on all company assets, hence diminishing back and forth

- <!-- #p100612 -->
  Giving IT and Business teams  a common vocabulary

- <!-- #p100621 -->
  Helping to identify policies, data governance, and data management initiatives. 

<!-- #p100633 -->
Zeenea allows you to create different kinds of Items to build your business glossary to better reflect your organization's business landscape: business terms, KPIs, reports, domains, etc. Glossary Items represent all these kinds of business Items in the catalog.

<!-- #p100639 -->
The attributes of a Glossary Item are the following:

- <!-- #p100645 -->
  Name

- <!-- #p100654 -->
  Description

- <!-- #p100663 -->
  Properties

- <!-- #p100672 -->
  Contacts

- <!-- #p100681 -->
  Parents &amp; children (other Glossary Items that have direct links in the glossary hierarchy)

- <!-- #p100690 -->
  Implementations (technical assets that can be defined by the Glossary Item)

<!-- #p100702 -->
## Key

<!-- #p100708 -->
A key allows for each object in the catalog to be uniquely identified. Keys are especially useful when using synchronizing the catalog with an External System, either via the APIs, or when using the Excel Import feature. 

<!-- #p100714 -->
## Orphan Dataset

<!-- #p100720 -->
An orphan dataset is a dataset that is still present in the catalog but is no longer listed by the connection during automatic or manual inventories.

<!-- #p100726 -->
### Possible Causes

- <!-- #p100732 -->
  moving this dataset to a new storage system,

- <!-- #p100741 -->
  a migration of the data to another table,

- <!-- #p100750 -->
  etc.

<!-- #p100762 -->
### Objective

<!-- #p100768 -->
Zeenea helps identify orphan datasets to keep catalog content up-to-date and avoid directing Explorers to obsolete data assets.

<!-- #p100774 -->
### Impacts

- <!-- #p100780 -->
  The documentation of an orphan dataset can no longer be updated through its original connection.

- <!-- #p100789 -->
  If this dataset has been moved, it is treated by Zeenea as a new entry.

<!-- #p100801 -->
## Property

<!-- #p100807 -->
A property is a component of the metamodel used to store metadata specific to a given item. It allows to provide context and/or to categorize the items in the catalog. The properties are also used as search criteria or filters and thus provide more efficient access to items.

<!-- #p100813 -->
Properties options when configuring them: 

- <!-- #p100819 -->
  Flexible configuration: Simple Text, Rich Text, Enumeration...

- <!-- #p100828 -->
  Indexable from the search engine. 

- <!-- #p100837 -->
  Mandatory or important status.

- <!-- #p100846 -->
  Display properties in the result list under the item it is associated with.

<!-- #p100858 -->
Read more about it: Creating, Editing, or deleting a property 

<!-- #p100864 -->
## Template

<!-- #p100870 -->
The template of a type of Item (datasets, visualizations, business terms, etc.) is a structured representation of all the information (metadata) used to describe it. 

<!-- #p100876 -->
### Characteristics

<!-- #p100882 -->
The notion of template in Zeenea represents a coherent set of properties. From Zeenea Studio, you can define templates for each item type by adding and ordering sections and properties.

<!-- #p100888 -->
The template will allow you to document each item in a unitary manner by highlighting the properties that make it up.

<!-- #p100894 -->
By choosing the right concepts, organizing them in a coherent way, and framing their input via appropriate typing, you optimize the efficiency of the Data Stewards' work but also the quality of their production. They will enable data consumers to quickly find the data they are interested in with its context.  

<!-- #p100900 -->
<font color="red">Link broken in Community docs:</font>

<!-- #p100927 -->
 Read more: <font color="red">Configuring metamodels</font>

<!-- #p100933 -->
## Topic

<!-- #p100939 -->
A Topic is a collection of Catalog Items defined by the people in charge of managing the Catalog metamodel.

<!-- #p100945 -->
This collection will be presented to business users as soon as they arrive in the catalog to help them to : 

- <!-- #p100951 -->
  Understand the organization of the catalog

- <!-- #p100960 -->
  Guide their search to the sub-sections of the catalog that are most likely to be of interest to them

- <!-- #p100969 -->
  Discover the catalog through business, organization,...

<!-- #p100981 -->
## Visualization

<!-- #p100987 -->
Visualizations are reports from source reporting solutions such as PowerBI or Tableau. 

<!-- #p100993 -->
The datasets linked to these visualizations were used to build them. 

<!-- #p100999 -->
Characteristics of a Visualization:

- <!-- #p101005 -->
  Like Datasets, they are subject to automated discovery, via a connector and can be imported.

- <!-- #p101014 -->
  Objects of type Visualization are documentable in the same way as other objects.

- <!-- #p101023 -->
  Visualization objects are potentially linked to Datasets (the Datasets having made it possible to generate the reports they represent), they also appear in the Data Lineage asset graph.

<!-- #p101035 -->
Elements of a Visualization:

<!-- #p101041 -->
They are therefore present in the object's detail in the same way as the following elements: 

- <!-- #p101047 -->
  a title (a logical name and the technical name)

- <!-- #p101056 -->
  a description 

- <!-- #p101065 -->
  related business terms

- <!-- #p101074 -->
  the lineage and its data sets

- <!-- #p101083 -->
  contacts

- <!-- #p101092 -->
  properties

<!-- #p101104 -->
Read more: Importing Datasets or Visualizations

