class jsonform.FieldCollectionItem

  constructor: (config, defaultValue) ->

    @defaultValue = defaultValue
    @deltmpl = JST["fields/fieldcollection-del"]
    @sorttmpl = JST["fields/fieldcollection-sort"]
    @jel = $('<div class="jfCollectionItem"></div>')
    @el = @jel[0]
    @fields = []

    # THIS SHOULD CHECK FOR MULTIPLE FIELDS
    # remove some values that are meant for the
    # collection.
    fieldConfig = _.extend({}, config)
    delete fieldConfig.jfTitle
    delete fieldConfig.jfHelper

    @fields.push jsonform.helpers.newField(fieldConfig)


  render: ->

    @jel.html("")

    # first append all fields in this item, then render.
    # this makes is possible for them to instantiate chosen in render
    _.each(@fields, (field) =>
      @jel.append(field.el)
      field.render()
    )

    # THIS SHOULD WORK WITH MORE THAN ONE FIELD.
    if !_.isUndefined(@defaultValue)
      @fields[0].setValue(@defaultValue)

    # if sortable, add sort handle
    if $().sortable
      @jel.prepend(@sorttmpl())

    # delete button
    del = $(@deltmpl())
    @jel.append(del)
    del.click( (e) =>
     e.preventDefault()
     @jel.trigger("delete_clicked", @)
    )

  getValue: ->
    # return whatever value the field(s) have
    # right now I just hardcode the first.
    @fields[0].getValue()