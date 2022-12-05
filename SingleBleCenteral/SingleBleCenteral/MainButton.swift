//
//  MainButton.swift
//  SingleBleCenteral
//
//  Created by Navpreet Kaur on 1/12/2022.
//

import SwiftUI

struct MainButton: View {

    var text: String

    var body: some View {
        Text(text)
            .font(.title2)
            .padding()
            .foregroundColor(.black)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white, lineWidth: 2)
                    .background(Color.white.cornerRadius(25))
            )
    }
}

struct MainButton_Previews: PreviewProvider {
    static var previews: some View {
        MainButton(text: "test")
    }
}
