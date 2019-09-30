//
//  Attributes.swift
//  JSONejercicio
//
//  Created by Pau Enrech on 13/03/2019.
//  Copyright © 2019 Pau Enrech. All rights reserved.
//

import Foundation
import SwiftyJSON

class Attributes{
    var age: Int?
    var gender: String?
    var smile: Double?
    var moustache: Double?
    var beard: Double?
    var sideburns: Double?
    var glasses: String?
    var emotions = [String : Double]()
    var baldness: Double?
    var hairVisible: Bool?
    //var hairColors = [HairColor]()
    var hairColors : hairColorsArray?
    var eyeMakeUp: Bool?
    var lipMakeUp: Bool?
    var accessories =  [Accessory]()
    
    var faceRectangle : CGRect?
    
    // MARK: - inicializador
    
    //Aqui parseo el json y inicializo el objeto con todos los atributos
    init(attributesJson: JSON) {
        self.age = attributesJson[0]["faceAttributes"]["age"].intValue
        self.gender = attributesJson[0]["faceAttributes"]["gender"].stringValue
        self.smile = attributesJson[0]["faceAttributes"]["smile"].doubleValue
        self.moustache = attributesJson[0]["faceAttributes"]["facialHair"]["moustache"].doubleValue
        self.beard = attributesJson[0]["faceAttributes"]["facialHair"]["beard"].doubleValue
        self.sideburns = attributesJson[0]["faceAttributes"]["facialHair"]["sideburns"].doubleValue
        self.glasses = attributesJson[0]["faceAttributes"]["glasses"].stringValue
        let emotions = attributesJson[0]["faceAttributes"]["emotion"].dictionaryObject
        for (key, value) in emotions! {
            self.emotions[key] = value as? Double
        }
        // Aqui utilizo json codable para mostrar otra forma de hacer lo mismo. En este caso es un combinado de
        // Swifty y de codable, ya que asi me ahorro crear structs extra ya que el json inicial es bastante ramificado, asi que lo simplifico con swifty
        // Dejo en comentario la forma de como lo hacía con swifty, que a mi parecer es más intuitiva de implementar pero no se si mas o menos eficiente.
        // Todo lo demás lo mantengo en Swifty.
        let hairJson = "\(attributesJson[0]["faceAttributes"]["hair"])"
        print(hairJson)
        let decoder = JSONDecoder()
        if let hairJsonData = hairJson.data(using: .utf8) {
            do {
                hairColors = try decoder.decode(hairColorsArray.self, from: hairJsonData)
            } catch {
                print(error)
            }
        }
        //Swifty version
        /*let hairColors = attributesJson[0]["faceAttributes"]["hair"]["hairColor"].array
        for hairColor in hairColors!{
            let color = hairColor["color"].stringValue
            let conficende = hairColor["confidence"].doubleValue
            let hairColorObject = HairColor(color: color, confidence: conficende)
            self.hairColors.append(hairColorObject)
        }*/
        self.baldness = attributesJson[0]["faceAttributes"]["hair"]["bald"].doubleValue
        self.hairVisible = attributesJson[0]["faceAttributes"]["hair"]["invisible"].boolValue
        self.eyeMakeUp = attributesJson[0]["faceAttributes"]["makeup"]["eyeMakeup"].boolValue
        self.lipMakeUp = attributesJson[0]["faceAttributes"]["makeup"]["lipMakeup"].boolValue
        let accesories = attributesJson[0]["faceAttributes"]["accessories"].array
        for accessory in accesories!{
            let type = accessory["type"].stringValue
            let confidence = accessory["type"].doubleValue
            let accessoryObject = Accessory(type: type, confidence: confidence)
            self.accessories.append(accessoryObject)
        }
        let rectangle = attributesJson[0]["faceRectangle"]
        faceRectangle = CGRect(x: rectangle["left"].intValue, y: rectangle["top"].intValue, width: rectangle["width"].intValue, height: rectangle["height"].intValue)

    }
    
    // MARK: - Tool-functions
    
    //Esta funcion es necesaria para adaptar correctamente el cuadrado que indica donde está la cara en la imagen
    //Utilizo la escala nativa del dispositivo para que se adapte igual a todos los dispositivos
    //El ancho normalizado lo extraigo de una constante, es el valor que tiene la imagen subida al servidor de microsoft, 1000 pixels
    func normalizeRectanglePosition(imageSizeInScreen: CGRect) -> CGRect{
        let normalizeWidth = FaceApi.sharedInstance.scaleWidthToNormalize!
        let difference = ((imageSizeInScreen.width * UIScreen.main.nativeScale) / normalizeWidth)

        let leftX = faceRectangle!.origin.x * difference
        let topY = faceRectangle!.origin.y * difference
        let width = faceRectangle!.width * difference
        let height = faceRectangle!.height * difference
        
        let resultRect = CGRect(x: leftX , y: topY , width: width , height: height)
        
        return resultRect
    }
    
