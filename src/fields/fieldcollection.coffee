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
      jsonform.helpers.changed()
    )

    # call changed to update json
    jsonform.helpers.changed()
