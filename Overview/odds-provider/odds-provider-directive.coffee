bookieDirective = angular.module 'bb.modules.odds.oddsProvider', []

bookieDirective.directive 'oddsProvider', ['$document', 'Popups', ($document, Popups) ->
    restrict: 'EA'
    require: '^eventOdds'
    scope: {
        provider: "="
        providerEventRelationObject: "="
    }
    templateUrl: 'scripts/modules/odds/directives/odds-provider/odds-provider-directive.html'
    link: ($scope, $el, attr, eventOdds) ->
        $scope.$watch( ->
                return eventOdds.eventData.event.statusId
            , (newStatusId) ->
                $scope.eventStatusId = newStatusId
        )

        # popup listener--- with service
        $scope.$watch () ->
            Popups.getPopup()
        , (newPop, oldPop) ->
            $scope.popupId = newPop
        # popup handler----
        $scope.checkProviderId = (popup) ->
            if popup.pid
                Popups.setPopup(popup.pid)
]
