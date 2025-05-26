<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include 'koneksi.php';

// Ambil data dari JSON body jika tersedia
$data = json_decode(file_get_contents("php://input"), true);

// Jika data JSON tidak ada, fallback ke $_POST
$email = $data['email'] ?? $_POST['email'] ?? null;
$password = $data['password'] ?? $_POST['password'] ?? null;
$username = $data['username'] ?? $_POST['username'] ?? null;
    
// Cek apakah username sudah ada
$check_username = mysqli_query($koneksi, "SELECT * FROM users WHERE username='$username'");
if (mysqli_num_rows($check_username) > 0) {
    echo json_encode(['success' => false, 'message' => 'Username sudah digunakan']);
    exit();
}

// Cek apakah email sudah ada
$check_email = mysqli_query($koneksi, "SELECT * FROM users WHERE email='$email'");
if (mysqli_num_rows($check_email) > 0) {
    echo json_encode(['success' => false, 'message' => 'Email sudah digunakan']);
    exit();
}

// Hash password
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Simpan data
$query = mysqli_query($koneksi, "INSERT INTO users (email, password, username) VALUES ('$email', '$hashed_password', '$username')");

if ($query) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Pendaftaran gagal']);
}
?>
