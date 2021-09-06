//
//  ResetPassword.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 9/5/21.
//

import SwiftUI
import Firebase

struct ResetPassword: View {
    @Binding var resetPasswordView: Bool
    @State private var email: String = ""
    var body: some View {
        TextField("Email", text: $email)
            .padding()
            .keyboardType(.emailAddress)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .padding(.horizontal, UIScreen.main.bounds.size.width * 0.05)
        Button(action: {
            resetPassword()
        }, label: {
            Text("Reset password")
        })
    }
    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email, completion: { error in
            if error != nil {
                print("error\(error.debugDescription)" )
            } else {
                resetPasswordView = false
            }
        })
    }
}
