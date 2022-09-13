//
//  TutorialView.swift
//  Learn Borsch
//
//  Created by Yuriy Lisovskiy on 11.09.2022.
//

import SwiftUI
import HighlightedTextEditor

struct CodePreviewView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var text: String = ""
    
    private let rules: [HighlightRule] = [
        HighlightRule(pattern: .all, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: defaultColor),
        ]),
        HighlightRule(pattern: numberLiteral, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(hex: "#6897bbff")),
        ]),
        HighlightRule(pattern: variable, formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: defaultColor),
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
            .introspect { editor in
                // access underlying UITextView or NSTextView
                editor.textView.font = UIFont.monospacedSystemFont(ofSize: UIFont.labelFontSize, weight: .regular)
                editor.textView.backgroundColor = UIColor(hex: "#2b2b2bff")
                editor.textView.autocapitalizationType = .none
                editor.textView.isEditable = false
                editor.textView.autocorrectionType = .no
            }
    }
}

struct TutorialItemView: View {
    let title: String
    let text: String
    let note: String
//    let code: String
    
    @State var code = ""
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(try! AttributedString(markdown: self.text)).padding()
            }
            .background(.gray.opacity(0.15))
            .cornerRadius(5)
            .padding()
            
            CodePreviewView(text: self.code)
                .overlay(alignment: .bottom) {
                    let slSource = SLSource(title: "Редактор", filename: self.title.replacingOccurrences(of: " ", with: "_").lowercased(), readonly: false, code: self.code)
                    NavigationLink("Відкрити редактор", destination: CodeEditorView(sourceFile: slSource, loadSource: false))
                        .buttonStyle(.borderedProminent)
                        .padding()
                }
                .frame(height: 120)
                .cornerRadius(5)
                .padding(.horizontal)
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "info.circle").padding(.leading)
                    Text(try! AttributedString(markdown: self.note)).padding(.vertical).padding(.trailing)
                }
                .background(.blue.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(5)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarTitle(self.title, displayMode: .inline)
        Spacer()
        Button("Завершити") {
            print("Завершити!")
        }
        .buttonStyle(.borderedProminent)
        .font(.title2)
        .padding()
    }
}

struct TutorialView: View {
    var body: some View {
        List {
            Section("Основні поняття") {
                NavigationLink("Вступ - \"Привіт, Світе!\"") {
                    TutorialItemView(title: "Вступ - \"Привіт, Світе!\"", text: "Розпочнемо з короткої програми, яка відображає рядок \"Привіт, Світе!\". У мові Борщ, ми використаємо функцію **друкр**, щоб вивести текст.", note: "_Про функції буде йти мова пізніше._", code: "друкр(\"Привіт, Світе!\");")
                }
                NavigationLink("Прості Операції") {
                    TutorialItemView(title: "Прості Операції", text: "Розпочнемо з короткої програми, яка відображає рядок \"Привіт, Світе!\". У мові Борщ, ми використаємо функцію **друкр**, щоб вивести текст.", note: "_Про функції буде йти мова пізніше._", code: "друкр(\"Привіт, Світе!\");")
                }
            }
        }
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
    }
}
