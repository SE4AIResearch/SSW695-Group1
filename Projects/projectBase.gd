extends Node

var projectName: String
var projectDescription: String

var clientName: String

var frontEndProjectMin: int
var backEndProjectMin: int
var documentingProjectMin: int

var baseSprintAmount: int
var baseSprintLength: int
var baseSprintMetricAmount: int

var sprintAmount: int #Total amount of Sprints
var sprintLength: int #Dictates how many weeks for a sprint
var sprintMetricAmount: int #How many metrics must be assigned per sprint

var methodology: Dictionary
var constraints: Dictionary

var frontEndMetrics: Dictionary
var backEndMetrics: Dictionary
var documentingMetrics: Dictionary
