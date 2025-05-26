<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

echo json_encode([
    'status' => 'success',
    'message' => 'API server is online',
    'timestamp' => date('Y-m-d H:i:s')
]);
?>