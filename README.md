knife-cookbook-utils
====================

Some useful tools for working with cookbooks

Copyright 2013 Opscode, Inc

Authors:
  Ho-Sheng Hsiao <hosh@opscode.com>


knife cookbook keep
-------------------

Sometimes, you just want to delete all but the latest versions of cookbooks on a server. You
can do this with knife cookbook keep. For example:

    knife cookbook keep 1

Will report the latest version of each cookbook on the server.

    knife cookbook keep 2

Will report the latest two versions of each cookbook on the server.

This command will also list out the older versions of cookbooks. To delete those, you have
to specify the --purge-old flag, such as

    knife cookbook keep 2 --purge-old

NOTE: --purge-old will *not* prompt you.


knife cookbook missing deps
---------------------------

This command will scan through all cookbooks on the server and determine if there are any
missing dependencies. You can list out any such cookbooks with

    knife cookbook missing deps

If you wish to purge cookbooks with missing depenencies, you can use

    knife cookbook missing deps --purge

NOTE: This will *not* ascend the dependency tree.
