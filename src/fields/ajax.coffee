class jsonform.AjaxField

  constructor: (config) ->
    @config = config
    @tmpl = JST["fields/ajax"]

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

  loadAjax: (e) ->

    chosen = @jel.find(".chosen-container")

    query = {}
    searchVal = chosen.find(".chosen-search input").val()
    query[@config.jfQueryParam] = searchVal

    $.ajax(
      url: @config.jfUrl
      data: query
      type: 'GET'
      success: (data) =>
        results = @config.jfParse(data)
        if results.length is 0
          chosen.find("chosen-results").html("<li class=\"no-results\">No results matched \"<span>#{searchVal}</span>\"</li>")
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

