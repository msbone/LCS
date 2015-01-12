DLINK AUTOCONFIG
===
Script made to push out config to dlink dgs1210-28 switches.

For the run.pl and most other of the magic to work, LCS must be installed and setup with switches in database.

---
This is only a plan
When you are at location, run the script setup_dlink_config.pl, this will select one switch, set the distro port in config mode, and then stop.
You can then use a web browser and pint to 10.90.90.90, do the changes. DO NOT EDIT IP OR PASSWORD. When you are happy with the config. Press enter in the terminal running the script.
This will save all config, then upload it to the server tftp server as config.bin
