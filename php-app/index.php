<?php

$redis = new Redis();
$redis->connect('redis');

if (isset($_POST['vote']) && !empty($_POST['vote'])) {
    $option = $_POST['choice'];
    $redis->incr('vote-'.((int) $_POST['vote']).'-'.$option);
}

$results = [
    'a' => (int) $redis->get('vote-1-a'),
    'b' => (int) $redis->get('vote-1-b')
];

?>
<!DOCTYPE html>
<html lang=fr>
<head>
    <meta charset=utf-8>
    <title>Voting app</title>
</head>
<body>
<h1>Vote</h1>
<form method=POST>
    <input type=hidden name=vote value=1>
    <p><label><input type=radio name=choice value=a checked> A</label></p>
    <p><label><input type=radio name=choice value=b> B</label></p>
    <button type=submit>Votez</button>
</form>
<h2>Résultats</h2>
<ul>
<?php foreach($results as $k => $v): ?>
    <li><?php echo $k . ': ' . $v ?></li>
<?php endforeach ?>
</ul>
    <address>Server: <?php echo $_SERVER['SERVER_ADDR'] ?></address>
</body>
</html>
