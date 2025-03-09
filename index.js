// index.js
const express = require('express');
const admin = require('firebase-admin');
const dotenv = require('dotenv');
const cors = require('cors'); // Add this

dotenv.config();

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const app = express();
const port = process.env.PORT || 3000;

app.use(cors()); // Add this line
app.use(express.json());

// Predefined list of conditions for validation
const validConditions = [
  'ADHD',
  'Autism',
  'Alzheimer’s',
  'Anxiety',
  'Stroke Recovery',
  'Lazy Eyes',
  'other'
];

// Signup Endpoint
app.post('/signup', async (req, res) => {
  const { email, password, conditions } = req.body;

  // Validate input
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }
  if (!conditions || !Array.isArray(conditions) || conditions.length === 0) {
    return res.status(400).json({ error: 'At least one condition must be selected' });
  }

  // Validate selected conditions
  const invalidConditions = conditions.filter((c) => !validConditions.includes(c));
  if (invalidConditions.length > 0) {
    return res.status(400).json({ error: `Invalid conditions: ${invalidConditions.join(', ')}` });
  }

  try {
    // Create user in Firebase Authentication
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      emailVerified: false,
      disabled: false,
    });

    // Store user conditions in Firestore
    await db.collection('users').doc(userRecord.uid).set({
      email: userRecord.email,
      conditions: conditions,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(201).json({
      message: 'User created successfully',
      uid: userRecord.uid,
      email: userRecord.email,
      conditions: conditions,
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Login Endpoint
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    // Check if user exists in Firebase Authentication
    const userRecord = await admin.auth().getUserByEmail(email);

    // Fetch user conditions from Firestore
    const userDoc = await db.collection('users').doc(userRecord.uid).get();
    if (!userDoc.exists) {
      return res.status(500).json({ error: 'User data not found in database' });
    }

    const userData = userDoc.data();

    // Note: Actual sign-in happens client-side with Firebase Auth SDK.
    // Return user info for client to proceed with login.
    res.status(200).json({
      message: 'User found, proceed with client-side login',
      uid: userRecord.uid,
      email: userRecord.email,
      conditions: userData.conditions,
    });
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(400).json({ error: error.message });
  }
});

// Optional: Get available conditions (for frontend dropdown)
app.get('/conditions', (req, res) => {
  res.status(200).json({
    conditions: validConditions,
  });
});

// Start the server (only once)
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
