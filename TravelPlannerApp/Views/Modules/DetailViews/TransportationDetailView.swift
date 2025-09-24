import SwiftUI

struct TransportationDetailView: View {
    @Binding var data: TransportationData
    @FocusState private var focusedField: TransportationField?
    
    enum TransportationField {
        case startDate, type, destination, departureLocation, duration, departureTime, arrivalTime, cost, notes
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transportation Information")
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
                        
                        TextField("Transportation Type", text: $data.type)
                            .padding()
                            .background(focusedField == .type ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .type)
                            .placeholder(when: data.type.isEmpty) {
                                Text("e.g., Train, Bus, Car").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        TextField("Destination", text: $data.destination)
                            .padding()
                            .background(focusedField == .destination ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .destination)
                            .placeholder(when: data.destination.isEmpty) {
                                Text("e.g., Paris").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        TextField("Departure Location", text: $data.departureLocation)
                            .padding()
                            .background(focusedField == .departureLocation ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .departureLocation)
                            .placeholder(when: data.departureLocation.isEmpty) {
                                Text("e.g., London").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        TextField("Duration", text: $data.duration)
                            .padding()
                            .background(focusedField == .duration ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .duration)
                            .placeholder(when: data.duration.isEmpty) {
                                Text("e.g., 2 hours 30 minutes").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        DatePicker("Departure Time", selection: $data.departureTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                        
                        DatePicker("Arrival Time", selection: $data.arrivalTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                        
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
                                Text("e.g., 45.00").foregroundColor(.gray.opacity(0.6))
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
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Booking Status")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Transportation Booked:")
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
                                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        
                        if data.isBooked {
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Booking Reference", text: $data.bookingReference)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                                    .placeholder(when: data.bookingReference.isEmpty) {
                                        Text("e.g., TRANS123456").foregroundColor(.gray.opacity(0.6))
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}
