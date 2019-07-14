//
//  NoteExtension.swift
//  YandexCourse
//
//  Created by Vitaliy Pyatnikov on 07.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation
import UIKit

extension Note {
    static func parse(json: [String: Any]) -> Note? {
        // TODO: - change print with log
        guard let title = json["title"] as? String else {
            print("Title not found in json: \(json)")
            return nil
        }
        guard let content = json["content"] as? String else {
            print("Content not found in json: \(json)")
            return nil
        }
        let importance: Importance
        if let importanceAsString = json["importance"] as? String {
            importance = Importance(rawValue: importanceAsString) ?? .usual
        } else {
            importance = .usual
        }

        guard let uid = json["uid"] as? String else {
            print("Uid not found in json: \(json)")
            return nil
        }
        let color: UIColor
        if let colorDictionary = json["color"] as? [String: Any],
            let red = colorDictionary["red"] as? CGFloat,
            let green = colorDictionary["green"] as? CGFloat,
            let blue = colorDictionary["blue"] as? CGFloat,
            let alpha = colorDictionary["alpha"] as? CGFloat {
            color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            print("Color not found in json: \(json), use default")
            color = .white
        }

        let selfDestructionDate: Date?
        if let selfDestructionAsInt = json["selfDestructionDate"] as? Double {
            selfDestructionDate = Date(timeIntervalSince1970: selfDestructionAsInt)
        } else {
            selfDestructionDate = nil
        }
        return Note(title: title,
                    content: content,
                    importance: importance,
                    uid: uid,
                    color: color,
                    selfDestructionDate: selfDestructionDate)
    }
    var json: [String: Any] {
        var jsonObject = [String: Any]()
        jsonObject.updateValue(title, forKey: "title")
        jsonObject.updateValue(content, forKey: "content")
        if importance != .usual {
            jsonObject.updateValue(importance.rawValue, forKey: "importance")
        }
        jsonObject.updateValue(uid, forKey: "uid")
        if color != .white {
            var colorObject = [String: Any]()
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            // TODO: - Move to UIColor extension
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            colorObject.updateValue(red, forKey: "red")
            colorObject.updateValue(green, forKey: "green")
            colorObject.updateValue(blue, forKey: "blue")
            colorObject.updateValue(alpha, forKey: "alpha")
            jsonObject.updateValue(colorObject, forKey: "color")
        }
        if let selfDestructionDate = self.selfDestructionDate {
            jsonObject.updateValue(selfDestructionDate.timeIntervalSince1970, forKey: "selfDestructionDate")
        }
        return jsonObject
    }
}
