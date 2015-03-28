class jsonform.StringField

  constructor: (config) ->
    @config = config
    @tmpl = JST["fields/string"]
    @jel = $('<div class="jfField"></div>')
    @el = @jel[0]

  render: ->
    @jel.html(@tmpl(@config))
    @jel.find("input").change(jsonform.helpers.changed)

  getValue: ->
    @jel.find("input").val()

  setValue: (val) ->
    @jel.find("input").val(val)