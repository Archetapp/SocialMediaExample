//
//  SignInView.swift
//  SocialMediaApp
//
//  Created by Jared on 4/2/20.
//  Copyright © 2020 Davidson Family. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignInView: View {
    @State var email : String = ""
    @State var password : String = ""
    @State private var login : Bool = false
    @State var isPresented = false
    @State var error : Bool = false
    @State var errorMessage : String = ""
    
    
    
    var UsernameField = CustomTextField(placeholderString: "Email")
    var PasswordField = CustomTextField(placeholderString: "Password")
    
    var LoginButton = CustomButton(title : "Log In")
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Text("Social Media")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Image("SME").resizable().frame(width: 100, height: 100, alignment: .center)
                HStack {
                    VStack {
                        TextField("Email", text: $email)
                            .padding([.horizontal], 10)
                            .textContentType(.emailAddress)
                    }
                        .padding(.vertical)
                        .background(BlurView(style: .systemThinMaterial))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black, radius: 2, x: 0, y: 0)
                        .padding()
                }
                HStack {
                    VStack {
                        TextField("Password", text: $password)
                            .padding([.horizontal], 10)
                            .textContentType(.password)
                    }
                        .padding(.vertical)
                        .background(BlurView(style: .systemThinMaterial))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black, radius: 2, x: 0, y: 0)
                        .padding()
                }
                Text(UsernameField.text + PasswordField.text)
                Spacer()
                LoginButton
                    .onTapGesture {
                        withAnimation {

                           self.Login(completion: { (loggedIn, error) in
                            if loggedIn == true {
                                self.isPresented = true
                            } else {
                                self.isPresented = false
                                self.error = true
                                self.errorMessage = error
                            }
                        })
                    }
                }.frame(width: 200, height: nil, alignment: .bottom).alert(isPresented: $error) { () -> Alert in
                    self.error = false
                    return Alert(title: Text(errorMessage))
                }
            }
            ZStack {
                Spacer()
                ContentView().edgesIgnoringSafeArea(.all).frame(width: UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.frame.width, height: UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.frame.height, alignment: .leading)
                Spacer()
            }.background(Color.white).offset(x: 0, y: isPresented ? 0 : UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.frame.height  ?? 0).edgesIgnoringSafeArea([.horizontal])
        }
        
    }
    func Login(completion: @escaping(Bool, String) -> ()) {
        Firebase.Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            //.signIn(withEmail: self.email, password: self.password) { (result, error) in
            if error != nil {
                completion(false, String(error.debugDescription.description))
            } else {
                self.login.toggle()
                mainUser = result?.user
                completion(true, String(error.debugDescription))
            }
        }
    }

}


struct CustomButton : View {
    @State var text : String = ""
    
    init(title : String) {
        text = title
    }
    
    var body : some View {
        HStack {
            VStack {
                Button(action: pressedLogin, label: { Text(text)})
                    .frame(width: 200, height: 30, alignment: .center)
                    .accentColor(.blue)
            }
                .foregroundColor(.blue)
                .padding(.vertical)
                .background(BlurView(style: .systemThinMaterial))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                .shadow(color: .black, radius: 2, x: 0, y: 0)
                .padding()
        }
    }
    func pressedLogin() {

    }
}

struct CustomTextField : View {
    @State var text : String = ""
    var placeholder : String = ""
    
    init(placeholderString : String) {
        placeholder = placeholderString
    }
    
    var body : some View {
        HStack {
            VStack {
                TextField(placeholder, text: $text)
                    .padding([.horizontal], 10)
            }
                .padding(.vertical)
                .background(BlurView(style: .systemThinMaterial))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black, radius: 2, x: 0, y: 0)
                .padding()
        }
    }
}


struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

struct BlurView: UIViewRepresentable {
    
    let style: UIBlurEffect.Style
    
    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
        return view
    }
    
    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<BlurView>) {
    }
}
