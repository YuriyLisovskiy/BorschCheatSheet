import SwiftUI

struct RunResult: Identifiable, Codable {
    var id: String {
        UUID().uuidString
    }
    
    let error: String
    let output: String
    
    enum CodingKeys: String, CodingKey {
        case error
        case output
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        error = try values.decode(String.self, forKey: .error)
        output = try values.decode(String.self, forKey: .output)
    }
}

struct OutputSheet: View {
    var code: String = ""
    @State var output: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    public func runCode(code: String) {
        Task {
            var codeArg = code.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            codeArg = codeArg?.replacingOccurrences(of: ";", with: "%3B")
            guard let url = URL(string: "http://127.0.0.1:8080/run?code=\(codeArg!)") else { return }

            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(RunResult.self, from: data)
            print("===")
            print(result.id)
            print(result.output)
            print(result.error)
            print("===")
            output = result.id
        }
    }
    
    var body: some View {
        VStack {
            Button("Run") {
                self.runCode(code: code)
            }
            .font(.title)
            
            Button("Press to dismiss") {
                dismiss()
            }
            .font(.title)
            .padding()
            
            Text(output)
        }
        .onAppear {
            self.runCode(code: self.code)
        }
    }
}

//struct OutputSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        OutputSheet(code: "друкр(\"Привіт, Світе!\");")
//    }
//}
