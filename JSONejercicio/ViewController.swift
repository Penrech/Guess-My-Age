//
//  ViewController.swift
//  JSONejercicio
//
//  Created by Pau Enrech on 11/03/2019.
//  Copyright © 2019 Pau Enrech. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: - variables y constantes
    let radius: CGFloat = 30
    var imageCharged: Bool = false
    var imageSelected: UIImage?
    let uploadingImageMessage = "Loading image..."
    let analyzingImageMessage = "Analyzing image..."
    
    // MARK: - Outlets
    @IBOutlet weak var constraintEntreImagenYButton: NSLayoutConstraint!
    @IBOutlet weak var constraintEntreImagenYTop: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonView: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var containerView: UIView!
    {
        didSet{
        containerView.layer.cornerRadius = radius
        }
    }
    @IBAction func buttonAction(_ sender: Any) {
        loadingImageToServer()
    }

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var loadingView: UIStackView!
    
    // MARK: - metodos de vista y estilos
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaultImage = UIImage(named: "add-photo")
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(galleryOrCamera))
        imageView.addGestureRecognizer(tapImage)
        
        imageView.image = defaultImage
        
        progressView.transform = progressView.transform.scaledBy(x: 1.0, y: 4.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        UIApplication.shared.statusBarView?.backgroundColor = .clear
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.default
    }
    
    // MARK: - Metodos utiles
    
    // Esta función gestiona la carga de una imagen a la app desde la galeria
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            imageSelected = image
            imageView.image = image
            imageCharged = true
        } else {
            print("Error cargando imagen de la libreria")
            //Mostrar ventana
            showAlert(errorType: .Libreria)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // Esta función modifica la interfaz gráfica antes de proceder a enviar la imagen al servidor
    // Muestra una animación de error en caso de que no haya ninguna imagen seleccionada
    func loadingImageToServer(){
        if !imageCharged {
            print("No se ha seleccionado ninguna imagen")
            UIView.animate(withDuration: 0.05, animations: {
                self.imageView.transform = CGAffineTransform(translationX: 10, y: 0)
            }) { (completion) in
                UIView.animate(withDuration: 0.1, animations: {
                    self.imageView.transform = CGAffineTransform(translationX: -10, y: 0)
                }, completion: { (completion) in
                    UIView.animate(withDuration: 0.1, animations: {
                        self.imageView.transform = CGAffineTransform(translationX: 5, y: 0)
                    }, completion: { (completion) in
                        UIView.animate(withDuration: 0.05, animations: {
                            self.imageView.transform = .identity
                        })
                    })
                })
            }
            return
        }
        self.imageView.isUserInteractionEnabled = false
        self.constraintEntreImagenYButton.constant = -self.buttonView.frame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        self.progressLabel.text = uploadingImageMessage
        self.loadingView.isHidden = false
        sendImageToServerAndWaitForResponse()
    }
    
    //Esta función restaura la interfaz gráfica que estaba en modo cargando, ya sea por un error o porque se cambia de view controller
    func restartUI(){
        self.imageView.isUserInteractionEnabled = true
        self.constraintEntreImagenYButton.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        self.loadingView.isHidden = true
        self.progressView.progress = 0.0
    }

    @objc func galleryOrCamera(){
        let alert = UIAlertController(title: "Multimedia", message: "Select the photo source", preferredStyle: .actionSheet)
        let actionCamera = UIAlertAction(title: "Camera", style: .default) { (actionCamera) in
            self.imageClicked(type: .camera)
        }
        let actionGallery = UIAlertAction(title: "Gallery", style: .default) { (actionGallery) in
            self.imageClicked(type: .photoLibrary)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            alert.addAction(actionCamera)
        }
        alert.addAction(actionGallery)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Esta función inicia la galeria y la carga de imagenes de esta hacia la app
    // Anima también la interfaz gráfica para mostrar una respuesta visual al usuario del toque en la imagen
        func imageClicked(type: UIImagePickerController.SourceType){
        let startColor = self.imageView.tintColor
        UIView.animate(withDuration: 0.15, animations: {
            self.imageView.tintColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        }) { (completado) in
            UIView.animate(withDuration: 0.15, animations: {
                self.imageView.tintColor = startColor
            })
        }
        UIView.animate(withDuration: 0.3) {
            self.imageView.backgroundColor = UIColor.ImageViewClicked
        }
        let image = UIImagePickerController()
        image.delegate = self
    
        image.sourceType = type
        image.allowsEditing = true
    
        self.present(image, animated: true){
            self.imageView.backgroundColor = .clear
        }
    }
    
    // MARK: - send data to server function
    
    //Esta es la función principal encargada de formatear y enviar la imagen al servidor para ser analizada y recibir y procesar la respuesta
    func sendImageToServerAndWaitForResponse(){
        let apiKey = FaceApi.sharedInstance.apiKey!
        let stringUrl = FaceApi.sharedInstance.stringUrl!
        print(stringUrl)
        
        guard let url = URL(string: stringUrl) else {
            print("Error formateando url de string a URL")
            showAlert(errorType: .Desconocido)
            return
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let imageData = imageSelected?.resizeWithWidth(widthInPixels: FaceApi.sharedInstance.scaleWidthToNormalize!)?.jpegData(compressionQuality: 1.0)
        print("Tamaño imagen: \(imageData!.count) Bytes")
        
        request.httpBody = imageData
       
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                print("Error realizando la consulta")
                self.showAlert(errorType: .Desconocido)
                return
            }
            
            guard let data = data else {
                print("Objeto data vacio")
                self.showAlert(errorType: .Desconocido)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error obteniendo respuesta")
                self.showAlert(errorType: .Desconocido)
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            guard let json = try? JSON(data: data) else {
                print("Error parseando json")
                self.showAlert(errorType: .Desconocido)
                return
            }
            
            
            switch statusCode {
            case 200:
                self.successFromRequest(jsonData: json)
            case 400:
                let extraMessage = "Error, wrong url format sent"
                let errorCode = json["error"]["code"].stringValue
                let message = json["error"]["message"].stringValue
                self.errorFromRequest(errorCode: errorCode, message: message, extraMessage: extraMessage, ErrorType.ProcesadoServidor)
                return
            case 401:
                let extraMessage = "Error, wrong apiKey or user"
                let errorCode = json["error"]["code"].stringValue
                let message = json["error"]["message"].stringValue
                self.errorFromRequest(errorCode: errorCode, message: message, extraMessage: extraMessage, ErrorType.ProcesadoServidor)
                return
            case 403:
                let extraMessage = "Error: use quota exceeded"
                let errorCode = json["error"]["statusCode"].intValue
                let message = json["error"]["message"].stringValue
                self.errorFromRequest(errorCode: errorCode, message: message, extraMessage: extraMessage, ErrorType.ProcesadoServidor)
                return
            case 408:
                let extraMessage = "Error: conection timeout"
                let errorCode = json["error"]["code"].stringValue
                let message = json["error"]["message"].stringValue
                self.errorFromRequest(errorCode: errorCode, message: message, extraMessage: extraMessage, ErrorType.ProcesadoServidor)
                return
            case 415:
                let extraMessage = "Error media type not supported"
                let errorCode = json["error"]["code"].stringValue
                let message = json["error"]["message"].stringValue
                self.errorFromRequest(errorCode: errorCode, message: message, extraMessage: extraMessage, ErrorType.ProcesadoServidor)
                return
            case 429:
                let extraMessage = "Error: Requests per minute exceeded"
                let errorCode = json["error"]["statusCode"].intValue
                let message = json["error"]["message"].stringValue
                self.errorFromRequest(errorCode: errorCode, message: message, extraMessage: extraMessage, ErrorType.ProcesadoServidor)
                return
            default:
                let extraMessage = "Network error"
                let errorCode = statusCode
                let message = "Network error"
                self.errorFromRequest(errorCode: errorCode, message: message, extraMessage: extraMessage, ErrorType.Red)
                return
            }
        }
        
        task.resume()
        
    }
    
    // MARK : - funciones de respuesta
    
    //Esta función es llamada si la respuesta del servidor es correcta
    func successFromRequest(jsonData: JSON){
        print("Success")
        if jsonData.isEmpty {
            print("Error, no se ha detectado ninguna cara")
            showAlert(errorType: .NoCaras)
        } else {
            if jsonData.count > 1{
              print("Error, se ha detectado más de una cara")
                showAlert(errorType: .DemasiadasCaras)
                return
            }
        }
        performSegue(withIdentifier: "goToDetail", sender: jsonData)

    }
    
    //Estas funciones (una con codigo string, la otra con codigo int) son llamadas si la respuesta del servidor es un error
    func errorFromRequest(errorCode: String, message: String, extraMessage: String, _ error: ErrorType){
        let errorCode = errorCode
        let message = message
        print(extraMessage)
        print(errorCode)
        print(message)
        
        //Mostrar alerta
        showAlert(errorType: error)
    }
    func errorFromRequest(errorCode: Int, message: String, extraMessage: String, _ error: ErrorType){
        let errorCode = errorCode
        let message = message
        print(extraMessage)
        print(errorCode)
        print(message)
        
        //Mostrar alerta
        showAlert(errorType: error)
    }
    
    //Esta función es la encargada de mostrar una ventana de error cuando es llamada
    func showAlert(errorType : ErrorType){
        if errorType != .Libreria {
            self.restartUI()
        }
        
        let title = "Error"
        let message = errorType.rawValue
        let alerta = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alerta.addAction(dismissAction)
        
        present(alerta, animated: true, completion: nil)
        
    }
    
    // MARK: - enum de errores

    enum ErrorType: String {
        case Desconocido = "Unknown error"
        case Red = "Network error"
        case Libreria = "Error obtaining image from the gallery"
        case ProcesadoServidor = "Error analyzing the image"
        case ProcesadoLocal = "Error processing the image"
        case NoCaras = "No faces detected in the image"
        case DemasiadasCaras = "Two or more faces detected in the image, the image should contain only one(1) face"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.restartUI()
        if segue.identifier == "goToDetail"{
            let destinationController = segue.destination as? DetailTableViewController
            destinationController?.image = imageView.image
            destinationController?.infoJson = sender as? JSON
        }
    }
    
}
extension ViewController: URLSessionTaskDelegate {
    
    // MARK: - gestor de progreso de subida
    
    //Esta función muestra el progreso de subida de la imagen al servidor
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    {
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        if uploadProgress == 1 {
            self.progressLabel.text = analyzingImageMessage
        }
        DispatchQueue.main.async {
            self.progressView.setProgress(uploadProgress, animated: true)
        }
    }
    
    
}

