class jsonform.AjaxField

  @findExtraValues: (config, vals, success) ->

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
    @jel.find(".chosen-select")
      .chosen(
        width:"300px"
        allow_single_deselect: true
        no_results_text: 'Searching for'
      )
      .on('chosen:no_results', (e) =>
        clearTimeout(timeout)
        timeout = setTimeout(=>
          @loadAjax(e)
        , 800)
      )
      .change(jsonform.helpers.changed)

  getValue: ->
    @jel.find(".chosen-select").val()

  setValue: (val) ->

    # if val is a primitive, we have to load the value to
    # use as label in the select box. This happens only on single
    # fields where setValue is called from lib.
    if !_.isObject(val)
      @constructor.findExtraValues(@config, [val], (newVal) => @setValue(newVal[0]))
    else
      @jel.find(".chosen-select").html('<option value="'+val[0]+'">'+val[1]+'</option>')
      @jel.find(".chosen-select").val(val[0])
      @jel.find(".chosen-select").trigger("chosen:updated")

  loadAjax: (e) ->

    chosen = @jel.find(".chosen-container")

    query = {}
    searchVal = chosen.find(".chosen-search input").val()
    query[@config.jfSearchParam] = searchVal

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

