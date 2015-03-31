window.jsonform = {}

window.jsonform.helpers = {

  panic: (msg) ->
    console.error(msg)
    alert(msg)

  isJsonString: (str) ->
    try
      JSON.parse str
    catch e
      return false
    true

  changed: -> jQuery.event.trigger('jf:change');

  newField : (jfObj) ->
    klass = jsonform[jfObj.jfType]
    if klass
      return new jsonform[jfObj.jfType](jfObj)
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
      @jtxt.val(JSON.stringify(json, null, 2))
    )

    @jtxt.after(@jel)

    # if textarea has data
    txtval = @jtxt.val()
    if !!txtval
      # if value is valid json
      if jsonform.helpers.isJsonString(txtval)
        @fillFields(JSON.parse(txtval), @jsonConfig)
      else
        jsonform.helpers.panic("Textarea has invalid JSON. jsonform will not work")

  # Recursive.
  generateJson: (obj) ->

    if _.isArray(obj)

      # if array has single item and it has jfField
      # get values form collection
      if obj.length == 1 && obj[0].jfCollection
        vals = obj[0].jfCollection.getValues()
        if obj[0].jfCollection.config.jfValueType is "int"
          vals = _.map(vals, (val) -> parseInt(val))
        return vals
      else
        return _.map(obj, (v) => @generateJson(v))
    else
      # if this object has a jfType
      if obj.jfField
        val = obj.jfField.getValue()
        if obj.jfField.config.jfValueType is "int"
          val = parseInt(val)
        val
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

  # Recursive.
  parseJsonConfig: (obj) ->

    if _.isArray(obj)

      # if array has single item and it has jfType
      # convert it to a fieldcollection
      if obj.length == 1 && obj[0].jfType
        obj[0].jfCollection = new jsonform.FieldCollection(obj[0])
        @fields.push(obj[0].jfCollection)

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

  # Recursive. This function takes an existing json object (that was generated with this library)
  # and loads the data into the fields.
  fillFields: (obj, jsonConfig) ->

    # basic sanity check to prevent most configuration errors
    if obj is undefined || jsonConfig is undefined
      jsonform.helpers.panic("Existing JSON doesnt match JSON config.")

    if _.isArray(obj)

      # if config has single item and it has jfCollection
      # fill with fields based on values
      if jsonConfig.length == 1 && jsonConfig[0].jfCollection
        jsonConfig[0].jfCollection.fieldsFromValues(obj)
      else
        _.each(obj, (v, i) =>
          @fillFields(obj[i], jsonConfig[i])
        )
    else
      # if this object has a field, set value.
      if jsonConfig.jfField
        jsonConfig.jfField.setValue(obj)
      # else go deeper through the object.
      else
        # if this is an object, and the same object exist in the json config
        # loop through and fill fields inside those object values
        if _.isObject(obj)
          _.each(obj, (v,k) =>
            if jsonConfig[k]
              @fillFields(v, jsonConfig[k])
            else
              console.log "jsonConfig object not present:"
              console.log "key: ", k
              console.log "value: ", v
          )