    //Esta función devuelve una lista de atributos que luego se usa en el tableview de detalle
    func getListOfattributes() -> [Attribute] {
        var attributesList = [Attribute]()
        
        //Gender
        attributesList.append(Attribute(icon: GenreIcons(genre: gender!)!.rawValue, label: "Gender:", message: gender!.capitalizingFirstLetter()))
        
        //Smile amount
        var smileString = ""
        switch smile! {
        case 0 ... 0.15:
            smileString = "Not smiling"
        case 0.15 ... 0.25:
            smileString = "Minimum smiling"
        case 0.25 ... 0.50:
            smileString = "Smiling slightly"
        case 0.50 ... 0.75:
            smileString = "Smiling"
        case 0.75 ... 1.0:
            smileString = "Fully smiling"
        default:
            // En teoría nunca se llega a este supuesto
            smileString = "Not sure"
        }
        attributesList.append(Attribute(icon: smileIcon, label: "Smile:", message: smileString))
        
        //Emotion
        var mainEmotion = ""
        var emotionConfidenceLevel = 0.0
        for (key, value) in emotions {
            if value > emotionConfidenceLevel {
                mainEmotion = key
                emotionConfidenceLevel = value
            }
        }
        attributesList.append(Attribute(icon: EmotionIcons(type: mainEmotion)!.rawValue, label: "Emotion:", message: mainEmotion.capitalizingFirstLetter()))
        
        //Hair
        //Swifty version
        /*var mainHairColor = ""
        var mainHairIcon = ""
        if !hairVisible! {
            if baldness! >= 0.75 {
                mainHairColor = "No hair"
                mainHairIcon = HairIcons.bald.rawValue
            } else {
                var hairConfidenceLabel = 0.0
                for hairColor in hairColors{
                    if hairColor.confidence! > hairConfidenceLabel {
                        mainHairColor = hairColor.color!
                        hairConfidenceLabel = hairColor.confidence!
                    }
                }
                mainHairIcon = HairIcons.hair.rawValue
                }
        } else {
            mainHairIcon = HairIcons.bald.rawValue
            mainHairColor = "Not visible"
        }
        attributesList.append(Attribute(icon: mainHairIcon, label: "Hair color:", message: mainHairColor.capitalizingFirstLetter()))*/

        //Codable Version
         var mainHairColor = ""
         var mainHairIcon = ""
         if !hairVisible! {
             if baldness! >= 0.75 {
                 mainHairColor = "No hair"
                 mainHairIcon = HairIcons.bald.rawValue
             } else {
                 var hairConfidenceLabel = 0.0
                 for hairColor in hairColors!.hairColors{
                     if hairColor.confidence > hairConfidenceLabel {
                         mainHairColor = hairColor.color
                         hairConfidenceLabel = hairColor.confidence
                     }
                 }
                 mainHairIcon = HairIcons.hair.rawValue
             }
         } else {
             mainHairIcon = HairIcons.bald.rawValue
             mainHairColor = "Not visible"
         }
         attributesList.append(Attribute(icon: mainHairIcon, label: "Hair color:", message: mainHairColor.capitalizingFirstLetter()))
        
        //Moustache
        let moustacheString = setFacialHairString(quantity: moustache!, element: "moustache")
        attributesList.append(Attribute(icon: facialHairIcons.moustache.rawValue, label: "Moustache:", message: moustacheString))
        
        //Beard
        let beardString = setFacialHairString(quantity: beard!, element: "beard")
        attributesList.append(Attribute(icon: facialHairIcons.beard.rawValue, label: "Beard:", message: beardString))
        
        //Sideburns
        let sideburnString = setFacialHairString(quantity: sideburns!, element: "sideburns")
        attributesList.append(Attribute(icon: facialHairIcons.sideburns.rawValue, label: "Sideburns:", message: sideburnString))
        
        //Eye makeup
        let eyeMakeUpString = eyeMakeUp! ? "Yes" : "No"
        attributesList.append(Attribute(icon: makeupIcons.eyeMakeup.rawValue, label: "Eye makeup:", message: eyeMakeUpString))
        
        //Lip makeup
        let lipMakeUpString = lipMakeUp! ? "Yes" : "No"
        attributesList.append(Attribute(icon: makeupIcons.lipMakeup.rawValue, label: "Lip makeup:", message: lipMakeUpString))
        
        
        return attributesList
    }
    
