Version 1.4 (Not yet sent to the App Store)
-------------------------------------------

- New screen, "Activity", which shows the list of the latest actions
  done in the system. 
- Touching an item in the activity list takes you to the comments screen
  for that object.
- Comments can be deleted now, by swiping over the corresponding row.

Version 1.3 (September 20th, 2011)
----------------------------------

- Adapted the code for iOS 4.x and Xcode 4.1.
- Fixed issues with passwords, and the settings screen which would
  require an application restart to be usable again.
- Refactored the server proxy into a network manager, using separate
  classes for each type of request used by the system.

Version 1.1 (March 23rd, 2010)
------------------------------

- Faster XML parsing thanks to TBXML.
- Spanish and French localizations.
- The application shows the settings screen if the host, the username or
  the password are wrong.
- FIXED: The new task controller could create two identical tasks by
  mistake.
- FIXED: The refresh button had a weird behaviour in most controllers.
- Removed memory leaks and potentially crashing issues.


Version 1.0 (February 20th, 2010)
---------------------------------

First version sent to the App Store. Features:

- List pending tasks.
- Mark tasks as done.
- Create a new task.
- List contacts, accounts, opportunities, leads and campaigns (with
  page-based loading; scroll to the bottom, a new page of data loads
  automatically).
- Search contacts, accounts, opportunities, leads and campaigns.
- View comments for contacts, accounts, opportunities, leads and
  campaigns.
- Add comments for contacts, accounts, opportunities, leads and
  campaigns.
- View contacts as "address book" entries, with integrated e-mail and
  web browsing.
- Configurable to use any FFCRM instance (URL, username, password,
  done). Off the box it uses the http://demo.fatfreecrm.com/ site as a
  default entry, with a random entry ("aaron", "ben", "elizabeth") as
  username and password.
- Lists are sorted and displayed in the same order as the underlying
  FFCRM instance.
- Displays Gravatars for accounts with e-mails.

