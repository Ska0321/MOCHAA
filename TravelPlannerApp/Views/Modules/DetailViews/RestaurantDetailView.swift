import SwiftUI

struct RestaurantDetailView: View {
    @Binding var data: RestaurantData
    @FocusState private var focusedField: RestaurantField?
    
    enum RestaurantField {
        case startDate, time, name, cuisine, rating, cost, notes, reservationName
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Restaurant Information")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        DatePicker("Date", selection: $data.startDate, displayedComponents: .date)
                            .padding()
                            .background(focusedField == .startDate ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .startDate)
                        
                        DatePicker("Reservation Time", selection: $data.time, displayedComponents: .hourAndMinute)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                        
                        TextField("Restaurant Name", text: $data.name)
                            .padding()
                            .background(focusedField == .name ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .name)
                            .placeholder(when: data.name.isEmpty) {
                                Text("e.g., The French Laundry").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        TextField("Cuisine Type", text: $data.cuisine)
                            .padding()
                            .background(focusedField == .cuisine ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .cuisine)
                            .placeholder(when: data.cuisine.isEmpty) {
                                Text("e.g., French, Italian").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        TextField("Rating", value: $data.rating, format: .number)
                            .padding()
                            .background(focusedField == .rating ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .rating)
                            .keyboardType(.decimalPad)
                            .placeholder(when: data.rating == 0) {
                                Text("e.g., 4.5").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        TextField("Cost", value: $data.cost, format: .currency(code: "USD"))
                            .padding()
                            .background(focusedField == .cost ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .cost)
                            .keyboardType(.decimalPad)
                            .placeholder(when: data.cost == 0) {
                                Text("e.g., 150.00").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        Toggle("Has Reservation", isOn: $data.hasReservation)
                            .padding(.vertical, 8)
                        
                        if data.hasReservation {
                            TextField("Reservation Name", text: $data.reservationName)
                                .padding()
                                .background(focusedField == .reservationName ? Color(.systemGray6) : Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                )
                                .focused($focusedField, equals: .reservationName)
                                .placeholder(when: data.reservationName.isEmpty) {
                                    Text("e.g., John Smith").foregroundColor(.gray.opacity(0.6))
                                }
                        }
                        
                        TextField("Notes", text: $data.notes, axis: .vertical)
                            .padding()
                            .background(focusedField == .notes ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .notes)
                            .lineLimit(3...6)
                            .placeholder(when: data.notes.isEmpty) {
                                Text("Additional notes...").foregroundColor(.gray.opacity(0.6))
                            }
                    }
                }
            }
        }
    }
}
