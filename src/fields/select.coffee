class jsonform.SelectField

  constructor: (config) ->
    @config = config
    @tmpl = JST["fields/select"]
    @jel = $('<div class="jfField"></div>')
    @el = @jel[0]

  render: ->
    @jel.html(@tmpl(@config))
    @jel.find(".chosen-select")
      .chosen({disable_search_threshold: 5, width:"300px"})
      .change(=>
        @jel.trigger("jf:changed")
        jsonform.helpers.changed()
      )

  getValue: ->
    @jel.find(".chosen-select").val()

  setValue: (val) ->
    @jel.find(".chosen-select").val(val + "")
    @jel.find(".chosen-select").trigger("chosen:updated")