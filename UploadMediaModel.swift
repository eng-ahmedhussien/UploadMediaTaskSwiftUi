//
//  UploadMediaModel.swift
//  AlDwaaNewApp
//
//  Created by ahmed hussien on 15/08/2023.
//

import Foundation


struct UploadMediaModel: Codable {
    let altText, code, description, downloadURL: String?
    let mime, url, uuid: String?

    enum CodingKeys: String, CodingKey {
        case altText, code, description
        case downloadURL = "downloadUrl"
        case mime, url, uuid
    }
}
