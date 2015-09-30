class EventInfo

  constructor: (eventinfo, isForRootEventPart, orderNum, eventParticipantRelation) ->
    angular.copy(eventinfo, @)
    @isTotalScore = isForRootEventPart
    @orderIndex = orderNum
    @isInverted = false
    # set the first score and the second score based on any eventParticipantRelation
    for eprId, epr of eventParticipantRelation
      if (epr.participantRoleId == @HOME_AWAY_ROLE_ID)
        if (epr.participantId == @paramParticipantId1)
          @homeScore = @paramFloat1
          @awayScore = @paramFloat2
        else
          @homeScore = @paramFloat2
          @awayScore = @paramFloat1
          @isInverted = true
        break

  updateEventInfo: (update)->
    angular.extend(@, update)
    if !@isInverted
      @homeScore = @paramFloat1
      @awayScore = @paramFloat2
    else
      @homeScore = @paramFloat2
      @awayScore = @paramFloat1


  HOME_AWAY_ROLE_ID: 1

module.exports =  EventInfo
