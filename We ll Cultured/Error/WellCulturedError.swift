//
//  WellCulturedError.swift
//  We ll Cultured
//
//  Created by Onur Akdogan on 20.12.2022.
//

import Foundation
import UIKit

enum WellCulturedError: String, Error {
    
    case unavailableImage = "There is no image."
    case unableToComplete = "Unable to complete your request. Please try again."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
    case invalidParse = "Parsing error occured. Please try again."
}
