//
//  EditorView.swift
//  Borsch Cheat Sheet
//
//  Created by Yuriy Lisovskiy on 15.09.2022.
//

import SwiftUI

struct EditorView: View {
    var body: some View {
//        NavigationView {
            VStack {
                Text("Фрагменти коду відсутні")
                    .font(.title2).fontWeight(.medium)
                    .foregroundColor(Color(UIColor.systemGray))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: {
                        let slSource = SLSource(title: "Редактор", filename: "__вхід__", readonly: false, code: "друкр(\"Привіт, Світе!\");")
                        CodeEditorView(sourceFile: slSource, loadSource: false)
                    }) {
                        Image(systemName: "doc.fill.badge.plus")
                    }
                }
            }
//            .navigationBarTitle("Огляд", displayMode: .inline)
//        }
//        .phoneOnlyStackNavigationView()
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
