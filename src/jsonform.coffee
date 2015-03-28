window.jsonform = {}

#= require fields/*.coffee

class jsonform.Form

  constructor: (txtArea, jsonConfig) ->
    @jel = $('<div class="jfForm"></div>')
    @jtxt = $(txtArea)
    @fields = []
    @jsonConfig = jsonConfig
    @parseJsonConfig(jsonConfig)

    #@jtxt.hide()

    # first append field elements so they are a part of the dom
    # this makes is possible for them to instantiate chosen in render
    # then render
    _.each(@fields, (field) =>
      @jel.append(field.el)
      field.render()
      field.jel.on("jf:change", =>
        json = @generateJson(@jsonConfig)
        console.log json
      )
    )

    @jtxt.after(@jel)

    # check if textarea has data
    # if it has, we need to make absolutely sure it matches
    # the structure of the config.
      # if yes => figure out how to load in fields
      # if no => console.error

  generateJson: (obj) ->

    # if array, generate json from each object
    if _.isArray(obj)
      return _.map(obj, (v) => @generateJson(v))
    else
      # if this object has a jfType
      if obj.jfField
        return obj.jfField.getValue()
      # else go deeper through the object.
      else
        newObj = {}
        _.each(obj, (v,k) =>
          newObj[k] = @generateJson(v)
        )
        return newObj



  parseJsonConfig: (obj) ->

    # if array, parse each object
    if _.isArray(obj)
      _.each(obj, (v) => @parseJsonConfig(v))
    else

      # if this object has a jfType
      if !!obj.jfType

        # see if we have this field
        klass = jsonform[obj.jfType]
        if klass
          field = new jsonform[obj.jfType](obj)
          obj.jfField = field
          @fields.push(field)
        else
          console.error "jsonform field doesnt exist: " + obj.jfType

      # else go deeper through the object.
      else
        _.each(obj, (v,k) =>
          if _.isObject(v)
            @parseJsonConfig(v)
        )