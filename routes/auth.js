import express from "express";
import { requireCsrf } from "../middleware/csrf.js";

const router = express.Router();

// Login endpoint
router.post("/login", requireCsrf, async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // Simple authentication logic - replace with your actual auth logic
    if (username === "admin" && password === "password") {
      res.cookie("authenticated", "true", { 
        httpOnly: true, 
        secure: process.env.NODE_ENV === "production",
        maxAge: 24 * 60 * 60 * 1000 // 24 hours
      });
      
      res.json({ success: true, message: "Logged in successfully" });
    } else {
      res.status(401).json({ success: false, message: "Invalid credentials" });
    }
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// Logout endpoint
router.post("/logout", (req, res) => {
  res.clearCookie("authenticated");
  res.json({ success: true, message: "Logged out successfully" });
});

// Check auth status
router.get("/status", (req, res) => {
  const isAuthenticated = req.cookies.authenticated === "true";
  res.json({ authenticated: isAuthenticated });
});

export default router;