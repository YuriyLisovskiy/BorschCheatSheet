import SwiftUI

struct SLMenuItemView: View {
    let item: SLMenuItem
    
    @State private var code: String = ""

    var body: some View {
        if item.source != nil {
            NavigationLink(destination: CodeEditorView(sourceFile: item.source!, loadSource: true)) {
                Image(systemName: "doc.plaintext")
                Text(item.source?.title ?? "")
            }
        }
        else if item.submenu != nil {
            NavigationLink(destination: SLMenuView(menu: item.submenu ?? SLMenu())) {
                Image(systemName: "shippingbox")
                Text(item.submenu?.title ?? "")
            }
        }
    }
}

struct SLMenuView: View {
    let menu: SLMenu

    var body: some View {
        List {
            if menu.sections.count > 0 {
                ForEach(menu.sections) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.items) { item in SLMenuItemView(item: item) }
                    }
                }
            }

            if menu.items.count > 0 {
                ForEach(menu.items) { item in SLMenuItemView(item: item) }
            }
        }
        .navigationBarTitle(menu.title)
    }
}

struct StdLibraryMenuView: View {
    let menu = Bundle.main.decodeJson(SLMenu.self, from: "std_library_menu.json")

    var body: some View {
//        NavigationView {
            SLMenuView(menu: menu)
//                .navigationBarTitle("Стандартні пакети")
//        }
//        .phoneOnlyStackNavigationView()
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        StdLibraryMenuView()
    }
}
