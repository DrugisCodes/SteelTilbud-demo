import express from "express";
import { requireCsrf } from "../middleware/csrf.js";

const router = express.Router();

// In-memory storage for favorites (in production, use a database)
let favorites = [];

// Get all favorites
router.get("/", (req, res) => {
  res.json({ favorites });
});

// Add to favorites
router.post("/", requireCsrf, (req, res) => {
  try {
    const { productId, productName, butikk, pris } = req.body;
    
    // Check if already in favorites
    const existing = favorites.find(fav => fav.productId === productId && fav.butikk === butikk);
    if (existing) {
      return res.status(400).json({ success: false, message: "Already in favorites" });
    }
    
    const favorite = {
      id: Date.now().toString(),
      productId,
      productName,
      butikk,
      pris,
      dateAdded: new Date().toISOString()
    };
    
    favorites.push(favorite);
    res.json({ success: true, favorite });
  } catch (error) {
    console.error("Add favorite error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// Remove from favorites
router.delete("/:id", requireCsrf, (req, res) => {
  try {
    const { id } = req.params;
    const index = favorites.findIndex(fav => fav.id === id);
    
    if (index === -1) {
      return res.status(404).json({ success: false, message: "Favorite not found" });
    }
    
    favorites.splice(index, 1);
    res.json({ success: true, message: "Removed from favorites" });
  } catch (error) {
    console.error("Remove favorite error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

export default router;