import express, { Request, Response } from 'express';
import cors from 'cors';
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// Create Express app
const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Health check
app.get('/health', (_req: Request, res: Response) => {
  res.status(200).send('OK');
});

// ---- Create: POST /items ----
app.post('/items', async (req: Request, res: Response) => {
  const { name, note } = req.body;
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

// ---- Read (list): GET /items ----
app.get('/items', async (_req: Request, res: Response) => {
  const snap = await db
      .collection('items')
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();

  const data = snap.docs.map(d => ({ id: d.id, ...d.data() }));
  res.json(data);
});

// ---- Read (detail): GET /items/:id ----
app.get('/items/:id', async (req: Request, res: Response) => {
  const doc = await db.collection('items').doc(req.params.id).get();
  if (!doc.exists) return res.status(404).json({ error: 'Not found.' });
  res.json({ id: doc.id, ...doc.data() });
});

// ---- Update: PUT /items/:id ----
app.put('/items/:id', async (req: Request, res: Response) => {
  const payload = req.body || {};
  payload.updatedAt = Date.now();

  await db.collection('items').doc(req.params.id).set(payload, { merge: true });
  const doc = await db.collection('items').doc(req.params.id).get();
  if (!doc.exists) return res.status(404).json({ error: 'Not found.' });
  res.json({ id: doc.id, ...doc.data() });
});

// ---- Delete: DELETE /items/:id ----
app.delete('/items/:id', async (req: Request, res: Response) => {
  await db.collection('items').doc(req.params.id).delete();
  res.status(204).send();
});

// Export Express app as Firebase Function
exports.api = functions.https.onRequest(app);
