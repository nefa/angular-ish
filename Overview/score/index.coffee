require './tennis-score/tennis-score-directive.coffee'
require './default-score/default-score-directive.js'

angular.module 'bb.modules.overview.directives.score', [
    'bb.modules.overview.directives.score.tennisScore'
    'bb.modules.overview.directives.score.defaultScore'
]
