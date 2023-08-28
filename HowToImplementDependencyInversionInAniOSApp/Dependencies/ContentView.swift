//
//  ContentView.swift
//  Dependencies
//

import ModuleA
import ModuleB
import SwiftUI

struct ContentView: View {
    var body: some View {
        RandomNumberView(
            numberGenerator: ModuleB()
        )
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
