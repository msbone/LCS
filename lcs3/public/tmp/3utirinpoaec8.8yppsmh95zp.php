<h1>Devices</h1>
<table class="uk-table uk-table-hover">
    <thead>
    <tr>
        <th>Name</th>
        <th>Model</th>
        <th>Hostname</th>
    </tr>
    </thead>
    </tfoot>
    <tbody>
    <?php foreach (($result?:array()) as $item): ?>

        <?php if ($item['configured']): ?>
            <?php if ($item['latencyMs']): ?>
                <tr class="uk-alert uk-alert-success">
                <?php else: ?><tr class="uk-alert uk-alert-danger">
            <?php endif; ?>
            <?php else: ?><tr class="uk-alert uk-alert">
        <?php endif; ?>
            <td><?php echo $item['name']; ?></td>
            <td><?php echo $item['model']; ?></td>
            <td><?php echo $item['name']; ?>.vl.vatnelan.net</td>
            <td><a href="/devices/<?php echo $item['id']; ?>"><i class="uk-icon-bar-chart uk-icon-small"></i></a></td>
        </tr>
    <?php endforeach; ?>
    </tbody>
</table>
