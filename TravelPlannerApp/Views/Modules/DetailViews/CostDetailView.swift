import SwiftUI

struct CostDetailView: View {
    @Binding var data: CostData
    @State private var newItemDescription = ""
    @State private var newItemAmount = ""
    @FocusState private var focusedField: CostField?
    
    enum CostField {
        case newDescription, newAmount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cost Summary")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("Total Cost:")
                            .font(.headline)
                        Spacer()
                        Text("$\(data.totalCost, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cost Breakdown")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if data.breakdown.isEmpty {
                        Text("No cost items added yet")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(data.breakdown) { item in
                            HStack {
                                Text(item.description)
                                    .font(.body)
                                Spacer()
                                Text("$\(item.amount, specifier: "%.2f")")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add Cost Item")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Description", text: $newItemDescription)
                            .padding()
                            .background(focusedField == .newDescription ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .newDescription)
                            .placeholder(when: newItemDescription.isEmpty) {
                                Text("e.g., Museum tickets").foregroundColor(.gray)
                            }
                        
                        TextField("Amount", text: $newItemAmount)
                            .padding()
                            .background(focusedField == .newAmount ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .newAmount)
                            .keyboardType(.decimalPad)
                            .placeholder(when: newItemAmount.isEmpty) {
                                Text("e.g., 25.00").foregroundColor(.gray)
                            }
                        
                        Button("Add Item") {
                            addCostItem()
                        }
                        .disabled(newItemDescription.isEmpty || newItemAmount.isEmpty)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Payment Status")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Costs Paid:")
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                            Toggle("", isOn: $data.isBooked)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                        
                        if data.isBooked {
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Payment Reference", text: $data.bookingReference)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                    .placeholder(when: data.bookingReference.isEmpty) {
                                        Text("e.g., PAYMENT123456").foregroundColor(.gray)
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addCostItem() {
        guard let amount = Double(newItemAmount), !newItemDescription.isEmpty else { return }
        
        let newItem = CostItem(moduleId: "", description: newItemDescription, amount: amount)
        data.breakdown.append(newItem)
        data.totalCost += amount
        
        newItemDescription = ""
        newItemAmount = ""
    }
}
