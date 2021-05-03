//
//  ContentView.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 4/26/21.
//

import SwiftUI
import Firebase
import Combine

struct ContentView: View {
    
    
    var body: some View {
        Home()
        
    }
}

struct Home : View {
    
    @State private var show = false
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ??
        false



    
    var body: some View {
        
        NavigationView{
            VStack {
                
                if self.status{
                    Dashboard()
                    
                } else {
                    
                    ZStack {
                        
                        NavigationLink(destination: Register(show: self.$show), isActive: self.$show){
                            Text("")
                        }
                        .hidden()
                        
                        Login(show: self.$show)
                    }
                }
            }
            .onAppear {
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name("status"), object: nil, queue: .main) { _ in
                    
                    self.status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                }
            }
        }
    }
}

struct Login : View {
    
    @State var color = Color.black.opacity(0.7)
    @State var email = ""
    @State var pass = ""
    @State var visible = false
    @Binding var show : Bool
    @State var alert = false
    @State var error = ""
    let time = Date()
    @State var userID: String?

    
    var body: some View {
        ZStack {
            ZStack(alignment: .topTrailing) {
                
                GeometryReader{_ in
                    
                    VStack {
                        
                        Text("Login" )
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(self.color)
                            .padding(.top, 35)
                        
                        TextField("Email", text: self.$email)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color.green : self.color, lineWidth: 2))
                            .padding(.top, 25)
                        
                        HStack(spacing: 20) {
                            VStack {
                                if self.visible {
                                    TextField("Password", text: $pass)
                                } else {
                                    SecureField("Password", text: $pass)
                                }
                            }
                            
                            Button(action: {
                                self.visible.toggle()
                            }) {
                                
                                Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(self.color)
                            }
                            
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 4).stroke(self.pass != "" ? Color.green : self.color ,lineWidth: 2))
                        .padding(.top, 25)
                        
                        HStack{
                            Spacer()
                            
                            Button(action: {
                                
                            }) {
                                Text ("Forgot Password?")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.blue)
                            }
                        }.padding(.top, 20)
                        
                        NavigationView{
                            NavigationLink(destination: Dashboard()){
                                ButtonView()
                                    .onTapGesture {
                                        self.verify()
                                    }
                                
                                
                            }
                        }
                        
                        
                        NavigationView{
                            NavigationLink(destination: Dashboard()){
                                Image("googleLogo")
                                Text("Sign in with Google")
                                    .onTapGesture {
                                        self.verify()
                                    }
                                
                                
                            }
                        }
                        
                        
                    }
                    .padding(.vertical, 25)
                    .frame(width: UIScreen.main.bounds.width - 70)
                    .padding(.horizontal, 25)
                    .padding(.top, 200)
                    
                    Button(action: {
                        self.show.toggle()
                    })
                    {
                        Text("Register")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    
                    
                    
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
            if self.alert{
                
                ErrorView(alert: self.$alert, error: self.$error)
            }
        }
    }
    func verify()  {
        if self.email != "" && self.pass != "" {
            
            Auth.auth().signIn(withEmail: self.email, password: self.pass) {
                (res, err) in
                self.userID = res?.user.uid
                if err != nil {
                    
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                }
              
                
                
                UserDefaults.standard.set(true, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"),
                                                object: nil)
            }
            
        }
        else {
            
            self.error = "All the fields must be filled"
            self.alert.toggle()
        }
        
    }
}

struct Register : View {
    
    @State var color = Color.black.opacity(0.7)
    @State var email = ""
    @State var pass = ""
    @State var name = ""
    @State var height = 0.0
    @State var weight = ""
    @State var confirmPass = ""
    @Binding var show : Bool
    @State var visible = false
    @State var reVisible = false
    @State var alert = false
    @State var error = ""
    @State var expand = false
    @State var metric = false
    @State var verified = false
    @State private var bottomPadding: CGFloat = 0
    @State private var leftPadding: CGFloat = 0
    @State var userID: String?

    
    var db = Firestore.firestore()
    
