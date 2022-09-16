//
//  HomeView.swift
//  Borsch Cheat Sheet
//
//  Created by Yuriy Lisovskiy on 15.09.2022.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Борщ - це мова програмування інтерпретованого типу, яка дозволяє писати код українською мовою.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .navigationBarTitle("Домівка")
                .phoneOnlyStackNavigationView()
            Spacer()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
