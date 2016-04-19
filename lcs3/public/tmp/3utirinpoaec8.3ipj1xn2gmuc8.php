<h1>Devices</h1>
<table class="uk-table uk-table-hover">
    <thead>
    <tr>
        <th>Name</th>
        <th>Model</th>
        <th>IPv4</th>
        <th>IPv6</th>
    </tr>
    </thead>
    </tfoot>
    <tbody>
    <?php foreach (($result?:array()) as $item): ?>
        <tr class="uk-alert uk-alert-success">
            <td><?php echo $item['name']; ?></td>
            <td><?php echo $item['model']; ?></td>
            <td><?php echo $item['ipv4']; ?></td>
            <td><?php echo $item['ipv6']; ?></td>
        </tr>
    <?php endforeach; ?>
    </tbody>
</table>