import SwiftUI

class Api {
    func getPosts(completion: @escaping ([Post]) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:3000/api/v1/posts") else {
            DispatchQueue.main.async {
                print("Invalid URL")
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching posts:", error.localizedDescription)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received.")
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                // Настройка декодера для даты, если API возвращает даты в нестандартном формате
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // формат для апишки
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let posts = try decoder.decode([Post].self, from: data)
                DispatchQueue.main.async {
                    completion(posts)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to decode posts:", error.localizedDescription)
                }
            }
        }.resume()
    }
}

struct Post: Codable, Identifiable {
    var id: Int
    var name: String
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var author: String
    var postImage: URL? // Опционально, так как может отсутствовать
    var userId: Int

    enum CodingKeys: String, CodingKey {
        case id, name, title, content, author, userId
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case postImage = "post_image"
    }
}

class UserService {
    private let csrfToken: String // Здесь нуказывает токен
    
    init(csrfToken: String) {
        self.csrfToken = csrfToken
    }
    
    func registerUser(email: String, password: String, passwordConfirmation: String, completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:3000/api/v1/register") else {
            completion(false, "Invalid URL")
            return
        }
        
        let body: [String: Any] = [
            "user": [
                "email": email,
                "password": password,
                "password_confirmation": passwordConfirmation
            ]
        ]
        
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(csrfToken, forHTTPHeaderField: "X-CSRF-Token") // Добавляем CSRF-токен к заголовку запроса (если не знаем, напишите Оле)
        
        request.httpBody = finalBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Обработка ответа от сервера
        }.resume()
    }

    func loginUser(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:3000/api/v1/login") else {
            completion(false, "Invalid URL")
            return
        }
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(csrfToken, forHTTPHeaderField: "X-CSRF-Token") // Добавляем CSRF-токен к заголовку запроса
        
        request.httpBody = finalBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Обработка ответа от сервера
        }.resume()
    }
}

let csrfToken = "oQ5LGTg4cHgjm_nX6aVCXp4v-N8qldy6iprqWkVLr2cXVtanjGPhHCKwQekgiv5Wl_d9TN2ltxHlrtvl7dikVQ"
let userService = UserService(csrfToken: csrfToken)


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
//                NavigationLink(
//                    destination: MainView(),
//                    isActive: $shouldNavigate,
//                    label: {
//                        EmptyView() // Пустая вьюшка, так как нам не нужно ничего отображать для кнопки
//                    }
//                )
//                .hidden()

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



struct ContentView: View {
    // Определение структуры сетки
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    // Состояние для отслеживания выбранной вкладки
    @State private var selectedTab = "Рекомендации"
    
    var body: some View {
        TabView {
            NavigationView {
                VStack(spacing: 0) {
                    // Верхний бар
                    HStack {
                        Text("FAVIAS")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            // действие для кнопки уведомлений
                        }) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            // действие для кнопки поиска
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                        }
                    }
                    .padding([.leading, .trailing, .top])
                    
                    // Пользовательская панель вкладок
                    CustomTabPicker(selectedTab: $selectedTab)
                    
                    // Сетка фотографий или содержимое подписки
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            if selectedTab == "Рекомендации" {
                                ForEach(0..<10) { item in
                                    Image("photo\(item)") // Замените на имена ваших изображений
                                        .resizable()
                                        .scaledToFill()
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200)
                                        .cornerRadius(10)
                                        .clipped()
                                }
                            } else {
                                // Содержимое для вкладки "Твои подписки"
                                Text("Твои подписки") // Тут должно быть содержимое для вкладки "Твои подписки"
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "house")
                Text("Домой")
                    .foregroundColor(.white)
            }
            
            NavigationView {
                Text("Вторая страница") // Замените на другой экран
            }
            .tabItem {
                Image(systemName: "heart")
                Text("Избранное")
                    .foregroundColor(.white)
            }
        }
        .preferredColorScheme(.dark) // Темная тема
    }
}

// Пользовательский компонент для панели вкладок
struct CustomTabPicker: View {
    @Binding var selectedTab: String
    let tabs = ["Рекомендации", "Твои подписки"]
    
    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                Text(tab)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(selectedTab == tab ? Color.black : Color.clear)
                    .foregroundColor(selectedTab == tab ? .white : .gray)
                    .cornerRadius(10)
                    .overlay(
                        // Подчеркивание для выбранной вкладки
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == tab ? .white : .clear)
                            .padding(.top, 30),
                        alignment: .bottom
                    )
                    .onTapGesture {
                        withAnimation {
                            self.selectedTab = tab
                        }
                    }
            }
        }
        .background(Color.clear) // Убираем серый фон
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
