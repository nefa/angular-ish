
tennisScoreDirective = angular.module 'bb.modules.overview.directives.score.tennisScore', []

tennisScoreDirective.directive 'scoreTennis', () ->
    restrict: 'EA'
    # require: '^matchInfo'
    scope: {
        eventInfos: '='
        event: '='
    }
    templateUrl: "scripts/modules/overview/directives/score/tennis-score/tennis-score-directive.html"

    controller: 'scoreController as ctrl'

tennisScoreDirective.controller 'scoreController', class scoreController
    @$inject = [
        '$scope'
        'orderByFilter'
    ]
    constructor: ($scope, orderByFilter) ->
        $scope.scoreArray = []
        $scope.$watchCollection("eventInfos", (newVal, oldVal) =>
            $scope.scoreArray = []
            if $scope.finalScore
                delete $scope.finalScore
            for eventInfoId, eventInfo of newVal
                if eventInfo.isTotalScore
                    $scope.finalScore = eventInfo
                else if !@isTieBreak(eventInfo.eventPartId)
                    $scope.scoreArray.push(eventInfo)
            $scope.scoreArray = orderByFilter($scope.scoreArray,'orderIndex')
        )

    isTieBreak: (eventPartId) ->
        tieBreaks = [574, 575, 576, 577, 578]
        return tieBreaks.indexOf(eventPartId) != -1
