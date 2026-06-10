import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ReviewViewModel()

    var body: some View {
        Group {
            switch vm.screen {
            case .home:
                HomeView(vm: vm)
            case .setup:
                SetupView(vm: vm)
            case .review:
                ReviewView(vm: vm)
            case .debrief:
                DebriefView(vm: vm)
            case .complete:
                CompletionView(vm: vm)
            }
        }
        .animation(.easeInOut, value: vm.screen)
    }
}
