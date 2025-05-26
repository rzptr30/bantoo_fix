<?php
include 'koneksi.php';

// Menerima data dari aplikasi Flutter dalam format JSON
$data = json_decode(file_get_contents('php://input'), true);

// Memastikan ID event tersedia
if (isset($data['id'])) {
    $id = mysqli_real_escape_string($koneksi, $data['id']);
    
    // Periksa jika ada relasi di tabel volunteers
    $check_query = "SELECT COUNT(*) as count FROM volunteers WHERE event_id = $id";
    $check_result = mysqli_query($koneksi, $check_query);
    $row = mysqli_fetch_assoc($check_result);
    
    if ($row['count'] > 0) {
        // Hapus data relasi di tabel volunteers terlebih dahulu
        $delete_volunteers = "DELETE FROM volunteers WHERE event_id = $id";
        mysqli_query($koneksi, $delete_volunteers);
    }
    
    // Setelah relasi dihapus, baru hapus event
    $query = "DELETE FROM events WHERE id = $id";
    
    if (mysqli_query($koneksi, $query)) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Event berhasil dihapus'
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Event gagal dihapus: ' . mysqli_error($koneksi)
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'ID event tidak disediakan'
    ]);
}
?>