//
//  WorkerBookingCard.swift
//  IOS_CW2_Supportives
//
//  Created by user3 on 08/05/2026.
//

import SwiftUI

struct WorkerBookingCard: View {
    let name: String
    let distance: String
    let image: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .cornerRadius(16)
            
            Text(name)
                .font(.headline)
            
            Text(distance)
                .font(.caption)
                .foregroundColor(.gray)
            
            Button("View Profile") {}
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.top, 6)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 2)
    }
}
