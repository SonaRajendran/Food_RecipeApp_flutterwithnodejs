const express = require("express");
const router = express.Router();
const knex = require("../db/knex");
const multer = require("multer");
const path = require("path");

// Configure Multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname)),
});

const upload = multer({ storage });

// ✅ Create Recipe
router.post("/", upload.single("image"), async (req, res) => {
  try {
    const { title, description, ingredients, steps, category, createdBy } = req.body;

    if (!title || !description) {
      return res.status(400).json({ error: "Title and description are required" });
    }

    const imagePath = req.file ? `/uploads/${req.file.filename}` : null;

    // Parse ingredients and steps if they are strings, else use as is
    let parsedIngredients = [];
    if (typeof ingredients === "string") {
      parsedIngredients = JSON.parse(ingredients);
    } else if (Array.isArray(ingredients)) {
      parsedIngredients = ingredients;
    }

    let parsedSteps = [];
    if (typeof steps === "string") {
      parsedSteps = JSON.parse(steps);
    } else if (Array.isArray(steps)) {
      parsedSteps = steps;
    }

    const [recipe] = await knex("recipes")
      .insert({
        title,
        description,
        image_url: imagePath,
        ingredients: JSON.stringify(parsedIngredients),
        steps: JSON.stringify(parsedSteps),
        category,
        created_by: createdBy,
      })
      .returning("*");

    res.status(201).json(recipe);
  } catch (error) {
    console.error("Error creating recipe:", error);
    res.status(500).json({ error: "Failed to create recipe" });
  }
});

// ✅ Get All Recipes
router.get("/", async (req, res) => {
  try {
    const recipes = await knex("recipes").select("*");
    res.json(recipes);
  } catch (error) {
    console.error("Error fetching recipes:", error);
    res.status(500).json({ error: "Failed to fetch recipes" });
  }
});

module.exports = router;