    var body: some View {

        ZStack{
            
            ZStack(alignment: .topTrailing ) {
             
                GeometryReader{geometry in
                    
                    
                    ScrollView {
                        
                        Text("Create an acount into your accout" )
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(self.color)
                            .padding(.top, 35)
                        
                        TextField("Email", text: self.$email)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color.green :self.color,lineWidth: 2))
                            .padding(.top, 20)
                            .keyboardType(.emailAddress)
                        
                        HStack(spacing: 20) {
                            VStack {
                                if self.visible {
                                    TextField("Password", text: $pass)
                                       
                                } else {
                                    SecureField("Password", text: $pass)
                                }
                            }
                            
                            Button(action: {
                                self.visible.toggle()
                            }) {
                                
                                Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(self.color)
                            }
                            
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 4).stroke(self.pass != "" ? Color.green : self.color ,lineWidth: 2))
                        .padding(.top, 20)
                        
                        HStack(spacing: 20) {
                            VStack {
                                if self.reVisible {
                                    TextField("Confirm Password", text: $confirmPass)
                                } else {
                                    SecureField("Password", text: $confirmPass)
                                }
                            }
                            
                            Button(action: {
                                self.reVisible.toggle()
                            }) {
                                
                                Image(systemName: self.reVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(self.color)
                            }
                            
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 4).stroke(self.confirmPass != "" ? Color.green : self.color ,lineWidth: 2))
                        .padding(.top, 20)
                        
                        TextField("Name", text: self.$name)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 4).stroke(self.name != "" ? Color.green :self.color,lineWidth: 2))
                            .padding(.top, 25)
                        ZStack(alignment: .leading){
                            
                            
                            HStack{
                                Spacer(minLength: 15)
                                if(height == 0){
                                    Text("Height").foregroundColor(.gray)
                                }
                                if !metric {
                                    Text("\(String(format: "%.1f", height)) '").foregroundColor(.black)
                                } else {
                                    Text("\(String(format: "%.1f", height)) cm").foregroundColor(.black)
                                }
                                
                                
                                Menu {
                                    Button(action:{
                                        if metric {
                                            self.height = 0.0}
                                        metric = false
                                        
                                    }){
                                        Text("Imperic").foregroundColor(.black)
                                        Image(systemName: "arrow.down.right.circle")
                                    }
                                    Button(action:{
                                        if !metric{
                                            self.height = 0.0}
                                        metric = true
                                        
                                    }){
                                        Text("Metric")
                                        
                                        Image(systemName: "arrow.up.and.down.circle")
                                    }
                                } label: {
                                    if(metric == false){
                                        Text("Imperic")
                                    } else {
                                        Text("Metric")
                                    }
                                    
                                }
                                .foregroundColor(.black)

                                HeightPicker(metric: $metric, height: $height)
                            }
                        }
                        
                        .background(RoundedRectangle(cornerRadius: 4).stroke(self.height != 0 ? Color.green :self.color,lineWidth: 2))
                        .padding(.top, 20)
                        
