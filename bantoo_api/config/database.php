<?php
class Database {
    // Database credentials
    private $host = "localhost"; // sesuaikan dengan host Anda
    private $db_name = "bantoo_db"; // sesuaikan dengan nama database Anda
    private $username = "root"; // sesuaikan dengan username Anda
    private $password = ""; // sesuaikan dengan password Anda
    public $conn;
    
    // get database connection
    public function connect() {
        $this->conn = null;
        
        try {
            $this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $this->db_name, $this->username, $this->password);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch(PDOException $exception) {
            echo "Connection error: " . $exception->getMessage();
        }
        
        return $this->conn;
    }
}
?>