// Minimal REST API using Firebase Functions + Express + Firestore
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as express from 'express';
import * as cors from 'cors';

// Initialize Firebase Admin SDK (uses project default credentials)
admin.initializeApp();
const db = admin.firestore();

// Create an Express app and enable CORS + JSON parsing
const app = express();
app.use(cors({ origin: true })); // For dev: allow all origins. Narrow down in prod.
app.use(express.json());

// ---- Health check -----------------------------------------------------------
app.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'api', ts: Date.now() });
});

// ---- Create: POST /items ----------------------------------------------------
app.post('/items', async (req, res) => {
  const { name, note } = req.body || {};
  if (!name || typeof name !== 'string') {
    return res.status(400).json({ error: 'Field \'name\' (string) is required.' });
  }

  const now = Date.now();
  const docRef = await db.collection('items').add({
    name,
    note: typeof note === 'string' ? note : '',
    createdAt: now,
    updatedAt: now,
  });

  const snap = await docRef.get();
  res.status(201).json({ id: docRef.id, ...snap.data() });
});

// ---- Read (list): GET /items -----------------------------------------------
app.get('/items', async (_req, res) => {
  const snap = await db
      .collection('items')
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();

  const data = snap.docs.map(d => ({ id: d.id, ...d.data() }));
  res.json(data);
});

// ---- Read (detail): GET /items/:id -----------------------------------------
app.get('/items/:id', async (req, res) => {
  const doc = await db.collection('items').doc(req.params.id).get();
  if (!doc.exists) return res.status(404).json({ error: 'Not found.' });
  res.json({ id: doc.id, ...doc.data() });
});

// ---- Update: PUT /items/:id -------------------------------------------------
app.put('/items/:id', async (req, res) => {
  const payload = req.body || {};
  payload.updatedAt = Date.now();

  await db.collection('items').doc(req.params.id).set(payload, { merge: true });
  const doc = await db.collection('items').doc(req.params.id).get();
  if (!doc.exists) return res.status(404).json({ error: 'Not found.' });
  res.json({ id: doc.id, ...doc.data() });
});

// ---- Delete: DELETE /items/:id ----------------------------------------------
app.delete('/items/:id', async (req, res) => {
  await db.collection('items').doc(req.params.id).delete();
  res.status(204).send(); // No Content
});

// Export the Express app as an HTTPS Function
exports.api = functions.https.onRequest(app);

