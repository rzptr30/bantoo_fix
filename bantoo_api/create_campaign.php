<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Check if request is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        'success' => false,
        'message' => 'Only POST requests are allowed'
    ]);
    exit();
}

// Get the request body
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Validate required fields
if (!isset($data['title']) || !isset($data['description']) || !isset($data['target_amount'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing required fields: title, description, or target_amount'
    ]);
    exit();
}

// Database connection parameters
$host = "localhost"; // Or your database host
$username = "root"; // Your database username
$password = ""; // Your database password
$database = "bantoo_db"; // Your database name

// Create connection
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]);
    exit();
}

// Extract and sanitize data
$title = $conn->real_escape_string($data['title']);
$description = $conn->real_escape_string($data['description']);
$targetAmount = floatval($data['target_amount']);
$collectedAmount = isset($data['collected_amount']) ? floatval($data['collected_amount']) : 0.0;
$imageUrl = isset($data['image_url']) ? $conn->real_escape_string($data['image_url']) : '';
$deadline = isset($data['deadline']) ? $conn->real_escape_string($data['deadline']) : date('Y-m-d H:i:s', strtotime('+30 days'));
$isEmergency = isset($data['is_emergency']) ? ($data['is_emergency'] ? 1 : 0) : 0;
$progress = isset($data['progress']) ? floatval($data['progress']) : 0.0;

// Check if target amount is reasonable (not too large)
if ($targetAmount > 1000000000000) { // 1 trillion limit
    echo json_encode([
        'success' => false,
        'message' => 'Target amount is too large, maximum allowed is 1 trillion'
    ]);
    exit();
}

// SQL to insert a record
$sql = "INSERT INTO campaigns (title, description, target_amount, collected_amount, image_url, deadline, is_emergency, progress, created_at, updated_at) 
        VALUES ('$title', '$description', $targetAmount, $collectedAmount, '$imageUrl', '$deadline', $isEmergency, $progress, NOW(), NOW())";

if ($conn->query($sql) === TRUE) {
    $campaign_id = $conn->insert_id;
    echo json_encode([
        'success' => true,
        'message' => 'Campaign created successfully',
        'campaign_id' => $campaign_id
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Error creating campaign: ' . $conn->error
    ]);
}

$conn->close();
?>