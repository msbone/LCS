<?php
/**
 * Created by PhpStorm.
 * User: olemathiasheggem
 * Date: 16.04.2016
 * Time: 21.39
 */

#YOO
$f3->route('GET /api',
    function($f3) {

    }
);

#Send all enabled devices with a IP
$f3->route('GET /api/devices',
    function($f3) use($db) {
        header("Content-Type: application/json", true);
        echo json_encode(\lcs\devices::getConfigured($db));
    }
);
#Send all enabled devices with a IP
$f3->route('GET /api/devices/simple',
    function($f3) use($db) {
        header("Content-Type: application/json", true);
        echo json_encode(\lcs\devices::getConfigured($db,true));
    }
);
$f3->route('GET /api/devices/@id',
    function($f3) use($db) {
        header("Content-Type: application/json", true);
        echo json_encode(\lcs\devices::getByID($db,$f3->get('PARAMS.id')));
    }
);

$f3->route('GET /api/devices/@id/freePorts',
    function($f3) use($db) {
        header("Content-Type: application/json", true);

        $device = new \lcs\device($db,$f3->get('PARAMS.id'));
        echo json_encode($device->getFreePorts());

    }
);

$f3->route('GET /api/graph/@id/ping',
    function($f3) use($db) {
        header("Content-Type: application/json", true);
        echo json_encode(\lcs\graph::pingGraph($db,$f3->get('PARAMS.id')));
    }
);