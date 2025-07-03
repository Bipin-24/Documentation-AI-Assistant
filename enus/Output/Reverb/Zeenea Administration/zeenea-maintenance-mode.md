<!-- #p100003 -->


<!-- #p100009 -->
title: Maintenance Mode
=======================

<!-- #p100015 -->
# Maintenance Mode

<!-- #p100021 -->
You can activate a maintenance mode from the Administration interface for your Zeenea platform. This feature allows Super Admins to set up a maintenance landing page and redirect all users during maintenance time. Only Super Admins can access the catalog during maintenance time.

<!-- #p100027 -->
## Activating the maintenance mode

<!-- #p100033 -->
To activate the maintenance mode, go to the Maintenance mode section in the Administration interface and click the "Activate the maintenance mode" toggle. You'll need to confirm before activation.

<!-- #p100039 -->
Only Super Admin users can activate the maintenance mode.

<!-- #p100051 -->
  

<!-- #p100057 -->
## Maintenance landing page

<!-- #p100063 -->
### Redirection of users

<!-- #p100069 -->
During maintenance time, all users (Studio, Explorer, Administration) are redirected to the maintenance page after login, except Super Admins.

<!-- #p100075 -->
Connected users are redirected as soon as an interaction with the application is detected (login, navigation, etc.).

<!-- #p100081 -->
Note that if a write action has been started and not finished before activating the maintenance mode (like a bulk action), it is not stopped when maintenance mode is activated.

<!-- #p100087 -->
### Content of the page

<!-- #p100093 -->
The maintenance page contains a generic message inviting users to connect later:

- <!-- #p100099 -->
  Title: Maintenance in progress

- <!-- #p100108 -->
  Message: Your administrators carry out scheduled maintenance. Please check back soon!

  <!-- #p100120 -->
  

<!-- #p100132 -->
## Super Admin access during maintenance time

<!-- #p100138 -->
When the maintenance mode is activated, Super Admins can access the application as usual (Studio, Explorer, Administration).

<!-- #p100144 -->
On top of the applications, a tag indicates that the maintenance mode is activated.

<!-- #p100156 -->
  

<!-- #p100162 -->
## Working with APIs during maintenance time

<!-- #p100168 -->
API calls (read and write) are not blocked during maintenance time.

<!-- #p100174 -->
## Disabling the maintenance mode

<!-- #p100183 -->
To disable the maintenance mode, return to the Administration and toggle the **Activate maintenance mode** button. You'll need to confirm before disabling.

