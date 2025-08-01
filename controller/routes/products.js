const express = require('express');
const router = express.Router();
const pool = require('../../model/db');

const validTypes = ['beds', 'night_stands', 'dressers', 'couches', 'tvs', 'tables'];

/**
 * @swagger
 * /api/products:
 *  get:
 *    summary: Get all furniture products
 *    tags:
 *      - Products
 *    responses:
 *      200:
 *        description: A list of all products
 *        content:
 *          application/json:
 *            schema:
 *              type: array
 *              items:
 *                type: object
 *                properties:
 *                  id:
 *                    type: integer
 *                  item_id:
 *                    type: integer
 *                  name:
 *                    type: string
 *                  price:
 *                    type: numeric
 *                  quantity:
 *                    type: integer
 *            examples:
 *              example1:
 *                value:
 *                  - id: 1   
 *                    item_id: 1
 *                    name: racecar
 *                    price: 1000.00
 *                    furniture_type: bed
 *                    quantity: 5
 *                  - id: 2
 *                    item_id: 1
 *                    name: gas_can
 *                    price: "250.00"
 *                    furniture_type: night_stand
 *                    quantity: 5
 *                  - id: 3
 *                    item_id: 1
 *                    name: tool_box
 *                    price: "250.00"
 *                    furniture_type: dresser
 *                    quantity: 5
 */

router.get('/', async (req, res) => {
  const result = await pool.query('SELECT * FROM all_furniture');
  res.json(result.rows);
});

/**
 * @swagger
 * /api/products/{type}:
 *   get:
 *     summary: Get furniture items by type
 *     tags:
 *       - Products
 *     parameters:
 *       - in: path
 *         name: type
 *         required: true
 *         description: Product category (e.g. beds, couches)
 *         schema:
 *           type: string
 *           enum: [beds, night_stands, dressers, couches, tvs, tables]
 *     responses:
 *       200:
 *         description: A list of products by type
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: integer
 *                   name:
 *                     type: string
 *                   price:
 *                     type: number
 *                   furniture_type:
 *                     type: string
 *                   quantity:
 *                     type: integer
 *             examples:
 *              example1:
 *                value:
 *                  - id: 1
 *                    name: racecar
 *                    price: 1000
 *                    furniture_type: bed
 *                    quantity: 5
 *                  - id: 2
 *                    name: water_bed
 *                    price: 200
 *                    furniture_type: bed
 *                    quantity: 10
 *       400:
 *         description: Invalid category
 */



router.get('/:type', async (req, res) => {
  const { type } = req.params;
  if (!validTypes.includes(type)) return res.status(400).json({ error: 'Invalid category' });

  const result = await pool.query(`SELECT * FROM ${type}`);
  res.json(result.rows);
});

/**
 * @swagger
 * /api/products/{type}/{id}:
 *  get:
 *    summary: Get single furniture type by id
 *    tags:
 *      - Products
 *    parameters:
 *      - in: path
 *        name: type
 *        required: true
 *        description: Product category (e.g. beds, couches)
 *        schema:
 *          type: string
 *          enum: [beds, night_stands, dressers, couches, tvs, tables]
 *      - in: path
 *        name: id
 *        required: true
 *        description: Furniture type id
 *        schema:
 *          type: integer
 *    responses:
 *      200:
 *        description: The requested product
 *        content:
 *          application/json:
 *            schema:
 *              type: object
 *              properties:
 *                id:
 *                  type: integer
 *                name:
 *                  type: string
 *                price:
 *                  type: number
 *                furniture_type:
 *                  type: string
 *                quantity:
 *                  type: integer
 *            examples:
 *              example1:
 *                value:
 *                  id: 2
 *                  name: water_bed
 *                  price: 200
 *                  furniture_type: bed
 *                  quantity: 10
 *      400: 
 *        description: Invalid category
 *      404:
 *        description: Not found    
 */

router.get('/:type/:id', async (req, res) => {
  const { type, id } = req.params;
  if (!validTypes.includes(type)) return res.status(400).json({ error: 'Invalid category' });

  const result = await pool.query(`SELECT * FROM ${type} WHERE id = $1`, [id]);
  if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
  res.json(result.rows[0]);
});

module.exports = router;
