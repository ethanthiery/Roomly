import Foundation
import Combine

class StreakViewModel: ObservableObject {

    // MARK: - Persisted state

    @Published var clothBalance: Int {
        didSet { UserDefaults.standard.set(clothBalance, forKey: "clothBalance") }
    }

    @Published var monthlyClothBalance: Int {
        didSet { UserDefaults.standard.set(monthlyClothBalance, forKey: "monthlyClothBalance_\(currentMonthKey())") }
    }

    @Published var claimedDates: Set<String> {
        didSet { UserDefaults.standard.set(Array(claimedDates), forKey: "claimedDates") }
    }

    @Published var luckyDayAvailable: Bool {
        didSet { UserDefaults.standard.set(luckyDayAvailable, forKey: "luckyDayAvailable_\(currentMonthKey())") }
    }

    /// Cloths accumulated this week — versés au solde uniquement le dimanche.
    @Published var pendingCloths: Int {
        didSet { UserDefaults.standard.set(pendingCloths, forKey: "pendingCloths_\(currentWeekKey())") }
    }

    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2 // Monday
        return c
    }()

    // MARK: - Init

    init() {
        let balance = UserDefaults.standard.integer(forKey: "clothBalance")
        self.clothBalance = balance

        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        let monthKey = f.string(from: Date())
        let savedMonthKey = UserDefaults.standard.string(forKey: "currentMonthKey") ?? ""
        if savedMonthKey != monthKey {
            let previousTotal = UserDefaults.standard.integer(forKey: "monthlyClothBalance_\(savedMonthKey)")
            UserDefaults.standard.set(previousTotal, forKey: "lastMonthFinalTotal_avatar1")
            UserDefaults.standard.set(savedMonthKey, forKey: "lastGrindMonthToProcess")
            self.monthlyClothBalance = 0
            UserDefaults.standard.set(monthKey, forKey: "currentMonthKey")
        } else {
            self.monthlyClothBalance = UserDefaults.standard.integer(forKey: "monthlyClothBalance_\(monthKey)")
        }

        let saved = UserDefaults.standard.stringArray(forKey: "claimedDates") ?? []
        self.claimedDates = Set(saved)

        if savedMonthKey != monthKey {
            self.luckyDayAvailable = false
        } else {
            self.luckyDayAvailable = UserDefaults.standard.bool(forKey: "luckyDayAvailable_\(monthKey)")
        }

        // Pending cloths — keyed by week so they auto-reset each new week
        let weekKey = Self.staticWeekKey()
        self.pendingCloths = UserDefaults.standard.integer(forKey: "pendingCloths_\(weekKey)")

        processWeeklyRewardIfNeeded()
    }

    // MARK: - Current week (Mon → Sun)

    var currentWeekDates: [Date] {
        let today = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
    }

    let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // MARK: - Computed state

    var isTodayClaimed: Bool {
        claimedDates.contains(dateString(Date()))
    }

    var canClaim: Bool { !isTodayClaimed }

    var currentTrailingStreak: Int {
        var count = 0
        for date in currentWeekDates.reversed() {
            guard !isFutureDay(date) else { continue }
            if claimedDates.contains(dateString(date)) {
                count += 1
            } else {
                break
            }
        }
        return count
    }

    func isClaimed(_ date: Date) -> Bool {
        claimedDates.contains(dateString(date))
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    func isFutureDay(_ date: Date) -> Bool {
        date > Date() && !calendar.isDateInToday(date)
    }

    func isMissedDay(_ date: Date) -> Bool {
        guard !isFutureDay(date) && !calendar.isDateInToday(date) else { return false }
        return !isClaimed(date)
    }

    // MARK: - Actions

    func claimToday() {
        claimedDates.insert(dateString(Date()))
        pendingCloths += 1

        // Si c'est dimanche → verser immédiatement tous les cloths en attente
        if let sunday = currentWeekDates.last, calendar.isDateInToday(sunday) {
            let sundayStr = dateString(sunday)
            let lastProcessed = UserDefaults.standard.string(forKey: "lastProcessedSunday") ?? ""
            if sundayStr != lastProcessed {
                addCloths(pendingCloths)
                pendingCloths = 0
                UserDefaults.standard.set(sundayStr, forKey: "lastProcessedSunday")
            }
        }

        syncToFirebase()
    }

    func addCloths(_ count: Int) {
        clothBalance        += count
        monthlyClothBalance += count
        syncToFirebase()
    }

    func removeCloths(_ count: Int) {
        clothBalance        = max(0, clothBalance - count)
        monthlyClothBalance = max(0, monthlyClothBalance - count)
        syncToFirebase()
    }

    func purchaseLuckyDay() {
        guard clothBalance >= 199 else { return }
        removeCloths(199)
        luckyDayAvailable = true
    }

    func syncToFirebase() {
        guard let avatarId = UserDefaults.standard.string(forKey: "currentAvatarId") else { return }
        FirebaseManager.shared.uploadMemberData(avatarId: avatarId, fields: [
            "clothBalance":        clothBalance,
            "monthlyClothBalance": monthlyClothBalance,
            "name":                AvatarInfo.info(for: avatarId).name,
            "currentStreak":       currentTrailingStreak
        ])
    }

    // MARK: - Sunday weekly reward

    private func processWeeklyRewardIfNeeded() {
        guard let sunday = currentWeekDates.last else { return }
        guard calendar.isDateInToday(sunday) else { return }
        let sundayStr = dateString(sunday)
        let lastProcessed = UserDefaults.standard.string(forKey: "lastProcessedSunday") ?? ""
        guard sundayStr != lastProcessed else { return }

        // Fallback : si le dimanche a déjà été claim avant l'ouverture de l'app
        if claimedDates.contains(sundayStr) && pendingCloths > 0 {
            addCloths(pendingCloths)
            pendingCloths = 0
            UserDefaults.standard.set(sundayStr, forKey: "lastProcessedSunday")
        }
    }

    // MARK: - Helpers

    func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func currentMonthKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.string(from: Date())
    }

    private func currentWeekKey() -> String { Self.staticWeekKey() }

    private static func staticWeekKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-ww"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }
}
