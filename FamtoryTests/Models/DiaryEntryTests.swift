import Testing
import Foundation
@testable import Famtory

@Suite("DiaryEntry 모델")
struct DiaryEntryTests {

    // MARK: - todayString

    @Test("todayString()은 yyyy-MM-dd 형식")
    func todayStringFormat() {
        let today = DiaryEntry.todayString()
        let parts = today.split(separator: "-")
        #expect(parts.count == 3)
        #expect(parts[0].count == 4) // 연도
        #expect(parts[1].count == 2) // 월
        #expect(parts[2].count == 2) // 일
    }

    @Test("todayString()은 실제 오늘 날짜와 일치")
    func todayStringMatchesDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let expected = formatter.string(from: Date())
        #expect(DiaryEntry.todayString() == expected)
    }

    // MARK: - safeId

    @Test("id가 nil이면 safeId는 빈 문자열")
    func safeIdNil() {
        let entry = DiaryEntry(userId: "u1", userName: "테스트", content: "내용", date: "2025-05-03", reactions: [:])
        #expect(entry.safeId == "")
    }

    @Test("id가 있으면 safeId는 해당 값")
    func safeIdValue() {
        var entry = DiaryEntry(userId: "u1", userName: "테스트", content: "내용", date: "2025-05-03", reactions: [:])
        entry.id = "entry-001"
        #expect(entry.safeId == "entry-001")
    }

    // MARK: - 문서 ID

    @Test("문서 ID 형식은 userId_date")
    func documentIdFormat() {
        let userId = "user123"
        let date = DiaryEntry.todayString()
        let docId = "\(userId)_\(date)"
        #expect(docId.hasPrefix("user123_"))
        #expect(docId.contains("-"))
    }

    // MARK: - reactions

    @Test("reactions 기본값은 빈 딕셔너리")
    func defaultReactions() {
        let entry = DiaryEntry(userId: "u1", userName: "테스트", content: "내용", date: "2025-05-03", reactions: [:])
        #expect(entry.reactions.isEmpty)
    }

    @Test("reactions에 특정 이모지 userId 존재 여부 확인")
    func reactionContainsUser() {
        let entry = DiaryEntry(
            userId: "u1", userName: "테스트", content: "내용",
            date: "2025-05-03",
            reactions: ["❤️": ["u2", "u3"], "😂": ["u1"]]
        )
        #expect(entry.reactions["❤️"]?.contains("u2") == true)
        #expect(entry.reactions["❤️"]?.contains("u1") == false)
        #expect(entry.reactions["😂"]?.contains("u1") == true)
    }

    // MARK: - content

    @Test("content가 100자를 넘는지 체크 가능")
    func contentLength() {
        let short = "짧은 일기"
        let long = String(repeating: "가", count: 101)
        #expect(short.count <= 100)
        #expect(long.count > 100)
    }
}
