class jsonform.FieldCollection

  constructor: (config) ->
    @config = config
    @tmpl = JST["fields/fieldcollection"]
    @deltmpl = JST["fields/fieldcollection-del"]
    @sorttmpl = JST["fields/fieldcollection-sort"]
    @jel = $("<div></div>")
    @el = @jel[0]
    @fields = []

  render: ->

    @jel.html(@tmpl(@config))

    @jel.find(".jfAdd").click( (e) =>
      return if $(this).is("[disabled]")
      e.preventDefault()
      @addOne()
    )

    if $().sortable
      @jel.find(".jfCollection").sortable(
        placeholder: '<span class="placeholder">&nbsp;</span>'
        itemSelector: '.jfField'
        handle: 'i.jfSort'
        onDrop: (item, container, _super) =>
          _super(item, container)

          # sort by what number of child the el is
          @fields = _.sortBy(@fields, (field) ->
            field.jel.index()
          )

          jsonform.helpers.changed()
      )

  getValues: ->
    results = _.map(@fields, (field) -> field.getValue())
    _.compact(results)

  addOne: (defaultValue) ->

    # remove some values that are meant for the
    # collection.
    fieldConfig = _.extend({}, @config)
    delete fieldConfig.jfTitle
    delete fieldConfig.jfHelper
    field = jsonform.helpers.newField(fieldConfig)

    @fields.push(field)

    # first append field elements so they are a part of the dom
    # this makes is possible for them to instantiate chosen in render
    @jel.find(".jfCollection").append(field.el)
    field.render()

    if !_.isUndefined(defaultValue)
      field.setValue(defaultValue)

    # if sortable, add sort handle
    if $().sortable
      field.jel.prepend(@sorttmpl())

    # delete button
    del = $(@deltmpl())
    field.jel.append(del)
    del.click( (e) =>
      e.preventDefault()
      del.remove()
      field.jel.remove()
      @fields = _.without(@fields, field)
      @checkAddState()
      jsonform.helpers.changed()
    )

    # check if we hide or show the add button
    @checkAddState()

    # update sortable
    if $().sortable
      @jel.find(".jfCollection").sortable("refresh")

    # call changed to update json
    jsonform.helpers.changed()

  fieldsFromValues: (vals) ->

    # if this field needs extra values for setvalue,
    # call the function. This is mostly for select boxes
    # where we also need the label besides the value
    if jsonform[@config.jfType].findExtraValues
      jsonform[@config.jfType].findExtraValues(@config, vals, (vals) =>
        _.each(vals, (val) => @addOne(val))
      )
    else
      _.each(vals, (val) => @addOne(val))

  checkAddState: ->
    if @config.jfMax
      if @fields.length >= @config.jfMax
        @jel.find(".jfAdd").attr("disabled", "disabled")
      else
        @jel.find(".jfAdd").removeAttr("disabled")
