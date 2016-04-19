<?php

/**
 * Created by PhpStorm.
 * User: olemathiasheggem
 * Date: 16.04.2016
 * Time: 12.52
 */

namespace lcs;

class devices
{
    public static function getAll($db){
        return $db->exec('SELECT  d.*, p.latencyMs, p.time pingTime
        FROM    devices d LEFT OUTER JOIN
        (SELECT  ping.deviceId,MAX(time) MaxDate FROM ping GROUP BY ping.deviceId)
        MaxDates ON d.id = MaxDates.deviceId LEFT OUTER JOIN
        ping p ON MaxDates.deviceId = p.deviceId
        AND MaxDates.MaxDate = p.time');
    }

    public static function getConfigured($db,$simple = false){
        if($simple === true){
           return $db->exec('SELECT id, ipv4, ipv6 FROM devices WHERE configured = true');
        }
        return $db->exec('SELECT  d.*, p.latencyMs, p.time pingTime
        FROM    devices d LEFT OUTER JOIN
        (SELECT  ping.deviceId,MAX(time) MaxDate FROM ping GROUP BY ping.deviceId)
        MaxDates ON d.id = MaxDates.deviceId LEFT OUTER JOIN
        ping p ON MaxDates.deviceId = p.deviceId
        AND MaxDates.MaxDate = p.time WHERE configured = true ');}

    public static function getAlive($db){
        return $db->exec('SELECT  d.*, p.latencyMs, p.time pingTime
        FROM    devices d LEFT OUTER JOIN
        (SELECT  ping.deviceId,MAX(time) MaxDate FROM ping GROUP BY ping.deviceId)
        MaxDates ON d.id = MaxDates.deviceId LEFT OUTER JOIN
        ping p ON MaxDates.deviceId = p.deviceId
        AND MaxDates.MaxDate = p.time WHERE configured = true AND p.latencyMs IS NOT NULL');
    }

    public static function getDead($db){
        return $db->exec('SELECT id,name,model,ipv4,ipv6 FROM devices WHERE configured = TRUE');
    }

    public static function getByID($db, $id){
        return $db->exec('SELECT  d.*, p.latencyMs, p.time pingTime
        FROM    devices d LEFT OUTER JOIN
        (SELECT  ping.deviceId,MAX(time) MaxDate FROM ping GROUP BY ping.deviceId)
        MaxDates ON d.id = MaxDates.deviceId LEFT OUTER JOIN
        ping p ON MaxDates.deviceId = p.deviceId
        AND MaxDates.MaxDate = p.time WHERE d.id = '.$id);
    }

    public static function getAllSwitches($db)
    {
        //Yes, yes a router is not a switch.
        return $db->exec('SELECT  *
        FROM devices d WHERE type IN (1,2,3)');
    }
}