<?php
/**
 * Created by PhpStorm.
 * User: olemathiasheggem
 * Date: 17.04.2016
 * Time: 16.27
 */

namespace lcs;


use DB\SQL;

class networks
{
    public static function getAll(SQL $db){
        return $db->exec('SELECT *
        FROM networks');
    }

    public static function getAllSimple(SQL $db){
        return $db->exec('SELECT id,name
        FROM networks');
    }
}