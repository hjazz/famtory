import SwiftUI

struct CalendarView: View {
    @ObservedObject var familyVM: FamilyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var calVM = CalendarViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.famBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 월 네비게이션
                    HStack {
                        Button {
                            Task { if let id = familyVM.family?.safeId { await calVM.previousMonth(familyId: id) } }
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.famBrown)
                                .padding(10)
                        }

                        Spacer()

                        Text(String(format: "%d년 %d월", calVM.currentYear, calVM.currentMonth))
                            .font(.famHeadline())
                            .foregroundColor(.famBrown)

                        Spacer()

                        Button {
                            Task { if let id = familyVM.family?.safeId { await calVM.nextMonth(familyId: id) } }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.famBrown)
                                .padding(10)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)

                    CalendarGridView(
                        year: calVM.currentYear,
                        month: calVM.currentMonth,
                        activeDates: calVM.datesWithEntries(),
                        selectedDate: calVM.selectedDate,
                        onSelect: { calVM.selectDate($0) }
                    )
                    .padding(.horizontal)

                    Divider().padding(.top, 8)

                    // 선택일 일기
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if let sel = calVM.selectedDate {
                                Text(formattedDate(sel))
                                    .font(.famHeadline())
                                    .foregroundColor(.famBrown)
                                    .padding(.horizontal)
                                    .padding(.top, 16)

                                if calVM.selectedEntries.isEmpty {
                                    Text("이 날은 일기가 없어요 🐹")
                                        .font(.famBody())
                                        .foregroundColor(.famBrown.opacity(0.4))
                                        .padding(.horizontal)
                                } else {
                                    ForEach(calVM.selectedEntries) { entry in
                                        DiaryEntryCard(
                                            entry: entry,
                                            currentUserId: authVM.currentUser?.safeId ?? "",
                                            onReaction: { _ in }
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                            } else {
                                Text("날짜를 선택하면 일기를 볼 수 있어요")
                                    .font(.famBody())
                                    .foregroundColor(.famBrown.opacity(0.38))
                                    .padding(.top, 32)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("달력")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if let id = familyVM.family?.safeId { await calVM.loadMonth(familyId: id) }
            }
        }
    }

    private func formattedDate(_ str: String) -> String {
        let parse = DateFormatter(); parse.dateFormat = "yyyy-MM-dd"
        guard let date = parse.date(from: str) else { return str }
        let out = DateFormatter()
        out.locale = Locale(identifier: "ko_KR"); out.dateFormat = "M월 d일 EEEE"
        return out.string(from: date)
    }
}

// MARK: - Grid

struct CalendarGridView: View {
    let year: Int
    let month: Int
    let activeDates: Set<String>
    let selectedDate: String?
    let onSelect: (String) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack(spacing: 6) {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(weekdays, id: \.self) { d in
                    Text(d)
                        .font(.famCaption())
                        .foregroundColor(d == "일" ? .red.opacity(0.65) : .famBrown.opacity(0.45))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(calendarDays(), id: \.self) { day in
                    if day == 0 {
                        Color.clear.frame(height: 38)
                    } else {
                        let ds = dateString(day: day)
                        let active   = activeDates.contains(ds)
                        let selected = selectedDate == ds
                        let today    = ds == DiaryEntry.todayString()

                        Button { onSelect(ds) } label: {
                            ZStack {
                                if selected {
                                    Circle().fill(Color.famPrimary)
                                } else if today {
                                    Circle().fill(Color.famPrimary.opacity(0.14))
                                }

                                VStack(spacing: 2) {
                                    Text("\(day)")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(selected ? .white : .famBrown)
                                    if active {
                                        Circle()
                                            .fill(selected ? Color.white.opacity(0.8) : Color.famPrimary)
                                            .frame(width: 4, height: 4)
                                    }
                                }
                            }
                            .frame(height: 38)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func calendarDays() -> [Int] {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = 1
        guard let first = Calendar.current.date(from: comps) else { return [] }
        let offset = Calendar.current.component(.weekday, from: first) - 1
        let count  = Calendar.current.range(of: .day, in: .month, for: first)!.count
        return Array(repeating: 0, count: offset) + Array(1...count)
    }

    private func dateString(day: Int) -> String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }
}
