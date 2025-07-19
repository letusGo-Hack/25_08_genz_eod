//
//  NavigationHeader.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import SwiftUI

struct NavigationHeader: View {
    let onBack: () -> Void
    let onIconImageClicked: () -> Void
    
    var body: some View {
        ZStack {
            Text("퇴근 시간 설정")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
            
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                NavigationLink {
                    PremiumCalendarView()
                } label: {
                    Image(systemName: "calendar")
                        .foregroundColor(.accent)
                }
            }
        }
        .padding()
        .background(Color.white)
    }
}

#Preview {
    NavigationHeader {
        
    } onIconImageClicked: {
        
    }

}
