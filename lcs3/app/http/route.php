<?php
/**
 * Created by PhpStorm.
 * User: olemathiasheggem
 * Date: 16.04.2016
 * Time: 10.53
 */

include "routeApi.php";
include "routeGraph.php";


$f3->route('GET /',
    function($f3) {
        $f3->set('content','../views/frontpage.htm');
        echo \Template::instance()->render('../views/template.htm');
    }
);

$f3->route('GET /devices',
    function($f3)use($db) {
        $f3->set('result',\lcs\devices::getAll($db));
        $f3->set('content','../views/devices.htm');
        echo \Template::instance()->render('../views/template.htm');
    }
);

$f3->route('GET /devices/new',
    function($f3)use($db) {
        $models = \lcs\deviceConfig::getModels();
        $f3->set('models',$models);
        $networks = \lcs\networks::getAllSimple($db);
        $f3->set('networks',$networks);
        $f3->set('content','../views/newDevice.htm');
        echo \Template::instance()->render('../views/template.htm');
    }
);

$f3->route('POST /devices/new',
    function($f3)use($db) {
        $post = $f3->get('POST');
        $devices = \lcs\device::createNew($db,$post);

        $switches = \lcs\devices::getAllSwitches($db);

        $f3->set('devices',$devices);
        $f3->set('switches',$switches);

        $f3->set('postData',json_encode($post));

        $f3->set('content','../views/newDevicePatch.htm');
        echo \Template::instance()->render('../views/template.htm');
    }
);

$f3->route('POST /devices/new/save',
    function($f3)use($db) {
        $post = $f3->get('POST');
        $devices = \lcs\device::saveNew($db,$post);


        $f3->set('content','../views/newDevicePatch.htm');
        echo \Template::instance()->render('../views/template.htm');
    }
);

$f3->route('GET /devices/@id',
    function($f3)use($db) {
        $device=new \lcs\device($db,$f3->get('PARAMS.id'));
        $f3->set('device',$device);

        $f3->set('content','../views/device.htm');
        echo \Template::instance()->render('../views/template.htm');
    }
);

$f3->route('GET /networks',
    function($f3)use($db) {
        $f3->set('result',\lcs\networks::getAll($db));
        $f3->set('content','../views/networks.htm');
        echo \Template::instance()->render('../views/template.htm');
    }
);


$f3->set('ONERROR',
    function($f3) {
        $f3->set('content','../views/error.htm');

        $f3->set('error',$f3->get('ERROR.text'));
        echo \Template::instance()->render('../views/template.htm');
    }
);