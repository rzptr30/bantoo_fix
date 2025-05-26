<?php
// Header dan konfigurasi
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Log akses
$logFile = __DIR__ . '/test_api_log.txt';
$timestamp = date('Y-m-d H:i:s');
file_put_contents($logFile, "[$timestamp] API accessed from " . $_SERVER['REMOTE_ADDR'] . "\n", FILE_APPEND);

// Tangkap raw input
$raw_data = file_get_contents("php://input");
file_put_contents($logFile, "[$timestamp] Raw data: $raw_data\n", FILE_APPEND);

// Kirim respons sederhana
echo json_encode([
    'success' => true,
    'message' => 'API Test successful',
    'received_data' => json_decode($raw_data, true),
    'time' => date('Y-m-d H:i:s')
]);
?>