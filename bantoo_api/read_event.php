<?php
include 'koneksi.php';

$query = "SELECT e.*, u.username as creator_name 
          FROM events e 
          LEFT JOIN users u ON e.created_by = u.id 
          ORDER BY e.created_at DESC";

$result = mysqli_query($koneksi, $query);

if ($result) {
    $events = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $events[] = $row;
    }
    
    echo json_encode([
        'status' => 'success',
        'data' => $events
    ]);
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Gagal mengambil data events: ' . mysqli_error($koneksi)
    ]);
}
?>