class jsonform.SelectAjaxField

  constructor: (config) ->
    @config = config
    @jel = $('<div class="jfField"></div>')
    @el = @jel[0]
    @selectField = new jsonform.SelectField(jfValues: _.map(@config.jfValues, (val) -> val.jfValue))
    @ajaxField = new jsonform.AjaxField(@config.jfValues[0])

  render: ->
    @jel.html("")
    @jel.append(@selectField.el)
    @jel.append(@ajaxField.el)
    @selectField.render()
    @ajaxField.render()
    @selectField.jel.on("jf:changed", => @selectSwitched())

  getValue: ->
    val = {}
    val[@config.jfSelectKey] = @selectField.getValue()
    val[@config.jfAjaxKey] = @ajaxField.getValue()
    val

  setValue: (val) ->
    @selectField.setValue(val[@config.jfSelectKey])

    # find config based on selected key and load the
    # needed extra values using that config
    ajaxConfig = @getConfigBySelectKey(@selectField.getValue())
    jsonform.AjaxField.findExtraValues(ajaxConfig, [val[@config.jfAjaxKey]], (data) =>
      @ajaxField.config = ajaxConfig
      @ajaxField.setValue(data[0])
    )

  selectSwitched: ->
    ajaxConfig = @getConfigBySelectKey(@selectField.getValue())
    @ajaxField.config = ajaxConfig
    @ajaxField.setValue(["", ""])

  getConfigBySelectKey: (key) ->
    _.find(@config.jfValues, (conf) ->
      conf.jfValue[0] is key
    )