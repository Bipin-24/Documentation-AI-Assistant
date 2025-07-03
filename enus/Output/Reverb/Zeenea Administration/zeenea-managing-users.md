<!-- #p100003 -->


<!-- #p100009 -->
title: Managing Users
=====================

<!-- #p100015 -->
# Managing Users

<!-- #p100021 -->
Managing the repository of users is done through the administration interface in the section "Users &amp; Contacts.

<!-- #p100033 -->
  

<!-- #p100039 -->
## Creating a new user

<!-- #p100051 -->
Click the **New User**"** button and fill in the required fields:

- <!-- #p100057 -->
  Email: The user's email is used as his unique identifier in Zeenea and also as his login

- <!-- #p100066 -->
  Groups: A user can belong to one or several groups. Select groups to give extra permissions to the user. Note that there are two types of group licenses (Explorer and Data Steward) with different pricing). A user can also belong to no group. In this case, he has read access in the Explorer to the default catalog items and also to the shared items in the Federated Catalog

- <!-- #p100075 -->
  First name/Lastname

- <!-- #p100084 -->
  Phone number

  <!-- #p100096 -->
  

<!-- #p100108 -->
:::note Once the user is created, you can not modify his email address. If necessary, you delete and then recreate the user. 
:::

<!-- #p100114 -->
When you create a new user, a new contact is automatically created in the Zeenea repository.

<!-- #p100120 -->
## Defining the user password

<!-- #p100126 -->
If you are using an identity federation for the connection with Zeenea: the password to use is therefore the one of the identity federation

<!-- #p100132 -->
If you are using a database specific to Zeenea for the connection, the user will receive 2 emails inviting him to validate his email address via a link and to change his password via a dedicated interface. The password must comply with a security level that is indicated to the user when it is set up.

<!-- #p100138 -->
## Editing a user

<!-- #p100144 -->
It is possible at any time to edit an existing user. Only two restrictions apply: 

- <!-- #p100150 -->
  There must always be at least one user in the Super Admin group.

- <!-- #p100159 -->
  Once the user is created, his email cannot be changed.

<!-- #p100171 -->
## Deleting a user

<!-- #p100177 -->
You can delete a user directly from the list or the edition modal.

<!-- #p100183 -->
When deleting, three restrictions apply:

- <!-- #p100189 -->
  You cannot delete your own user.

- <!-- #p100198 -->
  You cannot delete the last Super Admin.

- <!-- #p100207 -->
  You cannot delete a user assigned as a Curator of an item. Before deleting it, you must first delete the links.

