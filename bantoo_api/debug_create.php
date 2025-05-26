    <?php
// Headers
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST, GET');
header('Access-Control-Allow-Headers: Access-Control-Allow-Headers, Content-Type, Access-Control-Allow-Methods, Authorization, X-Requested-With');

// Enable error reporting
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Jika request adalah GET, tampilkan form untuk menguji API
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    echo '<html>
    <head>
        <title>Debug Create API</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            .form-group { margin-bottom: 15px; }
            label { display: block; margin-bottom: 5px; }
            input, textarea { width: 100%; padding: 8px; }
            button { padding: 10px 15px; background-color: #4CAF50; color: white; border: none; cursor: pointer; }
            pre { background-color: #f5f5f5; padding: 15px; overflow: auto; }
        </style>
    </head>
    <body>
        <h1>Debug Create Donasi API</h1>
        <form id="testForm">
            <div class="form-group">
                <label for="title">Judul:</label>
                <input type="text" id="title" name="title" required>
            </div>
            <div class="form-group">
                <label for="description">Deskripsi:</label>
                <textarea id="description" name="description" rows="4" required></textarea>
            </div>
            <div class="form-group">
                <label for="target_amount">Target Amount:</label>
                <input type="number" id="target_amount" name="target_amount" value="0">
            </div>
            <div class="form-group">
                <label for="image_url">Image URL:</label>
                <input type="text" id="image_url" name="image_url">
            </div>
            <div class="form-group">
                <label>
                    <input type="checkbox" id="is_emergency" name="is_emergency"> Emergency Campaign
                </label>
            </div>
            <button type="submit">Test API</button>
        </form>
        <div id="result" style="margin-top: 20px;"></div>
        
        <script>
            document.getElementById("testForm").addEventListener("submit", function(e) {
                e.preventDefault();
                
                const formData = {
                    title: document.getElementById("title").value,
                    description: document.getElementById("description").value,
                    target_amount: parseFloat(document.getElementById("target_amount").value) || 0,
                    image_url: document.getElementById("image_url").value,
                    is_emergency: document.getElementById("is_emergency").checked
                };
                
                const resultDiv = document.getElementById("result");
                resultDiv.innerHTML = "<h3>Sending data...</h3>";
                
                fetch("create.php", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(formData)
                })
                .then(response => response.json())
                .then(data => {
                    resultDiv.innerHTML = `
                        <h3>API Response:</h3>
                        <pre>${JSON.stringify(data, null, 2)}</pre>
                        <h3>Data Sent:</h3>
                        <pre>${JSON.stringify(formData, null, 2)}</pre>
                    `;
                })
                .catch(error => {
                    resultDiv.innerHTML = `
                        <h3>Error:</h3>
                        <pre>${error}</pre>
                        <h3>Data Sent:</h3>
                        <pre>${JSON.stringify(formData, null, 2)}</pre>
                    `;
                });
            });
        </script>
    </body>
    </html>';
    exit();
}

// Jika request adalah POST, teruskan ke create.php
$raw_data = file_get_contents("php://input");
include_once 'create.php';
?>