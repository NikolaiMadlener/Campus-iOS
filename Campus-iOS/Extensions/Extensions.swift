//
//  Extensions.swift
//  Campus-iOS
//
//  Created by Milen Vitanov on 15.12.21.
//

import Foundation
import Alamofire
import CoreLocation
import SWXMLHash
import XMLCoder
import SwiftUI

extension Bundle {
    var version: String { infoDictionary?["CFBundleShortVersionString"] as? String ?? "1" }
    var build: String { infoDictionary?["CFBundleVersion"] as? String ?? "1.0" }
    var userAgent: String { "TCA iOS \(version)/\(build)" }
}

extension Session {
    static let defaultSession: Session = {
        let adapterAndRetrier = Interceptor(adapter: AuthenticationHandler(), retrier: AuthenticationHandler())
        let cacher = ResponseCacher(behavior: .cache)
//        let trustManager = ServerTrustManager(evaluators: TUMCabeAPI.serverTrustPolicies)
        let manager = Session(interceptor: adapterAndRetrier, redirectHandler: ForceHTTPSRedirectHandler(), cachedResponseHandler: cacher)
        return manager
    }()
}

extension DataRequest {
    @discardableResult
    public func responseXML(queue: DispatchQueue = .main,
                             completionHandler: @escaping (AFDataResponse<XMLIndexer>) -> Void) -> Self {

        response(queue: queue,
                 responseSerializer: XMLSerializer(),
                 completionHandler: completionHandler)
    }
}

extension UIColor {
    static let tumBlue = UIColor(red: 0, green: 101/255, blue: 189/255, alpha: 1)
}

extension Color {
    
    static var tumBlue = Color("tumBlue")
    
    static var widget = Color("widgetColor")
}

extension JSONDecoder.DateDecodingStrategy: DecodingStrategyProtocol { }

extension XMLDecoder.DateDecodingStrategy: DecodingStrategyProtocol { }

extension JSONDecoder: DecoderProtocol {
    static var contentType: [String] { return ["application/json"] }
    static func instantiate() -> Self {
        //  infers the type of self from the calling context:
        func helper<T>() -> T {
            let decoder = JSONDecoder()
            return decoder as! T
        }
        return helper()
    }
}

extension XMLDecoder: DecoderProtocol {
    static var contentType: [String] { return ["text/xml"] }
    static func instantiate() -> Self {
        // infers the type of self from the calling context
        func helper<T>() -> T {
            let decoder = XMLDecoder()
            return decoder as! T
        }
        return helper()
    }
}

extension View {
    /// Applies the given transform according to condition.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transformT: The transform to apply to the source `View` if condition is true.
    ///   - transformF: The transform to apply to the source `View` if condition is false.
    /// - Returns: Modified `View` based on condition.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transformT: (Self) -> Content, transformF: ((Self) -> Content)? = nil) -> some View {
        if condition {
            transformT(self)
        } else if let transform = transformF {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func `expandable`(size: Binding<WidgetSize>, initialSize: WidgetSize, biggestSize: WidgetSize = .bigSquare, scale: Binding<CGFloat> = .constant(1)) -> some View {
        self
            .onTapGesture{} // Must come before the long press gesture, else scrolling breaks.
            .onLongPressGesture(maximumDistance: .infinity) {
                let vibrator = UIImpactFeedbackGenerator(style: .heavy)
                
                if initialSize == biggestSize {
                    vibrator.impactOccurred(intensity: 0.5)
                    return
                }
                
                vibrator.impactOccurred()
                
                withAnimation(.widget) {
                    
                    scale.wrappedValue = 1
                    
                    if size.wrappedValue == initialSize {
                        size.wrappedValue = biggestSize
                    } else {
                        size.wrappedValue = initialSize
                    }
                }
                
            } onPressingChanged: { value in
                if !value {
                    withAnimation(.widget) {
                        scale.wrappedValue = 1
                    }
                    return
                }
                withAnimation(.easeOut(duration: 0.65)) { // Should be longer than long press gesture duration.
                    scale.wrappedValue = 0.975
                }
            }
            .scaleEffect(x: scale.wrappedValue, y: scale.wrappedValue)
    }
}

extension Animation {
    static let widget: Animation = .interpolatingSpring(
        mass: 0.5,
        stiffness: 100,
        damping: 10,
        initialVelocity: 10
    )
}

extension UIColor {
    
    @available(iOS 13, *)
    static func useForStyle(dark: UIColor, white: UIColor) -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .dark ? dark : white
        }
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

// For the NewsView: In order to show the right link when using the WebView when tapping on a NewsCard
extension URL: Identifiable {
    public var id: UUID { UUID() }
}

extension Notification.Name {
    static let tcaSheetBecameActiveNotification = Notification.Name("tcaSheetBecameActiveNotification")
    static let tcaSheetBecameInactiveNotification = Notification.Name("tcaSheetBecameInactiveNotification")
}
