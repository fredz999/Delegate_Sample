//
//  ContentView.swift
//  DelegatePattern
//
//  Created by Jonathan Brown on 26/11/2024.
//


//what follows is some code used to examplify the delegate pattern
//it is a simple class system that handles
//a change in a GBP transaction amount ,then changes
//its amount in two other currencies JPY and USD

import SwiftUI

struct ContentView : View {
    var transfer_Manager : Transfer_Manager
    init(){
        transfer_Manager = Transfer_Manager()
    }
    var body: some View {
        Balance_UI(transfer_ManagerParam: transfer_Manager)
    }
}

//4: UI
struct Balance_UI : View {
    @ObservedObject var transfer_Manager : Transfer_Manager
    var usdTransferDisplay = UsdTransferDisplay()
    var yenTransferDisplay = YenTransferDisplay()
    
    init(transfer_ManagerParam:Transfer_Manager){
        transfer_Manager = transfer_ManagerParam
        transfer_Manager.usdDelegate = usdTransferDisplay
        transfer_Manager.yenDelegate = yenTransferDisplay
    }
    
    var body: some View {
        ZStack {
            Rectangle().frame(width:300,height:100).foregroundColor(.red)
            VStack{
                Text("increase amount by 10").foregroundColor(.white)
                Text("Amount:"+transfer_Manager.current_Balance.description).foregroundColor(.white)
            }
        }.onTapGesture {
            transfer_Manager.amountChange(isUp: true)
        }
    }
}



// there are 3 main actor types,
//1: protocol description
protocol P__Balance_Protocol : AnyObject {
    var rate:Double{get}
    func reactAmountChange(gbpIn:Double)
}



//2 delegates - this conforms to the protocol - implements its methods
// 1: USD_Delegate, 2: JPY_Delegate
class YenTransferDisplay: P__Balance_Protocol{
    var rate:Double = 192.0
    func reactAmountChange(gbpIn:Double) {
        print("transfer in yen: \(gbpIn * rate)")
    }
}

class UsdTransferDisplay: P__Balance_Protocol{
    var rate:Double = 1.2
    func reactAmountChange(gbpIn:Double) {
        print("transfer in usd: \(gbpIn * rate)")
    }
}

//3 delegating object - this holds reference to the delegate type and calls its methods
class Transfer_Manager : ObservableObject {
    weak var yenDelegate: P__Balance_Protocol?
    weak var usdDelegate: P__Balance_Protocol?
    @Published var current_Balance:Double = 100.0
    
    func amountChange(isUp:Bool){
        if isUp{
            current_Balance += 10
        }
        else {
            if (current_Balance - 10) > 0{
                current_Balance -= 10
            }
        }

        if let lclYen = yenDelegate{
            lclYen.reactAmountChange(gbpIn: current_Balance)
        }
        
        if let lclUsd = usdDelegate {
            lclUsd.reactAmountChange(gbpIn: current_Balance)
        }
        
    }
}

