struct Menu: Decodable, Identifiable {
    let title: String
    let sections: [MenuSection]
    let items: [MenuItem]

    var id: String {
        title
    }

    enum CodingKeys: String, CodingKey {
        case title
        case sections
        case items
    }

    init() {
        title = ""
        sections = []
        items = []
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        sections = try values.decodeIfPresent([MenuSection].self, forKey: .sections) ?? []
        items = try values.decodeIfPresent([MenuItem].self, forKey: .items) ?? []
    }
}

struct MenuSection: Decodable, Identifiable {
    let title: String
    let items: [MenuItem]

    var id: String {
        title
    }

    enum CodingKeys: String, CodingKey {
        case title
        case items
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        items = try values.decode([MenuItem].self, forKey: .items)
    }
}

struct MenuItem: Decodable, Identifiable {
    let source: Source?
    let submenu: Menu?

    var id: String {
        if source != nil {
            return source?.filename ?? ""
        }

        return submenu?.title ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case title
        case source
        case submenu
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        source = try values.decodeIfPresent(Source.self, forKey: .source)
        submenu = try values.decodeIfPresent(Menu.self, forKey: .submenu)
    }
}

struct Source: Decodable, Equatable, Identifiable {
    let filename: String
    let readonly: Bool
    let code: String

    var id: String {
        filename
    }

    enum CodingKeys: String, CodingKey {
        case filename
        case readonly
        case code
    }

    init() {
        filename = ""
        readonly = false
        code = ""
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        filename = try values.decode(String.self, forKey: .filename)
        readonly = try values.decode(Bool.self, forKey: .readonly)
        code = try values.decode(String.self, forKey: .code)
    }
}
