<?php
header('Content-Type: application/json');

// Uji koneksi ke database
try {
    include_once 'config/database.php';
    $database = new Database();
    $db = $database->connect();
    
    $response = [
        'status' => 'success',
        'message' => 'PHP berhasil dijalankan dan koneksi database berhasil',
        'php_version' => phpversion(),
        'server' => $_SERVER['SERVER_SOFTWARE']
    ];
    
    // Cek tabel donasi
    $stmt = $db->prepare("SHOW TABLES LIKE 'donasi'");
    $stmt->execute();
    $tableExists = $stmt->rowCount() > 0;
    
    if ($tableExists) {
        $response['donasi_table'] = 'exists';
    } else {
        $response['donasi_table'] = 'not found';
    }
    
} catch (Exception $e) {
    $response = [
        'status' => 'error',
        'message' => 'Error: ' . $e->getMessage()
    ];
}

// Tampilkan response
echo json_encode($response, JSON_PRETTY_PRINT);
?>