                        TextField("Weight", text: self.$weight)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 4).stroke(self.weight != ""  ? Color.green : self.color,lineWidth: 2))
                            .padding(.top, 25)
                            .keyboardType(.decimalPad)
                            .onReceive(Just(weight)) { newValue in
                                            let filtered = newValue.filter { "0123456789".contains($0) }
                                            if filtered != newValue {
                                                self.weight = filtered
                                            }
                                    }

                        NavigationLink(destination: Dashboard(), isActive: $verified) {
                     
                            Text("Register")
                                .padding()
                                .onTapGesture {
                                    self.registerVerification()
                                }
                         
                            
                                
                        }
                        .buttonStyle(ThemeAnimationStyle())

                            
                               
                    }
                    .padding(.horizontal, 25)
            
                    Button(action: {
                        self.show.toggle()
                    })
                    {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.title)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .navigationTitle("")
        }

        
        if self.alert {
            ErrorView(alert: self.$alert, error: self.$error)
        }
        
    }
    
    func registerVerification() {

        
        if self.email != "" {
            
            if self.pass == self.confirmPass {
                Auth.auth().createUser(withEmail: self.email, password: self.pass) {
                    (res, err) in
                    
                    if err != nil {
                        
                        self.error = err!.localizedDescription
                        self.alert.toggle()
                    } else {
                        userID = res?.user.uid
                        db.collection("users").document(userID!).setData([
                            "name": self.name,
                            "height": self.height,
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                verified = true
                                print("Document successfully written!")
                            }
                        }
                    }
                }
            } else {
                self.error = "Password mismatch"
                self.alert.toggle()
            }
        } else {
            self.error = "Please fill a the contents properly"
            self.alert.toggle()
        }
        
        
        
        UserDefaults.standard.set(true, forKey: "status")
        NotificationCenter.default.post(name: NSNotification.Name("status"),
                                        object: nil)
    }

    struct HeightPicker: View {
        
        @State var foot:Int = 0
        @State var inch: Int = 0
        @State var meter: Int = 0
        @State var cm: Int = 0
        @Binding var metric: Bool
        @Binding var height: Double
        
        
        var feet = [Int](0..<10)
        var inches = [Int](0..<12)
        var meters = [Int](0..<3)
        var cms = [Int](0..<100)
        var measurements = ["in", "cm" ]
        
        var body: some View{
            VStack{
                GeometryReader() { geometry in
                    
                    HStack {
                        
                        if !metric {
                            
                            Picker(selection: self.$foot, label: Text("")) {
                                ForEach(0 ..< self.feet.count){ index in
                                    Text("\(self.feet[index])").tag(self.feet[index])
                                }
                            }
                            .onChange(of: foot) { _ in
                                self.height = 0.0
                                self.height = Double((self.foot * 12) + self.inch)
                                print("--> height: \(height)")
                            }
                            .frame(width: geometry.size.width/4,height: geometry.size.height, alignment: .center)
                            .clipped()
                            .scaleEffect(CGSize(width: 1.0, height: 1.0))
                            .pickerStyle(WheelPickerStyle())
                            .scaledToFit()
                            .background(Color.white)
                            
                            Text("\"")
                            
                            
                            Picker(selection: self.$inch, label: Text("")) {
                                ForEach(0 ..< self.inches.count){ index in
                                    Text("\(self.inches[index])").tag(self.inches[index])
                                }
                                
                            }
                            .onChange(of: inch) { _ in
                                self.height = 0.0
                                self.height = Double((self.foot * 12) + self.inch)
                                print("--> height: \(height)")}
                            .frame(width: geometry.size.width/4,height: geometry.size.height, alignment: .center)
                            .clipped()
                            .scaleEffect(CGSize(width: 1.0, height: 1.0))
                            .pickerStyle(WheelPickerStyle())
                            .scaledToFit()
                            .background(Color.white)
                            
                            Text("'")
                            
                            
                        } else if(metric == true) {
                            Picker(selection: self.$meter, label: Text("")) {
                                ForEach(0 ..< self.meters.count){ index in
                                    Text("\(self.meters[index])").tag(self.meters[index])
                                }
                            }
                            .onChange(of: meter) { _ in
                                self.height = 0.0
                                self.height = Double((self.meter * 100) + self.cm)
                                print("--> height: \(height)")}
                            .frame(width: geometry.size.width/4, height: geometry.size.height, alignment: .center)
                            .scaleEffect(CGSize(width: 1.0, height: 1.0))
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                            .scaledToFit()
                            .background(Color.white)
                            
                            
                            Text("m")
                            
                            
                            Picker(selection: self.$cm, label: Text("")) {
                                ForEach(0 ..< self.cms.count){ index in
                                    Text("\(self.cms[index])").tag(self.cms[index])
                                }
                            }
                            .onChange(of: cm) { _ in
                                self.height = 0.0
                                self.height = Double((self.meter * 100) + self.cm)
                                print("--> height: \(height)")
                                
                            }
                            .frame(width: geometry.size.width/4,height: geometry.size.height, alignment: .center)
                            .clipped()
                            .scaleEffect(CGSize(width: 1.0, height: 1.0))
                            .pickerStyle(WheelPickerStyle())
                            .scaledToFit()
                            .background(Color.white)
                            
                            Text("cm")
                        }
                    }
                }.frame(height: 45)
            }
            .frame(height: 45)
            .padding(.top,5)
            .padding(.bottom, 5)
            
        }
    }
    
}

struct ErrorView: View {
    
    @State var color = Color.black.opacity(0.7)
    @Binding var alert : Bool
    @Binding var error : String
    
    var body: some View{
        
        GeometryReader{_ in
            VStack {
                HStack {
                    
                    Text("Error")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.green)
                    
                    Spacer()
                }
                .padding(.horizontal, 25)
                
                Text(self.error)
                    .foregroundColor(self.color)
                    .padding(.top)
                    .padding(.horizontal, 25)
                
                Button(action: {
                    
                    self.alert.toggle()
                    
                }) {
                    Text("Cancel")
                        .foregroundColor(Color.white)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 120)
                    
                }
                .background(Color.red)
                .cornerRadius(10)
                .padding(.top, 25)
            }
            .frame(width: UIScreen.main.bounds.width - 70)
            .background(Color.white)
            .cornerRadius(15)
        }
        .background(Color.black.opacity(0.35).edgesIgnoringSafeArea(.all))
        .padding(.vertical, 350)
        .padding(.horizontal, 35)
        
    }
    
}
struct ButtonView: View {
    var body: some View {
        Text("Sign in")
            .padding(9)
            .background(RoundedRectangle(cornerRadius: 23).stroke(Color.black ,lineWidth: 2))
            .background(Color.black)
            .foregroundColor(Color(red: 133 / 255, green: 147 / 255, blue: 162 / 255))
            .font(.headline)
    }
}

struct ThemeAnimationStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title2)
            .foregroundColor(Color.white)
            .frame(height: 50, alignment: .center)
            .background(configuration.isPressed ? Color.black.opacity(0.5) : Color.black)
            .cornerRadius(8)
            .shadow(color: Color.gray, radius: 10, x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0) //<- change scale value as per need. scaleEffect(configuration.isPressed ? 1.2 : 1.0)
    }
}



