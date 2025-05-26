<?php
// Headers
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: PUT');
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
logMessage("UPDATE API accessed");

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

    // Pastikan ID tersedia
    if (!isset($data->id)) {
        $response = [
            'success' => false,
            'message' => 'ID diperlukan'
        ];
        logMessage("Validation failed: " . json_encode($response));
        echo json_encode($response);
        exit();
    }

    // Buat query update yang sesuai dengan semua kolom di tabel
    $query = "UPDATE donasi 
              SET nama = :nama,
                  title = :title,
                  description = :description,
                  target_amount = :target_amount,
                  collected_amount = :collected_amount,
                  foto = :foto,
                  image_url = :image_url,
                  target = :target,
                  current = :current,
                  nominal = :nominal,
                  pesan = :pesan,
                  progress = :progress,
                  deadline = :deadline,
                  is_emergency = :is_emergency
              WHERE id = :id";
    
    // Prepare statement
    $stmt = $db->prepare($query);
    
    // Sanitize data
    $id = $data->id;
    $nama = isset($data->nama) ? htmlspecialchars(strip_tags($data->nama)) : null;
    $title = isset($data->title) ? htmlspecialchars(strip_tags($data->title)) : null;
    $description = isset($data->description) ? htmlspecialchars(strip_tags($data->description)) : null;
    $target_amount = isset($data->target_amount) ? $data->target_amount : null;
    $collected_amount = isset($data->collected_amount) ? $data->collected_amount : null;
    $foto = isset($data->foto) ? htmlspecialchars(strip_tags($data->foto)) : null;
    $image_url = isset($data->image_url) ? htmlspecialchars(strip_tags($data->image_url)) : null;
    $target = isset($data->target) ? $data->target : $target_amount;
    $current = isset($data->current) ? $data->current : $collected_amount;
    $nominal = isset($data->nominal) ? $data->nominal : null;
    $pesan = isset($data->pesan) ? htmlspecialchars(strip_tags($data->pesan)) : null;
    $progress = isset($data->progress) ? $data->progress : null;
    $deadline = isset($data->deadline) ? $data->deadline : null;
    $is_emergency = isset($data->is_emergency) ? ($data->is_emergency ? 1 : 0) : null;
    
    // Log sanitized data
    logMessage("Sanitized data for update: " . json_encode([
        'id' => $id,
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
        'is_emergency' => $is_emergency,
    ]));
    
    // Bind data
    $stmt->bindParam(':id', $id);
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
    $result = $stmt->execute();
    logMessage("Query executed with result: " . ($result ? "true" : "false"));
    
    if ($result) {
        $rowCount = $stmt->rowCount();
        logMessage("Update successful! Rows affected: $rowCount");
        
        $response = [
            'success' => true,
            'message' => 'Campaign berhasil diperbarui',
            'rows_affected' => $rowCount
        ];
        echo json_encode($response);
    } else {
        $errorInfo = $stmt->errorInfo();
        logMessage("Update failed! Error: " . json_encode($errorInfo));
        
        $response = [
            'success' => false,
            'message' => 'Campaign gagal diperbarui',
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