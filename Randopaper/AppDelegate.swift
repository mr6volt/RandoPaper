//
//  AppDelegate.swift
//  Randopaper
//
//  Created by Steven Avrenli on 9/24/16.
//  Copyright © 2016 Avrenli Design. All rights reserved.
//

import Cocoa

struct gAppVar {
    static let popover = NSPopover()
    
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    
    

    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
   // var loadedPhoto = ""
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            gAppVar.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        gAppVar.popover.performClose(sender)
    }
    
    func togglePopover(_ sender: AnyObject?) {
        var event = NSApp.currentEvent!
        if event.type == NSEventType.rightMouseDown {
        //    statusItem?.menu = myMenu
        //    statusItem?.popUpStatusItemMenu(myMenu)
            print("Right Button Clicked!")
        } else {
        if gAppVar.popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
        }
    }
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: "Entypo_d83c(0)_32")
            button.action = #selector(AppDelegate.togglePopover)
        }
               
        gAppVar.popover.contentViewController = RandopaperViewController(nibName: "RandopaperViewController", bundle: nil)
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

