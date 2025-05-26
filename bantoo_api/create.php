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
    
    $logFile = $logDir . '/api_log.txt';
    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $message" . PHP_EOL;
    
    // Tulis ke file log
    file_put_contents($logFile, $logEntry, FILE_APPEND);
}

// Log akses ke API
logMessage("CREATE API accessed");

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
    if (!isset($data->title) || !isset($data->description)) {
        $response = [
            'success' => false,
            'message' => 'Judul dan deskripsi diperlukan'
        ];
        logMessage("Validation failed: " . json_encode($response));
        echo json_encode($response);
        exit();
    }

    // Buat query insert yang sesuai dengan semua kolom di tabel donasi
    $query = "INSERT INTO donasi 
              (nama, title, description, target_amount, collected_amount, foto, image_url, 
              target, current, nominal, pesan, progress, deadline, is_emergency) 
              VALUES 
              (:nama, :title, :description, :target_amount, :collected_amount, :foto, :image_url,
              :target, :current, :nominal, :pesan, :progress, :deadline, :is_emergency)";
    
    // Prepare statement
    $stmt = $db->prepare($query);
    logMessage("Prepared query: $query");
    
    // Sanitize dan siapkan data
    $nama = isset($data->nama) ? htmlspecialchars(strip_tags($data->nama)) : null;
    $title = htmlspecialchars(strip_tags($data->title));
    $description = htmlspecialchars(strip_tags($data->description));
    $target_amount = isset($data->target_amount) ? $data->target_amount : 0;
    $collected_amount = 0; // Selalu dimulai dari 0
    $foto = null; // Default null
    $image_url = isset($data->image_url) ? htmlspecialchars(strip_tags($data->image_url)) : null;
    $target = isset($data->target) ? $data->target : $target_amount; // Default sama dengan target_amount
    $current = isset($data->current) ? $data->current : $collected_amount; // Default sama dengan collected_amount
    $nominal = isset($data->nominal) ? $data->nominal : 0;
    $pesan = isset($data->pesan) ? htmlspecialchars(strip_tags($data->pesan)) : null;
    $progress = isset($data->progress) ? $data->progress : 0;
    $deadline = isset($data->deadline) ? $data->deadline : date('Y-m-d', strtotime('+30 days'));
    $is_emergency = isset($data->is_emergency) ? ($data->is_emergency ? 1 : 0) : 0;
    
    // Log sanitized data
    logMessage("Sanitized data for insertion: " . json_encode([
        'nama' => $nama,
        'title' => $title,
        'description' => $description,
        'target_amount' => $target_amount,
        'collected_amount' => $collected_amount,
        'foto' => $foto,
        'image_url' => $image_url,
        'target' => $target,
        'current' => $current,
        'nominal' => $nominal,
        'pesan' => $pesan,
        'progress' => $progress,
        'deadline' => $deadline,
        'is_emergency' => $is_emergency
    ]));
    
    // Bind data
    $stmt->bindParam(':nama', $nama);
    $stmt->bindParam(':title', $title);
    $stmt->bindParam(':description', $description);
    $stmt->bindParam(':target_amount', $target_amount);
    $stmt->bindParam(':collected_amount', $collected_amount);
    $stmt->bindParam(':foto', $foto);
    $stmt->bindParam(':image_url', $image_url);
    $stmt->bindParam(':target', $target);
    $stmt->bindParam(':current', $current);
    $stmt->bindParam(':nominal', $nominal);
    $stmt->bindParam(':pesan', $pesan);
    $stmt->bindParam(':progress', $progress);
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