<?php
// Headers
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

// Informasi server
$serverInfo = [
    'php_version' => phpversion(),
    'server' => $_SERVER['SERVER_SOFTWARE'],
    'document_root' => $_SERVER['DOCUMENT_ROOT'],
    'script_filename' => $_SERVER['SCRIPT_FILENAME'],
    'current_time' => date('Y-m-d H:i:s'),
];

// Cek koneksi ke database
include_once 'config/database.php';

try {
    $database = new Database();
    $db = $database->connect();
    
    // Cek apakah koneksi berhasil
    if ($db) {
        $serverInfo['database_connection'] = 'Success';
        
        // Cek tabel donasi
        $stmt = $db->prepare("SHOW TABLES LIKE 'donasi'");
        $stmt->execute();
        $tableExists = $stmt->rowCount() > 0;
        
        if ($tableExists) {
            $serverInfo['donasi_table_exists'] = true;
            
            // Cek struktur tabel
            $stmt = $db->prepare("DESCRIBE donasi");
            $stmt->execute();
            $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
            $serverInfo['donasi_columns'] = $columns;
        } else {
            $serverInfo['donasi_table_exists'] = false;
        }
    } else {
        $serverInfo['database_connection'] = 'Failed';
    }
    
} catch(PDOException $e) {
    $serverInfo['database_error'] = $e->getMessage();
}

// Return informasi sebagai JSON
echo json_encode($serverInfo, JSON_PRETTY_PRINT);
?>