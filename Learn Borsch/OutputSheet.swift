import SwiftUI

struct RunResult: Identifiable, Decodable {
    var id: String {
        UUID().uuidString
    }
    
    let error: String?
    let output: String?
    let exitCode: Int
    
    enum CodingKeys: String, CodingKey {
        case error
        case output
        case exit_code
    }
    
    init(error: String?, output: String?, exitCode: Int) {
        self.error = error
        self.output = output
        self.exitCode = exitCode
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        error = try values.decodeIfPresent(String.self, forKey: .error)
        output = try values.decodeIfPresent(String.self, forKey: .output)
        exitCode = try values.decode(Int.self, forKey: .exit_code)
    }
    
    func makeOutput() -> String {
        var output = ""
        if self.output != nil {
            output = self.output!
        }
        else if self.error != nil {
            output = self.error!
        }
        
        print("===")
        print(self.id)
        print("===")
        
        while output.hasSuffix("\n") {
            output = output.dropSuffix("\n")
        }
        
        return output + (self.exitCode != -99999 ? "\n\n" + "Процес завершено з кодом виходу \(self.exitCode)." : "")
    }
}

struct OutputSheet: View {
    var code: String = ""
    @State var output: String = ""
    @State var result: RunResult?
    
    @Environment(\.dismiss) var dismiss
    
    public func runCode(code: String) {
        self.result = nil
//        guard let url = URL(string: "http://127.0.0.1:8080/run?code=\(code.toBase64())") else { return }
        
//        let task = URLSession.shared.dataTask(with: url) {(data: Data?, response: URLResponse?, error: Error?) in
//            guard
//                error == nil,
//                let data = data
//            else {
//                print(error ?? "Not started.")
//                self.result = RunResult(error: "Not started.", output: "", exitCode: -99999)
//                return
//            }
//
//            self.result = try! JSONDecoder().decode(RunResult.self, from: data)
////                guard let data = data else { return }
////                print(String(data: data, encoding: .utf8)!)
//        }
//
//        task.resume()
        Task {
            guard let url = URL(string: "http://127.0.0.1:8080/run?code=\(code.toBase64())") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            self.result = try JSONDecoder().decode(RunResult.self, from: data)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if result != nil {
                    Text(result!.makeOutput())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .font(Font.body.monospaced())

                    Spacer()
                    Button(action: { self.runCode(code: self.code) }) {
                        Image(systemName: "gobackward")
                            .font(Font.body.weight(.semibold))
                        Text("Запустити знову")
                    }
                }
                else {
                    ProgressView().onAppear {
                        self.runCode(code: self.code)
                    }
                }
            }
            .navigationBarTitle("Вивід", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .font(Font.body.weight(.semibold))
                        Text("Назад")
                    }
                }
            }
        }
    }
}

//struct OutputSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        OutputSheet(code: "друкр(\"Привіт, Світе!\");")
//    }
//}
