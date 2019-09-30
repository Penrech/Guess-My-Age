//
//  FaceApi.swift
//  JSONejercicio
//
//  Created by Pau Enrech on 15/03/2019.
//  Copyright © 2019 Pau Enrech. All rights reserved.
//

import Foundation
import UIKit

//En este objeto guardo todos los datos constantes para gestionar la conexión con la api
struct FaceApi {
    
    static let sharedInstance = FaceApi()
    let location : String?
    let returnFaceId : Bool?
    let returnFaceLandmarks : Bool?
    let returnFaceAttributes : String?
    let apiKey : String?
    let stringUrl : String?
    let scaleWidthToNormalize: CGFloat?
    
    private init() {
        let apiKey: String = String()
        self.scaleWidthToNormalize = 1000
        self.location = "westeurope"
        self.returnFaceId = false
        self.returnFaceLandmarks = false
        self.returnFaceAttributes = "age,gender,smile,facialHair,glasses,emotion,hair,makeup,accessories"
        self.apiKey = apiKey.getApiKey()
        self.stringUrl = "https://\(self.location!).api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=\(self.returnFaceId!)&returnFaceLandmark=\(self.returnFaceLandmarks!)&returnFaceAttributes=\(self.returnFaceAttributes!)"
    }
    
    
}
