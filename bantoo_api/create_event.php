<?php
include 'koneksi.php';

// Menerima data dari aplikasi Flutter dalam format JSON
$data = json_decode(file_get_contents('php://input'), true);

// Memastikan semua data yang diperlukan tersedia
if (isset($data['title'], $data['description'], $data['location'], $data['event_date'], $data['created_by'])) {
    $title = mysqli_real_escape_string($koneksi, $data['title']);
    $description = mysqli_real_escape_string($koneksi, $data['description']);
    $location = mysqli_real_escape_string($koneksi, $data['location']);
    $event_date = mysqli_real_escape_string($koneksi, $data['event_date']);
    $created_by = mysqli_real_escape_string($koneksi, $data['created_by']);
    
    $query = "INSERT INTO events (title, description, location, event_date, created_by) 
              VALUES ('$title', '$description', '$location', '$event_date', $created_by)";
    
    if (mysqli_query($koneksi, $query)) {
        $event_id = mysqli_insert_id($koneksi);
        echo json_encode([
            'status' => 'success',
            'message' => 'Event berhasil dibuat',
            'event_id' => $event_id
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Event gagal dibuat: ' . mysqli_error($koneksi)
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Data tidak lengkap'
    ]);
}
?>