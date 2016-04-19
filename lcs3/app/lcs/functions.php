<?php
/**
 * Created by PhpStorm.
 * User: olemathiasheggem
 * Date: 17.04.2016
 * Time: 15.47
 */

namespace lcs;


class functions
{
    public static function getDirContents($dir, &$results = array()){
        $files = scandir($dir);
        foreach($files as $key => $value){
            $path = $dir.DIRECTORY_SEPARATOR.$value;
            if(!is_dir($path)) {
                $x["short"] = $value;
                $x["long"] = $path;
                $results[] = $x;
            } else if($value != "." && $value != "..") {
                functions::getDirContents($path, $results);
                //$results[] = $path;
            }
        }
        return $results;
    }

    public static function v4cidrToRange($cidr) {
        $range = array();
        $cidr = explode('/', $cidr);
        $range[0] = long2ip((ip2long($cidr[0])) & ((-1 << (32 - (int)$cidr[1]))));
        $range[1] = long2ip((ip2long($cidr[0])) + pow(2, (32 - (int)$cidr[1])) - 1);
        return $range;
    }

    public static function v4cidrToList($cidr){
        $range = array();
        $cidr = explode('/', $cidr);

        $first = (ip2long($cidr[0])) & ((-1 << (32 - (int)$cidr[1])));
        $last = (ip2long($cidr[0])) + pow(2, (32 - (int)$cidr[1])) - 1;

        for ($x = $first; $x <= $last; $x++) {
            $range[] = long2ip($x);
        }
        return $range;
    }
}