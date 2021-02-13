//
//  ContentView.swift
//  List
//
//  Created by Talita Groppo on 11/02/2021.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Int
}

struct MyTextStyled: View {
    let amount: Int
    
    var body: some View {
        Text("$\(amount)")
            .fontWeight(amount <= 10 ? .bold : .none)
            .foregroundColor(amount > 10 ? .red : .primary)
            .background(amount > 100 ? Color.blue : Color.white)
    }
}


class Expenses: ObservableObject {
    
    @Published var items: [ExpenseItem] {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items")
        {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items){
                self.items = decoded
                return
            }
        }
        self.items = []
    }
}
struct ContentView: View {
    @ObservedObject var expenses = Expenses()
    @State private var showingAddExpense = false
    var body: some View {
        NavigationView{
            List{
                ForEach(expenses.items) { item in
                    HStack{
                        VStack(alignment: .leading){
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        Spacer()
                        MyTextStyled(amount: item.amount)
                    }
                }
                .onDelete(perform: removeItems)
            }
            .navigationBarTitle("iExpense")
            .navigationBarItems(leading: EditButton(),
                                trailing:
                                    Button(action:{
                                            self.showingAddExpense = true}) {
                                        Image(systemName: "plus")
                                    })
            .sheet(isPresented: $showingAddExpense){
                AddView(expenses: self.expenses)
            }
        }
    }
    func removeItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
        let tempItems = self.expenses.items
        self.expenses.items.removeAll()
        self.expenses.items = tempItems
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
