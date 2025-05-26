<?php
include 'koneksi.php';

// Menerima data dari aplikasi Flutter dalam format JSON
$data = json_decode(file_get_contents('php://input'), true);

// Memastikan ID event dan data yang diperlukan tersedia
if (isset($data['id'], $data['title'], $data['description'], $data['location'], $data['event_date'])) {
    $id = mysqli_real_escape_string($koneksi, $data['id']);
    $title = mysqli_real_escape_string($koneksi, $data['title']);
    $description = mysqli_real_escape_string($koneksi, $data['description']);
    $location = mysqli_real_escape_string($koneksi, $data['location']);
    $event_date = mysqli_real_escape_string($koneksi, $data['event_date']);
    
    $query = "UPDATE events SET 
              title = '$title', 
              description = '$description', 
              location = '$location', 
              event_date = '$event_date' 
              WHERE id = $id";
    
    if (mysqli_query($koneksi, $query)) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Event berhasil diperbarui'
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Event gagal diperbarui: ' . mysqli_error($koneksi)
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Data tidak lengkap'
    ]);
}
?>