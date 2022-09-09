import SwiftUI

struct OutputSheet: View {
    @State private var showingErrorAlert = false
    @State private var errorAlertMessage = ""
    
    var code: String = ""
    @State private var consoleOutputRows: [String] = []
    @State private var exitCode: Int64 = Int64.min
    
    private enum ExecutionState {
        case Starting, Running, Finished, StartingError, RunningError
    }
    
    @State private var execState: ExecutionState = ExecutionState.Starting
    
    @Environment(\.dismiss) var dismiss
    
    private func runCode(code: String) {
        self.execState = ExecutionState.Starting
        self.consoleOutputRows = []
        self.exitCode = Int64.min
        PlaygroundApi.createJob(langVersion: "0.1.0", sourceCode: code) { result in
            switch result {
            case .success(let resultObj):
                self.execState = ExecutionState.Running
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
                        if self.execState == ExecutionState.Running {
                            PlaygroundApi.getOutput(jobId: resultObj.jobId, offset: self.consoleOutputRows.count) { innerResult in
                                switch innerResult {
                                case .success(let output):
                                    self.consoleOutputRows.append(contentsOf: output.rows.map{ row in row.text })
                                    if output.exitCode != nil {
                                        self.execState = ExecutionState.Finished
                                        self.exitCode = output.exitCode!
                                    }
                                case .failure(let error):
                                    print("Request failed with error: \(error)")
                                    self.execState = ExecutionState.RunningError
                                    self.errorAlertMessage = error.localizedDescription
                                    self.showingErrorAlert = true
                                }
                            }
                        }
                        else {
                            timer.invalidate()
                        }
                    })
                }
            case .failure(let error):
                self.execState = ExecutionState.StartingError
                print("Request failed with error: \(error)")
                self.errorAlertMessage = error.localizedDescription
                self.showingErrorAlert = true
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                switch self.execState {
                case .Starting:
                    ProgressView().onAppear {
                        self.runCode(code: self.code)
                    }
                    Text("Очікування запуску...")
                case .Running, .Finished:
                    Text(self.consoleOutputRows.joined(separator: "\n"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .font(Font.body.monospaced())
                    if self.execState == .Running {
                        ProgressView()
                    }
                    Spacer()
                case .StartingError, .RunningError:
                    Button(action: { self.runCode(code: self.code) }) {
                        Image(systemName: "gobackward")
                            .font(Font.body.weight(.semibold))
                        Text("Повторити запуск")
                    }
                }
            }
            .navigationBarTitle("Вивід", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if self.execState == .Finished {
                        Button(action: { self.runCode(code: self.code) }) {
                            Image(systemName: "gobackward")
                                .font(Font.body.weight(.semibold))
                        }
                    }
                }
                
                ToolbarItem(placement: .status) {
                    if self.execState == .Finished {
                        Text("Програму завершено з кодом \(self.exitCode)")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .font(Font.body.weight(.semibold))
                        Text("Назад")
                    }
                }
            }
            .alert("Помилка", isPresented: $showingErrorAlert, actions: {
                Button("Запустити знову") {
                    self.runCode(code: self.code)
                }
                Button("Закрити", role: .cancel, action: {})
            }, message: { Text(self.errorAlertMessage) })
        }
    }
}

//struct OutputSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        OutputSheet(code: "друкр(\"Привіт, Світе!\");")
//    }
//}
