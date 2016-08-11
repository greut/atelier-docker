<?php

$r = new Redis();
$r->connect('redis');
$r->incr('test');

echo $r->get('test');
