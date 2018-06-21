//
//  ProfileVC.swift
//  NVOII
//
//  Created by Himanshu Singla on 27/01/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imgViewProfile: SetCornerImageView!
    @IBOutlet weak var btnChooseImage: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPhoneNo: UITextField!
    @IBOutlet weak var txtFieldCountryCode: UITextField!
    @IBOutlet weak var btnChangePassword: SetCorner!
    @IBOutlet weak var viewFullName: UIView!
    @IBOutlet weak var viewFirstName: UIView!
    @IBOutlet weak var txtFieldFirstName: UITextField!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var viewLastName: UIView!
    @IBOutlet weak var txtFieldLastName: UITextField!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    var countryID = Int()
    var currentLat = String()
    var currentLong = String()
    var ImagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultSettings()
        showDetails()
    }
    func showDetails() {
        txtFieldName.text = profile.firstName + " " + profile.lastName
        txtFieldFirstName.text = profile.firstName
        txtFieldLastName.text = profile.lastName
        txtFieldEmail.text = profile.email
        txtFieldPhoneNo.text = profile.contactNumber
        txtFieldCountryCode.text = profile.countryCode
        countryID = profile.countryID
        if  profile.imageFile != "" {
            imgViewProfile.sd_setImage(with: URL(string: profile.imageFile), placeholderImage: #imageLiteral(resourceName: "icnProfile"))
        } else {
            imgViewProfile.image = #imageLiteral(resourceName: "icnProfile")
        }
    }
 

    func setDefaultSettings() {
        txtFieldName.isUserInteractionEnabled = false
        txtFieldEmail.isUserInteractionEnabled = false
        txtFieldCountryCode.isUserInteractionEnabled = false
        txtFieldPhoneNo.isUserInteractionEnabled = false
        viewFirstName.isHidden = true
        viewLastName.isHidden = true
        viewFullName.isHidden = false
        btnEdit.isSelected = false
        btnChooseImage.isHidden = true
    }
    func editableSettings() {
        viewFirstName.isHidden = false
        viewLastName.isHidden = false
        viewFullName.isHidden = true
        btnEdit.isSelected = true
        btnChooseImage.isHidden = false
    }
    
      //MARK:- Image Delegates
    
    func customActionSheet()
    {
        let myActionSheet = UIAlertController()
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openGallary()
        })
        let cmaeraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openCamera()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        myActionSheet.addAction(galleryAction)
        myActionSheet.addAction(cmaeraAction)
        myActionSheet.addAction(cancelAction)
        
        self.present(myActionSheet, animated: true, completion: nil)
        
    }
    
    func openCamera(){
        
        DispatchQueue.main.async {
            
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))  {
                self.ImagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.ImagePicker.delegate = self
                self.ImagePicker.allowsEditing = false
                self .present(self.ImagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Alert", message: "Camera is not supported", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func openGallary()
    {
        ImagePicker.delegate = self
        ImagePicker.allowsEditing = true //2
        ImagePicker.sourceType = .photoLibrary //3
        present(ImagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        DispatchQueue.main.async
            {
                NSLog("info=%@", info)
                if(picker.sourceType == UIImagePickerControllerSourceType.camera)
                {
                    let objImagePick: UIImage = (info[UIImagePickerControllerOriginalImage] as! UIImage)
                    self.imgViewProfile.image = self.resizeImage(objImagePick)
                    
                }
                else
                {
                    let objImagePick: UIImage = (info[UIImagePickerControllerEditedImage] as! UIImage)
                    self.imgViewProfile.image = self.resizeImage(objImagePick)
                }
        }
        picker .dismiss(animated: true, completion: {
        })
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func resizeImage(_ image: UIImage) -> UIImage {
        
        var actualHeight: CGFloat = image.size.height
        var actualWidth: CGFloat = image.size.width
        let maxHeight: CGFloat = 300.0
        let maxWidth: CGFloat = 300.0
        var imgRatio: CGFloat = actualWidth/actualHeight
        let maxRatio: CGFloat = maxWidth/maxHeight
        let compressionQuality: CGFloat = 0.5;//50 percent compression
        
        if (actualHeight > maxHeight || actualWidth > maxWidth)
        {
            if(imgRatio < maxRatio)
            {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if(imgRatio > maxRatio)
            {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else
            {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData: Data = UIImageJPEGRepresentation(img, compressionQuality)!
        UIGraphicsEndImageContext()
        return UIImage(data: imageData)!
    }
    

    //MARK: - Actions
    @IBAction func actionBack(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated : true)
    }
    @IBAction func actionEditProfile(_ sender: UIButton) {
        if !btnEdit.isSelected {
            editableSettings()
        } else if txtFieldFirstName.isBlank {
                proxy.sharedProxy().displayStatusCodeAlert("Please enter first name")
            } else  if txtFieldLastName.isBlank {
                 proxy.sharedProxy().displayStatusCodeAlert("Please enter last name")
            } else {
                self.uploadImages(self.imgViewProfile.image!)
        }
    }
    
    @IBAction func actionChooseImage(_ sender: UIButton) {
        customActionSheet()
    }
    @IBAction func actionChangePassword(_ sender: UIButton) {
        let passwordVC = storyboard?.instantiateViewController(withIdentifier: "UserChangePasswordVC") as! UserChangePasswordVC
        self.present(passwordVC, animated: true, completion: nil)
    }
    
    //MARK: - SignUp APIs
    func uploadImages(_ stampImage: UIImage) {
        uploadImage(
            stampImage ,
            progress: { percent in
        },
            completion: { completed in
                if(completed == true) {
                }else {
                    
                }
        })
    }
    func uploadImage(_ stampImage: UIImage , progress: (_ percent: Float) -> Void, completion: @escaping (_ completed: Bool) -> Void)   {
        let reachable = Reachability()
        if reachable?.isReachable == true {
            let signUpURL = "\(KServerUrl)\(KImageUpdate)"
            guard let imageData1 = UIImageJPEGRepresentation(stampImage , 0.5) else {
                return
            }
            KAppDelegate.showActivityIndicator()
            Alamofire.upload(multipartFormData:{ multipartFormData in
                let interval = NSDate().timeIntervalSince1970
                multipartFormData.append( imageData1, withName:"User[profile_file]", fileName:  "image\(interval).png", mimeType: "image/png")
                multipartFormData.append(self.txtFieldFirstName.trimmedValue.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName : "User[first_name]")
                multipartFormData.append(self.txtFieldLastName.trimmedValue.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName : "User[last_name]")
            },
                             usingThreshold:UInt64.init(),
                             to:signUpURL,
                             method:.post,
                             headers:["User-Agent":"\(userAgent)", "auth_code":proxy.sharedProxy().authNil()],
                             encodingCompletion: { encodingResult in
                                switch encodingResult {
                                case .success(let upload, _, _):
                                    upload.responseJSON { response in
                                        KAppDelegate.hideActivityIndicator()
                                        if response.result.value != nil {
                                             if response.response?.statusCode == 200 || response.response?.statusCode == 1000  {
                                                let JSON = response.result.value as! NSDictionary
                                                self.serviceResponse(JSON.mutableCopy() as! NSMutableDictionary)
                                            }else{
                                                proxy.sharedProxy().displayStatusCodeAlert("Something went wrong")
                                            }
                                        }else{
                                            proxy.sharedProxy().displayStatusCodeAlert("No response found")
                                        }
                                    }
                                case .failure(let encodingError):
                                    KAppDelegate.hideActivityIndicator()
                                    print(encodingError)
                                }
            })
        }else{
            proxy.sharedProxy().openSettingApp()
        }
    }

    //MARK: - Service response
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KImageUpdate)")  {
            KAppDelegate.debugPrint(text: "Profile Response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if JSON["detail"] != nil  {
                    let detail = JSON["detail"] as! NSDictionary
                    if detail["id"] != nil {
                        profile.id = detail["id"] as! Int
                    }
                    if detail["contact_no"] != nil {
                        profile.contactNumber = detail["contact_no"] as! String
                    }
                    if detail["image_file"] != nil {
                        profile.imageFile = detail["image_file"] as! String
                    }
                    if detail["email"] != nil {
                        profile.email = detail["email"] as! String
                    }
                    if detail["first_name"] != nil {
                        profile.firstName = detail["first_name"] as! String
                    }
                    if detail["last_name"] != nil {
                        profile.lastName = detail["last_name"] as! String
                    }
                    if detail["referral_code"] != nil {
                        profile.referralCode = detail["referral_code"] as! String
                    }
                    if detail["pay_type"] != nil {
                        profile.payType = detail["pay_type"] as! Int
                    }
                    if detail["is_verify"] != nil {
                        profile.isVerified = detail["is_verify"] as! Int
                    }
                    if detail["telephone_code"] != nil {
                        profile.countryCode = detail["telephone_code"] as! String
                    }
                    if let countryID = detail["country"] as? String {
                        profile.countryID = Int(countryID)!
                    } else if let countryID =  detail["country"] as? Int {
                        profile.countryID = countryID
                    }
                }
                setDefaultSettings()
                showDetails()
                proxy.sharedProxy().displayStatusCodeAlert("Profile  successfully updated")
            }else{
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
