'use strict'

defaultState = angular.module 'em.states.root.default', []

defaultState.config ['$stateProvider', ($stateProvider) ->
    $stateProvider.state 'default',
        parent: 'root'
        resolve:
            bootstrap: [
                '$q'
                'bootstrapApi'
                '$rootScope'
                ($q, bootstrapApi, $rootScope) ->
                    bootstrapApi.init()
                    bootstrapApi.on 'updated', ->
                        $rootScope.$apply()
            ]
        abstract: true
        views:
            header:
               templateUrl: 'views/partials/header.html'
            content:
                template: "<ui-view  autoscroll='true'/>"
]
