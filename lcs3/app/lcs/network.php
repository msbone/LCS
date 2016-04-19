<?php
/**
 * Created by PhpStorm.
 * User: olemathiasheggem
 * Date: 17.04.2016
 * Time: 16.27
 */

namespace lcs;


use DB\SQL;

class network
{

    private $id;

    private $db;

    private $object;

    public function __construct(SQL $db, $id)
    {
        $this->db = $db;
        $this->id = $id;

        $this->object =new \DB\SQL\Mapper($db,'networks');
        $this->object->load(array('id=?',$id));

    }

    public function getNextFreeIpv4($nr = 1, $offset = 0){
        $range = functions::v4cidrToList($this->object->prefixV4."/".$this->object->maskV4);
        array_shift($range);array_shift($range);array_pop($range);
        $taken = $this->db->exec("SELECT id,ipv4 from devices WHERE networkId = '".$this->id."'");
        foreach ($taken as $item) {$takenv4[] = $item["ipv4"];}
        if($takenv4 != null) {
        $free = array_diff($range, $takenv4);
        $free = array_values($free);
        } else {$free = $range;}
        for ($x = $offset; $x < ($nr + $offset); $x++) {$return[] = $free[$x];}
        return $return;
    }

    public function getNextFreeIpv6($nr, $offset = 0){
        throw new \Exception("IPV6 is not implemented yet, sorry :(");
        return false;
    }
}