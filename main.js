require('dotenv').config();
console.log("JWT_SEC:", process.env.JWT_SEC);
console.log("PASS_SEC:", process.env.PASS_SEC);

const express = require("express");
const cors = require('cors');
const router = require("./routes/index")
const app = express();

// Use CORS middleware
app.use(cors());
// Middleware
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

//routes
app.use("/", router) 


// Start the server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

