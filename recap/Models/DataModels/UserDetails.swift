import Foundation

struct UserDetails:Codable, FireBaseDecodable {
    var firstName: String
    var lastName: String
    let patientUID: String
    var dateOfBirth: String
    var sex: String
    var bloodGroup: String
    var stage: String
    var profileImageURL: String?
    var familyMembers: [FamilyMember] = []
    var id: String
    var email: String
    
    // Default initializer
    init(firstName: String = "",
         lastName: String = "",
         patientUID: String = "",
         dateOfBirth: String = "",
         sex: String = "",
         bloodGroup: String = "",
         stage: String = "",
         profileImageURL: String? = nil,
         email: String = "",
         id: String) {
        self.id = UUID().uuidString
        self.firstName = firstName
        self.lastName = lastName
        self.patientUID = patientUID
        self.dateOfBirth = dateOfBirth
        self.sex = sex
        self.bloodGroup = bloodGroup
        self.stage = stage
        self.profileImageURL = profileImageURL
        self.id = id
        self.email = email
    }
    
    // FirebaseDecodable initializer
    init(id: String, fireData: Any) {
        self.id = id
        if let data = fireData as? [String: Any] {
            firstName = data["firstName"] as? String ?? ""
            lastName = data["lastName"] as? String ?? ""
            patientUID = data["patientUID"] as? String ?? ""
            dateOfBirth = data["dateOfBirth"] as? String ?? ""
            sex = data["sex"] as? String ?? ""
            bloodGroup = data["bloodGroup"] as? String ?? ""
            stage = data["stage"] as? String ?? ""
            profileImageURL = data["profileImageURL"] as? String
            familyMembers = (data["familyMembers"] as? [[String: Any]])?
                .compactMap { try? FamilyMember(from: $0 as! Decoder) } ?? []
            email = data["email"] as? String ?? ""
        } else {
            firstName = ""
            lastName = ""
            patientUID = ""
            dateOfBirth = ""
            sex = ""
            bloodGroup = ""
            stage = ""
            profileImageURL = nil
            familyMembers = []
            email = ""
        }
    }
    var dictionary: [String: Any] {
            return [
                "firstName": firstName,
                "lastName": lastName,
                "patientUID": patientUID,
                "dateOfBirth": dateOfBirth,
                "sex": sex,
                "bloodGroup": bloodGroup,
                "stage": stage,
                "profileImageURL": profileImageURL ?? "",
                "familyMembers": familyMembers.map { $0.dictionary },
                "email": email
            ]
        }
    // UserDefaults keys
        static let userDefaultsKey = "PatientProfile"

}


enum SexOptions: String, Codable, CaseIterable {
    case Male
    case Female
    case Other
}

enum BloodGroupOptions: String, Codable, CaseIterable {
    case APlus = "A+"
    case AMinus = "A-"
    case BPlus = "B+"
    case BMinus = "B-"
    case OPlus = "O+"
    case OMinus = "O-"
    case ABPlus = "AB+"
    case ABMinus = "AB-"
}

enum StageOptions: String, Codable, CaseIterable {
    case Early
    case Middle
    case Advanced
}
