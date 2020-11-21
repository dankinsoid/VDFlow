//
//  SharedSteps.swift
//  FlowStart
//
//  Created by Данил Войдилов on 18.11.2020.
//

import Foundation

public enum SharedSteps {
	public static let url = NodeID<URL>("openUrlFlowStep")
	public static let alert = NodeID<AlertConfig>("openAlertFlowStep")
}
