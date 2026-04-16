import Foundation
import Combine

class GrindViewModel: ObservableObject {

    // MARK: - Model
    struct MedalRecord: Codable {
        var gold: Int = 0
        var silver: Int = 0
        var bronze: Int = 0
    }

    // Simulated monthly totals for roommates (mirrors LeaderboardData)
    private static let roommateMonthlyTotals: [String: Int] = [
        "avatar2": 34,
        "avatar3": 20,
        "avatar4": 34
    ]

    // MARK: - Published state
    @Published var records: [String: MedalRecord] = [:]

    // MARK: - Init
    init() {
        loadRecords()
        processLastMonthIfNeeded()
    }

    // MARK: - Public API
    func victories(for avatar: String) -> MedalRecord {
        records[avatar] ?? MedalRecord()
    }

    // MARK: - Process last month (called on init)
    func processLastMonthIfNeeded() {
        let monthToProcess = UserDefaults.standard.string(forKey: "lastGrindMonthToProcess") ?? ""
        guard !monthToProcess.isEmpty else { return }

        let alreadyProcessed = UserDefaults.standard.string(forKey: "lastGrindMonthProcessed") ?? ""
        guard monthToProcess != alreadyProcessed else { return }

        // Build rankings for the finished month
        let ethanTotal = UserDefaults.standard.integer(forKey: "lastMonthFinalTotal_avatar1")
        var allTotals: [(avatarId: String, total: Int)] = Self.roommateMonthlyTotals.map { ($0.key, $0.value) }
        allTotals.append(("avatar1", ethanTotal))

        // Sort descending; stable tie-break by avatarId
        let sorted = allTotals.sorted {
            $0.total != $1.total ? $0.total > $1.total : $0.avatarId < $1.avatarId
        }

        // Assign medals — handle ties (same score = same medal)
        var rank = 1
        for i in sorted.indices {
            if i > 0 && sorted[i].total < sorted[i - 1].total {
                rank = i + 1
            }
            let avatarId = sorted[i].avatarId
            var record = records[avatarId] ?? MedalRecord()
            switch rank {
            case 1: record.gold += 1
            case 2: record.silver += 1
            case 3: record.bronze += 1
            default: break
            }
            records[avatarId] = record
        }

        saveRecords()
        UserDefaults.standard.set(monthToProcess, forKey: "lastGrindMonthProcessed")
    }

    // MARK: - Persistence (keyed by year — resets each new year)
    private func currentYearKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return "grindRecords_\(f.string(from: Date()))"
    }

    private func loadRecords() {
        let key = currentYearKey()
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: MedalRecord].self, from: data)
        else {
            // New year or first launch → fresh records
            records = [:]
            return
        }
        records = decoded
    }

    private func saveRecords() {
        let key = currentYearKey()
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
