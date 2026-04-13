const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const FLAT_ID = "roomly-default-flat";

// ---------------------------------------------------------------------------
// TRIGGER: fires whenever a member document is updated in Firestore.
// If the taskCompletedDate just changed to today, notify all roommates.
// ---------------------------------------------------------------------------
exports.onMemberTaskCompleted = functions.firestore
  .document(`flats/${FLAT_ID}/members/{avatarId}`)
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after  = change.after.data();
    const avatarId = context.params.avatarId;

    // Today's date in yyyy-MM-dd (UTC — Cloud Functions run UTC by default)
    const today = new Date().toISOString().split("T")[0];

    // Only proceed when taskCompletedDate changes to today (not on other field updates)
    if (after.taskCompletedDate !== today || before.taskCompletedDate === today) {
      return null;
    }

    const name = after.name || avatarId;

    // Collect FCM tokens from all OTHER members
    const membersSnap = await db
      .collection("flats").doc(FLAT_ID)
      .collection("members")
      .get();

    const tokens = [];
    membersSnap.forEach((doc) => {
      if (doc.id !== avatarId && doc.data().fcmToken) {
        tokens.push(doc.data().fcmToken);
      }
    });

    if (tokens.length === 0) return null;

    // "{name} is done for the day." — no body (Option B)
    const message = {
      notification: { title: `${name} is done for the day.` },
      tokens,
    };

    const res = await admin.messaging().sendEachForMulticast(message);
    console.log(`✅ Roommate completion: sent ${res.successCount}/${tokens.length}`);
    return null;
  });

// ---------------------------------------------------------------------------
// SCHEDULED: fires every day at 00h05 Paris time.
// Checks who didn't complete their task yesterday and notifies roommates.
// ---------------------------------------------------------------------------
exports.dailyMissedCheck = functions.pubsub
  .schedule("5 0 * * *")
  .timeZone("Europe/Paris")
  .onRun(async () => {
    // Compute yesterday in Paris time
    const now = new Date();
    // Paris offset (UTC+1 standard / UTC+2 DST) — approximate with Date math
    // Firebase Scheduler already delivers at 00h05 Paris, so "now" is ~23h05 UTC (winter)
    // or ~22h05 UTC (summer). Either way, yesterday in Paris = today in UTC minus 1.
    const yesterday = new Date(now);
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split("T")[0];

    const membersSnap = await db
      .collection("flats").doc(FLAT_ID)
      .collection("members")
      .get();

    const allMembers = [];
    membersSnap.forEach((doc) => {
      allMembers.push({ id: doc.id, ...doc.data() });
    });

    for (const member of allMembers) {
      // Skip members who completed yesterday
      if (member.taskCompletedDate === yesterdayStr) continue;

      const name = member.name || member.id;

      // Collect FCM tokens from all other members
      const tokens = allMembers
        .filter((m) => m.id !== member.id && m.fcmToken)
        .map((m) => m.fcmToken);

      if (tokens.length === 0) continue;

      // "{name} didn't show up today." — no body (Option C)
      const message = {
        notification: { title: `${name} didn't show up today.` },
        tokens,
      };

      const res = await admin.messaging().sendEachForMulticast(message);
      console.log(`✅ Missed check [${name}]: sent ${res.successCount}/${tokens.length}`);
    }

    return null;
  });
