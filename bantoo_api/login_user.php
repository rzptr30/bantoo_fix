<?php
include 'config.php';

$data = json_decode(file_get_contents("php://input"));
$email = $_POST['email'];
$password = $_POST['password'];


$query = "SELECT * FROM users WHERE email='$email'";
$result = mysqli_query($conn, $query);

if (mysqli_num_rows($result) > 0) {
    $user = mysqli_fetch_assoc($result);
    if (password_verify($password, $user['password'])) {
        echo json_encode(["success" => true, "message" => "Login successful"]);
    } else {
        echo json_encode(["success" => false, "message" => "Wrong password"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "User not found"]);
}
?>
