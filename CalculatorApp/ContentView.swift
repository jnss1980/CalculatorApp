//
//  ContentView.swift
//  CalculatorApp
//
//  Created by 李若塵 on 2021/7/21.
//

import SwiftUI


enum CalculatorButton : String{
    case zero, one, two, three, four, five, six, seven, eight, nine
    case equals, plus, minus, multiply, divide, deciml
    case ac, plusMinus, percent
    
    var title : String{
        switch self {
        case .zero:return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .plus: return "+"
        case .plusMinus: return "±"
        case .minus : return "-"
        case .multiply: return "X"
        case .percent: return "%"
        case .divide: return "÷"
        case .equals: return "="
        case .deciml: return "."
        default: return "AC"
        }
    }
    var backgroundColor: Color{
        switch self {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            return Color(.darkGray)
        case .ac, .plusMinus, .percent, .divide:
            return Color(.lightGray)
        default:
            return .orange
        }
    }
}

class GlobalEnviromment: ObservableObject{
    @Published var display = ""                //顯示的數字
    var operatingString = ""
    var currentNumber : Double = 0
    var previousNumber : Double = 0
    var isCalculating: Bool = false
    var startNew : Bool = true
    
    enum OperationType {
        case add, subtract, multiply, divide, none
    }
    
    var operation: OperationType = .none
    
    
    func Count( number: String){
        if previousNumber != 0{
            giveAnswer()
        }
        previousNumber = currentNumber
        isCalculating = true
        startNew = false
        operatingString = number
        switch number {
        case "÷":
            operation = .divide
        case "X":
            operation = .multiply
        case "-":
            operation = .subtract
        case "+":
            operation = .add
        default:
            operation = .none
        }
    }
    
    func okAnswerString(number: Double){
        if floor(number) == number{
            display = String(Int(number))
        }else{
            display = String(number)
        }
        
        if display.count >= 7 {
            display = String(display.prefix(7))
        }
    }
    
    
    func clear(){
        display = "0"
        operatingString = ""
        currentNumber = 0
        previousNumber = 0
        isCalculating = false
        startNew = true
    }
    
    func receiveInput(calculatorButton: CalculatorButton){
        let skey : String = calculatorButton.title
        
        if skey == "AC" {
            clear()
            return
        }
        
        if skey == ""{
            return
        }
        
        if skey == "="{
            giveAnswer()
            return
        }
      
        
        if skey == "±" {
            currentNumber = Double(display)! * -1
            okAnswerString(number: currentNumber)
            isCalculating = true
            startNew = false
            return
        }
        
        if skey == "%" {
            currentNumber = Double(display)! / 100
            okAnswerString(number: currentNumber)
            isCalculating = true
            startNew = false
            return
        }
        
        //Count
        if  skey == "÷" || skey == "X" || skey == "-" || skey == "+"{
            Count( number: skey)
            return
        }
        
        if startNew {
            display = skey
            startNew = false
        }else{
            if display == "0" || operatingString == "÷" || operatingString == "X" || operatingString == "-" || operatingString == "+"{
                display = skey
                operatingString = ""
            }else{
                self.display = display + skey
                
            }
        }
        currentNumber = Double(self.display) ?? 0
    }
    
    func giveAnswer(){
        if isCalculating {
            switch operation {
            case .add:
                currentNumber = previousNumber + currentNumber
                okAnswerString(number: currentNumber)
            case .subtract:
                currentNumber = previousNumber - currentNumber
                okAnswerString(number: currentNumber)
            case .multiply:
                currentNumber = previousNumber * currentNumber
                okAnswerString(number: currentNumber)
            case .divide:
                currentNumber = previousNumber / currentNumber
                okAnswerString(number: currentNumber)
                
                
            default:
                display = ""
            }
            isCalculating = false
            startNew = true
        }
        previousNumber = 0
    }
}



struct ContentView: View {
    @EnvironmentObject var env: GlobalEnviromment
    
    let buttons : [[CalculatorButton]] = [
        [.ac, .plusMinus, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.zero, .deciml, .equals]
        
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            VStack(spacing: 10){
                HStack{
                    Spacer()
                    VStack{
                        Text("")
                            .foregroundColor(.white)
                            .font(.system(size: 40))
                            .padding()
                        Text(env.display)
                            .foregroundColor(.white)
                            .font(.system(size: 64))
                    }
                    
                }.padding()
                ForEach(buttons, id: \.self){ row in
                    HStack{
                        ForEach(row,id: \.self) {btnVa in
                            calculatorButtonView(button:  btnVa)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GlobalEnviromment())
    }
}

struct calculatorButtonView: View {
    var button : CalculatorButton
    @EnvironmentObject var env : GlobalEnviromment
    
    var body: some View {
        Button(action:{
            self.env.receiveInput(calculatorButton: button)
            
        }){
            Text(button.title)
                .font(.system(size: 32))
                .frame(width: self.buttonWidth(button: button), height: (UIScreen.main.bounds.width - 5 * 12) / 4)
                .foregroundColor(.white)
                .background(button.backgroundColor)
                .cornerRadius(self.buttonWidth(button: button))
        }
    }
    
    func buttonWidth(button: CalculatorButton) -> CGFloat{
        if button == .zero{
            return (UIScreen.main.bounds.width - 4 * 12) / 4 * 2
        }
        return (UIScreen.main.bounds.width - 5 * 12) / 4
    }
}
