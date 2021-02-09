//
//  ContentView.swift
//  Better Rest
//
//  Created by Kevin Boulala on 30/01/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var bedTime = ""
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .onChange(of: wakeUp, perform: { _ in
                            calculateBedtime()
                        })
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        
                }
                .textCase(.none)
                
                
                Section(header: Text("Desire amount of sleep")) {
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                    .onChange(of: sleepAmount, perform: { _ in
                        calculateBedtime()
                    })
                }
                .textCase(.none)
                
                
                Section(header: Text("Daily coffee intake")) {
                    Stepper(value: $coffeeAmount, in: 1...20) {
                        if coffeeAmount == 1 {
                            Text("\(coffeeAmount) cup")
                        } else {
                            Text("\(coffeeAmount) cups")
                        }
                    }
                    .onChange(of: coffeeAmount, perform: { _ in
                        calculateBedtime()
                    })
                }
                .textCase(.none)
                
                
                Section(header: Text("Your ideal bedtime is")) {
                    HStack {
                        Spacer()
                        Text("\(bedTime)")
                            .font(.largeTitle)
                        Spacer()
                    }
                }
                .textCase(.none)
            }
            .navigationTitle("Better Rest")
            .onAppear {
                calculateBedtime()
            }
        }
    }

    static var defaultWakeTime: Date {
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0
        
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    func calculateBedtime() {
        do {
            let model = try SleepCalculator(configuration: .init())
        
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (dateComponents.hour ?? 0) * 60 * 60
            let minute = (dateComponents.minute ?? 0) * 60
            
            let wake = Double(hour + minute)
        
            let prediction = try model.prediction(wake: wake, estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            
            bedTime = dateFormatter.string(from: sleepTime)
        } catch {
            bedTime = ""
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
