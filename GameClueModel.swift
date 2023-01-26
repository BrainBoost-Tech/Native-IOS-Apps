//
//	GameClueModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON


class GameClueModel : NSObject, NSCoding{
    
    var v : Int!
    var id : String!
    var ans : String!
    var clueType : String!
    var createdAt : String!
    var gameId : GameId!
    var hint1 : String!
    var hint2 : String!
    var hint3 : String!
    var name : String!
    var text : String!
    var type : String!
    var updatedAt : String!
    var url : String!
    var urls : [Url]!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        v = json["__v"].intValue
        id = json["_id"].stringValue
        ans = json["ans"].stringValue
        clueType = json["clue_type"].stringValue
        createdAt = json["createdAt"].stringValue
        let gameIdJson = json["gameId"]
        if !gameIdJson.isEmpty{
            gameId = GameId(fromJson: gameIdJson)
        }
        hint1 = json["hint_1"].stringValue
        hint2 = json["hint_2"].stringValue
        hint3 = json["hint_3"].stringValue
        name = json["name"].stringValue
        text = json["text"].stringValue
        type = json["type"].stringValue
        updatedAt = json["updatedAt"].stringValue
        url = json["url"].stringValue
        urls = [Url]()
        let urlsArray = json["urls"].arrayValue
        for urlsJson in urlsArray{
            let value = Url(fromJson: urlsJson)
            urls.append(value)
        }
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
        if ans != nil{
            dictionary["ans"] = ans
        }
        if clueType != nil{
            dictionary["clue_type"] = clueType
        }
        if createdAt != nil{
            dictionary["createdAt"] = createdAt
        }
        if gameId != nil{
            dictionary["gameId"] = gameId.toDictionary()
        }
        if hint1 != nil{
            dictionary["hint_1"] = hint1
        }
        if hint2 != nil{
            dictionary["hint_2"] = hint2
        }
        if hint3 != nil{
            dictionary["hint_3"] = hint3
        }
        if name != nil{
            dictionary["name"] = name
        }
        if text != nil{
            dictionary["text"] = text
        }
        if type != nil{
            dictionary["type"] = type
        }
        if updatedAt != nil{
            dictionary["updatedAt"] = updatedAt
        }
        if url != nil{
            dictionary["url"] = url
        }
        if urls != nil{
            var dictionaryElements = [[String:Any]]()
            for urlsElement in urls {
                dictionaryElements.append(urlsElement.toDictionary())
            }
            dictionary["urls"] = dictionaryElements
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
         ans = aDecoder.decodeObject(forKey: "ans") as? String
         clueType = aDecoder.decodeObject(forKey: "clue_type") as? String
         createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
         gameId = aDecoder.decodeObject(forKey: "gameId") as? GameId
         hint1 = aDecoder.decodeObject(forKey: "hint_1") as? String
         hint2 = aDecoder.decodeObject(forKey: "hint_2") as? String
         hint3 = aDecoder.decodeObject(forKey: "hint_3") as? String
         name = aDecoder.decodeObject(forKey: "name") as? String
         text = aDecoder.decodeObject(forKey: "text") as? String
         type = aDecoder.decodeObject(forKey: "type") as? String
         updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? String
         url = aDecoder.decodeObject(forKey: "url") as? String
         urls = aDecoder.decodeObject(forKey: "urls") as? [Url]

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
        if ans != nil{
            aCoder.encode(ans, forKey: "ans")
        }
        if clueType != nil{
            aCoder.encode(clueType, forKey: "clue_type")
        }
        if createdAt != nil{
            aCoder.encode(createdAt, forKey: "createdAt")
        }
        if gameId != nil{
            aCoder.encode(gameId, forKey: "gameId")
        }
        if hint1 != nil{
            aCoder.encode(hint1, forKey: "hint_1")
        }
        if hint2 != nil{
            aCoder.encode(hint2, forKey: "hint_2")
        }
        if hint3 != nil{
            aCoder.encode(hint3, forKey: "hint_3")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if text != nil{
            aCoder.encode(text, forKey: "text")
        }
        if type != nil{
            aCoder.encode(type, forKey: "type")
        }
        if updatedAt != nil{
            aCoder.encode(updatedAt, forKey: "updatedAt")
        }
        if url != nil{
            aCoder.encode(url, forKey: "url")
        }
        if urls != nil{
            aCoder.encode(urls, forKey: "urls")
        }

    }

}
