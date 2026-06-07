import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ReviewViewModel()

    var body: some View {
        Group {
            if vm.isComplete {
                CompletionView(vm: vm)
            } else if vm.isRunning || vm.isPaused {
                ReviewView(vm: vm)
            } else {
                SetupView(vm: vm)
            }
        }
        .animation(.easeInOut, value: vm.isRunning)
        .animation(.easeInOut, value: vm.isComplete)
    }
}
