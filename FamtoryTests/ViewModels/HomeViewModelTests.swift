import Testing
import Foundation
@testable import Famtory

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    // MARK: - myTodayEntry

    @Test("내 오늘 일기가 없으면 myTodayEntry는 nil")
    func myTodayEntryNilWhenNoMatch() {
        let vm = HomeViewModel()
        let entries = [
            DiaryEntry(userId: "other-uid", userName: "다른사람", content: "다른 일기", date: DiaryEntry.todayString(), reactions: [:])
        ]
        vm.todayEntries = entries
        vm.myTodayEntry = entries.first { $0.userId == "my-uid" }
        #expect(vm.myTodayEntry == nil)
    }

    @Test("내 오늘 일기가 있으면 myTodayEntry 반환")
    func myTodayEntryFound() {
        let vm = HomeViewModel()
        let myEntry = DiaryEntry(userId: "my-uid", userName: "나", content: "내 일기", date: DiaryEntry.todayString(), reactions: [:])
        let entries = [
            myEntry,
            DiaryEntry(userId: "other-uid", userName: "다른사람", content: "다른 일기", date: DiaryEntry.todayString(), reactions: [:])
        ]
        vm.todayEntries = entries
        vm.myTodayEntry = entries.first { $0.userId == "my-uid" }
        #expect(vm.myTodayEntry?.userId == "my-uid")
        #expect(vm.myTodayEntry?.content == "내 일기")
    }

    // MARK: - 초기 상태

    @Test("초기 todayEntries는 빈 배열")
    func initialTodayEntriesEmpty() {
        let vm = HomeViewModel()
        #expect(vm.todayEntries.isEmpty)
    }

    @Test("초기 isLoading은 false")
    func initialIsLoadingFalse() {
        let vm = HomeViewModel()
        #expect(vm.isLoading == false)
    }

    @Test("초기 error는 nil")
    func initialErrorNil() {
        let vm = HomeViewModel()
        #expect(vm.error == nil)
    }

    // MARK: - entries 필터링

    @Test("여러 유저 일기 중 본인 것만 필터링")
    func filterMyEntry() {
        let entries = [
            DiaryEntry(userId: "uid-A", userName: "A", content: "A의 일기", date: DiaryEntry.todayString(), reactions: [:]),
            DiaryEntry(userId: "uid-B", userName: "B", content: "B의 일기", date: DiaryEntry.todayString(), reactions: [:]),
            DiaryEntry(userId: "uid-C", userName: "C", content: "C의 일기", date: DiaryEntry.todayString(), reactions: [:]),
        ]
        let myEntry = entries.first { $0.userId == "uid-B" }
        #expect(myEntry?.content == "B의 일기")
    }
}
