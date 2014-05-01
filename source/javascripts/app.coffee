'use strict'

# Required modules for the WCC app
reqModules = [
  'ui.router'
]

# Load and configure app
window.SplitApp = angular.module('splitApp', reqModules)

.config ($urlRouterProvider, $stateProvider) ->


  $stateProvider.state 'tests',
    url: "/tests"
    templateUrl: "partials/tests.html"
    controller: 'splitAppController'

  $urlRouterProvider.otherwise('/tests').when('/', 'tests')



.controller 'splitAppController', ($scope, $http, splitKeen) ->
  ###
  splitKeen.getTests (err, tests) ->
    if err
      throw "Could not find tests"

    $scope.tests = tests
  ###

  $scope.tests = {}

  splitKeen.getVariations (err, tests) ->
    if err
      throw "Could not get variations"

    for test_name, test of tests
      if !$scope.tests[test_name]
        $scope.tests[test_name] = variations: {}

      total_visits = 0
      total_completed_goals = 0

      for variation_name, variation of test.variations
        $scope.tests[test_name].variations[variation_name] = variation
        total_visits += variation.total_hits
        total_completed_goals += variation.completed_goal

      $scope.tests[test_name].total_visits = total_visits
      $scope.tests[test_name].completed_goals = total_completed_goals

  splitKeen.getTestDetails (err, tests) ->
    if err
      throw "Could not get test details"

    for test in tests
      if !$scope.tests[test.test]?
        $scope.tests[test.test] =
          variations: {}

      $scope.tests[test.test].start_time = test.start_time
      $scope.tests[test.test].end_time = test.end_time

  $scope.sortVariations = (variation) ->
    console.log variation
    variation.completed_goal

.filter "toArray", () ->
  (obj) ->
    result = []
    angular.forEach obj, (val, key) ->
      result.push val
    result
