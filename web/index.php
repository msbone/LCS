<?php
include("content.php");
include("sidebar.php");
$content = new content;
$sidebar = new sidebar;
?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
    <script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

    <title>LCS - Area51-LAN 2015</title>

    <!-- Bootstrap core CSS -->
    <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="/bootstrap/css/dashboard.css" rel="stylesheet">

    <!-- Include the dropdown-multiselect's CSS and JS: -->
<script type="text/javascript" src="bootstrap/bootstrap-multiselect.js"></script>
<link rel="stylesheet" href="bootstrap/bootstrap-multiselect.css" type="text/css"/>

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <nav class="navbar navbar-inverse navbar-fixed-top">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="/">LCS - Area51-LAN - <?php echo $content->get_page_name(); ?></a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav navbar-nav navbar-right">
            <?php
            $content->render_menu();
             ?>
            <li><a href="https://github.com/msbone/LCS">About LCS</a></li>
          </ul>
        </div>
      </div>
    </nav>

    <div class="container-fluid">
      <div class="row">
        <div class="col-sm-3 col-md-2 sidebar">
          <ul class="nav nav-sidebar">
            <?php
            $content->render_menu();
             ?>
          </ul>
          <div class="custom-sidebar">
            <?php
            $sidebar->render();
             ?>
           </div>
        </div>
        <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
          <h1 class="page-header"><?php echo $content->get_page_header(); ?></h1>
          <?php
          $content->render();
          ?>
        </div>
      </div>
    </div>

  </body>
</html>
