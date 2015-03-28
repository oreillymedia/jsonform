window.jsonform = {}

window.jsonform.helpers = {

  changed: -> jQuery.event.trigger('jf:change');

  newField : (jfObj) ->
    klass = jsonform[jfObj.jfType]
    if klass
      field = new jsonform[jfObj.jfType](jfObj)
      field.jel = $('<div class="jfField"></div>')
      field.el = field.jel[0]
      return field
    else
      console.error "jsonform field doesnt exist: " + jfObj.jfType
}

#= require fields/*.coffee

class jsonform.Form

  constructor: (txtArea, jsonConfig) ->

    @jel = $('<div class="jfForm"></div>')
    @jtxt = $(txtArea)
    @jtxt.hide()

    @fields = []
    @jsonConfig = jsonConfig
    @parseJsonConfig(@jsonConfig)

    # first append field elements so they are a part of the dom
    # this makes is possible for them to instantiate chosen in render
    _.each(@fields, (field) =>
      @jel.append(field.el)
      field.render()
    )

    # listen to global change events
    $(document).bind('jf:change', =>
      json = @generateJson(@jsonConfig)
      @jtxt.val(JSON.stringify(json))
    )

    @jtxt.after(@jel)

    # check if textarea has data
    # if it has, we need to make absolutely sure it matches
    # the structure of the config.
      # if yes => figure out how to load in fields
      # if no => console.error

  generateJson: (obj) ->

    if _.isArray(obj)

      # if array has single item and it has jfField
      # get values form collection
      if obj.length == 1 && obj[0].jfField
        return obj[0].jfField.getValue()
      else
        return _.map(obj, (v) => @generateJson(v))
    else
      # if this object has a jfType
      if obj.jfField
        return obj.jfField.getValue()
      # else go deeper through the object.
      else
        # if this is an object, loop through and generate
        # json from all values in the object into new object
        if _.isObject(obj)
          newObj = {}
          _.each(obj, (v,k) =>
            newObj[k] = @generateJson(v)
          )
          return newObj
        # if not an object (string, number, etc), just return that
        else
          return obj


  parseJsonConfig: (obj) ->

    if _.isArray(obj)

      # if array has single item and it has jfType
      # convert it to a fieldcollection
      if obj.length == 1 && obj[0].jfType
        obj[0].jfField = new jsonform.FieldCollection(obj[0])
        @fields.push(obj[0].jfField)

      # else parse each object in the array
      else
        _.each(obj, (v) => @parseJsonConfig(v))

    else

      # if this object has a jfType, create this
      # type of field
      if obj.jfType
        obj.jfField = jsonform.helpers.newField(obj)
        @fields.push(obj.jfField)

      # else go deeper through the object.
      else
        _.each(obj, (v,k) =>
          if _.isObject(v)
            @parseJsonConfig(v)
        )