<?php
/**
 * Created by PhpStorm.
 * User: olemathiasheggem
 * Date: 16.04.2016
 * Time: 22.31
 */

namespace lcs;


use DB\SQL;

class graph
{
    public static function pingGraph(SQL $db, $deviceId){
       return $db->exec('SELECT ping.time, ping.latencyMS, devices.id FROM ping JOIN devices ON devices.id = ping.deviceID WHERE ping.deviceID = '.$deviceId);
    }

}