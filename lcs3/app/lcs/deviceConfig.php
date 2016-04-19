<?php
/**
 * Created by PhpStorm.
 * User: olemathiasheggem
 * Date: 17.04.2016
 * Time: 11.18
 */

namespace lcs;


class deviceConfig
{

    private $template;
    private $shortName;
    private $fullName;
    private $vendor;
    private $numberOfPorts;
    private $type;
    private $ports;
    private $ac;
    private $snmp;

    public static function getModels(){
        $dir = "../deviceModels";
        return json_decode(str_replace(str_replace('/', '\/', $dir), "",  json_encode(functions::getDirContents($dir))),true);
    }


    public function __construct($jsonFile)
    {
       $device = json_decode(file_get_contents("../deviceModels/".$jsonFile));
        if($device->template != null) {
            $template = new deviceConfig("../deviceModels/".$device->template);
        }

        $this->shortName = $device->shortName;
        $this->fullName = $device->fullName;
        $this->vendor = $device->vendor;
        $this->numberOfPorts = $device->numberOfPorts;
        $this->type = $device->type;
        $this->ports = $device->ports;
        $this->ac = $device->ac;
        $this->snmp = $device->snmp;

    }
    
    public function getPorts() {
        foreach ($this->ports as $port){
            #Each portType/module
            $prefix = $port->prefix;
            for ($x = $port->first; $x <= $port->last; $x++) {
                $name = str_replace("%", $x, $prefix);
                $ports[] = $name;
            }
        }
        return $ports;
    }

    /**
     * @return mixed
     */
    public function getTemplate()
    {
        return $this->template;
    }

    /**
     * @return mixed
     */
    public function getShortName()
    {
        return $this->shortName;
    }

    /**
     * @return mixed
     */
    public function getFullName()
    {
        return $this->fullName;
    }

    /**
     * @return mixed
     */
    public function getVendor()
    {
        return $this->vendor;
    }

    /**
     * @return mixed
     */
    public function getNumberOfPorts()
    {
        return $this->numberOfPorts;
    }

    /**
     * @return mixed
     */
    public function getType()
    {
        return $this->type;
    }
}