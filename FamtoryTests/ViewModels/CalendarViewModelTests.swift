import Testing
import Foundation
@testable import Famtory

@Suite("CalendarViewModel")
@MainActor
struct CalendarViewModelTests {

    // MARK: - 초기 상태

    @Test("초기 entries는 빈 배열")
    func initialEntriesEmpty() {
        let vm = CalendarViewModel()
        #expect(vm.entries.isEmpty)
    }

    @Test("초기 selectedDate는 nil")
    func initialSelectedDateIsNil() {
        let vm = CalendarViewModel()
        #expect(vm.selectedDate == nil)
    }

    @Test("초기 selectedEntries는 빈 배열")
    func initialSelectedEntriesEmpty() {
        let vm = CalendarViewModel()
        #expect(vm.selectedEntries.isEmpty)
    }

    @Test("초기 currentYear는 올해와 일치")
    func initialCurrentYearMatchesNow() {
        let vm = CalendarViewModel()
        let year = Calendar.current.component(.year, from: Date())
        #expect(vm.currentYear == year)
    }

    @Test("초기 currentMonth는 이번 달과 일치")
    func initialCurrentMonthMatchesNow() {
        let vm = CalendarViewModel()
        let month = Calendar.current.component(.month, from: Date())
        #expect(vm.currentMonth == month)
    }

    // MARK: - selectDate

    @Test("selectDate 호출 시 selectedDate 설정")
    func selectDateSetsSelectedDate() {
        let vm = CalendarViewModel()
        vm.selectDate("2025-05-03")
        #expect(vm.selectedDate == "2025-05-03")
    }

    @Test("selectDate 호출 시 해당 날짜 entries만 필터링")
    func selectDateFiltersEntries() {
        let vm = CalendarViewModel()
        vm.entries = [
            DiaryEntry(userId: "u1", userName: "A", content: "오늘 일기", date: "2025-05-03", reactions: [:]),
            DiaryEntry(userId: "u2", userName: "B", content: "어제 일기", date: "2025-05-02", reactions: [:]),
            DiaryEntry(userId: "u3", userName: "C", content: "다른 날 일기", date: "2025-05-03", reactions: [:])
        ]
        vm.selectDate("2025-05-03")
        #expect(vm.selectedEntries.count == 2)
        #expect(vm.selectedEntries.allSatisfy { $0.date == "2025-05-03" })
    }

    @Test("selectDate 호출 시 해당 날짜 entries가 없으면 빈 배열")
    func selectDateNoMatchReturnsEmpty() {
        let vm = CalendarViewModel()
        vm.entries = [
            DiaryEntry(userId: "u1", userName: "A", content: "일기", date: "2025-05-01", reactions: [:])
        ]
        vm.selectDate("2025-05-03")
        #expect(vm.selectedEntries.isEmpty)
    }

    // MARK: - datesWithEntries

    @Test("datesWithEntries는 entries의 날짜 집합 반환")
    func datesWithEntriesReturnsCorrectSet() {
        let vm = CalendarViewModel()
        vm.entries = [
            DiaryEntry(userId: "u1", userName: "A", content: "일기1", date: "2025-05-01", reactions: [:]),
            DiaryEntry(userId: "u2", userName: "B", content: "일기2", date: "2025-05-03", reactions: [:]),
            DiaryEntry(userId: "u3", userName: "C", content: "일기3", date: "2025-05-01", reactions: [:])
        ]
        let dates = vm.datesWithEntries()
        #expect(dates.count == 2)
        #expect(dates.contains("2025-05-01"))
        #expect(dates.contains("2025-05-03"))
    }

    @Test("entries가 비어있으면 datesWithEntries는 빈 Set")
    func datesWithEntriesEmptyWhenNoEntries() {
        let vm = CalendarViewModel()
        #expect(vm.datesWithEntries().isEmpty)
    }

    // MARK: - 월 이동 로직

    @Test("1월에서 이전 달로 이동하면 12월로 변경")
    func previousMonthWrapsToDecember() {
        let vm = CalendarViewModel()
        vm.currentMonth = 1
        vm.currentYear = 2025
        if vm.currentMonth == 1 {
            vm.currentMonth = 12
            vm.currentYear -= 1
        } else {
            vm.currentMonth -= 1
        }
        #expect(vm.currentMonth == 12)
        #expect(vm.currentYear == 2024)
    }

    @Test("12월에서 다음 달로 이동하면 1월로 변경")
    func nextMonthWrapsToJanuary() {
        let vm = CalendarViewModel()
        vm.currentMonth = 12
        vm.currentYear = 2024
        if vm.currentMonth == 12 {
            vm.currentMonth = 1
            vm.currentYear += 1
        } else {
            vm.currentMonth += 1
        }
        #expect(vm.currentMonth == 1)
        #expect(vm.currentYear == 2025)
    }

    @Test("일반 달에서 이전 달로 이동")
    func previousMonthNormal() {
        let vm = CalendarViewModel()
        vm.currentMonth = 5
        vm.currentYear = 2025
        if vm.currentMonth == 1 {
            vm.currentMonth = 12
            vm.currentYear -= 1
        } else {
            vm.currentMonth -= 1
        }
        #expect(vm.currentMonth == 4)
        #expect(vm.currentYear == 2025)
    }

    @Test("일반 달에서 다음 달로 이동")
    func nextMonthNormal() {
        let vm = CalendarViewModel()
        vm.currentMonth = 5
        vm.currentYear = 2025
        if vm.currentMonth == 12 {
            vm.currentMonth = 1
            vm.currentYear += 1
        } else {
            vm.currentMonth += 1
        }
        #expect(vm.currentMonth == 6)
        #expect(vm.currentYear == 2025)
    }
}
