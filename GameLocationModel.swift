//
//	GameLocationModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON


class GameLocationModel : NSObject, NSCoding{

	var v : Int!
	var id : String!
	var createdAt : String!
	var name : String!
	var updatedAt : String!
    var isSelect : Bool!
    var url: String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		v = json["__v"].intValue
		id = json["_id"].stringValue
		createdAt = json["createdAt"].stringValue
		name = json["name"].stringValue
		updatedAt = json["updatedAt"].stringValue
        url = json["url"].stringValue
        isSelect = false
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if v != nil{
			dictionary["__v"] = v
		}
		if id != nil{
			dictionary["_id"] = id
		}
		if createdAt != nil{
			dictionary["createdAt"] = createdAt
		}
		if name != nil{
			dictionary["name"] = name
		}
		if updatedAt != nil{
			dictionary["updatedAt"] = updatedAt
		}
        if url != nil{
            dictionary["url"] = url
        }
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         v = aDecoder.decodeObject(forKey: "__v") as? Int
         id = aDecoder.decodeObject(forKey: "_id") as? String
         createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
         name = aDecoder.decodeObject(forKey: "name") as? String
         updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? String
         url = aDecoder.decodeObject(forKey: "url") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if v != nil{
			aCoder.encode(v, forKey: "__v")
		}
		if id != nil{
			aCoder.encode(id, forKey: "_id")
		}
		if createdAt != nil{
			aCoder.encode(createdAt, forKey: "createdAt")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}
		if updatedAt != nil{
			aCoder.encode(updatedAt, forKey: "updatedAt")
		}
        if url != nil{
            aCoder.encode(url, forKey: "url")
        }

	}

}
