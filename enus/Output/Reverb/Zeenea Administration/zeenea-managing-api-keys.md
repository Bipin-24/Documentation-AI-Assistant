<!-- #p100003 -->


<!-- #p100009 -->
title: Managing API Keys
========================

<!-- #p100015 -->
# Managing API Keys

<!-- #p100021 -->
Zeenea offers a "machine-to-machine" authentication mechanism based on API keys. This key must be generated from the administration interface on your platform.

<!-- #p100027 -->
# Create an API key

1. <!-- #p100033 -->
   Login to Zeenea as a user with the "Connectivity Administration" permission.

2. <!-- #p100042 -->
   Go to the Administration interface.

3. <!-- #p100054 -->
   Select the **API Keys** section.

4. <!-- #p100066 -->
   Click the **New API Key** button.

5. <!-- #p100075 -->
   Give a name to your API key. The name will help you later identify the key in the interface.

6. <!-- #p100084 -->
   Choose the permission scope of the API key:

   - <!-- #p100093 -->
     **Read-only**: allows read access on all catalog items

   - <!-- #p100105 -->
     **Manage documentation**: allows read and write permission on all catalog items (create, update, delete)

   - <!-- #p100117 -->
     **Admin**: allows full permission on the catalog content (includes user and metamodel management)

   - <!-- #p100129 -->
     **Scanner**: if you wish to use the key for a scanner set up

7. <!-- #p100144 -->
   Select an expiration date.

8. <!-- #p100156 -->
   Click **Create**.

9. <!-- #p100165 -->
   Your new key is now ready to be copy pasted with the correct format. 

   <!-- #p100171 -->
    :::caution\[IMPORTANT\]  When creating an API key, make sure to write down the secret key as it will only be visible at that moment.  :::

<!-- #p100183 -->
## Delete an API key

<!-- #p100192 -->
You can delete an existing API key at any time from the **API Key** section in the administration interface.

<!-- #p100198 -->
```
:::caution[IMPORTANT]
Be careful when deleting the API key, because the services (script, scanners, or others) that use this key for authentication will no longer be able to connect to the Zeenea platform.
:::
```

