import UIKit
import SwiftUI

struct OutputSheet: View {
    @State private var showingErrorAlert = false
    @State private var errorAlertMessage = ""
    
    var code: String = ""
    var langVersion: String = ""
    
    struct ShareCode: Identifiable {
        let id = UUID()
        let code: String
    }
    
    @State private var shareCode: ShareCode?
    @State private var isShare = false
    
    struct SharingViewController: UIViewControllerRepresentable {
        @Binding var isPresenting: Bool
        var content: () -> UIViewController

        func makeUIViewController(context: Context) -> UIViewController {
            UIViewController()
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            if isPresenting {
                uiViewController.present(content(), animated: true, completion: nil)
            }
        }
    }
    
    @State private var consoleOutputRows: [String] = []
    @State private var exitCode: Int64 = Int64.min
    @State private var rawOutputUrl: URL? = nil
    
    private enum ExecutionState {
        case Initial, Starting, Running, Finished, StartingError, RunningError
    }
    
    @State private var execState: ExecutionState = .Initial
    
    @Environment(\.presentationMode) var presentationMode
    
    private func loadOutput(jobId: String, offset: Int) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        PlaygroundApi.getOutput(jobId: jobId, offset: offset) { innerResult in
            switch innerResult {
            case .success(let output):
                self.consoleOutputRows.append(contentsOf: output.rows.map{ row in row.text })
                if output.exitCode != nil {
                    self.execState = ExecutionState.Finished
                    self.exitCode = output.exitCode!
                    self.rawOutputUrl = URL(string: "\(PlaygroundApi.ApiV1)/jobs/\(jobId)/output.txt")
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                self.execState = ExecutionState.RunningError
                self.errorAlertMessage = error.localizedDescription
                self.showingErrorAlert = true
            }
            
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            if self.execState == ExecutionState.Running {
                self.loadOutput(jobId: jobId, offset: self.consoleOutputRows.count)
            }
        }
    }
    
    private func runCode(code: String) {
        if self.execState == .Starting || self.execState == .Running {
            return
        }
        
        self.rawOutputUrl = nil
        self.execState = ExecutionState.Starting
        self.consoleOutputRows = []
        self.exitCode = Int64.min
        PlaygroundApi.createJob(langVersion: self.langVersion, sourceCode: code) { result in
            switch result {
            case .success(let resultObj):
                self.execState = ExecutionState.Running
                self.loadOutput(jobId: resultObj.jobId, offset: self.consoleOutputRows.count)
                
//                DispatchQueue.main.async {
//                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
//                        if self.execState == ExecutionState.Running {
//                            self.getOutput(jobId: resultObj.jobId, offset: self.consoleOutputRows.count)
//                        }
//                        else {
//                            timer.invalidate()
//                        }
//                    })
//                }
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
                case .Starting, .Initial:
                    ProgressView("Очікування запуску...").onAppear {
                        self.runCode(code: self.code)
                    }
                case .Running, .Finished:
                    Text(self.consoleOutputRows.joined(separator: "\n"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .font(Font.body.monospaced())
                    if self.execState == .Running {
                        ProgressView("Виконується...")
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.isShare = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(self.execState != .Finished || self.rawOutputUrl == nil)
                    .background(SharingViewController(isPresenting: self.$isShare) {
                        let av = UIActivityViewController(activityItems: [self.rawOutputUrl!], applicationActivities: nil)
                         
                         // For iPad
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            av.popoverPresentationController?.sourceView = UIView()
                        }

                        av.completionWithItemsHandler = { _, _, _, _ in
                            self.isShare = false // required for re-open !!!
                        }
                        
                        return av
                    })
                }
                
                ToolbarItem(placement: .status) {
                    if self.execState == .Finished {
                        Text("Програму завершено з кодом \(self.exitCode)")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрити", role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
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
