<h2><?php echo $device->name; ?> <a href=""><i class="uk-icon-cog"></i></a></h2>
<div class="uk-panel uk-panel-box uk-panel-box-primary"><?php echo $device->desc; ?></div> <br>
<div class="uk-grid" data-uk-grid-margin>
    <div class="uk-width-2-10"><table class="uk-table uk-table-striped uk-table-condensed uk-table-hover">
        <tbody>
        <tr><td>Mikrotik RB3011UiAS</td></tr>
        <tr><td>Uptime: 3h 1m 53s</td></tr>
        <tr><td>Last seen: 1 second</td></tr>
        <tr><td>Last polled: 33 seconds</td></tr>
        <tr><td>CPU: 11%</td></tr>
        <tr><td>Mem: 56%</td></tr>
        <tr><td>IPv4: <?php echo $device->ipv4; ?></td></tr>
        <tr><td>IPv6: <?php echo $device->ipv6; ?></td></tr>
        </tbody>
    </table>
    </div>
    <div class="uk-width-8-10">
        <h3>Network <small><a href="/devices/<?php echo $device->id; ?>/ports">Show ports</a></small></h3>
        <img src="/images/graph.png"> </br>
    </div>
    <div class="uk-width-1-2">
        <h3>CPU</h3>
        <img src="/images/graph.png"> </br>
    </div>
    <div class="uk-width-1-2">
        <h3>Memory</h3>
        <img src="/images/graph.png"> </br>
    </div>
</div>