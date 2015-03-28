class jsonform.StringField

  constructor: (config) ->
    @config = config
    @tmpl = JST["fields/string"]

  render: ->
    @jel.html(@tmpl(@config))
    @jel.find("input").change(jsonform.helpers.changed)

  getValue: ->
    @jel.find("input").val()