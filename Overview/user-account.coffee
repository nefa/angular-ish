emUtils = require 'em-utils'

mod = angular.module 'bb.account', []

mod.factory 'accountService', (bbWebApi) -> new class accountService extends emUtils.module
    @include(emUtils.observable)

    login: (username, password) ->
        bbWebApi.postData 'login', {username, password}

    logout: ->
        bbWebApi.postData 'logout'

    register: (params) ->
        bbWebApi.postData 'register', params