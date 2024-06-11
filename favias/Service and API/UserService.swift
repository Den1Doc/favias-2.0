import Foundation

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
