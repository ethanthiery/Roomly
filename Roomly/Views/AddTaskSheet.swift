import SwiftUI

// MARK: - Suggested Task Model

struct SuggestedTask: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let imageName: String
    let clothReward: Int

    static let all: [SuggestedTask] = [
        SuggestedTask(id: "mopping",  title: "Mopping",  subtitle: "All common areas",  imageName: "serpillerito", clothReward: 3),
        SuggestedTask(id: "trash",    title: "Trash",    subtitle: "Empty every bin",   imageName: "poubelito",    clothReward: 2),
        SuggestedTask(id: "laundry",  title: "Laundry",  subtitle: "Wash & fold",       imageName: "chiffonito",   clothReward: 4),
        SuggestedTask(id: "ironing",  title: "Ironing",  subtitle: "Shirts & pants",    imageName: "ferito",       clothReward: 3),
        SuggestedTask(id: "windows",  title: "Windows",  subtitle: "Inside & outside",  imageName: "carreausito",  clothReward: 4),
        SuggestedTask(id: "plants",   title: "Plants",   subtitle: "All rooms",         imageName: "arrosito",     clothReward: 2),
        SuggestedTask(id: "fridge",   title: "Fridge",   subtitle: "Shelves & drawers", imageName: "frigorito",    clothReward: 4),
        SuggestedTask(id: "cooking",  title: "Cooking",  subtitle: "For all roommates", imageName: "placito",      clothReward: 5),
        SuggestedTask(id: "bathroom", title: "Bathroom", subtitle: "Full scrub",        imageName: "douchito",     clothReward: 5),
        SuggestedTask(id: "pantry",   title: "Pantry",   subtitle: "Sort & restock",    imageName: "placarito",    clothReward: 3),
    ]
}

// MARK: - Sheet

struct AddTaskSheet: View {
    /// Optionnel : appelé à la place du manager quand la sheet est présentée localement (ex: ClothWalletView)
    var localDismiss: (() -> Void)? = nil
    @EnvironmentObject var manager: AddTaskSheetManager
    @EnvironmentObject var taskStore: TaskStore

    @State private var searchText = ""
    @State private var selected: SuggestedTask? = nil
    @FocusState private var searchFocused: Bool

    private let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]

    /// Tâches supprimées du jeu converties en SuggestedTask pour apparaître ici
    private var removedTasks: [SuggestedTask] {
        TaskData.all
            .filter { taskStore.isRemoved($0.id) }
            .map { SuggestedTask(id: $0.id, title: $0.title, subtitle: $0.subtitle, imageName: $0.image, clothReward: $0.clothReward) }
    }

    private var allAvailableTasks: [SuggestedTask] {
        SuggestedTask.all + removedTasks
    }

    private var displayedTasks: [SuggestedTask] {
        guard !searchText.isEmpty else { return allAvailableTasks }
        return allAvailableTasks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add a Task")
                        .font(.switzer(28))
                        .foregroundColor(.roomlyBlack)
                    HStack(alignment: .center, spacing: 10) {
                        Image("icon_info")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.roomlyBlack)
                            .padding(6)
                            .background(Color.white)
                            .clipShape(Circle())
                            .roomlyShadow()
                        Text("Browse suggestions or search for a task.")
                            .font(.satoshi(16))
                            .foregroundColor(.roomlyBlack)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                Spacer()
                Button {
                    searchFocused = false
                    if let localDismiss { localDismiss() } else { manager.hide() }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.roomlyBlack)
                        .frame(width: 32, height: 32)
                        .background(Color.roomlyGrey0)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 16)

            Spacer().frame(height: 20)

            // ── Search bar ──
            HStack(spacing: 10) {
                Image("icon_search")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.roomlyGrey25)
                TextField("Search a task…", text: $searchText)
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyBlack)
                    .autocorrectionDisabled()
                    .focused($searchFocused)
                if !searchText.isEmpty {
                    Button { withAnimation { searchText = "" } } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.roomlyGrey25)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.roomlyGrey0)
            .clipShape(Capsule())

            Spacer().frame(height: 20)

            // ── Grille ──
            if displayedTasks.isEmpty {
                Text("No tasks found.")
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyGrey25)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(displayedTasks) { task in
                            SuggestedTaskCard(
                                task: task,
                                isSelected: selected?.id == task.id
                            ) {
                                searchFocused = false
                                withAnimation(.easeInOut(duration: 0.12)) {
                                    selected = selected?.id == task.id ? nil : task
                                }
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                // Tap hors clavier = ferme le clavier
                .onTapGesture {
                    searchFocused = false
                }
            }

            Spacer().frame(height: 16)

            // ── CTA ──
            Button {
                guard let sel = selected else { return }
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                if taskStore.isRemoved(sel.id) {
                    // Tâche supprimée du jeu → on la restaure directement
                    taskStore.restore(sel.id)
                } else {
                    // Nouvelle tâche → on l'ajoute en "en attente"
                    taskStore.addPending(PendingTask(
                        id: sel.id,
                        title: sel.title,
                        imageName: sel.imageName,
                        clothReward: sel.clothReward
                    ))
                }
                if let localDismiss { localDismiss() } else { manager.hide() }
            } label: {
                Text(selected != nil
                     ? "ADD \"\(selected!.title.uppercased())\""
                     : "PICK A TASK TO ADD")
                    .font(.switzer(14))
                    .foregroundColor(selected != nil ? .white : Color(hex: "7A7572"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selected != nil ? Color.roomlyBlack : Color(hex: "251819"))
                    .clipShape(Capsule())
            }
            .disabled(selected == nil)

            Spacer().frame(height: 44)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Card (style GameCardView)

private struct SuggestedTaskCard: View {
    let task: SuggestedTask
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button { onTap() } label: {
            VStack(spacing: 8) {
                // Badge WIN centré
                HStack(spacing: 4) {
                    Text("WIN : \(task.clothReward)")
                        .font(.switzer(14))
                        .foregroundColor(.roomlyBlack)
                    Image("chiffon")
                        .resizable().scaledToFit()
                        .frame(width: 18, height: 18)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(Capsule())
                .frame(maxWidth: .infinity, alignment: .center)

                // Illustration
                Spacer(minLength: 0)
                Image(task.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 65)
                Spacer(minLength: 0)

                // Nom
                Text(task.title)
                    .font(.switzer(14))
                    .foregroundColor(.roomlyBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 193, maxHeight: 193)
            .background(isSelected ? Color(hex: "E3EAF0") : Color.roomlyGrey0)
            .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: RoomlyRadius.card)
                    .strokeBorder(isSelected ? Color.roomlyBlack.opacity(0.15) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(RoomlyStaticButtonStyle())
    }
}
