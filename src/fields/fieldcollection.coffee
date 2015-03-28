class jsonform.FieldCollection

  constructor: (config) ->
    @config = config
    @tmpl = JST["fields/fieldcollection"]
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

    # call changed to get it in the json
    field.changed()