import SwiftUI

struct MenuItemView: View {
    let item: MenuItem

    var body: some View {
        if item.source != nil {
            NavigationLink(item.source?.filename ?? "", destination: CodeEditorView(sourceFile: item.source ?? Source()))
        }
        else if item.submenu != nil {
            NavigationLink(item.submenu?.title ?? "", destination: MenuView(menu: item.submenu ?? Menu()))
        }
    }
}

struct MenuView: View {
    let menu: Menu

    var body: some View {
        List {
            if menu.sections.count > 0 {
                ForEach(menu.sections) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.items) { item in MenuItemView(item: item) }
                    }
                }
            }

            if menu.items.count > 0 {
                ForEach(menu.items) { item in MenuItemView(item: item) }
            }
        }
                .navigationTitle(menu.title)
    }
}

struct MainView: View {
    let menu = Bundle.main.decode(Menu.self, from: "menu.json")

    var body: some View {
        NavigationView {
            MenuView(menu: menu)
                    .navigationTitle(menu.title)
                    .listStyle(.grouped)
        }
    }
}
