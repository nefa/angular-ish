emUtils = require 'em-utils'
EventInfo = require './event-info-class.coffee'

eventOverviewModule = angular.module 'bb.modules.overview.services.eventOverviewModule', []

class EventOverview extends emUtils.module
    @include(emUtils.observable)

    constructor: (@eventOverviewData, eventId, @bootstrapApi) ->
        for eventInfoId, eventInfoData of @eventOverviewData.eventInfos
            @eventOverviewData.eventInfos[eventInfoId] = @createEventInfo(eventInfoData)

        @activeBettingTypes = []
        if @eventOverviewData.allAvailableBettingTypes?.length
            for bettingTypeId in @eventOverviewData.allAvailableBettingTypes
                @activeBettingTypes[bettingTypeId] = true

    createEventInfo: (eventInfoData) ->
        eventPartId = eventInfoData.eventPartId
        isEventPartRoot = @bootstrapApi.isBootstrapProperty("eventPart", eventPartId,"parentId",null)
        eventPartOrderNum = @bootstrapApi.getBootstrapProperty("eventPart", eventPartId,"orderNum")
        eventInfoData = new EventInfo(eventInfoData, isEventPartRoot, eventPartOrderNum, @eventOverviewData.eventParticipantRelation)
        return eventInfoData

    handleCreate: (resource, dataObj) ->
        switch resource
            when 'eventInfo'
                for eventInfoId, eventInfoObj of dataObj
                    if @eventOverviewData.eventInfos[eventInfoId]
                        console.error("EventInfo entity already exists: ", eventInfoId)
                    else
                        @eventOverviewData.eventInfos[eventInfoId] = @createEventInfo(eventInfoObj)
            when 'providerEventRelation'
                for relationId, relationObj of dataObj
                    if @eventOverviewData.providerEventRelation[relationId]
                        console.error('providerEventRelation already exists:', relationId)
                    else
                        @eventOverviewData.providerEventRelation[relationId] = relationObj
            when 'eventParticipantRelation'
                for relationId, epr of dataObj
                    if @eventOverviewData.eventParticipantRelation[relationId]
                        console.error('eventParticipantRelation already exists:', relationId)
                    else
                        @eventOverviewData.eventParticipantRelation[relationId] = epr
            when 'participant'
                for participantId, participant of dataObj
                    if @eventOverviewData.participant[participantId]
                        console.error('participant already exists:', participantId)
                    else
                        @eventOverviewData.participant[participantId] = participant

            #@TODO handle all entities in time...
            else
                console.error('Unhandled create:', resource, dataObj)

    handleUpdate: (resource, dataObj) ->
        switch resource
            when 'eventInfo'
                for eventInfoId, eventInfoObj of dataObj
                    @eventOverviewData.eventInfos[eventInfoId].updateEventInfo(eventInfoObj)
            when 'event'
                for eventId, eventObj of dataObj
                    angular.extend(@eventOverviewData.event[eventId], eventObj)
            when 'providerEventRelation'
                for relationId, relationObj of dataObj
                    angular.extend(@eventOverviewData.providerEventRelation[relationId], relationObj)
            when 'eventParticipantRelation'
                for relationId, epr of dataObj
                    angular.extend(@eventOverviewData.eventParticipantRelation[relationId], epr)

            # backend does not send 'participant' updates so no need to handle them here

            when 'bettingType'
                for bettingTypeId, bettingTypeObj of dataObj
                    if bettingTypeObj.status == 'added'
                        indexOfBettingTypeId = @eventOverviewData.allAvailableBettingTypes.indexOf(parseInt(bettingTypeId))
                        if indexOfBettingTypeId == -1
                            @eventOverviewData.allAvailableBettingTypes.push(parseInt(bettingTypeId))
                        @activeBettingTypes[parseInt(bettingTypeId)] = true
                    else if bettingTypeObj.status == 'removed'
                        indexOfBettingTypeId = @eventOverviewData.allAvailableBettingTypes.indexOf(parseInt(bettingTypeId))
                        # we are not removing it from allAvailableBettingTypes because we need to be able to display removed
                        # betting types. We are just updating its status (selectable, non-selectable)
                        if indexOfBettingTypeId != -1
                            @activeBettingTypes[parseInt(bettingTypeId)] = false
                    else
                        console.error 'unhandled update for bettingType ', dataObj

            #@TODO handle all entities in time...
            else
                console.error('Unhandled update:', resource, dataObj)

    handleDelete: (resource, key) ->
         switch resource
            when 'eventInfo'
                if @eventOverviewData.eventInfos[key]
                    delete @eventOverviewData.eventInfos[key]

            when 'providerEventRelation'
                if @eventOverviewData.providerEventRelation[key]
                    delete @eventOverviewData.providerEventRelation[key]

            when 'eventParticipantRelation'
                if @eventOverviewData.eventParticipantRelation[key]
                    delete @eventOverviewData.eventParticipantRelation[key]

            when 'participant'
                if @eventOverviewData.participant[key]
                    delete @eventOverviewData.participant[key]

            #@TODO handle all entities in time

            else
                console.error('Unhandled delete:', resource, key)

    handleServerPush: (updates) ->
        for update in updates
            for entityType, entityUpdate of update
                for updateType, updateData of entityUpdate
                    switch updateType
                        when 'update'
                            @handleUpdate(entityType, updateData)
                        when 'create'
                            @handleCreate(entityType, updateData)
                        when 'delete'
                            @handleDelete(entityType, updateData)
                        else
                            console.error('unknown update type:', updateType)
        @trigger('updated')


eventOverviewModule.provider 'eventOverviewService', -> class eventOverviewService
    @$get = [
        '$q'
        '$filter'
        'bbWebApi'
        'bootstrapApi'
        ($q, $filter, bbWebApi,bootstrapApi) -> new class eventOverviewService extends emUtils.module
            @include(emUtils.observable)

            getStreamedEventOverviewData: (eventId) ->
                deferred = $q.defer()
                eventOverviewStream = bbWebApi.createStream('eventOverview', {eventId: eventId})

                eventOverviewStream.on 'init', (initialDump) ->
                    eventOverview = new EventOverview(initialDump, eventId, bootstrapApi)
                    deferred.resolve(eventOverview)

                    batchedUpdates = []
                    updateIntervalId = 0

                    eventOverviewStream.on 'data', (data) ->
                        batchedUpdates.push(data)
                        if updateIntervalId == 0
                            updateIntervalId = setTimeout ->
                                eventOverview.handleServerPush(batchedUpdates)
                                updateIntervalId = 0
                                batchedUpdates = []
                            , 400

                    eventOverviewStream.on 'end', ->
                        clearTimeout updateIntervalId
                        eventOverview.trigger 'destroy'

                eventOverviewStream.on 'error', (err) ->
                    deferred.reject(err)

                return {
                    promise: deferred.promise
                    end: ->
                        eventOverviewStream.end()
                }
    ]
