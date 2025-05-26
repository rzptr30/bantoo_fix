<?php
// Headers
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Access-Control-Allow-Headers, Content-Type, Access-Control-Allow-Methods, Authorization, X-Requested-With');

// Fungsi untuk logging
function logMessage($message) {
    $logDir = __DIR__ . '/logs';
    
    // Buat direktori log jika belum ada
    if (!file_exists($logDir)) {
        mkdir($logDir, 0777, true);
    }
    
    $logFile = $logDir . '/campaign_log.txt';
    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $message" . PHP_EOL;
    
    // Tulis ke file log
    file_put_contents($logFile, $logEntry, FILE_APPEND);
}

// Log akses ke API
logMessage("CREATE CAMPAIGN API accessed");

// Tangkap raw input data
$raw_data = file_get_contents("php://input");
logMessage("Raw request data: $raw_data");

// Koneksi database
include_once 'config/database.php';

try {
    // Inisialisasi database
    $database = new Database();
    $db = $database->connect();
    logMessage("Database connection established");

    // Mendapatkan data dari request
    $data = json_decode($raw_data);

    // Log data yang diterima
    logMessage("Decoded data: " . json_encode($data, JSON_PRETTY_PRINT));

    // Validasi data
    if (!isset($data->title) || !isset($data->description) || !isset($data->target_amount)) {
        $response = [
            'success' => false,
            'message' => 'Judul, deskripsi dan target donasi diperlukan'
        ];
        logMessage("Validation failed: " . json_encode($response));
        echo json_encode($response);
        exit();
    }

    // Buat query insert sederhana
    $query = "INSERT INTO donasi 
              (title, description, target_amount, collected_amount, image_url, deadline, is_emergency) 
              VALUES 
              (:title, :description, :target_amount, :collected_amount, :image_url, :deadline, :is_emergency)";
    
    // Prepare statement
    $stmt = $db->prepare($query);
    logMessage("Prepared query: $query");
    
    // Sanitize dan siapkan data
    $title = htmlspecialchars(strip_tags($data->title));
    $description = htmlspecialchars(strip_tags($data->description));
    $target_amount = isset($data->target_amount) ? $data->target_amount : 0;
    $collected_amount = 0; // Selalu dimulai dari 0
    $image_url = isset($data->image_url) ? htmlspecialchars(strip_tags($data->image_url)) : '';
    
    // Format deadline dengan benar
    if (isset($data->deadline)) {
        // Cek apakah deadline dalam format timestamp atau ISO string
        if (is_string($data->deadline) && strpos($data->deadline, 'T') !== false) {
            // Format ISO string ke format date MySQL
            $deadline_date = new DateTime($data->deadline);
            $deadline = $deadline_date->format('Y-m-d');
        } else {
            $deadline = $data->deadline;
        }
    } else {
        $deadline = date('Y-m-d', strtotime('+30 days'));
    }
    
    $is_emergency = isset($data->is_emergency) ? ($data->is_emergency ? 1 : 0) : 0;
    
    // Log sanitized data
    logMessage("Sanitized data for insertion: " . json_encode([
        'title' => $title,
        'description' => $description,
        'target_amount' => $target_amount,
        'collected_amount' => $collected_amount,
        'image_url' => $image_url,
        'deadline' => $deadline,
        'is_emergency' => $is_emergency
    ]));
    
    // Bind data
    $stmt->bindParam(':title', $title);
    $stmt->bindParam(':description', $description);
    $stmt->bindParam(':target_amount', $target_amount);
    $stmt->bindParam(':collected_amount', $collected_amount);
    $stmt->bindParam(':image_url', $image_url);
    $stmt->bindParam(':deadline', $deadline);
    $stmt->bindParam(':is_emergency', $is_emergency);
    
    // Execute query
    logMessage("Executing query...");
    $result = $stmt->execute();
    logMessage("Query executed with result: " . ($result ? "true" : "false"));
    
    if ($result) {
        $lastInsertId = $db->lastInsertId();
        logMessage("Insert successful! Last insert ID: $lastInsertId");
        
        $response = [
            'success' => true,
            'message' => 'Campaign berhasil ditambahkan',
            'id' => $lastInsertId
        ];
        echo json_encode($response);
    } else {
        $errorInfo = $stmt->errorInfo();
        logMessage("Insert failed! Error: " . json_encode($errorInfo));
        
        $response = [
            'success' => false,
            'message' => 'Campaign gagal ditambahkan',
            'error' => $errorInfo[2] ?? 'Unknown error'
        ];
        echo json_encode($response);
    }
    
} catch(PDOException $e) {
    logMessage("Database error: " . $e->getMessage());
    
    $response = [
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ];
    echo json_encode($response);
} catch(Exception $e) {
    logMessage("General error: " . $e->getMessage());
    
    $response = [
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ];
    echo json_encode($response);
}
?>