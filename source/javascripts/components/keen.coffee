'use strict'

window.SplitApp.factory "splitKeen", ($http) ->

  url_pre: "https://api.keen.io/3.0/projects/#{keen_project_id}/queries"
  collection: "ab_event"

  getTestDetails: (cb) ->

    analyses = encodeURIComponent(JSON.stringify(
      start_time:
        analysis_type: "minimum"
        target_property: "keen.timestamp"
      end_time:
        analysis_type: "maximum"
        target_property: "keen.timestamp"
    ))

    filters = encodeURIComponent(JSON.stringify(
      [
        {
          property_name: "event"
          operator: "eq"
          property_value: "pageload"
        }
      ]))

    url = "#{@url_pre}/multi_analysis?api_key=#{keen_read_key}&event_collection=#{@collection}&filters=#{filters}&analyses=#{analyses}&group_by=test"

    $http.get url
      .success (data, status, headers, config) ->
        if status == 200
          cb? null, data.result
        else
          cb? data

  getVariations: (cb) ->
    group = encodeURIComponent(JSON.stringify(["test", "variation"]))
    filters = encodeURIComponent(JSON.stringify([
      property_name: "event"
      operator: "eq"
      property_value: "pageload"
    ]))
    url = "#{@url_pre}/count?api_key=#{keen_read_key}&event_collection=#{@collection}&group_by=#{group}&filters=#{filters}"

    sentinel = 2
    finished = 0
    variationTotals = false
    variationGoals = false

    $http.get url
      .success (data, status, headers, config) ->
        if status == 200
          finished++
          variationTotals = data.result
        else
          cb? data

        if finished >= sentinel
          onCompleted()

    filters = encodeURIComponent(JSON.stringify([
      property_name: "event"
      operator: "eq"
      property_value: "goal"
    ]))

    url = "#{@url_pre}/count?api_key=#{keen_read_key}&event_collection=#{@collection}&group_by=#{group}&filters=#{filters}"
    $http.get url
      .success (data, status, headers, config) ->
        if status == 200
          finished++
          variationGoals = data.result
        else
          cb? data

        if finished >= sentinel
          onCompleted()

    tests = {}
    onCompleted = () ->
      for variation in variationTotals
        if !tests[variation.test]?
          tests[variation.test] =
            variations: {}

        tests[variation.test].variations[variation.variation] =
          total_hits: variation.result

      for variation in variationGoals
        tests[variation.test].variations[variation.variation].completed_goal = variation.result

      cb? null, tests
