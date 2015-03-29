# JSON form

![JSON Form](https://dmgpayxepw99m.cloudfront.net/jsonform.jpg)

This is a javascript library that can auto-generate a form to help a user generate a JSON document.

The library takes a textarea DOM element (empty or filled with existing JSON data), and a JSON object that describes the JSON you want to manipulate via the form.

```js
var config = {
  ...      
}
var jf = new jsonform.Form($("#myTextField")[0], config);
```

## The config object

The config object defines the outline of the JSON object that the library should generate. You can use any type of object: The only requirement is that whereever you need dynamic data input, you create an object with the property `jsType` set to the type of field you want in the form.

The following json config shows a single textfield to the user:

```js
var config = {
  "name" : {
    "jfType" : "StringField"
  }    
}
```

The user will then be presented with a single textfield, and the original textarea will automatically update with the latest JSON representation:

```html
<textarea>
{
  "name" : "whatever the user typed"
}
</textarea>
```

Although that's a very simple use-case, the library supports a number of advanced fields. Look in the field parameters guide below.

But what if you want the user to add more than a single name? Easy. Wrap your `jfType` object in an array, and the UI will show buttons to add/remove multiple fields. For example, this is a more complex example where a user can add up to 7 names:

```js
var config = {
  "names" : [
    {
      "jfType" : "StringField",
      "jfMax" : 7
    }
  ]    
}
```

Corresponding output:

```html
<textarea>
{
  "names" : [
    "whatever the user typed",
    "whatever the user typed"
    "whatever the user typed"
    "whatever the user typed"
    "whatever the user typed"
  ]
}
</textarea>
```

If the textarea has existing JSON data, and that data matches the schema of the JSON config, the existing JSON values will be pre-filled into the form.

Look in `test/index.html` for a more complicated JSON config structure.

## Field parameters

There's a number of fields in this library, each of them with specific parameters. These params apply to all fields:

```js
{
  "jfType" : "XXXXField", // name of field to use
  "jfTitle" : "My title", // label to show before the input field(s)
  "jfHelper" : "Do this, do that", // smaller help text to show before the input field(s)
  "jfValueType" : "int" // force the value to be integer over string. Helpful for text input, etc.
}
```

### BooleanField

No specific options. Will show a select box with `true` or `false`.

```js
{
  "jfType" : "BooleanField"
}
```

### StringField

No specific options. Will show an input text field.

```js
{
  "jfType" : "StringField"
}
```

### AjaxField

Will show a search box that queries against an API endpoint, and populates the results in a dropdown box. It also supports parsing existing data into the dropdown, via the `jfReloadParam`.

```js
{
  "jfType" : "AjaxField",
  "jfUrl" : "http://my.api", // URL for API endpoint
  "jfSearchParam" : "search", // query param to use for search query (http://my.api?search=QUERY)
  "jfParse" : function(data, vals) { }) // Parse function that received the API response, and should return an array of [value, label] for the select box. Takes an optional parameter with single values from existing JSON, to use for sorting. Look in test/index.html for an example. 
  "jfReloadParam" : "uuid[]", // used to populate existing data. A single request will be made with all values set to this array param, and the parse function will be used to populate the fields from the response. Look in test/index.html for an example.
}
```



