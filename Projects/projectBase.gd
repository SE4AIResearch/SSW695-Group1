extends Node

var projectName: String
var projectDescription: String
var preferredMethodology: String = ""
var learningObjective: String = ""
var successCriteria: String = ""
var recommendedMethodology: String = ""
var tutorialSprintPlan: Array = []

var clientName: String

var frontEndProjectMin: int
var backEndProjectMin: int
var documentingProjectMin: int

var sprintAmount: int #Total amount of Sprints
var sprintLength: int #Dictates how many weeks for a sprint
var sprintMetricAmount: int #How many metrics must be assigned per sprint

var eventChance: float = 0.45
var methodology: Dictionary
var constraints: Array

var frontEndMetrics: Dictionary
var backEndMetrics: Dictionary
var documentingMetrics: Dictionary
