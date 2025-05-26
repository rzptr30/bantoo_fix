<?php
include 'koneksi.php';

// Mengambil ID event dari parameter URL
$event_id = isset($_GET['id']) ? $_GET['id'] : '';

if (!empty($event_id)) {
    $event_id = mysqli_real_escape_string($koneksi, $event_id);
    
    $query = "SELECT e.*, u.username as creator_name 
              FROM events e 
              LEFT JOIN users u ON e.created_by = u.id 
              WHERE e.id = $event_id";
    
    $result = mysqli_query($koneksi, $query);
    
    if ($result && mysqli_num_rows($result) > 0) {
        $event = mysqli_fetch_assoc($result);
        
        echo json_encode([
            'status' => 'success',
            'data' => $event
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Event tidak ditemukan'
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'ID event tidak disediakan'
    ]);
}
?>