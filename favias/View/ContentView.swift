import SwiftUI
import Foundation

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirmation: String = ""
    @State private var isRegistering: Bool = false
    @State private var message: String = ""
    @State private var successMessage: String = ""
    @State private var shouldNavigate: Bool = false
    
    // Здесь передаем токен CSRF при создании экземпляра UserService
    private var userService = UserService(csrfToken: "oQ5LGTg4cHgjm_nX6aVCXp4v-N8qldy6iprqWkVLr2cXVtanjGPhHCKwQekgiv5Wl_d9TN2ltxHlrtvl7dikVQ")

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)

                if isRegistering {
                    SecureField("Confirm Password", text: $passwordConfirmation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                }

                Button(isRegistering ? "Register" : "Login") {
                    if isRegistering {
                        userService.registerUser(email: email, password: password, passwordConfirmation: passwordConfirmation) { success, responseMessage in
                            DispatchQueue.main.async {
                                self.message = responseMessage
                                self.successMessage = success ? "Registration Successful" : ""
                                self.shouldNavigate = success
                            }
                        }
                    } else {
                        userService.loginUser(email: email, password: password) { success, responseMessage in
                            DispatchQueue.main.async {
                                self.message = responseMessage
                                self.successMessage = success ? "Login Successful" : ""
                                self.shouldNavigate = success
                            }
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                
                // Отображение сообщений пользователю только в случае, если сообщение не пусто
                Text(message)
                    .foregroundColor(.red)
                    .opacity(message.isEmpty ? 0 : 1)
                
                // Отображение успешного сообщения
                Text(successMessage)
                    .foregroundColor(.green)
                    .opacity(successMessage.isEmpty ? 0 : 1)
                
                // Навигационная ссылка на MainView
                NavigationLink(
                    destination: MainView(),
                    isActive: $shouldNavigate,
                    label: {
                        EmptyView() // Пустая вьюшка, так как нам не нужно ничего отображать для кнопки
                    }
                )
                .hidden()

                Button(isRegistering ? "Switch to Login" : "Switch to Register") {
                    isRegistering.toggle()
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
//Доработать в 4 модуле
