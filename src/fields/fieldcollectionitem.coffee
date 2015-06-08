class jsonform.FieldCollectionItem

  constructor: (config, jsonValue) ->

    @jsonValue = jsonValue
    @deltmpl = JST["fields/fieldcollection-del"]
    @sorttmpl = JST["fields/fieldcollection-sort"]
    @jel = $('<div class="jfCollectionItem"></div>')
    @el = @jel[0]
    @fields = []

    @config = {}
    jQuery.extend(true, @config, config)
    delete @config.jfTitle
    delete @config.jfHelper
    delete @config.jfCollection
    delete @config.jfMax

    # if there is a jfType on the root config object,
    # this will be a collection holding only single values:
    # [1, 2, 3, 4]
    if config.jfType
      @fields.push jsonform.helpers.newField(@config)

    # otherwise it will be a collection where each collection
    # item has a number of fields that become objects in the output:
    # [{..}, {..}, {..}]
    else
      _.each(@config, (v, k) =>
        if v.jfType
          field = jsonform.helpers.newField(v)
          v.jfField = field
          @fields.push field
      )


    # ALSO FIND EXTRA VALUES. SHOULD BE RENAMED PRELOAD.
    #if jsonform[@config.jfType].findExtraValues
    #    jsonform[@config.jfType].findExtraValues(@config, vals, (vals) =>
    #      _.each(vals, (val) => @addItem(val))
    #    )
    #  else

  render: ->

    @jel.html("")

    # first append all fields in this item, then render.
    # this makes is possible for them to instantiate chosen in render
    _.each(@fields, (field) =>
      @jel.append(field.el)
      field.render()
    )

    # if sortable, add sort handle
    if $().sortable
      @jel.append(@sorttmpl())

    # delete button
    del = $(@deltmpl())
    @jel.append(del)
    del.click( (e) =>
     e.preventDefault()
     @jel.trigger("delete_clicked", @)
    )

    # If we have values to set.
    if !_.isUndefined(@jsonValue)

      # if this is just a single field
      if @config.jfType
        @fields[0].setValue(@jsonValue)

      # otherwise loop through json values and
      # assign to fields.
      else
        _.each(@config, (v, k) =>
          if v.jfField && @jsonValue[k]
            v.jfField.setValue(@jsonValue[k])
        )

  getValue: ->

    # if this is just a single field
      if @config.jfType
        @fields[0].getValue()

      # otherwise generate js object from the values.
      else
        values = {}
        jQuery.extend(true, values, @config)
        _.each(values, (v, k) =>
          if v.jfField
            values[k] = v.jfField.getValue()
        )
        values
