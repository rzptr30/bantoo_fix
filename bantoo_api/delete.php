<?php
// Headers
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: DELETE');
header('Access-Control-Allow-Headers: Access-Control-Allow-Headers, Content-Type, Access-Control-Allow-Methods, Authorization, X-Requested-With');

// Fungsi untuk logging
function logMessage($message) {
    $logDir = __DIR__ . '/logs';
    if (!file_exists($logDir)) {
        mkdir($logDir, 0777, true);
    }
    $logFile = $logDir . '/api_log.txt';
    $timestamp = date('Y-m-d H:i:s');
    file_put_contents($logFile, "[$timestamp] $message" . PHP_EOL, FILE_APPEND);
}

logMessage("DELETE API accessed");

include_once 'config/database.php';

try {
    // Inisialisasi database
    $database = new Database();
    $db = $database->connect();
    
    // Mendapatkan data dari request
    $data = json_decode(file_get_contents("php://input"));
    
    // Validasi ID
    if(!isset($data->id)) {
        echo json_encode([
            "success" => false,
            "message" => "ID diperlukan"
        ]);
        exit();
    }
    
    $id = $data->id;
    
    // Query untuk delete
    $query = "DELETE FROM donasi WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    
    // Execute query
    if($stmt->execute()) {
        echo json_encode([
            "success" => true,
            "message" => "Donasi berhasil dihapus"
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Donasi gagal dihapus"
        ]);
    }
    
} catch(Exception $e) {
    logMessage("Error: " . $e->getMessage());
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>