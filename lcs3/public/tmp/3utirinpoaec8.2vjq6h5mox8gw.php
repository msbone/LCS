<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>LCS 3.0</title>
    <link rel="stylesheet" href="/uikit/css/uikit.almost-flat.min.css" />
    <script src="https://code.jquery.com/jquery-2.2.3.min.js"></script>
    <script src="/uikit/js/uikit.min.js"></script>
    <script src="https://cdn.socket.io/socket.io-1.4.5.js"></script>

    <script>
        //var socket = io.connect('http://localhost:3000',{'forceNew': true});
        //socket.on('alarms', function(msg){

        //});
    </script>
</head>
<body>

<div class="uk-container uk-container-center uk-margin-top uk-margin-large-bottom">
    <nav class="uk-navbar uk-margin-large-bottom">
        <a class="uk-navbar-brand uk-hidden-small" href="/">LCS - HypeLAN 2016</a>
        <ul class="uk-navbar-nav uk-hidden-small">
            <li class="uk-active">
                <a href="/">Frontpage</a>
            </li>
            <li>
                <a href="/devices">Devices</a>
            </li>
            <li>
                <a href="/networks">Networks</a>
            </li>
            <li>
                <a href="/networks">Maps</a>
            </li>
        </ul>
        <div class="uk-navbar-flip">
            <ul class="uk-navbar-nav">
                <li>
                    <a href="/status"><i class="uk-icon-heartbeat uk-alert-danger uk-icon-large"></i></a>
                </li>
            </ul>
        </div>
        <a href="#offcanvas" class="uk-navbar-toggle uk-visible-small" data-uk-offcanvas></a>
        <div class="uk-navbar-brand uk-navbar-center uk-visible-small">LCS - HypeLAN 2016</div>
    </nav>
    <?php echo $this->render($content,$this->mime,get_defined_vars(),0); ?>
</div>

<div id="offcanvas" class="uk-offcanvas">
    <div class="uk-offcanvas-bar">
        <ul class="uk-nav uk-nav-offcanvas">
            <li class="uk-active">
                <a href="/">Frontpage</a>
            </li>
            <li>
                <a href="/devices">Devices</a>
            </li>
            <li>
                <a href="/networks">Networks</a>
            </li>
            <li>
                <a href="/maps">Maps</a>
            </li>
        </ul>
    </div>
</div>

</body>
</html>

