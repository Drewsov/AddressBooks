//
//  Logging.swift
//  Vip-76.ru
//
//  Created by Drew on 18/12/14.
//  Copyright (c) 2014 Andrey Toropov. All rights reserved.
//

import Foundation
func prnfln(message: String, function: String = __FUNCTION__) {
    #if DEBUG
        println("\(function): \(message)")
    #endif
}

func prn(message: String, function: String = __FUNCTION__) {
   // #if DEBUG
        print("\(message)")
   // #endif
}

func prnln(message: String, function: String = __FUNCTION__) {
   // #if DEBUG
        println("\(message)")
    //#endif
}