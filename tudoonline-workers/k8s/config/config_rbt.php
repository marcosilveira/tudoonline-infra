<?php

require_once '../vendor/autoload.php';


use PhpAmqpLib\Connection\AMQPStreamConnection;

//acesso dentro do kubernetes
$connection = new AMQPStreamConnection('rabbitmq.production.svc.cluster.local', 5672, 'tudoonline_workers_production', '8AOh4DKOzA7cTpKHRZOssExPcijVxbdg', 'production');