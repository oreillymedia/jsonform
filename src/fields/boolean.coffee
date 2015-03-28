class jsonform.BooleanField

  constructor: (config) ->
    @jel = $("<div></div>")
    @el = @jel[0]
    @config = config
    @tmpl = JST["fields/boolean"]

  render: ->
    @jel.html(@tmpl(@config))
    @jel.find(".chosen-select")
      .chosen({disable_search_threshold: 5, width:"300px"})
      .change(=> @jel.trigger('jf:change') )

  getValue: ->
    @jel.find(".chosen-select").val() == "true"