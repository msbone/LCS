require "/lcs/include/config.pm";

use String::Random;
$pass = new String::Random;

my $db_name = $lcs::config::db_name;
my $db_user = $lcs::config::db_username;
my $db_password = $pass->randpattern("CnnCnCcCnCcn");
my $root_password = $lcs::config::db_root_password;

if($root_password eq "") {
  print "\n Root password is blank, change the root password in config.pm \n";
  exit;
}

$Q1="CREATE DATABASE IF NOT EXISTS $db_name;";
$Q2="GRANT ALL ON $db_name.* TO \'$db_user\'@\'localhost\' IDENTIFIED BY \'$db_password\';";
$Q3="FLUSH PRIVILEGES;";
$sql = "$Q1 $Q2 $Q3";

system("mysql -uroot -p$root_password  -e \"$sql\"");
system("mysql -uroot -p$root_password $db_name < include/lcs.sql");

my $db_password_file = '/lcs/include/db_password.txt';
open(my $fh, '>', $db_password_file) or die "Could not open file '$db_password_file' $!";
print $fh $db_password;
close $fh;

print "Created database $db_name with user: $db_user and password: $db_password \n  REMOVE ROOT PASSWORD FROM config.pm\n";
print "THE SERVER NEED A REBOOT TO RUN SMOOTH, PLEASE RESTART\n";
