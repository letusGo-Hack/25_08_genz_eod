//
//  CongratulationsAlertView.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import SwiftUI
import Lottie

struct CongratulationsAlertView: View {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismissal by tapping background
                }
            
            // Alert Content
            VStack(spacing: 10) {
                // Lottie Animation
                LottieView(animation: .named("Congratulations"))
                    .playing(loopMode: .loop)
                    .frame(width: 200, height: 200)
                
                // Title
                Text("퇴근 완료! 🎉")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                // Message
                Text("오늘도 수고하셨습니다")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Dismiss Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                        onDismiss()
                    }
                }) {
                    Text("확인")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
            .scaleEffect(isPresented ? 1.0 : 0.8)
            .opacity(isPresented ? 1.0 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
        }
    }
}
