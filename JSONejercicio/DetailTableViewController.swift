//
//  DetailTableViewController.swift
//  JSONejercicio
//
//  Created by Pau Enrech on 13/03/2019.
//  Copyright © 2019 Pau Enrech. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailTableViewController: UITableViewController {
    
    // MARK: - variables y constantes
    
    var image: UIImage?
    var displayLink : CADisplayLink?
    
    var infoJson: JSON?
    var attributesList = [Attributes.Attribute]()
    var accessoryList = [Attributes.AccessoryItem]()
    
    var startValue: Double = 0
    var endValue: Double = 0
    let animationDuration = 2.0
    
    var navigationBarOpaque = false
    let titlesForSection = ["Attributes", "Accessories"]
    
    let animationStartDate = Date()
    
    // MARK: -outlets
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var ageLabel: UILabel!
    
    // MARK: - funciones de vista y estilos
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView?.frame.size = CGSize(width: tableView.frame.width, height: tableView.frame.width)
        tableView.contentInsetAdjustmentBehavior = .never

        let attributes = Attributes(attributesJson: infoJson!)
        headerImageView.image = image?.DrawOnImage(rectangleSize: attributes.normalizeRectanglePosition(imageSizeInScreen: headerView.frame))
     
        print(infoJson!)
        endValue = Double(attributes.age!)
        attributesList = attributes.getListOfattributes()
        accessoryList = attributes.getListOfAccesories()
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    
        displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink!.add(to: .main, forMode: .default)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .blackTranslucent

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
 
    // MARK: - función animación edad
    
    // Esta función es la encargada de animar el número de la edad desde 0 hasta la edad que ha estimado el servidor
    @objc func handleUpdate(){
        let now = Date()
        let elapsedTime = now.timeIntervalSince(animationStartDate)

        if elapsedTime > animationDuration {
            let intEndValue = Int(endValue)
            self.ageLabel.text = "\(intEndValue)"
            displayLink?.remove(from: .main, forMode: .default)
        } else {
            let percentage = elapsedTime / animationDuration
            let value = startValue + percentage * (endValue - startValue)
            let intValue = Int(value)
            self.ageLabel.text = "\(intValue)"
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if accessoryList.count > 0 {
            return 2
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return attributesList.count
        } else {
            return accessoryList.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttributeCell", for: indexPath) as! AttributesTableViewCell
            cell.iconForLabel.image = UIImage(named: attributesList[indexPath.row].icon!)
            cell.label.text = attributesList[indexPath.row].label!
            cell.message.text = attributesList[indexPath.row].message
            cell.containerView.layer.cornerRadius = 20
   
            if indexPath.row == attributesList.count - 1 {
                cell.containerViewBottomConstraint.constant = 10
            } else {
                cell.containerViewBottomConstraint.constant = 0
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AcessoryCell", for: indexPath) as! AccessoriesTableViewCell
            cell.iconView.image = UIImage(named: accessoryList[indexPath.row].icon!)
            cell.label.text = accessoryList[indexPath.row].label
            cell.containerView.layer.cornerRadius = 20
            
            if indexPath.row == accessoryList.count - 1 {
                print("True")
                cell.containerViewBottomConstraint.constant = 10
            } else {
                cell.containerViewBottomConstraint.constant = 0
            }
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == attributesList.count - 1 {
                return 90
            }
        } else {
            if indexPath.row == accessoryList.count - 1 {
                return 90
            }
        }
        return 80
    }
   
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let label = createHeaderLabel(section)
        let minPaddingHeight: CGFloat = 32.0
        let size = label.sizeThatFits(CGSize(width: view.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let finalHeight = size.height + minPaddingHeight
        
        switch finalHeight {
        case 0...55:
            return 55
        default:
            return finalHeight
        }
        
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        let label = createHeaderLabel(section)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.defaultRed
        headerView.backgroundView = backgroundView
        headerView.addSubview(label)
        
        return headerView
    }
    
    // MARK: - función gestion de scroll
    
    //Esta función gestiona si se muestra o no la barra de navegación al hacer scroll y si está es transparente o no
    //En función de la posición del scroll
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollTop = tableView.contentOffset.y <= 0 ? true : false
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        let scrollUp = translation.y > 0 ? true : false
    
        guard let navigationControllerUnWrapped = navigationController else {
            return
        }
        if scrollUp{
            if navigationControllerUnWrapped.navigationBar.isHidden{
                navigationControllerUnWrapped.setNavigationBarHidden(false, animated: true)
            }
            if scrollTop{
                if navigationBarOpaque {
                    UIView.animate(withDuration: 0.3) {
                        navigationControllerUnWrapped.navigationBar.backgroundColor = .clear
                    }
                    navigationBarOpaque = false
                }
            } else {
                
                if !navigationBarOpaque {
                    UIView.animate(withDuration: 0.3) {
                        navigationControllerUnWrapped.navigationBar.backgroundColor = UIColor.defaultRed
                    }
                    navigationBarOpaque = true
                }
            }
        } else {
            if !navigationControllerUnWrapped.navigationBar.isHidden{
                navigationControllerUnWrapped.setNavigationBarHidden(true, animated: true)
            }
        }
        
        if scrollTop {
            UIView.animate(withDuration: 0.3) {
                UIApplication.shared.statusBarView?.backgroundColor = .clear
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                UIApplication.shared.statusBarView?.backgroundColor = UIColor.defaultRed
            }
        }
        
    }

    // MARK: - función crear section header
    
    //En esta función se crea y customizan los headers de las secciones
    func createHeaderLabel(_ section: Int) -> UILabel{
        let labelWidhtPadding: CGFloat = 32.0
        let label = UILabel(frame: CGRect(x: labelWidhtPadding / 2, y: 0, width: tableView.frame.width - labelWidhtPadding, height: 0.0))
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont(name: "Comfortaa-Bold", size: 18)
        label.textColor = UIColor.white
        label.autoresizingMask = .flexibleHeight
        label.text = titlesForSection[section]
        label.backgroundColor = .clear
        return label
    }


}
