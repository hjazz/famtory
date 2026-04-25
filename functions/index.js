const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp }     = require("firebase-admin/app");
const { getFirestore }      = require("firebase-admin/firestore");
const { getMessaging }      = require("firebase-admin/messaging");

initializeApp();

/**
 * 새 일기가 작성되면 같은 가족의 다른 멤버에게 FCM 푸시 알림을 전송한다.
 */
exports.onNewDiaryEntry = onDocumentCreated(
  "families/{familyId}/entries/{entryId}",
  async (event) => {
    const db      = getFirestore();
    const entry   = event.data.data();
    const { familyId } = event.params;

    // 가족 문서에서 멤버 목록 가져오기
    const familySnap = await db.collection("families").doc(familyId).get();
    if (!familySnap.exists) return;

    const memberIds = (familySnap.data().memberIds || [])
      .filter((uid) => uid !== entry.userId);   // 본인 제외

    if (memberIds.length === 0) return;

    // 각 멤버의 FCM 토큰 수집
    const userSnaps = await Promise.all(
      memberIds.map((uid) => db.collection("users").doc(uid).get())
    );
    const tokens = userSnaps
      .map((snap) => snap.data()?.fcmToken)
      .filter(Boolean);

    if (tokens.length === 0) return;

    // 멀티캐스트 전송
    await getMessaging().sendEachForMulticast({
      tokens,
      notification: {
        title: `${entry.userName}이(가) 일기를 썼어요 🐹`,
        body:  entry.content,
      },
      apns: {
        payload: {
          aps: { sound: "default", badge: 1 },
        },
      },
    });
  }
);
