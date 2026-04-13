import Foundation

// MARK: - TaskData

struct TaskData: Codable {
    let id: String
    let title: String
    let subtitle: String
    let image: String
    let winPoints: String
    let ownerLabel: String
    let clothReward: Int
}

extension TaskData {
    /// Tâche spéciale achetée avec des cloths — jour sans obligation
    static let luckyDay = TaskData(
        id: "lucky_day",
        title: "Day-Off",
        subtitle: "TODAY IS YOUR DAY OFF",
        image: "mouth2",
        winPoints: "FREE DAY",
        ownerLabel: "YOUR DAY-OFF",
        clothReward: 0
    )

    static let all: [TaskData] = [
        TaskData(id: "daily_cleaning", title: "Cleaning",
                 subtitle: "KITCHEN, BEDROOM & TOILETS",
                 image: "task_cleaning", winPoints: "WIN : 5", ownerLabel: "", clothReward: 5),
        TaskData(id: "do_dishes", title: "Dishes",
                 subtitle: "MUGS, PLATES, CUTLERY...",
                 image: "task_dishes", winPoints: "WIN : 2", ownerLabel: "", clothReward: 2),
        TaskData(id: "grocery", title: "Groceries",
                 subtitle: "PICK-UP STEAK, FRIES...",
                 image: "task_grocery", winPoints: "WIN : 4", ownerLabel: "", clothReward: 4),
        TaskData(id: "vacuum", title: "Vacuum",
                 subtitle: "COMMON ROOM",
                 image: "task_vacuum", winPoints: "WIN : 3", ownerLabel: "", clothReward: 3),
    ]
}

// MARK: - AvatarInfo

struct AvatarInfo {
    let id: String
    let name: String
    let ownerLabel: String
    let isMe: Bool
}

extension AvatarInfo {
    static let all: [AvatarInfo] = [
        AvatarInfo(id: "avatar1", name: "Ethan",  ownerLabel: "",             isMe: true),
        AvatarInfo(id: "avatar2", name: "Laura",  ownerLabel: "LAURA'S TASK", isMe: false),
        AvatarInfo(id: "avatar3", name: "Lea",    ownerLabel: "LEA'S TASK",   isMe: false),
        AvatarInfo(id: "avatar4", name: "James",  ownerLabel: "JAMES'S TASK", isMe: false),
    ]

    static func info(for avatarId: String) -> AvatarInfo {
        all.first { $0.id == avatarId } ?? all[0]
    }
}
