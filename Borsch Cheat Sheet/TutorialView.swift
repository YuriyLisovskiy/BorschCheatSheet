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
    
    @State private var showingEditor: Bool = false
    
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
            .overlay(alignment: .bottom) {
                Button("???????????????? ????????????????") {
                    self.showingEditor = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .sheet(isPresented: self.$showingEditor, content: {
                NavigationView {
                    CodeEditorView(sourceFile: SLSource(title: "????????????????", filename: "", readonly: false, code: self.text), loadSource: false)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("??????????????") {
                                    self.showingEditor = false
                                }
                            }
                        }
                }
                .phoneOnlyStackNavigationView()
                .padding(.vertical)
            })
    }
}

struct TutorialView: View {
    let sections: [SectionModel]

    init() {
        self.sections = Bundle.main.decodeYaml([SectionModel].self, from: "cheatsheet.yaml")
        print("Read \(self.sections.count) items")
    }
    
    struct SectionModel: Decodable, Identifiable {
        var id: String {
            title
        }
        
        let title: String
        let pages: [PageModel]
    }
    
    struct PageModel: Decodable, Identifiable {
        var id: String {
            title
        }
        
        let title: String
        let contents: [ContentModel]?
        let pages: [PageModel]?
        let sections: [SectionModel]?
        
        var finished: Bool {
            get {
                false
            }
            set(newFinished) {
            }
        }
    }

    struct ContentModel: Decodable {
        let type: String
        let text: String
        let previewHeight: Int?
    }
    
    struct SectionView: View {
        let section: SectionModel
        
        var body: some View {
            ForEach(self.section.pages) { pageItem in
                NavigationLink(pageItem.title) {
                    PageView(page: pageItem)
                        .navigationBarTitle(pageItem.title)
                }
            }
        }
    }
    
    struct PageView: View {
        let page: PageModel
        
        var body: some View {
            if self.page.contents != nil {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(Array(self.page.contents!.enumerated()), id: \.offset) { _, contentItem in
                            PageContentView(content: contentItem)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationBarTitle(self.page.title, displayMode: .inline)
                Spacer()
            }
            else if self.page.pages != nil {
                List {
                    ForEach(self.page.pages!) { pageItem in
                        NavigationLink(pageItem.title) {
                            PageView(page: pageItem).navigationBarTitle(pageItem.title)
                        }
                    }
                }
            }
            else if self.page.sections != nil {
                List {
                    ForEach(self.page.sections!) { sectionItem in
                        Section(sectionItem.title) {
                            SectionView(section: sectionItem)
                        }
                    }
                }
            }
        }
    }
    
    struct PageContentView: View {
        let content: ContentModel
        
        @State private var showingEditor: Bool = false
        
        private var codePreviewHeight: CGFloat {
            CGFloat(self.content.previewHeight ?? 120)
        }
        
        var body: some View {
            switch self.content.type {
            case "text", "title":
                Text(self.content.text.toMarkdown())
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case "divider":
                Divider()
            case "code":
                CodePreviewView(text: self.content.text)
                    .frame(height: self.codePreviewHeight)
                    .cornerRadius(5)
                    .padding(.horizontal)
            case "note":
                HStack {
                    Image(systemName: "info.circle")
                        .padding(.leading)
                    Text(self.content.text.toMarkdown())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical)
                        .padding(.trailing)
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBlue))
                .foregroundColor(.white)
                .cornerRadius(5)
                .padding(.horizontal)
            default:
                EmptyView()
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(self.sections) { sectionItem in
                Section(sectionItem.title) {
                    SectionView(section: sectionItem)
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
