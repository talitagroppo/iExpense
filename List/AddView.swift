//
//  AddView.swift
//  List
//
//  Created by Talita Groppo on 11/02/2021.
//

import SwiftUI

struct AddView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var expenses: Expenses
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = ""
    @State private var showingAlert = false
    
    static let types = ["Business", "Personal"]
    
    var body: some View {
        NavigationView{
            Form{
                TextField("Name", text: $name)
                Picker("Type", selection: $type){
                    ForEach(Self.types, id: \.self){
                    Text($0)
                }
            }
            TextField("Amount", text:$amount)
                .keyboardType(.decimalPad)
        }
        .navigationBarTitle("Add new expense")
            .navigationBarItems(leading: Button("Cancel"){
                self.presentationMode.wrappedValue.dismiss()
            },
                trailing: Button("Save"){
                if let actualAmount = Float(self.amount){
                    let item = ExpenseItem(name: self.name == "" ? "Miscellaneous" : self.name, type: self.type, amount: Int(actualAmount))
                    
                    self.expenses.items.append(item)
                    
                    self.saveToUserDefaults()
                    
                    self.presentationMode.wrappedValue.dismiss()
                    
                }else{
                    self.showingAlert = true
                }
            })
    }
        .alert(isPresented: $showingAlert){
            Alert(title: Text("Error"), message: Text("Amount must be numeric"), dismissButton: .default(Text("Continue")))
        }
}
    func saveToUserDefaults(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(expenses.items){
            UserDefaults.standard.set(encoded, forKey: "Items")
        }
    }
}
struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}
