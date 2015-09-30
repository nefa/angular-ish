popupService = angular.module 'bb.modules.odds.popup', []

popupService.factory 'Popups', ->
  popupId = null

  return {
    setPopup: (id) ->
      if popupId == id
        popupId = null
      else popupId = id

    getPopup: ->
      return popupId
  }

