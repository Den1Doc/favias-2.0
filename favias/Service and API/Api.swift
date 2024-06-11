import Foundation

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
