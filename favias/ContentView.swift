import SwiftUI

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
