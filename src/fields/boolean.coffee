class jsonform.BooleanField

  constructor: (config) ->
    @config = config
    @tmpl = JST["fields/boolean"]

  render: ->
    @jel.html(@tmpl(@config))
    @jel.find(".chosen-select")
      .chosen({disable_search_threshold: 5, width:"300px"})
      .change(jsonform.helpers.changed)

  getValue: ->
    @jel.find(".chosen-select").val() == "true"