class jsonform.AjaxField

  @preloadValues: (config, vals, success) ->

    # remove null values
    vals = _.compact(vals)
    return if _.isEmpty(vals)

    query = {}
    query[config.jfReloadParam] = vals

    $.ajax(
      url: config.jfUrl
      data: query
      type: 'GET'
      success: (data) =>
        success(config.jfParse(data, vals))
      error: (data) ->
        console.log("error baby")
    )

  constructor: (config) ->
    @config = config
    @tmpl = JST["fields/ajax"]
    @jel = $('<div class="jfField"></div>')
    @el = @jel[0]

  render: ->

    timeout = undefined

    @jel.html(@tmpl(@config))
    @chosen = @jel.find(".chosen-select")
      .chosen(
        width:"300px"
        allow_single_deselect: true
        no_results_text: 'Searching for'
      )
    @jel.find(".chosen-search input").on('input', (e) =>
      clearTimeout(timeout)
      timeout = setTimeout(=>
        @loadAjax(e)
      , 800)
    )

    @chosen.change(jsonform.helpers.changed)

  getValue: ->
    @jel.find(".chosen-select").val()

  clearValues: ->
    @jel.find("select option").remove()
    @jel.find("select").append("<option value=\"\"></option>")
    @jel.find(".chosen-select").trigger("chosen:updated")

  setValue: (val) ->

    # if val is a primitive, we have to load the value to
    # use as label in the select box. This makes a HTTP request per
    # field, which is annoying for hundreds of fields. However, it
    # was too hard to implement for collections with nexted objects, so
    # that's how it is right now.
    if !_.isObject(val)
      @constructor.preloadValues(@config, [val], (newVal) =>
        @setValue(newVal[0])
      )
    else
      @jel.find(".chosen-select").html('<option value></option><option value="'+val[0]+'">'+val[1]+'</option>')
      @jel.find(".chosen-select").val(val[0])
      @jel.find(".chosen-select").trigger("chosen:updated")
      jsonform.helpers.changed()

  loadAjax: (e) ->

    chosen = @jel.find(".chosen-container")

    query = {}
    searchVal = chosen.find(".chosen-search input").val()
    query[@config.jfSearchParam] = searchVal
    @clearValues()

    $.ajax(
      url: @config.jfUrl
      data: query
      type: 'GET'
      success: (data) =>
        results = @config.jfParse(data)
        if results.length is 0
          chosen.find(".chosen-results").html("<li class=\"no-results\">No results matched \"<span>#{searchVal}</span>\"</li>")
        else
          select = @jel.find(".chosen-select")
          _.each(results, (result) =>
            select.append('<option value="'+result[0]+'">'+result[1]+'</option>')
          )
          select.trigger("chosen:updated")
          chosen.find(".chosen-search input").val(searchVal)
      error: (data) ->
        console.log("error baby")
    )

