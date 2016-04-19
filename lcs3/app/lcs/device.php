<?php
/**
 * Created by PhpStorm.
 * User: olemathiasheggem
 * Date: 17.04.2016
 * Time: 01.44
 */

namespace lcs;


use DB\SQL;

class device
{
    private $db;

    private $object;

    private $id;

    private $config;

    public function __construct(SQL $db, $id)
    {
        $this->db = $db;
        $this->id = $id;
        $this->object =new \DB\SQL\Mapper($db,'devices');
        $this->object->load(array('id=?',$id));

        $this->config = new \lcs\deviceConfig($this->object->model);

    }

    public function getLastSeenInSec(){
       $lastSeen = $this->db->exec("SELECT ping.deviceId,MAX(time) MaxDate FROM ping WHERE ping.deviceId = ".$this->id." AND ping.latencyMs IS NOT NULL GROUP BY ping.deviceId");
        if($lastSeen[0]["MaxDate"] == NULL) {
            return null;
        }
        return time() - $lastSeen[0]["MaxDate"];
    }

    public function getLastSeenTime(){
        $lastSeen = $this->db->exec("SELECT ping.deviceId,MAX(time) MaxDate FROM ping WHERE ping.deviceId = ".$this->id." AND ping.latencyMs IS NOT NULL GROUP BY ping.deviceId");
        if($lastSeen[0]["MaxDate"] == NULL) {
            return null;
        }
        return $lastSeen[0]["MaxDate"];
    }

    /**
     * @return mixed
     */
    public function getObject()
    {
        return $this->object;
    }

    public static function createNew(SQL $db, $post){
        $deviceConfig = new deviceConfig($post["model"]);

        $network = new \lcs\network($db,$post["network"]);
        $ipRange = $network->getNextFreeIpv4($post["number"]);

        for ($x = 1; $x <= $post["number"]; $x++) {
            $name = str_replace("%", sprintf("%02d", $x), $post["name"]);
            $ipv4 = $ipRange[$x-1];
            $var["id"] = $x;
            $var["name"] = $name;
            $var["ipv4"] = $ipv4;
            $var["ports"] = $deviceConfig->getPorts();
            $devices[] = $var;
        }
        return $devices;
    }

    public static function saveNew(SQL $db, $post){
        
        $oldPost = json_decode($post["oldPost"]);

        $deviceConfig = new deviceConfig($oldPost->model);

        $network = new \lcs\network($db,$oldPost->network);
        $ipRange = $network->getNextFreeIpv4($oldPost->number);

        $device =new \DB\SQL\Mapper($db,'devices');

        $portsDb =new \DB\SQL\Mapper($db,'ports');

        for ($x = 1; $x <= $oldPost->number; $x++) {
            $name = str_replace("%", sprintf("%02d", $x), $oldPost->name);
            $ipv4 = $ipRange[$x-1];

            $device->reset();
            $device->name=$name;
            $device->ipv4=$ipv4;
            $device->ipv6=null;
            $device->type=$deviceConfig->getType();
            $device->model=$oldPost->model;
            $device->configured=0;
            $device->desc="";
            $device->created=time();
            $device->updated=null;
            $device->save();

            ##Create the ports
            $ports = $deviceConfig->getPorts();

            foreach ($ports as $port) {
                $portsDb->reset();
                $portsDb->deviceId = $device->id;
                $portsDb->name = $port;
                $portsDb->type = 2;
                $portsDb->created=time();

                if($port == $post["port".$x]) {
                    //Selected uplink
                    $portsDb->connectedPort = $post["switchPort".$x];
                    $portsDb->save();
                    $db->exec("UPDATE `lcs`.`ports` SET `connectedPort`='".$portsDb->id."' WHERE `id`='".$post["switchPort".$x]."'");
                } else {
                    $portsDb->save();
                }

            }
        }
    }

    public function getFreePorts(){
        return $this->db->exec("SELECT * from ports WHERE deviceId = $this->id AND connectedPort IS NULL");
    }

    /**
     * @return deviceConfig
     */
    public function getConfig()
    {
        return $this->config;
    }


}