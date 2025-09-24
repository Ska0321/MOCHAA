import SwiftUI

struct FlightDetailView: View {
    @Binding var data: FlightData
    @FocusState private var focusedField: FlightField?
    
    enum FlightField {
        case departureDate, flightNumber, departureTime, departureAirport, arrivalAirport, cost, notes
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Flight Information")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        DatePicker("Departure Date", selection: $data.departureDate, displayedComponents: .date)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                        
                        TextField("Flight Number", text: $data.flightNumber)
                            .padding()
                            .background(focusedField == .flightNumber ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .flightNumber)
                            .placeholder(when: data.flightNumber.isEmpty) {
                                Text("e.g., AA123").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        DatePicker("Departure Time", selection: $data.departureTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Airports")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Departure Airport", text: $data.departureAirport)
                            .padding()
                            .background(focusedField == .departureAirport ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .departureAirport)
                            .placeholder(when: data.departureAirport.isEmpty) {
                                Text("e.g., LAX").foregroundColor(.gray.opacity(0.6))
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Arrival Airport", text: $data.arrivalAirport)
                            .padding()
                            .background(focusedField == .arrivalAirport ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .arrivalAirport)
                            .placeholder(when: data.arrivalAirport.isEmpty) {
                                Text("e.g., JFK").foregroundColor(.gray.opacity(0.6))
                            }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Additional Details")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Cost:")
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        TextField("0.00", value: $data.cost, format: .currency(code: "USD"))
                            .padding()
                            .background(focusedField == .cost ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .cost)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Notes", text: $data.notes, axis: .vertical)
                            .padding()
                            .background(focusedField == .notes ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .notes)
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
                            Text("Flight Booked:")
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
                                        Text("e.g., ABC123456").foregroundColor(.gray.opacity(0.6))
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
