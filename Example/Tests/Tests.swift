//
//  Tests.swift
//  ApodidaeTests
//
//  Created by Johnathan D Raymond on 8/13/15.
//  Copyright © 2015 Knights Who Say Nil. All rights reserved.
//

import Quick
import Nimble
import Apodidae

class RegistrarSpec: QuickSpec {
    
    override func spec() {
        describe("The Registrar"){
            let registrar = Registrar.instance
        
            beforeEach {
                registrar.clearRegistrations()
            }
            
            context("when nothing is registered") {
                it("returns nothing") {
                    let proto = registrar.obtain(ProtoA.self)
                    expect(proto).to(beNil())
                }
            }
            
            context("when protocols are registered") {
                
                beforeEach {
                    registrar.register(ProtoA.self, implementation: ImplementationA.self)
                    registrar.register(ProtoB.self, implementation: ImplementationB.self)
                    registrar.register(ProtoC.self, implementation: ImplementationC.self)
                }
                
                it("saves registrations") {
                    let impl = ImplementationA.self
                    expect { registrar.concreteType(ProtoA.self) == impl }.to(beTruthy())
                }
                
                it("returns simple instances") {
                    let proto = registrar.obtain(ProtoA.self) as? ProtoA
                    
                    expect(proto).notTo(beNil())
                    expect(proto!.hello()).to(equal(ImplementationA.NAME))
                }
            
                it("returns chained instances") {
                    let proto = registrar.obtain(ProtoB.self) as? ProtoB
                    
                    expect(proto).notTo(beNil())
                    
                    let implB = proto as? ImplementationB
                    expect(implB).notTo(beNil())
                    expect(implB?.protoA.hello()).to(equal(ImplementationA.NAME))
                }
                
                it("injects third party protocols") {
                    let proto = registrar.obtain(ProtoC.self) as? ProtoC
                    
                    expect(proto).notTo(beNil())
                    expect(proto!.hello()).to(equal(ImplementationC.NAME))
                }
                
                it("overwrites registrations") {
                    registrar.register(ProtoC.self, implementation: OtherImplementationC.self)
                    
                    let proto = registrar.obtain(ProtoC.self) as? ProtoC
                    
                    expect(proto).notTo(beNil())
                    expect(proto!.hello()).to(equal(OtherImplementationC.NAME))
                }
            }
        }
    }
}

public protocol ProtoA: Injectable {
    func hello() -> String
}

public final class ImplementationA : ProtoA {
    public static let NAME = "ImplementationA"
    public static func dependencies() -> [Any.Type] {
        return [Any.Type]()
    }
    
    required public init(dependencies: DependencyContainer) {
        
    }
    
    public func hello() -> String {
        return ImplementationA.NAME
    }
}

public protocol ProtoB : Injectable {}

public final class ImplementationB : ProtoB {
    public static func dependencies() -> [Any.Type] {
        return [
            ProtoA.self
        ]
    }
    
    public let protoA: ProtoA
    
    required public init(dependencies: DependencyContainer) {
        protoA = dependencies.extract(ProtoA.self)!
    }
}

public protocol ProtoC {
    func hello() -> String
}

public final class ImplementationC : ProtoC, Injectable {
    public static let NAME = "ImplementationC"

    public static func dependencies() -> [Any.Type] {
        return []
    }
    
    public func hello() -> String {
        return ImplementationC.NAME
    }
    
    required public init(dependencies: DependencyContainer) {
    }
}

public final class OtherImplementationC: ProtoC, Injectable {
    public static let NAME = "OtherImplementationC"
    
    public static func dependencies() -> [Any.Type] {
        return []
    }
    
    public func hello() -> String {
        return OtherImplementationC.NAME
    }
    
    required public init(dependencies: DependencyContainer) {
    }
}

