//
//  FilterDateModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/04/2021.
//

enum FilterSelection: Int {
    case none = 0, day, week, month, other
    
    public typealias RawValue = Int
    
    public var rawValue: RawValue {
        switch self {
        case .none:
            return 0
        case .day:
            return 1
        case .week:
            return 2
        case .month:
            return 3
        case .other:
            return 4
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case 0:
            self = .none
        case 1:
            self = .day
        case 2:
            self = .week
        case 3:
            self = .month
        case 4:
            self = .other
        default:
            self = .none
        }
    }
}
