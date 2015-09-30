'use strict';
var eventOverviewState, eventOverviewStateCtrl;

require('./ended');
require('./odds/event-odds-state.coffee');

eventOverviewState = angular.module('bb.states.event.overview', ['bb.states.event.overview.ended', 'bb.states.event.overview.odds']);

eventOverviewState.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('event.overview', {
        url: '/:eventId',
        templateUrl: 'scripts/states/event/overview/event-overview-state.html',
        controller: 'eventOverviewStateCtrl as ctrl',
        resolve: {
            eventOverviewDataStream: [
                'eventOverviewService',
                '$state',
                '$stateParams',
                '$q',
                function (eventOverviewService, $state, $stateParams, $q) {
                    var deferred = $q.defer();
                    var stream = eventOverviewService.getStreamedEventOverviewData($stateParams.eventId)

                    stream.promise.then(function (result) {
                            deferred.resolve({
                                data:result,
                                status:'success',
                                end: function () {
                                    stream.end()
                                }
                             });
                        }, function (err) {
                            deferred.resolve({data:err, status:'error'});
                        });
                    return deferred.promise;
                }
            ]
        },
        abstract: true
    });
}]);

eventOverviewState.controller('eventOverviewStateCtrl', eventOverviewStateCtrl = (function () {
    function constructorFn($scope, $location, $state, eventOverviewDataStream, Popups) {
        $scope.status = eventOverviewDataStream.status;
        this.Popups = Popups;

        if (eventOverviewDataStream.status === 'success') {
            $scope.eventOverviewData = eventOverviewDataStream.data.eventOverviewData;
            $scope.activeBettingTypes = eventOverviewDataStream.data.activeBettingTypes;
            $scope.eventId = $state.params.eventId;

            $scope.$watch(
                function () {
                    return $state.params.bettingTypeId;
                },
                function (newBTid, oldBTid) {
                    $scope.bettingTypeId = newBTid;
                }
            );

            $scope.isDataReady = true;
            $scope.$on('$destroy', function () {
                eventOverviewDataStream.end()
            });
            eventOverviewDataStream.data.on('updated', function () {
                $scope.$apply();
            });

        } else if (eventOverviewDataStream.status === 'error') {
            $scope.error = eventOverviewDataStream.data;

        } else {
            console.error("eventOverviewDataStream resolved with unknown status", eventOverviewDataStream.status);
        }

        $scope.selectBettingType = function (bettingTypeId, $event) {

            if ($scope.activeBettingTypes[bettingTypeId]) {

                this.Popups.setPopup('bettingTypes');

                if ($scope.bettingTypeId !== bettingTypeId) {
                    $state.go('event.overview.odds', {
                        eventId: $state.params.eventId,
                        bettingTypeId: bettingTypeId,
                        eventPartId: $state.params.eventPartId
                    });
                }

            } else {
                if ($event) {
                    $event.stopImmediatePropagation();
               }

            }

        }.bind(this);
    }

    constructorFn.prototype.checkDropdown = function(){
        return this.Popups.getPopup();
    };

    constructorFn.$inject = ['$scope', '$location', '$state', 'eventOverviewDataStream', 'Popups'];
    return constructorFn;
})());
