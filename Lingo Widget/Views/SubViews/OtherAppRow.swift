//
//  OtherAppRow.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 30.12.2024.
//


import SwiftUI

struct OtherAppRow: View {
    
    let icon: String
    let title: String
    let subtitle: String
    let appStoreUrl: String
    
    @EnvironmentObject var localeManager: LocaleManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                if let url = URL(string: appStoreUrl) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("GET".localized(language: localeManager.currentLocale))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.blue)
                    .cornerRadius(14)
            }
        }
    }
}

struct OtherAppRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OtherAppRow(
                icon: "kalory_icon",
                title: "Kalory",
                subtitle: "AI Calorie Tracker",
                appStoreUrl: "a"
            )
            OtherAppRow(
                icon: "iread_icon",
                title: "iRead",
                subtitle: "Minimalist Reader",
                appStoreUrl: "b"
            )
        }
        .padding()
        .background(Color("backgroundColor"))
        .previewLayout(.sizeThatFits)
        .environmentObject(LocaleManager())
    }
}
