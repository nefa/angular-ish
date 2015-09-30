deepLinks = angular.module 'bb.modules.odds.deepLinks', []

deepLinks.directive 'deepLink', ['$filter', ($filter) ->
    restrict: 'EA'
    require: '^eventOdds'
    scope: {
        offer: '='
        providerId: '@'
    }
    templateUrl: "scripts/modules/odds/directives/deep-links/deep-links-directive.html"
    link: ($scope, element, attributes, eventOdds) ->
        oddFormat = $filter('oddFormat')
        currentCouponKey = $scope.offer.couponKey

        # this should definitely be refactored into someting more manageable ... like OOP and shit...
        $scope.$watch 'offer.odds', (newOdds, oldOdds) =>

            $scope.currentProvider = eventOdds.eventData.providers[$scope.providerId]

            currentBetFormat = oddFormat(newOdds, 2)
            createDeepLink(currentBetFormat)

        createDeepLink = (currentBetFormat) ->
            if currentCouponKey
                if eventOdds.eventData.event.statusId == 2 #@ hardcoded for live events
                    replacedCouponKey = $scope.currentProvider.liveURL.replace('{cupon_key}', currentCouponKey)
                    $scope.finalUrl = replacedCouponKey.replace('{uk_frac}', currentBetFormat)

                else
                    replacedCouponKey = $scope.currentProvider.nonLiveURL.replace('{cupon_key}', currentCouponKey)
                    $scope.finalUrl = replacedCouponKey

            return $scope.finalUrl
]

