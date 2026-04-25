import Foundation

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var entries: [DiaryEntry] = []
    @Published var selectedDate: String?
    @Published var selectedEntries: [DiaryEntry] = []
    @Published var currentYear: Int
    @Published var currentMonth: Int

    init() {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        currentYear  = comps.year!
        currentMonth = comps.month!
    }

    func loadMonth(familyId: String) async {
        do {
            entries = try await DiaryService.shared.fetchMonthEntries(
                familyId: familyId, year: currentYear, month: currentMonth
            )
            if let selected = selectedDate { selectDate(selected) }
        } catch {}
    }

    func selectDate(_ date: String) {
        selectedDate    = date
        selectedEntries = entries.filter { $0.date == date }
    }

    func datesWithEntries() -> Set<String> {
        Set(entries.map { $0.date })
    }

    func previousMonth(familyId: String) async {
        if currentMonth == 1 { currentMonth = 12; currentYear -= 1 }
        else { currentMonth -= 1 }
        await loadMonth(familyId: familyId)
    }

    func nextMonth(familyId: String) async {
        if currentMonth == 12 { currentMonth = 1; currentYear += 1 }
        else { currentMonth += 1 }
        await loadMonth(familyId: familyId)
    }
}
