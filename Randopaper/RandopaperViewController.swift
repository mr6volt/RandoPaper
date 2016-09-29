//
//  RandopaperViewController.swift
//  Randopaper
//
//  Created by Steven Avrenli on 9/24/16.
//  Copyright © 2016 Avrenli Design. All rights reserved.
//

import Cocoa
import Alamofire
import AlamofireImage

struct gVar {
    static var selectedPhoto = [Any]()
    static var selectedPhoto2 = ""
    static var wallPaperURL = ""
    static var tags = ""
    static var tags2 = ""
    static let username = NSUserName()
    static var path = ""
    static var path2 = DownloadRequest.suggestedDownloadDestination()
    static var tagFromSearch = "wallpaper"
    static var oldSelectedPhoto2 = ""
    static let apiKey = "f28739b50441fda42e3e3c59f2656251"
    static let baseURL = "https://api.flickr.com/services/rest/?&method=flickr.photos.search&format=json&nojsoncallback=?"
    static let baseURL2 = "https://api.flickr.com/services/rest/?&method=flickr.photos.getSizes&format=json&nojsoncallback=?"
    static let apiString = "&api_key=\(gVar.apiKey)"
    static var searchString2 = ""
}

class RandopaperViewController: NSViewController {
    
    func GetFlickrData(_ tags: String) {
        var searchString = "&tags=\(tags)"
        gVar.tags = tags
        gVar.tags2 = tags
        var firstRequestURL = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
        var requestURL = URL(string: gVar.baseURL + gVar.apiString + firstRequestURL!)
        var session = URLSession.shared
        let task = session.dataTask(with: requestURL! as URL, completionHandler: { data, response, error -> Void in
            
            do {
                let result = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.allowFragments, JSONSerialization.ReadingOptions.mutableContainers]) as? [String : AnyObject]
                var list = [[]]
                // Debug
                print(tags)
                
                var result2 = result?["photos"]?["photo"] as? [[String : AnyObject]]
                if(result2?.isEmpty == false){
                    for anItem in result2! {
                        let userName = anItem["owner"]! as AnyObject
                        let photoID = anItem["id"]! as AnyObject
                        list.append([userName, photoID])
                    }
                } else {
                    // Debug
                    print("Borked Array at Flickr JSON Search responce!")
                    print("OR, Search Result was Empty!")
                    // Annoy the USer
                    self.errorShow()
                }
                
                var randomIndex = Int(arc4random_uniform(UInt32(list.count)))
                gVar.selectedPhoto = list[randomIndex]
                var oldSearchString2 = ""
                let isSelectedPhotoValid = gVar.selectedPhoto.indices.isEmpty
                
                // Prevents Index Out of Range Crash
                if (isSelectedPhotoValid == false) {
                    gVar.searchString2 = "&photo_id=\(gVar.selectedPhoto[1])"
                    oldSearchString2 = gVar.searchString2
                } else {
                    gVar.searchString2 = oldSearchString2
                }
                
                var requestURL2 = URL(string: gVar.baseURL2 + gVar.apiString + gVar.searchString2)
                
                // Clean the List ... just in case!
                list.removeAll()
                
                let task2 = session.dataTask(with: requestURL2! as URL, completionHandler: { data, response, error -> Void in
                    
                    do {
                        let resultDownload = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.allowFragments, JSONSerialization.ReadingOptions.mutableContainers]) as? [String : AnyObject]
                        var list2 = [[]]
                        let resultDownload2 = resultDownload?["sizes"]?["size"] as? [[String : AnyObject]]
                        
                        // Prevents Index Out Of Range Crash
                        if (resultDownload2?.isEmpty == false){
                            for anItem in resultDownload2! {
                                let label = anItem["label"]! as AnyObject
                                let source = anItem["source"]! as AnyObject
                                
                                list2.append([label, source])
                            }
                        } else {
                            // Debug
                            print("Borked Array at FLICKR JSON Photo Selection Responce!")
                            // Annoy the User
                            self.errorShow()
                        }
                        
                        let isIndexValid = list2.indices.contains(10)
                        // Prevents Yet Another Crash
                        if (isIndexValid == true) {
                            
                            var lastOfList2 = list2.last
                            print(lastOfList2![1])
                            gVar.selectedPhoto2 = "\(lastOfList2![1])"
                            gVar.oldSelectedPhoto2.removeAll()
                            gVar.oldSelectedPhoto2 = gVar.selectedPhoto2
                        } else {
                            gVar.selectedPhoto2 = gVar.oldSelectedPhoto2
                        }
                        
                        gVar.wallPaperURL = gVar.selectedPhoto2
                        
                        //Clean the List2... just in case
                        list2.removeAll()
                        
                        // Download the image we picked!
                        self.downloadImage()
                    } catch {
                        print(error)
                    }
                })
                task2.resume()
                
            } catch {
                print(error)
            }
            
        })
        
        task.resume()
    }
    
    // Image Screen Output
    @IBOutlet var imageView: NSImageView?
    // Downloads the images for us
    func downloadImage() {
        Alamofire.request(gVar.wallPaperURL).responseImage { (response) -> Void  in
            if let image = response.result.value {
                self.imageView?.image = image
                // This section resizes the popover to eliminate blank spaces caused by different image aspect ratios
                // This is the ViewController height ... probably don't need it.
                let viewHeight = 386
                //This is the ImageView height ... images cannot be larger than this when displayed.
                let imageViewHeight = 356
                // Calculate the width of images AS DISPLAYED and add 120 pixels to account for the buttons.
                var imageWidth: Int = Int(CGFloat(image.size.width))
                var imageHeight: Int = Int(CGFloat(image.size.height))
                var imageArc = Float(imageHeight) / Float(imageWidth)
                var newViewWidth = (Float(imageViewHeight) / imageArc) + Float(120)
                // Set new width on popover to make it grow and shrink dynamically. YAY MAGIC!
                gAppVar.popover.contentSize.width =  CGFloat(floor(newViewWidth))
            }
        }
    }
    
    // Tag Search box
    @IBOutlet weak var searchTextBox: NSTextField!
    
    // Enter Key Listener for the searchBox
    @IBAction func SearchReturn(_ sender: AnyObject) {
        imageRefresher(sender.mouseUp! as AnyObject)
    }
    
    // Refresh Image
    @IBAction func imageRefresher(_ sender: AnyObject) {
        var searchBox = searchTextBox.objectValue as! String
        if (searchBox != nil) { gVar.tagFromSearch = "\(searchBox)" } else { gVar.tagFromSearch = "new" }
        // Rerun the code in the view setup function ... i'm lazy okay?
        viewDidLoad()
    }
    
    // Set Current Image as Desktop Wallpaper
    @IBAction func setWallpaper(_ sender: AnyObject) {
        gVar.path2 = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(gVar.wallPaperURL, to: gVar.path2)
        
        var urlExploder = gVar.wallPaperURL.characters.split {$0 == "/"}.map(String.init)
        print(urlExploder)
        var fileWithPath = "/Users/\(gVar.username)/Documents/\(urlExploder[3])"
        var isImageOnDrive = false
        while (isImageOnDrive == false) {
            do {
                let imgurl = NSURL.fileURL(withPath: fileWithPath)
                let workspace = NSWorkspace.shared()
                if let screen = NSScreen.main()  {
                    try workspace.setDesktopImageURL(imgurl, for: screen, options: [:])
                    isImageOnDrive = true
                }
            } catch {
                print(error)
                // This file isn't done downloading, try again!
                isImageOnDrive = false
                sleep(1)
            }
        }
        
    }
    
    // Controls Error message
    @IBOutlet weak var errorStatus: NSTextField!
    func errorShow() {
        self.errorStatus.setValue(false, forKey: "Hidden")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.errorStatus.setValue(true, forKey: "Hidden")
        }
        
    }
    
    // Quit RandoPaper
    @IBAction func killRandoPaper(_ sender: AnyObject) {
        exit(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = true
        // Do view setup here.
        GetFlickrData(gVar.tagFromSearch)
    }
    
}
