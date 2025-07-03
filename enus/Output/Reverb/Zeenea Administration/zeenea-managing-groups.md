<!-- #p100003 -->


<!-- #p100009 -->
title: Managing Groups
======================

<!-- #p100015 -->
# Managing Groups

<!-- #p100021 -->
:::note Groups replace Permission sets to manage user permissions in Zeenea. Existing permission sets have already been automatically migrated to Groups with the same descriptions and scopes. 
:::

<!-- #p100027 -->
Groups allow you to manage user permissions in Zeenea. You can manage groups from the Administration section.

<!-- #p100039 -->
  

<!-- #p100045 -->
## Creating a group

<!-- #p100051 -->
To create a group, click the "Create a group" button on the top-right of the screen.

<!-- #p100057 -->
### Group type and license

<!-- #p100063 -->
First, select a type of group: Explorer or Data Steward.

<!-- #p100069 -->
An Explorer group only grants read access to the catalog, while a Data Steward group allows granting edit permission on catalog items or administration permissions.

<!-- #p100075 -->
Note that it also corresponds to the two different license options Zeenea offers.

<!-- #p100081 -->
## Creating an Explorer-type group

<!-- #p100087 -->
Users without groups can access the default catalog through the Explorer application. Thus, when the Federated Catalog option is disabled, users in an Explorer group have the same access rights as users without groups.

<!-- #p100093 -->
When the Federated Catalog option is activated, you can create Explorer groups to give a user read access to one or several catalogs.

<!-- #p100105 -->
  

<!-- #p100111 -->
## Creating a Data Steward-type group

<!-- #p100117 -->
### Global permissions

<!-- #p100123 -->
You can select global permissions for a Data Steward type group. Global permissions grant administration rights on the catalog. There are 5 possible global permissions:

- <!-- #p100129 -->
  Catalog Design

- <!-- #p100138 -->
  User and group administration

- <!-- #p100147 -->
  Connectivity administration

- <!-- #p100156 -->
  Access to the analytics dashboard

- <!-- #p100165 -->
  Manage catalogs

<!-- #p100177 -->
### Catalog Design

<!-- #p100183 -->
This permission allows users to manage all aspects of the metamodel: adding new Custom Item Types, editing templates, adding/editing/deleting properties, and adding/editing/deleting responsibilities.

<!-- #p100189 -->
### User and group administration

<!-- #p100195 -->
This permission allows the creation and management of users and contacts. Only users with this permission can create groups and assign them to users.

<!-- #p100201 -->
### Connectivity administration

<!-- #p100207 -->
This permission allows users to create API Keys (for Scanner configuration for example), configure connection options (data profiling, auto import, etc.), and launch jobs on existing connections (inventory, update, etc.).

<!-- #p100213 -->
### Access to the analytics dashboard

<!-- #p100219 -->
This permission grants access to the analytics dashboard in the Studio with metrics regarding the completion level of the documentation and user adoption.

<!-- #p100225 -->
### Manage catalogs

<!-- #p100231 -->
This permission allows you to create new catalogs on your tenant if the Federated Catalog option is activated for your subscription.

<!-- #p100237 -->
### Catalog Access

<!-- #p100243 -->
In this section, you can configure the read and write permissions on catalog items for Data Stewards. Write permissions on items are divided into three categories:

- <!-- #p100249 -->
  Datasets, Fields, Visualizations, Data Processes, and Categories

- <!-- #p100258 -->
  Custom Items

- <!-- #p100267 -->
  Glossary

<!-- #p100279 -->
For each of these permissions, you can adjust the perimeter of Data Stewards as the following:

- <!-- #p100285 -->
  All Items

- <!-- #p100294 -->
  Only if curator (requires to assign the user as curator on the Item to give him edit rights)

- <!-- #p100303 -->
  Include unassigned (In case the "Only if curator" option is selected, you can define if Data Stewards can edit Items with no assigned curators)

- <!-- #p100312 -->
  By default, you only have one catalog, so the group permissions apply to all Items (all Items belong to the default catalog).

<!-- #p100324 -->
In case the Federated Catalog option is activated, you will have the same configuration options but split by catalog.

<!-- #p100336 -->
  

<!-- #p100342 -->
### Adding users to groups

<!-- #p100348 -->
You can add users to a group from the Users &amp; Contacts section. Note that you can assign several groups to the same user. As a result, you can define groups with complex as well as atomic permission scopes for your groups.

<!-- #p100354 -->
### Editing or deleting a group

<!-- #p100360 -->
You can edit a group at any time to adjust its basic information (name, description) or its associated permissions.

<!-- #p100366 -->
You can delete a group only if there are no users left in this group.

<!-- #p100372 -->
:::note You can not edit or delete the Super Admin group for security reasons. :::

