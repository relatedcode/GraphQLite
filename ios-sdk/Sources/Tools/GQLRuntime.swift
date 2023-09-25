//
//	Runtime.swift
//	Swift Runtime [Swift 4]
//
//	The MIT License (MIT)
//
//	Copyright (c) 2016 Electricwoods LLC, Kaz Yoshikawa.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
//	Usage:
//
//		(find classes conform to objc protocol)
//		@objc protocol ThatProtocol {}
//		class ThatClass1: NSObject, ThatProtocol {}
//		Runtime.classes(conformToProtocol: ThatProtocol.Type.self) // [ThatClass1]
//
//		(find classes conform to swift protocol)
//		protocol ThisProtocol {}
//		class ThisClass1: ThisProtool {}
//		class ThisClass2: ThisClass1 {}
//		struct ThisStruct: ThisProtocol {}
//		Runtime.classes(conformTo: ThisProtocol.Type.self) // [ThisClass1, ThisClass2]
//
//		(find subclasses of a specified class)
//		class HerClass1 {}
//		class HerClass2: HerClass1 {}
//		class HerClass3: HerClass2 {}
//		Runtime.subclasses(of: HerClass1.self) // [HerClass1, HerClass2, HerClass3]
//		Runtime.subclasses(of: HerClass2.self) // [HerClass2, HerClass3]
//		Runtime.subclasses(of: HerClass3.self) // [HerClass3]
//
//	Caution:
//		You may not be able to use `as?` operator to filter AnyClass from `allClasses()`.
//		Because there are some classes such as `CNZombie` which causees crash with `as?`
//		operator.
//
//			for type in Runtime.allClasses() {
//				if let type = type as? NSView.self {  // could cause crash
//				}
//			}
//

import Foundation

class GQLRuntime {

	public static func allClasses() -> [AnyClass] {
		let numberOfClasses = Int(objc_getClassList(nil, 0))
		if numberOfClasses > 0 {
			let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
			let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
			let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
			assert(numberOfClasses == count)
			defer { classesPtr.deallocate() }
			let classes = (0 ..< numberOfClasses).map { classesPtr[$0] }
			return classes
		}
		return []
	}

	public static func subclasses(of `class`: AnyClass) -> [AnyClass] {
		return self.allClasses().filter {
			var ancestor: AnyClass? = $0
			while let type = ancestor {
				if ObjectIdentifier(type) == ObjectIdentifier(`class`) { return true }
				ancestor = class_getSuperclass(type)
			}
			return false
		}
	}

	public static func classes(conformToProtocol `protocol`: Protocol) -> [AnyClass] {
		let classes = self.allClasses().filter { aClass in
			var subject: AnyClass? = aClass
			while let aClass = subject {
				if class_conformsToProtocol(aClass, `protocol`) { return true }
				subject = class_getSuperclass(aClass)
			}
			return false
		}
		return classes
	}

	public static func classes<T>(conformTo: T.Type) -> [AnyClass] {
		return self.allClasses().filter { $0 is T }
	}
}
