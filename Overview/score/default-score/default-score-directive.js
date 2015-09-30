var defaultScoreDirective = angular.module('bb.modules.overview.directives.score.defaultScore', []);

defaultScoreDirective.directive('scoreDefault', function() {
    return {
        restrict: 'EA',
        scope: {
            eventInfos: '=',
            event: '=',
            eventParticipantRelation: '='
        },
        templateUrl: "scripts/modules/overview/directives/score/default-score/default-score-directive.html",
        controller: 'defaultScoreController as ctrl'
    }
});


defaultScoreDirective.controller('defaultScoreController', ['$scope', 'orderByFilter', function ($scope, orderByFilter) {
    $scope.scoreArray = [];
    $scope.$watchCollection("eventInfos", function(newVal, oldVal) {
        $scope.scoreArray = [];
        if($scope.finalScore) {
            delete $scope.finalScore;
        }
        var eventInfo, eventInfoId;
        for(eventInfoId in newVal) {
            eventInfo = newVal[eventInfoId];
            if(eventInfo.isTotalScore) {
                $scope.finalScore = eventInfo;
            }
            else {
                $scope.scoreArray.push(eventInfo);
                $scope.scoreArray = orderByFilter($scope.scoreArray, 'orderIndex');
            }
        }
    });
}]);


