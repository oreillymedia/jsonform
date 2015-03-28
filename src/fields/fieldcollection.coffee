class jsonform.FieldCollectionDel

  constructor: (field) ->
    @deltmpl = JST["fields/fieldcollection-del"]
    @field = field

  render: ->


class jsonform.FieldCollection

  constructor: (config) ->
    @config = config
    @tmpl = JST["fields/fieldcollection"]
    @deltmpl = JST["fields/fieldcollection-del"]
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

  getValue: ->
    _.map(@fields, (field) -> field.getValue())

  addOne: ->

    # remove some values that are meant for the
    # collection.
    fieldConfig = _.extend({}, @config)
    delete fieldConfig.jfTitle
    field = jsonform.helpers.newField(fieldConfig)
    @fields.push(field)

    # first append field elements so they are a part of the dom
    # this makes is possible for them to instantiate chosen in render
    @jel.append(field.el)
    field.render()

    # delete button
    del = $(@deltmpl())
    field.jel.append(del)
    del.click(=>
      del.remove()
      field.jel.remove()
      @fields = _.without(@fields, field)
      @checkAddState()
      jsonform.helpers.changed()
    )

    # check if we hide or show the add button
    @checkAddState()

    # call changed to update json
    jsonform.helpers.changed()

  checkAddState: ->
    if @config.jfMax
      if @fields.length >= @config.jfMax
        @jel.find(".jfAdd").attr("disabled", "disabled")
      else
        @jel.find(".jfAdd").removeAttr("disabled")
