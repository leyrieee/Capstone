const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging"); // Import messaging
const { onRequest } = require("firebase-functions/v2/https"); // Use v2
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const cors = require("cors")({ origin: true });

initializeApp();
const db = getFirestore();
const messaging = getMessaging(); // Initialize messaging

setGlobalOptions({ region: "us-central1" }); // Set region globally

// Helper function for consistent error responses
const sendErrorResponse = (res, statusCode, message, error) => {
  console.error(message, error);
  res.status(statusCode).json({ error: message });
};

// --- HTTP Functions (v2 syntax) ---

exports.getLatestProbability = onRequest(async (req, res) => {
  cors(req, res, async () => {
    const deviceId = req.query.device_id;
    if (!deviceId) {
      return sendErrorResponse(res, 400, "Missing deviceId");
    }

    try {
      const deviceDoc = await db.collection("devices").doc(deviceId).get();
      if (!deviceDoc.exists) {
        return sendErrorResponse(res, 404, "Device not found");
      }

      const latestProbability = deviceDoc.data().latest_probability ?? 0; //handle null
      res.status(200).json({ probability: latestProbability });
    } catch (error) {
      sendErrorResponse(res, 500, "Error getting latest probability", error);
    }
  });
});

exports.getRecentReadings = onRequest(async (req, res) => {
  cors(req, res, async () => {
    const deviceId = req.query.device_id;
    const count = parseInt(req.query.count || "20", 10); // Ensure integer

    if (!deviceId) {
      return sendErrorResponse(res, 400, "Missing deviceId");
    }

    try {
      const snapshot = await db
        .collection("devices")
        .doc(deviceId)
        .collection("readings")
        .orderBy("timestamp", "desc")
        .limit(count)
        .get();

      const readings = snapshot.docs.map((doc) => ({
        ...doc.data(),
        timestamp: doc.data().timestamp?.toDate()?.toISOString() || null, //convert timestamp
      }));
      res.status(200).json(readings);
    } catch (error) {
      sendErrorResponse(res, 500, "Error fetching readings", error);
    }
  });
});

exports.getAlertHistory = onRequest(async (req, res) => {
  cors(req, res, async () => {
    const deviceId = req.query.device_id;
    const limit = parseInt(req.query.limit || "50", 10); // Ensure integer

    if (!deviceId) {
      return sendErrorResponse(res, 400, "Missing deviceId");
    }

    try {
      const snapshot = await db
        .collection("devices")
        .doc(deviceId)
        .collection("alerts")
        .orderBy("alert_time", "desc")
        .limit(limit)
        .get();

      const alerts = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        alert_time: doc.data().alert_time?.toDate()?.toISOString() || null, //convert
      }));
      res.status(200).json(alerts);
    } catch (error) {
      sendErrorResponse(res, 500, "Error fetching alerts", error);
    }
  });
});

exports.updateFcmToken = onRequest(async (req, res) => {
  cors(req, res, async () => {
    const { device_id, fcm_token } = req.body;

    if (!device_id || !fcm_token) {
      return sendErrorResponse(res, 400, "Missing device_id or fcm_token");
    }

    try {
      await db.collection("devices").doc(device_id).set(
        { fcm_token },
        { merge: true }
      );
      res.status(200).json({ success: true });
    } catch (error) {
      sendErrorResponse(res, 500, "Error updating FCM token", error);
    }
  });
});

exports.acknowledgeAlert = onRequest(async (req, res) => {
  cors(req, res, async () => {
    const { device_id, alert_id } = req.body;

    if (!device_id || !alert_id) {
      return sendErrorResponse(res, 400, "Missing device_id or alert_id");
    }

    try {
      const alertRef = db
        .collection("devices")
        .doc(device_id)
        .collection("alerts")
        .doc(alert_id);

      const alertDoc = await alertRef.get();
      if (!alertDoc.exists) {
        return sendErrorResponse(res, 404, "Alert not found");
      }

      await alertRef.update({ acknowledged: true });
      res.status(200).json({ success: true });
    } catch (error) {
      sendErrorResponse(res, 500, "Error acknowledging alert", error);
    }
  });
});

// --- Helper Function ---
function getAlertMessage(probability) {
  if (probability <= 0.5) return "low";
  if (probability <= 0.8) return "medium";
  return "high";
}

exports.postReading = onRequest(async (req, res) => {
  cors(req, res, async () => {
    const { device_id, probability } = req.body;

    if (!device_id || typeof probability !== "number") {
      return sendErrorResponse(
        res,
        400,
        "Missing or invalid device_id or probability"
      );
    }

    try {
      const timestamp = admin.firestore.FieldValue.serverTimestamp(); // Use server timestamp

      // Save reading
      await db.collection("devices").doc(device_id).collection("readings").add({
        timestamp,
        probability,
      });

      // Update latest_probability
      await db.collection("devices").doc(device_id).set(
        { latest_probability: probability },
        { merge: true }
      );

      // Determine alert message
      const alertMessage = getAlertMessage(probability);

      // Save alert
      const newAlertRef = await db
        .collection("devices")
        .doc(device_id)
        .collection("alerts")
        .add({
          alert_time: timestamp,
          probability,
          acknowledged: false,
          alert_message: alertMessage,
        });
      const newAlertId = newAlertRef.id; // Get the id of the new alert

      //send notification
      if (probability >= 0.8) {
        const deviceDoc = await db.collection("devices").doc(device_id).get();
        const fcmToken = deviceDoc.data().fcm_token;
        if (fcmToken) {
          const message = {
            token: fcmToken,
            notification: {
              title: "⚠️ Seizure Risk Detected",
              body: `High seizure probability: ${(
                probability * 100
              ).toFixed(1)}%`,
            },
            data: {
              alert_id: newAlertId,
              device_id: device_id,
              probability: probability.toString(),
            },
          };
          try {
            await messaging.send(message);
            console.log("Push notification sent");
          } catch (e) {
            console.error("Error sending notification", e);
          }
        }
      }

      res.status(200).json({ success: true });
    } catch (error) {
      sendErrorResponse(res, 500, "Error posting reading", error);
    }
  });
});

// --- Firestore Trigger Function (v2 syntax) ---
exports.sendAlertNotification = onDocumentCreated(
  "devices/{deviceId}/alerts/{alertId}",
  async (event) => {
    const alert = event.data.data(); // Get the data from event.data.data()
    const { deviceId, alertId } = event.params;

    console.log("Alert data:", alert);

    if (alert.probability < 0.8) {
      console.log("Probability is below 0.8, not sending notification");
      return null; // only notify for high prob
    }

    try {
      const deviceDoc = await db.collection("devices").doc(deviceId).get();
      const token = deviceDoc.data().fcm_token;

      if (token) {
        const message = {
          token: token,
          notification: {
            title: "⚠️ Seizure Risk Detected",
            body: `High seizure probability: ${(alert.probability * 100).toFixed(1)}%`,
          },
          android: {
            notification: {
              channel_id: 'seizure_alerts',
              sound: "alert_sound", // Custom sound name (without extension)
            },
          },
          data: {
            alert_id: alertId,
            device_id: deviceId,
            probability: alert.probability.toString(),
          },
        };

        await messaging.send(message);
        console.log("Push notification sent");
      } else {
        console.log("Device has no FCM token");
      }
    } catch (err) {
      console.error("Error sending FCM notification:", err);
    }
    return null;
  }
);

