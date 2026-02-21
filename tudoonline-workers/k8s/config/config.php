<?php

$con = mysqli_connect("mysql", "tudoonline_production", "9HUlh2PzRzav5bIHv5FlN3erbApefs6J") or die('Erro ao conectar no MySQL.<br>' . mysqli_connect_error());
mysqli_select_db($con, 'tudoonline_production') or die('Erro ao selecionar o db.<br>' . mysqli_connect_error());

