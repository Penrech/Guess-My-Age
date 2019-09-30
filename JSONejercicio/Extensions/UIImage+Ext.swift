//
//  UIImage+Ext.swift
//  JSONejercicio
//
//  Created by Pau Enrech on 11/03/2019.
//  Copyright © 2019 Pau Enrech. All rights reserved.
//

import Foundation
import UIKit
extension UIImage {
    //Utilizo este método para normalizar la imagen que se envia al servidor, de modo que tenga los mismos pixeles
    //Independientemente del dispositivo que la envia, esto es util ya que la api pide que la imagen pese menos de 6mb y sea menor de 4000 x 4000 px
    //No he añadido estos valores al filtrado ya que la que envio es de 1000 pixeles que está lejos de los 4000 y es dificil que exceda los 6mb
    //Aun con esta función el peso de las imagenes en mb varia ligeramente entre dispositivos (Del entorno a +-100kB), supongo que por truncado o
    //Redondeo en las diferentes divisiones
    func resizeWithWidth(widthInPixels: CGFloat) -> UIImage? {
        let scaleFactor = UIScreen.main.nativeScale
        let originWidthInPixels = size.width * scaleFactor
        let originHeightInPixels = size.height * scaleFactor
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: widthInPixels, height: CGFloat(ceil(widthInPixels/originWidthInPixels * originHeightInPixels)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        let boundsSizeWidthInPixels = imageView.bounds.size.width * scaleFactor
        let boundsSizeHeightInPixels = imageView.bounds.size.height * scaleFactor
        let boundsInPixels = CGSize(width: boundsSizeWidthInPixels, height: boundsSizeHeightInPixels)
        print("ScaleFactor: \(scaleFactor)")
        UIGraphicsBeginImageContextWithOptions(boundsInPixels, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    //Esta función dibujo el cuadrado que indica donde está la cara en la imagen. Para el ancho de la línea utilizo
    //un pequeño porcentaje de la anchura del dispositivo mas su escala nativa, para que se vea igual en todos los dispositivos
    func DrawOnImage(rectangleSize: CGRect) -> UIImage {
        
        let lineWidth = 0.015 * UIScreen.main.bounds.width * UIScreen.main.nativeScale
        
        // Create a context of the starting image size and set it as the current one
        UIGraphicsBeginImageContext(self.size)
        
        // Draw the starting image in the current context as background
        self.draw(at: CGPoint.zero)
        
        // Get the current context
        let context = UIGraphicsGetCurrentContext()!
        
        //Draw rectangle
        context.setStrokeColor(UIColor.defaultRed.cgColor)
        context.setAlpha(0.75)
        context.setLineWidth(lineWidth)
        context.addRect(rectangleSize)
        context.drawPath(using: .stroke)
        
        // Save the context as a new UIImage
        let myImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Return modified image
        return myImage!
    }
}