    //Esta función devuelve una lista de accesorios que luego se usa en el tableview de detalles
    func getListOfAccesories() -> [AccessoryItem] {
        var accessoriesList = [AccessoryItem]()
        
        for accesory in accessories{
            if accesory.type! == "glasses"{
                var typeOfGlasses = ""
                var glassesIcon = ""
                switch glasses! {
                case "ReadingGlasses":
                    typeOfGlasses = "Glasses"
                    glassesIcon = AccesoriesIcons.init(type: glasses!)!.rawValue
                case "Sunglasses":
                    typeOfGlasses = "Sunglasses"
                    glassesIcon = AccesoriesIcons.init(type: glasses!)!.rawValue
                case "SwimmingGoggles":
                    typeOfGlasses = "Swimming goggles"
                    glassesIcon = AccesoriesIcons.init(type: glasses!)!.rawValue
                default: continue
                }
                accessoriesList.append(AccessoryItem(icon: glassesIcon, label: typeOfGlasses))
            } else {
                accessoriesList.append(AccessoryItem(icon: AccesoriesIcons(type: accesory.type!)!.rawValue, label: accesory.type!.lowercased().capitalizingFirstLetter()))
            }
        }
        
        return accessoriesList
    }
    
    //Esta función define el mensaje de la cantidad de un determinado elemento(barba, bigote, patillas) en función del nivel de confianza dado por la api
    //Los baremos los he añadido yo asi en base a prueba y error
    private func setFacialHairString(quantity: Double, element: String) -> String{
        var string = ""
        switch quantity {
        case 0 ... 0.11:
            string = "No \(element)"
        case 0.11 ... 0.25:
            string = "Very thin \(element)"
        case 0.25 ... 0.50:
            string = "Thin \(element)"
        case 0.50 ... 0.75:
            string = "Thick \(element)"
        case 0.75 ... 1.0:
            string = "Very thick \(element)"
        default:
            string = "Not sure"
        }
        return string
    }
    
    // MARK - Enums de iconos
    
    enum EmotionIcons: String {
        case anger = "iconAngry"
        case contempt = "iconContempt"
        case neutral = "iconNeutral"
        case disgust = "iconDisgust"
        case fear = "iconFear"
        case happiness = "iconHappiness"
        case sadness = "iconSad"
        case surprise = "iconSurprise"
        
        init?(type: String){
            switch type.lowercased() {
                case "anger": self = .anger
                case "contempt" : self = .contempt
                case "neutral" : self = .neutral
                case "disgust" : self = .disgust
                case "fear" : self = .fear
                case "happiness" : self = .happiness
                case "sadness" : self = .sadness
                case "surprise" : self = .surprise
                default: return nil
            }
        }
    }
    
    let smileIcon = "iconSmile"
    
    enum AccesoriesIcons: String {
        case headwear = "iconHeadwear"
        case ReadingGlasses = "iconGlasses"
        case Sunglasses = "iconSunglasses"
        case SwimmingGoggles = "iconSwimmingglasses"
        case mask = "iconMask"
        
        init?(type: String){
            switch type {
            case "headwear": self = .headwear
            case "ReadingGlasses" : self = .ReadingGlasses
            case "Sunglasses" : self = .Sunglasses
            case "SwimmingGoggles" : self = .SwimmingGoggles
            case "mask" : self = .mask
            default: return nil
            }
        }
    }
    
    enum makeupIcons: String {
        case eyeMakeup = "iconEyeMakeup"
        case lipMakeup = "iconLipMakeup"
    }
    
    enum facialHairIcons: String {
        case moustache  = "iconMoustache"
        case beard = "iconBeard"
        case sideburns = "iconSideburns"
        
        init?(type: String){
            switch type {
            case "moustache": self = .moustache
            case "beard" : self = .beard
            case "sideburns" : self = .sideburns
            default: return nil
            }
        }
    }
    
    enum HairIcons: String {
        case bald = "iconBald"
        case hair = "iconHair"
    }
    
    enum GenreIcons: String {
        case male = "iconMale"
        case female = "iconFemale"
        
        init?(genre: String){
            switch genre {
            case "male": self = .male
            case "female" : self = .female
            default: return nil
            }
        }
    }
    
    // MARK: - Clases de atributos y accesorios
    
    //Swifty version
    /*class HairColor {
        var color: String?
        var confidence: Double?
        
        init(color: String, confidence: Double) {
            self.color = color
            self.confidence = confidence
        }
    }*/
    
    //Codable version
    struct hairColorsArray: Codable {
        var hairColors: [HairColor]
        
        enum CodingKeys: String, CodingKey {
            case hairColors = "hairColor"
        }
    }
    struct HairColor: Codable {
        var color: String
        var confidence: Double
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            color = try values.decode(String.self, forKey: .color)
            confidence = try values.decode(Double.self, forKey: .confidence)
        }
        
    }
    
    class Accessory{
        var type: String?
        var confidence: Double?
        
        init(type: String, confidence: Double) {
            self.type = type
            self.confidence = confidence
        }
    }
    
    class Attribute {
        var icon: String?
        var label: String?
        var message: String
        
        init(icon: String, label: String, message: String) {
            self.icon = icon
            self.label = label
            self.message = message
        }
    }
    
    class AccessoryItem {
        var icon: String?
        var label: String?
        
        init(icon: String, label: String) {
            self.icon = icon
            self.label = label
        }
    }
    
}
