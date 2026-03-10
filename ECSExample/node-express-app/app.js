const express = require("express");
const app = express();
const port = 3000;

app.get("/", (req, res) => {
  const now = new Date();
  const formatted = now.toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo' });
  res.send("Hello ECS from Express!");
  console.log(`[INFO] Requset Log Test: ${formatted}`);
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
