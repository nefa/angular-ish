eventOverview = angular.module 'bb.modules.overview.directives.eventOverview', []

eventOverview.directive 'eventOverview', () ->
    restrict: 'EA'
    scope: {
        eventId: '@'
        eventOverviewData: '='
        activeBettingTypes: '='
    }
    templateUrl: "scripts/modules/overview/directives/event-overview/event-overview-directive.html"
    controller: 'eventOverviewCtrl'


eventOverview.controller 'eventOverviewCtrl', class eventOverviewCtrl
    @$inject = ['$scope','orderByFilter']
    constructor: ($scope,orderByFilter) ->
        event = $scope.eventOverviewData.event[$scope.eventId]
        $scope.status = 'success'

        $scope.$watch(() ->
                return event.startTime
            ,(newStartTime) ->
                eventStartDate =  moment.utc(newStartTime)
                $scope.tagStartDate = eventStartDate.format('YYYY-MM-DDTHH:mm')+ "Z"
                $scope.showStartDate = eventStartDate.local().format('MM/DD/YYYY HH:mm')
        )

        # need to have the EPRs in an array because orderBy filter does not work on objects
        $scope.eventParticipantRelationArray = []
        for eprId, eprObject of $scope.eventOverviewData.eventParticipantRelation
            if eprObject.participantRoleId in [1, 2, 5]
                $scope.eventParticipantRelationArray.push eprObject

        $scope.eventParticipantRelationArray = orderByFilter $scope.eventParticipantRelationArray, (eventParticipantRelation) ->
            switch eventParticipantRelation.participantRoleId
                when 1 then return 100
                when 2 then return 300
                when 5
                    parentParticipantId = eventParticipantRelation.parentParticipantId
                    for epr in $scope.eventParticipantRelationArray
                        if epr.participantId == parentParticipantId
                            if epr.participantRoleId == 1
                                return 200
                            else
                                return 400
                else return 0

        $scope.isRacingTournament = () ->
            return [24, 27, 74].indexOf(event.sportId) != -1

        # This function isn't 100% needed since generic tournaments should not be displayed here,
        # only races. But in case an URL is formed with a generic tournament, don't display the
        # title by looping over the participants as there may be several tens of participants
        # and you end up with a huge title
        $scope.isGenericTournament = () ->
            return event.typeId == 2 && (!$scope.isRacingTournament())
