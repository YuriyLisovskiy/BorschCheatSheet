import Foundation
import SwiftUI
import HighlightedTextEditor

let keywords = try! NSRegularExpression(pattern: "блок|заключний|клас|кінець|лямбда|небезпечно|нуль|панікувати|перервати|повернути|піймати|функція|хиба|цикл|якщо|інакше|істина|<лямбда>", options: [])
let singleLineComment = try! NSRegularExpression(pattern: "//[^\\n]*", options: [])
let multilineComment = try! NSRegularExpression(pattern: "/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/", options: [])
let numberLiteral = try! NSRegularExpression(pattern: "\\d+", options: [])
let stringLiteral = try! NSRegularExpression(pattern: "\"[^\"]*\"", options: [])
let functionDefinition = try! NSRegularExpression(pattern: "функція \\w[\\d\\w_]*", options: [])
let specialNames = try! NSRegularExpression(pattern: "__оператор_степеня__|__оператор_ділення_за_модулем__|__оператор_суми__|__оператор_різниці__|__оператор_добутку__|__оператор_частки__|__оператор_мінус__|__оператор_плюс__|__оператор_і__|__оператор_або__|__оператор_не__|__оператор_побітового_не__|__оператор_зсуву_ліворуч__|__оператор_зсуву_праворуч__|__оператор_побітового_і__|__оператор_побітового_XOR__|__оператор_побітового_або__|__оператор_рівності__|__оператор_нерівності__|__оператор_більше__|__оператор_більше_або_дорівнює__|__оператор_менше__|__оператор_менше_або_дорівнює__|__конструктор__|__оператор_виклику__|__довжина__|__логічне__|__рядок__|__представлення__|__пакет__|__атрибути__|__документ__|__експортовані__", options: [])
let classDefinition = try! NSRegularExpression(pattern: "клас [\\w_][\\d\\w_]*", options: [])
let typeUsage = try! NSRegularExpression(pattern: ":\\s*[\\w_][\\d\\w_]*", options: [])
let functionCall = try! NSRegularExpression(pattern: "\\w[\\d\\w_]*\\(", options: [])
let specialSymbol = try! NSRegularExpression(pattern: ",|;", options: [])
let otherSpecificSymbols = try! NSRegularExpression(pattern: ":|\\(", options: [])

let keywordColor = UIColor(hex: "#cb7832ff")
let specialVarOrFuncColor = UIColor(hex: "#ff5261ff")
let defaultColor = UIColor(hex: "#a9b7c5ff")
let typeColor = UIColor(hex: "#6eafbdff")
let commentColor = UIColor(hex: "#808080ff")

struct CodeEditorView: View {
    let sourceFile: Source

    @State private var text: String
    @State private var running: Bool = false

    init(sourceFile: Source, readonly: Bool = false) {
        self.sourceFile = sourceFile
        text = sourceFile.code
    }

    private let rules: [HighlightRule] = [
        HighlightRule(pattern: .all, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: defaultColor),
        ]),
        HighlightRule(pattern: numberLiteral, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(hex: "#6897bbff")),
        ]),
        HighlightRule(pattern: functionCall, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(hex: "#b09d79ff")),
        ]),
        HighlightRule(pattern: functionDefinition, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(hex: "#ffc66dff")),
        ]),
        HighlightRule(pattern: specialNames, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: specialVarOrFuncColor),
        ]),
        HighlightRule(pattern: classDefinition, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: typeColor),
        ]),
        HighlightRule(pattern: typeUsage, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: typeColor),
        ]),
        HighlightRule(pattern: otherSpecificSymbols, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: defaultColor),
        ]),
        HighlightRule(pattern: specialSymbol, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(hex: "#cb7832ff")),
        ]),
        HighlightRule(pattern: stringLiteral, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(hex: "#6a8759ff")),
        ]),
        HighlightRule(pattern: singleLineComment, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: commentColor),
        ]),
        HighlightRule(pattern: multilineComment, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: commentColor),
        ]),
        HighlightRule(pattern: keywords, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: keywordColor),
        ])
    ]

    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: rules)
                .onCommit {
                    print("commited")
                }
                .onEditingChanged {
                    print("editing changed")
                }
                .onTextChange {
                    print("latest text value", $0)
                }
                .onSelectionChange { (range: NSRange) in
                    print(range)
                }
                .introspect { editor in
                    // access underlying UITextView or NSTextView
                    editor.textView.backgroundColor = UIColor(hex: "#2b2b2bff")
                    editor.textView.autocapitalizationType = .none
                    editor.textView.isEditable = !sourceFile.readonly
                }
                .navigationBarTitle(sourceFile.filename/*, displayMode: .inline*/)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { print("share") }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Button(action: { print("SEARCH!") }) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        if !sourceFile.readonly {
                            Button(action: { print("!") }) {
                                Image(systemName: "arrow.right.to.line")
                            }
                            Button(action: { print("!") }) {
                                Image(systemName: "arrow.uturn.backward")
                            }
                            Button(action: {  }) {
                                Image(systemName: "arrow.uturn.forward")
                            }
                            Spacer()
                            Button(action: { running.toggle() }) {
                                Image(systemName: running ? "stop.fill" : "play.fill")
                                        .foregroundColor(running ? Color.red : Color.green)
                            }
                            Spacer()
                            Button(action: { print("!") }) {
                                Image(systemName: "xmark")
                            }
                            Button(action: { print("!") }) {
                                Image(systemName: "arrow.left")
                            }
                            Button(action: { print("!") }) {
                                Image(systemName: "arrow.right")
                            }
                        }
                    }
                }
    }
}
