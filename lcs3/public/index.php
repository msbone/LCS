<?php
// Kickstart the framework
$f3=require('../lib/f3/base.php');
$f3->set('DEBUG',1);
$f3->set('AUTOLOAD','../app/');

$db=new DB\SQL(
    'mysql:host=127.0.0.1;port=3306;dbname=lcs',
    'root',
    'Dataparty16'
);

$view=new View;

include ("../app/http/route.php");

$f3->run();
