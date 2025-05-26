<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

echo json_encode([
    'status' => 'online',
    'timestamp' => date('Y-m-d H:i:s'),
    'message' => 'Server is reachable',
    'server_info' => [
        'software' => $_SERVER['SERVER_SOFTWARE'],
        'php_version' => phpversion()
    ]
]);
?>