mod = angular.module 'bb.auth', []

mod.controller 'bbLoginCtrl', (accountService) ->
    class loginCtrl
        @authenticate = (username, password) ->
            accountService.login(username, password).then (result) ->
                console.log 'success', result
            , (err) ->
                console.log 'err', err